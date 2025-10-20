clc; clear;

% === CONFIGURATION ===
resultsDir   = 'Results';
filePattern  = fullfile(resultsDir,'results_scenario*_clients*.csv');
files        = dir(filePattern);

% === 1) LOAD DATA ===
allT = table();
for F = files'
    T = readtable(fullfile(resultsDir,F.name), 'TextType','string');
    allT = [allT; T]; %#ok<AGROW>
end
assert(~isempty(allT), 'No CSV files matched pattern %s', filePattern);

% Remove duplicates per dataset
% Keep only relevant columns
T_small = unique(allT(:, {'datasetName', 'N_total', 'm_features'}), 'rows');

% Rename N_total to N_train
T_small.Properties.VariableNames{'N_total'} = 'N_train';

% Add N_test and corrected total
T_small.N_test = round(0.25 * T_small.N_train);
T_small.N_total = T_small.N_train + T_small.N_test;

% Add output dimension (features + 1)
T_small.TotalFeatures = T_small.m_features + 1;

% Sort alphabetically
T_small = sortrows(T_small, 'datasetName');

% === 2) WRITE LATEX TABLE TO FILE ===
outFile = fopen('generated_dataset_table.tex','w');

fprintf(outFile,'\\begin{table}[htbp]\n');
fprintf(outFile,'  \\centering\n');
fprintf(outFile,'  \\caption{Datasets used in the experiments with number of features (inputs + output), train and test samples.}\n');
fprintf(outFile,'  \\begin{tabular}{lccc}\n');
fprintf(outFile,'    \\toprule\n');
fprintf(outFile,'    Dataset & Features & Train & Test \\\\\n');
fprintf(outFile,'    \\midrule\n');

for i = 1:height(T_small)
    name_latex = regexprep(T_small.datasetName(i), '_', '\\_');
    fprintf(outFile,'    \\texttt{%s} & %d & %d & %d \\\\\n', ...
        name_latex, ...
        T_small.TotalFeatures(i), ...
        T_small.N_train(i), ...
        T_small.N_test(i));
end

fprintf(outFile,'    \\bottomrule\n');
fprintf(outFile,'  \\end{tabular}\n');
fprintf(outFile,'  \\label{tab:datasets}\n');
fprintf(outFile,'\\end{table}\n');

fclose(outFile);
disp('LaTeX dataset table with inferred train/test written to generated_dataset_table.tex');
