clc; close all; clear all;

% Experiment settings
scenarios    = [1, 2, 3]; %Each scenario is one dataset with the model meta-parameters
clientCounts = [3, 10, 30]; %Number of clients
nReps        = 1; %Number of repetitions of the experiment
p            = 0.1; %Probability for the minimal cluster size
testFraction = 0.2; %Fraction of data used for testing
flag_debug   = 1; %Debugging, 0 is off, 1 is on
flag_generate_data = 0; %This loads and distributes the datasets for each repetition, it needs to be done only once

%Global error‐log for debugging
errorLogFile = 'Results/experiment_errors.log';
if ~exist('Results','dir')
    mkdir('Results');
end
errFid = fopen(errorLogFile, 'a');
fprintf(errFid, '=== Experiment started at %s ===\n', datestr(now));

for scenarioIdx = scenarios
    for n_C = clientCounts
 
        % CSV for this (scenario, n_C) pair, the result of the experiment
        csvFile = sprintf('Results/results_scenario%d_clients%d.csv', ...
            scenarioIdx, n_C);
        if ~isfile(csvFile)
            fid = fopen(csvFile, 'w');
            fprintf(fid, [
                'rep,' ...
                'nClustersPerClient,' ...
                'C_server,' ...
                'rmse,' ...
                'nrmse,' ...
                'r2,' ...
                't_client_per,' ...
                't_server_per,' ...
                'm_features,' ...
                'N_total,' ...
                'avgPerClient,' ...
                'datasetName\n' ...
                ]);
            fclose(fid);
        end

        %Repetitions of the experiment
        for rep = 1:nReps
            rng(rep)
            fprintf('\n')
            % Load data
            [data, trainData, testData, trueFunc, m, params, datasetName]  = loadScenario(scenarioIdx, n_C, p, testFraction);
            
            %This loads and distributes the datasets for each repetition, it needs to be done only once
            if flag_generate_data
                saveFLsplit(datasetName, n_C, rep, trainData, testData, "Datasets/Experiments")
                continue
            end
            
            fprintf('**New experiment**. Scenario=%d  Name=%s  Clients=%',scenarioIdx, datasetName, n_C);
            fprintf('\n')
            

            %Calculate minimal epsR for each client to ensure the clusters can form
            [epsR_client, ~]  = estimateEpsPerClientAndGlobal(trainData, p);
            clients = initAllClients(m, params, epsR_client);

            % The main code
            [serverStruct, clients, nClustersClients, C_server, ...
                t_client_per, t_server_per, ...
                m_features, N_total, avgPerClient, datasetName] = ...
                server(n_C, p, flag_debug, trainData, m, params, clients, datasetName);
            
            %Inference on the test data
            y_true = testData.y; %Save test data output
            [y_pred] = inferOutput(testData.u,serverStruct);
            
            %This is for debugging and visualization
            [~, bestPair] = gatherAndScoreClusters(clients, m); 
            if flag_debug
                debugPlots(testData.u, testData.y, trainData, clients, serverStruct, bestPair, y_true, y_pred);
            end
            
            % Console output for tracking
            fprintf('Results  Scenario=%d  Name=%s  Clients=%d  Clusters/client=%.2f  C_server=%d\n', ...
                scenarioIdx, datasetName, n_C, nClustersClients, C_server);
            [rmse, nrmse, r2] = computeAndPrintMetrics(y_true, y_pred);

            % Append to CSV
            fid = fopen(csvFile, 'a');
            fprintf(fid, '%d,%.4f,%d,%.6f,%.6f,%.6f,%.6g,%.6g,%d,%d,%.2f,%s\n', ...
                rep, ...
                nClustersClients, ...
                C_server, ...
                rmse, ...
                nrmse, ...
                r2, ...
                t_client_per, ...
                t_server_per, ...
                m_features, ...
                N_total, ...
                avgPerClient, ...
                datasetName);
            fclose(fid);
            pause(0.001)

        end
    end
end

% Close error log
fprintf(errFid, '=== Experiment ended at %s ===\n\n', datestr(now));
fclose(errFid);
