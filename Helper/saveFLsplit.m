function saveFLsplit(datasetName,  n_C, rep, trainData, testData, rootDir)

if nargin < 6, rootDir = "exports"; end
nClients = numel(trainData);
assert(nClients == n_C, "Mismatch: n_C argument ≠ numel(trainData)");

m = size(trainData{1},1) - 1;

outDir = fullfile(rootDir, datasetName, ...
                  sprintf("clients_%d", n_C), ...
                  sprintf("rep_%02d", rep));
if ~exist(outDir,"dir"); mkdir(outDir); end

% save each client
for k = 1:nClients
    blk = trainData{k};
    Xk  = blk(1:m,:).';            % rows = samples
    yk  = blk(end,:).';
    tbl = array2table([Xk yk], ...
           "VariableNames",[compose("x%d",1:m) "target"]);
    writetable(tbl, fullfile(outDir, sprintf("client_%d.csv",k)));
end

% save test set
Xtest = testData.u.';  ytest = testData.y.';
tblT  = array2table([Xtest ytest], ...
        "VariableNames",[compose("x%d",1:m) "target"]);
writetable(tblT, fullfile(outDir, "test.csv"));

fprintf("rep %d → saved %d clients to %s\n", rep, n_C, outDir);
end