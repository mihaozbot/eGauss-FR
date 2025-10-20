function [data, trainData, testData, trueFunc, m, params, name] = getPaper1DData(n_C, p_gate, testFraction)
%Synthetic
    % Dimension and total-sample settings
    m        = 1;
    N_total  = 900;
    name = "Synthetic";

    % Generate full dataset (u, y)
    alpha    = 0.1;
    beta     = 2.0;
    noiseStd = 0.02;

    u_all = 10 * rand(1, N_total);
    y_clean = exp(-alpha * u_all) .* sin(beta * u_all);
    y_all   = y_clean + noiseStd * randn(1, N_total);

    % Store full data
    data = [u_all; y_all];

    % Random train/test split
    idx = randperm(N_total);
    nTest = round(testFraction * N_total);
    testIdx  = idx(1:nTest);
    trainIdx = idx(nTest+1:end);

    u_train = u_all(:, trainIdx);
    y_train = y_all(:, trainIdx);
    u_test  = u_all(:, testIdx);
    y_test  = y_all(:, testIdx);

    % Partition training data to clients
    N_train = numel(trainIdx);
    trainData = cell(1, n_C);
    base   = floor(N_train / n_C);
    startI = 1;
    for j = 1:n_C
        if j < n_C
            endI = startI + base - 1;
        else
            endI = N_train;
        end
        Uj = u_train(startI:endI);
        Yj = y_train(startI:endI);
        trainData{j} = [Uj; Yj];
        startI = endI + 1;
    end

    % Store test data
    testData.u = u_test;
    testData.y = y_test;

    % Noise-free function for debugging
    trueFunc = @(u) exp(-alpha * u) .* sin(beta * u);

    % Federated-learning hyperparameters
    params.ipsilon     = 0.99;
    params.lambda_d    = chi2inv(p_gate, 1);
    params.lambda_r    = chi2inv(p_gate, m+1);
    params.epsilon_tolR = 1;
    params.epsilon_tolD = 1;
    params.kappa_m      = 1;
    params.kappa_n      = 1;
    params.c_merge      = sqrt(base);

end
