function [data, trainData, testData, m, params, name] = getMortgageData(n_C, p_gate, doNormalize, testFraction)
%https://sci2s.ugr.es/keel/dataset.php?cod=43
    
    arguments
        n_C         (1,1) double {mustBeInteger, mustBePositive}
        p_gate      (1,1) double {mustBeGreaterThan(p_gate,0), mustBeLessThan(p_gate,1)}
        doNormalize (1,1) logical = true
        testFraction (1,1) double {mustBeGreaterThanOrEqual(testFraction,0), mustBeLessThanOrEqual(testFraction,1)} = 0.2
    end
    
    % load dataset --------------------------------------------
    name      = "Mortgage";
    datFile   = fullfile("Datasets", name + ".dat");
    fprintf("Loading %s …\n", datFile);
    raw       = importdata(datFile);
    mat       = raw.data;                 % (1049×16)  15 feat + 1 target
    
    [N_total, totalCols] = size(mat);
    m        = totalCols - 1;             % 15 features
    X_all    = mat(:,1:m);
    y_all    = mat(:,m+1);
    
    % normalize
    if doNormalize
        mu  = mean(X_all,1);
        sig = std(X_all,0,1);   sig(sig==0) = 1;
        X_all = (X_all - mu) ./ sig;
    end
    
    % store full dataset
    data = [X_all'; y_all'];
    
    % train/test split 
    perm     = randperm(N_total);
    nTest    = round(testFraction * N_total);
    testIdx  = perm(1:nTest);
    trainIdx = perm(nTest+1:end);
    
    X_train = X_all(trainIdx, :)';
    y_train = y_all(trainIdx)';
    X_test  = X_all(testIdx, :)';
    y_test  = y_all(testIdx)';
    
    %partition training data into clients
    N_train = numel(trainIdx);
    trainData = cell(1,n_C);
    base   = floor(N_train / n_C);
    startIdx = 1;
    
    for k = 1:n_C
        rows = base + (k <= mod(N_train, n_C));
        endIdx = startIdx + rows - 1;
    
        Xk = X_train(:, startIdx:endIdx);
        yk = y_train(:, startIdx:endIdx);
        trainData{k} = [Xk; yk];
    
        startIdx = endIdx + 1;
    end
    
    % store test data
    testData.u = X_test;
    testData.y = y_test;
    
    % federated hyper-parameters 
    params              = struct;
    params.ipsilon      = 0.99;
    params.lambda_d     = chi2inv(p_gate, 1);
    params.lambda_r     = chi2inv(p_gate, m+1);
    params.epsilon_tolR = 1;
    params.epsilon_tolD = 0;
    params.kappa_m      = 1;
    params.kappa_n      = 1;
    params.c_merge      = sqrt(base);
end
