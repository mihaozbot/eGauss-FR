function [data, trainData, testData, m, params, name] = getCaliforniaData(n_C, p_gate, doNormalize, testFraction)
%https://sci2s.ugr.es/keel/dataset.php?cod=83
    
    arguments
        n_C         (1,1) double {mustBeInteger, mustBePositive}
        p_gate      (1,1) double {mustBeGreaterThan(p_gate,0),mustBeLessThan(p_gate,1)}
        doNormalize (1,1) logical = true
        testFraction (1,1) double {mustBeGreaterThanOrEqual(testFraction,0), mustBeLessThanOrEqual(testFraction,1)} = 0.2
    end
    
    %load data
    name      = "California";
    datFile   = fullfile("Datasets", name + ".dat");
    fprintf("Loading %s …\n", datFile);
    raw       = importdata(datFile);
    mat       = raw.data;                    % (20460×9)  8 feat + 1 target
    
    [N_total,totalCols] = size(mat);
    m        = totalCols - 1;                % 8 features
    X_all    = mat(:,1:m);
    y_all    = mat(:,m+1);
    
    % normalisation
    if doNormalize
        params.mu_X    = mean(X_all,1);
        params.sigma_X = std(X_all,0,1);   params.sigma_X(params.sigma_X==0)=1;
        X_all = (X_all - params.mu_X) ./ params.sigma_X;
    
        params.mu_y    = mean(y_all);
        params.sigma_y = std(y_all);       if params.sigma_y==0, params.sigma_y=1; end
        y_all = (y_all - params.mu_y) / params.sigma_y;
    else
        params.mu_X = []; params.sigma_X = [];
        params.mu_y = []; params.sigma_y = [];
    end
    
    % store full dataset 
    data = [X_all'; y_all'];
    
    % train/test split
    perm   = randperm(N_total);
    nTest  = round(testFraction * N_total);
    testIdx  = perm(1:nTest);
    trainIdx = perm(nTest+1:end);
    
    X_train = X_all(trainIdx, :)';
    y_train = y_all(trainIdx)';
    X_test  = X_all(testIdx, :)';
    y_test  = y_all(testIdx)';
    
    % partition training data into clients 
    N_train = numel(trainIdx);
    trainData = cell(1,n_C);
    base   = floor(N_train / n_C);
    start = 1;
    for k = 1:n_C
        rows = base + (k <= mod(N_train, n_C));
        stop = start + rows - 1;
    
        Xk = X_train(:, start:stop);
        yk = y_train(:, start:stop);
        trainData{k} = [Xk; yk];
    
        start = stop + 1;
    end
    
    % store test data
    testData.u = X_test;
    testData.y = y_test;
    
    % scenario hyper-parameters 
    params.ipsilon     = 0.99;
    params.lambda_d    = chi2inv(p_gate, 1);
    params.lambda_r    = chi2inv(p_gate, m+1);
    params.epsilon_tolR = 1;
    params.epsilon_tolD = 1;
    params.kappa_m      = 1;
    params.kappa_n      = 1;
    params.c_merge      = sqrt(base);

end
