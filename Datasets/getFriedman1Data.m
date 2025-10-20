function [data, trainData, testData, trueFunc, m, params, name] = getFriedman1Data(n_C, p_gate, testFraction)
%Synthetic

    m         = 5;
    N_total   = 10000;
    sigma_eps = 1.0;
    name      = "Friedman";
    
    % true function handle
    trueFunc = @(x) 10 * sin(pi .* x(1,:) .* x(2,:)) ...
                  + 20 * (x(3,:)-0.5).^2 ...
                  + 10 *  x(4,:) ...
                  +  5 *  x(5,:);
    
    % define train / test sizes
    N_test  = round(testFraction * N_total);
    N_train = N_total - N_test;
    
    % independently generate training set
    X_train = rand(m, N_train);
    x1 = X_train(1,:); x2 = X_train(2,:); x3 = X_train(3,:);
    x4 = X_train(4,:); x5 = X_train(5,:);
    y_clean_train = 10 * sin(pi .* x1 .* x2) + 20 * (x3 - 0.5).^2 + 10 * x4 + 5 * x5;
    y_train = y_clean_train + sigma_eps * randn(1, N_train);
    
    % independently generate test set
    X_test = rand(m, N_test);
    x1 = X_test(1,:); x2 = X_test(2,:); x3 = X_test(3,:);
    x4 = X_test(4,:); x5 = X_test(5,:);
    y_clean_test = 10 * sin(pi .* x1 .* x2) + 20 * (x3 - 0.5).^2 + 10 * x4 + 5 * x5;
    y_test = y_clean_test + sigma_eps * randn(1, N_test);
    
    % store full generated dataset (mainly for record keeping)
    data = [ [X_train, X_test]; [y_train, y_test] ];
    
    % partition train data into clients
    trainData = cell(1, n_C);
    base      = floor(N_train / n_C);
    startIdx  = 1;
    for j = 1:n_C
        if j < n_C
            endIdx = startIdx + base - 1;
        else
            endIdx = N_train;
        end
        trainData{j} = [X_train(:, startIdx:endIdx); y_train(1, startIdx:endIdx)];
        startIdx = endIdx + 1;
    end
    
    % store test data
    testData.u = X_test;
    testData.y = y_test;
    
    % hyperparameters
    params              = struct;
    params.ipsilon      = 0.99;
    params.lambda_d     = chi2inv(p_gate, 1);
    params.lambda_r     = chi2inv(p_gate, m+1);
    params.epsilon_tolR = 1;
    params.epsilon_tolD = 1;
    params.kappa_m      = 1;
    params.kappa_n      = 1;
    params.c_merge      = sqrt(base);

end
