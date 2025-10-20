function clients = initAllClients(m, params, epsTol)
    n_C = numel(epsTol);
    clients = cell(1,n_C);
    for j = 1:n_C
        clients{j} = initClient(m, params);
        clients{j}.params.epsilon_tolR = epsTol(j);
    end
end
