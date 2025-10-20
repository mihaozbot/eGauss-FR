function [data, trainData, testData, m, params, name] = getWeatherIzmirData(n_C, p_gate, doNormalize, testFraction)
%https://sci2s.ugr.es/keel/dataset.php?cod=78

arguments
    n_C         (1,1) double {mustBeInteger, mustBePositive}
    p_gate      (1,1) double {mustBeGreaterThan(p_gate,0), mustBeLessThan(p_gate,1)}
    doNormalize (1,1) logical = true
    testFraction (1,1) double {mustBeGreaterThanOrEqual(testFraction,0), mustBeLessThanOrEqual(testFraction,1)} = 0.2
end

% load data 
name        = "Weather";
datFile     = fullfile("Datasets", name + ".dat");
fprintf("Loading %s …\n", datFile);
raw         = importdata(datFile);
mat         = raw.data;                     % (1461×10)   9 feat + 1 target

[N_total, totalCols] = size(mat);
m          = totalCols - 1;                 % 9 input features
X_all      = mat(:,1:m);
y_all      = mat(:,m+1);

% optional z-score 
if doNormalize
    mu   = mean(X_all,1);
    sig  = std(X_all,0,1);    sig(sig==0) = 1;
    X_all= (X_all-mu)./sig;
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

% partition training data into clients 
N_train = numel(trainIdx);
trainData = cell(1,n_C);
baseSz  = floor(N_train / n_C);
startIx = 1;
for k = 1:n_C
    rows_k  = baseSz + (k <= mod(N_train, n_C));
    endIx   = startIx + rows_k - 1;

    Xk = X_train(:, startIx:endIx);
    yk = y_train(:, startIx:endIx);
    trainData{k} = [Xk; yk];

    startIx = endIx + 1;
end

% store test data 
testData.u = X_test;
testData.y = y_test;

% hyper-parameters 
params            = struct;
params.ipsilon    = 0.99;
params.lambda_d   = chi2inv(p_gate , 1);
params.lambda_r   = chi2inv(p_gate, m+1);
params.epsilon_tolR = 1;
params.epsilon_tolD = 1;
params.kappa_m      = 1;
params.kappa_n      = 1;
params.c_merge      = sqrt(baseSz);
end
