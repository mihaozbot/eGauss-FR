function plotInferenceResults(U, Y, y_true, y_pred, bestPair, m)

    if ~iscell(U)
        U = {U};
        Y = {Y};
    end

    U_all = [U{:}];
    Y_all = [Y{:}];

    % Plot data and predictions
    figure; clf;
    scatter(U_all, Y_all, 10, 'filled'); hold on;
    plot(U_all, y_true, 'b.');
    plot(U_all, y_pred, 'r.');
    legend('Data','True','Pred');
    
    % Scatter plot of true vs predicted
    figure; clf;
    scatter(y_true, y_pred, 15, 'filled'); hold on;
    mn = min([y_true y_pred]);
    mx = max([y_true y_pred]);
    plot([mn mx], [mn mx], 'k--');
    xlabel('True y');
    ylabel('Pred y');
end
