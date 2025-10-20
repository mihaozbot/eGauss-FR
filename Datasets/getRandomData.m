function [data, trainData, testData, trueFunc, m, params, name] = getRandomData(n_C, p_gate, testFraction)
%Synthetic
    arguments
        n_C   (1,1) double {mustBeInteger,mustBePositive}
        p_gate(1,1) double {mustBeGreaterThan(p_gate,0),mustBeLessThan(p_gate,1)}
        testFraction (1,1) double {mustBeGreaterThanOrEqual(testFraction,0), mustBeLessThanOrEqual(testFraction,1)}
    end
    
    %configuration
    m        = 100;             % feature dimension
    N_total  = 10000;          % total samples
    name     = "Random";
    
    %true linear model
    w_true = randn(m,1);
    b_true = randn;
    noiseStd = 0.1;     
    
    % generate full dataset
    U_all   = randn(m, N_total);                 % features
    Y_clean = w_true' * U_all + b_true;          % noise-free output
    Y_all   = Y_clean + noiseStd * randn(1,N_total);
    
    % store full data
    data = [U_all; Y_all];
    
    % train/test split 
    idx = randperm(N_total);
    nTest = round(testFraction * N_total);
    testIdx  = idx(1:nTest);
    trainIdx = idx(nTest+1:end);
    
    u_train = U_all(:, trainIdx);
    y_train = Y_all(:, trainIdx);
    u_test  = U_all(:, testIdx);
    y_test  = Y_all(:, testIdx);
    
    % partition training data to clients
    N_train = numel(trainIdx);
    trainData = cell(1, n_C);
    base   = floor(N_train / n_C);
    start  = 1;
    for k = 1:n_C
        if k < n_C
            stop = start + base - 1;
        else
            stop = N_train;
        end
        U_k = u_train(:,start:stop);
        Y_k = y_train( 1 ,start:stop);
        trainData{k} = [U_k; Y_k];                  % (m+1)×N_k
        start = stop + 1;
    end
    
    %store test data 
    testData.u = u_test;
    testData.y = y_test;
    
    % noise-free function for debugging
    trueFunc = @(u) w_true' * u + b_true;
    
    % federated hyper-parameters
    params              = struct;
    params.ipsilon      = 0.99;
    params.lambda_d     = chi2inv(p_gate , 1);
    params.lambda_r     = chi2inv(p_gate , m+1);
    params.epsilon_tolR = 1;
    params.epsilon_tolD = 0;
    params.kappa_m      = 1;
    params.kappa_n      = 1;
    params.c_merge      = 10;
end
