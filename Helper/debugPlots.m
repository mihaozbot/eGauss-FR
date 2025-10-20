function debugPlots(U, Y, Data, clients, serverStruct, bestPair, y_true, y_pred)

    if ~iscell(U)
        U = {U};
        Y = {Y};
    end

    % --- plotting functions
    plotInferenceResults(U, Y, y_true, y_pred, bestPair, numel(U{1}));
    plotClusters2D(Data, clients, bestPair);
    plotServerClusters(serverStruct, bestPair);
    
    % --- Sorting for error plots
    [~, order] = sort(y_true);
    ys  = y_true(order);
    fs  = y_pred(order);
    err = fs - ys;

    figure; clf;

    % True vs. Fuzzy after sorting
    subplot(2,1,1);
    plot(ys,  'b-', 'LineWidth', 1.2, 'DisplayName','True (sorted)');
    hold on;
    plot(fs, 'r--','LineWidth', 1.2, 'DisplayName','Fuzzy (same order)');
    ylabel('y');
    title('True vs. Fuzzy – samples sorted by true y');
    grid on;

    % Error plot
    subplot(2,1,2);
    plot(err, 'k-', 'LineWidth', 1.0);
    xlabel('Sample (sorted by y_{true})');
    ylabel('Residual (y_{pred} – y_{true})');
    title('Prediction Error (same sample order)');
    grid on;

end
