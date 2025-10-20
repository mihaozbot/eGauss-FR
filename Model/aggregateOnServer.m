function [serverStructAggregated] = aggregateOnServer(clients, params)

    % --- 1) Collect eligible clusters ---
    allSets = {};
    for j = 1:numel(clients)
        for c = clients{j}.clusters
            cl = c{1};
            if cl.n >= params.kappa_n
                Sigma = cl.Sigma + 1e-4 * eye(size(cl.Sigma)); % regularize
                allSets{end+1} = struct( ...
                    'v', cl.v, ...
                    'Sigma', Sigma, ...
                    'n', cl.n, ...
                    'theta', cl.theta ...
                );
            end
        end
    end

    % Return if no clusters
    if isempty(allSets)
        serverStructAggregated.clusters = {};
        serverStructAggregated.params   = params;
        return;
    end

    % Assign to output structures ---
    serverStructAggregated.clusters = allSets;
    serverStructAggregated.params   = params;

end
