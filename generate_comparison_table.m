clc; clear;

% === CONFIGURATION ===
egaussDir = 'Results';  % MATLAB eGauss+FR results
flfrDir   = 'Comparison/FederatedFuzzyRegressionTree-main/py_results';  % Python FL-FRT results
countCSV  = 'Comparison/FederatedFuzzyRegressionTree-main/dataset_sample_counts.csv';  % N_total CSV
floatFmt  = '%.3f';

% Load dataset sample counts
sampleCounts = readtable(countCSV);
datasetNames = sampleCounts.dataset;
N_totals     = sampleCounts.N_total;

% === 1) Load FL-FRT results
flfrFiles = dir(fullfile(flfrDir, '*', 'clients_10', '*.csv'));
results = table();

for i = 1:length(flfrFiles)
    pyFile = fullfile(flfrFiles(i).folder, flfrFiles(i).name);
    parts = split(pyFile, filesep);
    datasetName = parts{end-2};

    try
        T_flfr = readtable(pyFile);
    catch
        warning('Skipping unreadable file: %s', pyFile);
        continue;
    end

    % Get total number of samples for this dataset
    idx = strcmp(datasetNames, datasetName);
    if ~any(idx)
        warning('Missing N_total entry for dataset: %s', datasetName);
        continue;
    end
    N_total = N_totals(idx);

    % Mean metrics
    nrmse_flfr = mean(T_flfr.NRMSE, 'omitnan');
    rmse_flfr  = mean(T_flfr.RMSE,  'omitnan');
    r2_flfr    = mean(T_flfr.R2,    'omitnan');
    t_flfr_total = mean(1000*T_flfr.t_total_s, 'omitnan');
    t_flfr_per_sample_ms = t_flfr_total / N_total;


    % Match MATLAB results
    matFiles = dir(fullfile(egaussDir, 'results_scenario*_clients10.csv'));
    matched = false;

    for j = 1:length(matFiles)
        matFile = fullfile(egaussDir, matFiles(j).name);
        try
            T_egauss = readtable(matFile);
        catch
            continue;
        end

        if any(strcmp(T_egauss.datasetName, datasetName))
            matched = true;
            break;
        end
    end

    if ~matched
        warning('No matching eGauss+FR result for %s', datasetName);
        continue;
    end

    sub = T_egauss(strcmp(T_egauss.datasetName, datasetName), :);
    nrmse_egauss = mean(sub.nrmse, 'omitnan');
    rmse_egauss  = mean(sub.rmse,  'omitnan');
    r2_egauss    = mean(sub.r2,    'omitnan');
    t_egauss     = mean(sub.t_client_per + sub.t_server_per, 'omitnan') * 1000;

    % Save
    results = [results; table({datasetName}, ...
        rmse_egauss, rmse_flfr, ...
        nrmse_egauss, nrmse_flfr, ...
        r2_egauss, r2_flfr, ...
        t_egauss, t_flfr_per_sample_ms)];
end

results.Properties.VariableNames = { ...
    'Dataset', ...
    'RMSE_eGauss', 'RMSE_FLFRT', ...
    'NRMSE_eGauss', 'NRMSE_FLFRT', ...
    'R2_eGauss', 'R2_FLFRT', ...
    'Time_eGauss_ms', 'Time_FLFRT_ms'};
results = sortrows(results, 'Dataset');  % ← SORT HERE

% === 2) Write LaTeX Table ===
fout = fopen('latex_compare_egauss_flfr.tex', 'w');

fprintf(fout, '\\begin{table*}[!ht]\n');
fprintf(fout, '  \\centering\n');
fprintf(fout, '  \\caption{Comparison of {eGauss+FR} and {FL-FRT}  for 10 clients.}\n');
fprintf(fout, '  \\begin{tabular}{l|cc|cc|cc|cc}\n');
fprintf(fout, '    \\toprule\n');
fprintf(fout, '    \\multirow{2}{*}{Dataset} & \\multicolumn{2}{c}{RMSE} & \\multicolumn{2}{c}{NRMSE} & \\multicolumn{2}{c}{$R^2$} & \\multicolumn{2}{c}{$t$/sample [ms]} \\\\\n');
fprintf(fout, '    & {eGauss+FR} & FL-FRT & {eGauss+FR} & FL-FRT & {eGauss+FR} & FL-FRT & {eGauss+FR} & FL-FRT \\\\\n');
fprintf(fout, '    \\midrule\n');

for i = 1:height(results)
    name = strrep(results.Dataset{i}, '_', '\\_');

    % Extract values
    rmse_vals = [results.RMSE_eGauss(i), results.RMSE_FLFRT(i)];
    nrmse_vals = [results.NRMSE_eGauss(i), results.NRMSE_FLFRT(i)];
    r2_vals = [results.R2_eGauss(i), results.R2_FLFRT(i)];
    time_vals = [results.Time_eGauss_ms(i), results.Time_FLFRT_ms(i)];

    % Find best indices
    [~, best_rmse] = min(rmse_vals);
    [~, best_nrmse] = min(nrmse_vals);
    [~, best_r2] = max(r2_vals);
    [~, best_time] = min(time_vals);

    % Format values with bold for the best
    rmse_fmt = cell(1, 2); nrmse_fmt = cell(1, 2);
    r2_fmt   = cell(1, 2); time_fmt  = cell(1, 2);
    for j = 1:2
        rmse_fmt{j} = sprintf(floatFmt, rmse_vals(j));
        nrmse_fmt{j} = sprintf(floatFmt, nrmse_vals(j));
        r2_fmt{j} = sprintf(floatFmt, r2_vals(j));
        time_fmt{j} = sprintf(floatFmt, time_vals(j));
    end
    rmse_fmt{best_rmse}   = ['\textbf{' rmse_fmt{best_rmse} '}'];
    nrmse_fmt{best_nrmse} = ['\textbf{' nrmse_fmt{best_nrmse} '}'];
    r2_fmt{best_r2}       = ['\textbf{' r2_fmt{best_r2} '}'];
    time_fmt{best_time}   = ['\textbf{' time_fmt{best_time} '}'];

    % Write line
    fprintf(fout, '    \\texttt{%s}', name);
    fprintf(fout, ' & %s & %s', rmse_fmt{:});
    fprintf(fout, ' & %s & %s', nrmse_fmt{:});
    fprintf(fout, ' & %s & %s', r2_fmt{:});
    fprintf(fout, ' & %s & %s', time_fmt{:});
    fprintf(fout, ' \\\\\n');
end


fprintf(fout, '    \\bottomrule\n');
fprintf(fout, '  \\end{tabular}\n');
fprintf(fout, '\\end{table*}\n');

fclose(fout);
disp('LaTeX table written to latex_compare_egauss_flfr.tex');
