function [rmse, nrmse, r2] = computeAndPrintMetrics(y_true, y_pred)
    err=y_true-y_pred; rmse=sqrt(mean(err.^2));
    nrmse=rmse/(max(y_true)-min(y_true));
    r2=1-sum(err.^2)/sum((y_true-mean(y_true)).^2);
    fprintf('RMSE=%.4g, NRMSE=%.4g, R^2=%.4g\n',rmse,nrmse,r2);
end
