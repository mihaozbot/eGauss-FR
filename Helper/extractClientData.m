function [U, Y, u_all, y_all] = extractClientData(Data, m)
    n_C = numel(Data);
    U = cell(1,n_C); Y = cell(1,n_C);
    for j = 1:n_C
        U{j} = Data{j}(1:m, :);
        Y{j} = Data{j}(m+1, :);
    end
    u_all = cell2mat(U);
    y_all = cell2mat(Y);
end
