clc; clear;

% === CONFIGURATION ===
resultsDir   = 'Results';
filePattern  = fullfile(resultsDir,'results_scenario*_clients*.csv');
files        = dir(filePattern);

baseFields   = { ...
    'nClustersPerClient', 'C_server', ...
    'rmse','nrmse','r2', ...
    't_client_per','t_server_per'};
fields = baseFields;
labels = { ...
    '$C_{\text{client}}$', '$C_{\text{server}}$', ...
    'RMSE', 'NRMSE', '$R^2$', ...
    '$t_{\text{client}}$ [ms]', '$t_{\text{server}}$ [ms]'};
clientsList  = [1,3,10,30];
floatFmt     = '%.3f';

% === 1) LOAD DATA ===
allT = table();
for F = files'
    T = readtable(fullfile(resultsDir,F.name));
    tok = regexp(F.name,'scenario(\d+)_clients(\d+)','tokens','once');
    if isempty(tok), continue; end
    T.scenario = repmat(str2double(tok{1}),height(T),1);
    T.clients  = repmat(str2double(tok{2}),height(T),1);
    allT = [allT; T]; %#ok<AGROW>
end
assert(~isempty(allT), 'No CSV files matched pattern %s', filePattern);

% Create dataset list with total features (including output)
T_summary = unique(allT(:, {'datasetName', 'm_features'}), 'rows');
T_summary.TotalFeatures = T_summary.m_features + 1;
T_summary = sortrows(T_summary, 'TotalFeatures');
datasets_sorted = T_summary.datasetName;

% === 2) MEAN & STD ===
meansMap = struct(); stdsMap = struct();
for d = datasets_sorted'
    name = d{1}; rowsD = allT(strcmp(allT.datasetName,name),:);
    M = nan(numel(clientsList),numel(fields));
    S = nan(size(M));
    for i = 1:numel(clientsList)
        c = clientsList(i);
        sub = rowsD(rowsD.clients==c,:);
        if isempty(sub), continue; end
        sub.t_client_per = sub.t_client_per*1e3;
        sub.t_server_per = sub.t_server_per*1e3;
        X = table2array(sub(:,fields));
        M(i,:) = mean(X,1,'omitnan');
        S(i,:) = std( X,0,1,'omitnan');
    end
    meansMap.(matlab.lang.makeValidName(name)) = M;
    stdsMap.(matlab.lang.makeValidName(name))  = S;
end

% === 3) WRITE LATEX TABLE TO FILE ===
% --- indices of metrics to bold -------------------------------------
boldMinCols = [3 4 6 7];   % lowest RMSE, NRMSE, t_client, t_server
boldMaxCols = 5;           % highest R^2
floatTol    = 1e-12;       % tolerance to match extrema
% -------------------------------------------------------------------------

outFile = fopen('generated_table.tex','w');

fprintf(outFile,'\\begin{table*}[htbp]\n');
fprintf(outFile,'  \\centering\n');
fprintf(outFile,'  \\caption{Experimental results (mean $\\pm$~std over runs). The computational time required per sample is reported in milliseconds.}\n');
colSpec = ['l l', repmat(' c',1,numel(fields))];
fprintf(outFile,'  \\begin{tabular}{%s}\n', colSpec);
fprintf(outFile,'    \\toprule\n');

% header
fprintf(outFile,'    Dataset & Clients');
for k = 1:numel(labels)
    fprintf(outFile,' & %s', labels{k});
end
fprintf(outFile,' \\\\\n');
fprintf(outFile,'    \\midrule\n');

% body
for dIdx = 1:numel(datasets_sorted)
    name = datasets_sorted{dIdx};
    M = meansMap.(matlab.lang.makeValidName(name));
    S = stdsMap.(matlab.lang.makeValidName(name));

    % minima / maxima for each metric in current dataset
    minVals = min(M,[],1,'omitnan');
    maxVals = max(M,[],1,'omitnan');

    for r = 1:numel(clientsList)
        c = clientsList(r);
        if r==1
            % LaTeX-safe dataset name
            name_latex = regexprep(name, '_', '\\_');
            fprintf(outFile,'    \\multirow{4}{*}{\\texttt{%s}} & %d', name_latex, c);
        else
            fprintf(outFile,'                                     & %d', c);
        end
        for col = 1:numel(fields)
            mv = M(r,col); sv = S(r,col);
            if isnan(mv)
                fprintf(outFile,' & --');
            else
                isCnt = (col<=2);       % C_client / C_server
                if isCnt
                    if sv<0.5
                        fprintf(outFile,' & %d', round(mv));
                    else
                        fprintf(outFile,' & %d$\\pm%d$', round(mv), round(sv));
                    end
                else
                    % decide whether to bold this mean
                    meanStr = sprintf(floatFmt,mv);
                    if ismember(col,boldMinCols) && abs(mv-minVals(col)) < floatTol
                        meanStr = ['\mathbf{' meanStr '}'];
                    elseif ismember(col,boldMaxCols) && abs(mv-maxVals(col)) < floatTol
                        meanStr = ['\mathbf{' meanStr '}'];
                    end
                    fprintf(outFile,' & $%s\\pm%s$', meanStr, sprintf(floatFmt,sv));
                end
            end
        end
        fprintf(outFile,' \\\\\n');
    end
    if dIdx < numel(datasets_sorted)
        fprintf(outFile,'    \\midrule\n');
    end
end
fprintf(outFile,'    \\bottomrule\n');
fprintf(outFile,'  \\end{tabular}\n');
fprintf(outFile,'\\end{table*}\n');

fclose(outFile);
disp('LaTeX table written to generated_table.tex');
