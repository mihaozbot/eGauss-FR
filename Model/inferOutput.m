function [y_pred] = predictOriginalData(U_test, serverStruct)
%Evaluate fuzzy regression model on test data.

    N_test = size(U_test, 2);
    y_pred = zeros(1, N_test);

    for i = 1:N_test
        y_pred(i) = fuzzyPredict(U_test(:, i), serverStruct.clusters);
    end
end
