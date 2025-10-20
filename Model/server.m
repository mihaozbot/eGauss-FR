function [serverStruct, clients, nClustersClients, C_server, ...
          t_client_per, t_server_per, ...
          m_features, N_total, avgPerClient, datasetName] = ...
         server(n_C, p, flag_debug, trainData, m, params, clients, datasetName)

    %EXTRACT & COUNT SAMPLE
    [U, Y, u_all, y_all] = extractClientData(trainData, m);
    N_all = size(u_all, 2);
    m_features   = m;
    N_total      = N_all;
    avgPerClient = N_total / n_C;

    %OPTIONAL SCATTER
    if flag_debug, plotClientData(U, Y); end

    %LOCAL TRAINING
    t0 = tic;
    clients = runLocalTraining(clients, trainData);
    client_time = toc(t0);
    t_client_per = client_time / N_all;

    % count clusters per client
    nClustersPerClient = zeros(1, n_C);
    for j = 1:n_C
        nClustersPerClient(j) = numel(clients{j}.clusters);
    end
    nClustersClients = mean(nClustersPerClient);
    disp(nClustersPerClient)
    
    %SERVER-SIDE MERGE
    t1 = tic; %Start server timer

    [serverStructAggregated] = aggregateOnServer(clients, params);
    serverStruct = mergeClusters(serverStructAggregated);

    %Two options the auxiliary points can be generated after or before
    %merging the clusters. 
    %[U_aux, Y_aux] = generateAuxiliaryPoints(serverStruct,p);  %Auxiliary points for the merged clusters
    [U_aux, Y_aux] = generateAuxiliaryPoints(serverStructAggregated, p); %Auxiliary points for the aggregated clusters
    serverStruct.U_aux = U_aux;   
    serverStruct.Y_aux = Y_aux;   
    
    %REGRESSION 
    serverStruct = trainFuzzyRegression(serverStruct, U_aux, Y_aux, m);
    server_time = toc(t1);
    t_server_per = server_time / N_all;
    C_server = numel(serverStruct.clusters);

end
