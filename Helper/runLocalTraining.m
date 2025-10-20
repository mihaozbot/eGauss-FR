function clients = runLocalTraining(clients, Data)
%Stream each client's samples

    n_C = numel(clients);
    for j = 1:n_C
        [~, N] = size(Data{j});
        disp(['Client ', num2str(j), ' learning']);
        for k = 1:N
            u_k = Data{j}(1:end-1, k);
            y_k = Data{j}(end,     k);
            clients{j} = processSample(clients{j}, u_k, y_k);
        end
        %fprintf(' Client %d: epsilon_tolR observed = %.4f\n', j, clients{j}.params.epsilon_tolR);
    end
end
