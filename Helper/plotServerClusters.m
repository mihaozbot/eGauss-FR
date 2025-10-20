function plotServerClusters(serverStruct, bestPair)
% 2-D view of auxiliary points and final server clusters
%   bestPair = [i j] are the two dimensions to show.

    i = bestPair(1); 
    j = bestPair(2);
    hasAux = isfield(serverStruct,'U_aux') && ~isempty(serverStruct.U_aux);

    if hasAux
        x_aux = serverStruct.U_aux(i ,:);
        if j <= size(serverStruct.U_aux,1)     
            y_aux = serverStruct.U_aux(j ,:);
            ylab  = sprintf('Feature %d', j);
        else     
            y_aux = serverStruct.Y_aux(:);
            ylab  = 'Output  y';
        end
    end

    figure('Name','Server-Merged Clusters');  clf;  hold on;
    if hasAux
        scatter(x_aux, y_aux, 12, 'red', 'filled', ...
                'DisplayName','Aux points', ...
                'MarkerFaceAlpha',0.5);
    end
    clusts = serverStruct.clusters;
    for k = 1:numel(clusts)
        c   = clusts{k};
        assert(j <= numel(c.v), ...
              'Index j=%d exceeds size(c.v)=%d', j, numel(c.v));
        mu  = [c.v(i);            c.v(j)           ];
        Sig =  c.Sigma([i j],[i j]);

        plot(mu(1), mu(2), 'ks', ...
             'MarkerFaceColor','k', 'MarkerSize',7, ...
             'DisplayName','Cluster centres');
        plotClusterEllipse(mu, Sig, [0 0 0]); 
    end

    xlabel(sprintf('Feature %d', i));
    ylabel(ylab);
    title(sprintf('Server clusters – dims %d vs %d', i, j));
    grid on;  hold off;
    
end
