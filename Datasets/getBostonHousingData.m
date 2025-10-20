function [data, trainData, testData, m, params, name] = getBostonHousingData(n_C, p_gate, doNormalize, testFraction)
% https://www.kaggle.com/code/prasadperera/the-boston-housing-dataset
    
    arguments
        n_C         (1,1) double {mustBeInteger, mustBePositive}
        p_gate      (1,1) double {mustBeGreaterThan(p_gate,0), mustBeLessThan(p_gate,1)}
        doNormalize (1,1) logical = true
        testFraction (1,1) double {mustBeGreaterThanOrEqual(testFraction,0), mustBeLessThanOrEqual(testFraction,1)} = 0.2
    end
    
    name = "HousingData";
    filename = fullfile("Datasets", name + ".csv");
    if ~isfile(filename)
        error('Dataset file "%s" not found.', filename);
    end
    
    % Load dataset
    tbl = readtable(filename);
    dataMatrix = table2array(tbl);  % N_total×14
    if any(isnan(dataMatrix),'all')
        warning("Data contains NaNs. Imputing with column medians...");
        colMedians = median(dataMatrix, 1, 'omitnan');
        [rowIdx, colIdx] = find(isnan(dataMatrix));
        for k = 1:numel(rowIdx)
            dataMatrix(rowIdx(k), colIdx(k)) = colMedians(colIdx(k));
        end
    end
    
    % separate features and target
    X_all = dataMatrix(:,1:13)';   % 13×N_total
    y_all = dataMatrix(:,14)' ;    % 1 ×N_total
    m     = size(X_all,1);
    N_total = size(X_all,2);
    
    % normalization
    if doNormalize
        mu_X    = mean(X_all,2);
        sigma_X = std(X_all,0,2);
        sigma_X(sigma_X==0) = 1;
        X_all = (X_all - mu_X) ./ sigma_X;
    end
    
    % store full dataset
    data = [X_all; y_all];
    
    % Train/Test split
    idx = randperm(N_total);
    nTest = round(testFraction * N_total);
    testIdx  = idx(1:nTest);
    trainIdx = idx(nTest+1:end);
    
    X_train = X_all(:, trainIdx);
    y_train = y_all(:, trainIdx);
    X_test  = X_all(:, testIdx);
    y_test  = y_all(:, testIdx);
    
    % partition training data into clients
    N_train = numel(trainIdx);
    base = floor(N_train / n_C);
    remainder = mod(N_train, n_C);
    sizes = base * ones(1, n_C);
    sizes(1:remainder) = sizes(1:remainder) + 1;
    
    % Partition training to clinets
    trainData = cell(1, n_C);
    startIx = 1;
    for j = 1:n_C
        endIx = startIx + sizes(j) - 1;
        Xj = X_train(:, startIx:endIx);
        yj = y_train(startIx:endIx);
        trainData{j} = [Xj; yj];
        startIx = endIx + 1;
    end
    
    % Store test data
    testData.u = X_test;
    testData.y = y_test;
    
    % Federated hyper-parameters
    params             = struct;
    params.ipsilon     = 0.99;
    params.lambda_d    = chi2inv(p_gate, 1);
    params.lambda_r    = chi2inv(p_gate, m+1);
    params.epsilon_tolR = 1;
    params.epsilon_tolD = 0;
    params.kappa_m      = 1;
    params.kappa_n      = 1;
    params.c_merge      = sqrt(base);
end
