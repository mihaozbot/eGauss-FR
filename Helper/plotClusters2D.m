function plotClusters2D(Data, clients, bestPair)
%Plot feature vs output, overlay client clusters.

    i = bestPair(1);  
    j = size(Data{1},1); 
    n_C = numel(Data);
    colors = lines(n_C);

    figure('Name','Client Clusters (2D)'); clf; hold on;
    for k = 1:n_C

        Xk = Data{k}(i, :);
        Yk = Data{k}(j, :);
        scatter(Xk, Yk, 10, colors(k,:), 'filled', ...
                'MarkerFaceAlpha', 0.3, ...
                'DisplayName', sprintf('Client %d',k));

        % clusters
        clusts = clients{k}.clusters;
        for idx = 1:numel(clusts)
            if iscell(clusts)
                c = clusts{idx};
            else
                c = clusts(idx);
            end

            mu  = [ c.v(i);    c.v(j)    ];
            Sig =   c.Sigma([i j],[i j]);

            plot(mu(1), mu(2), 'o', ...
                 'Color', colors(k,:), ...
                 'MarkerFaceColor', colors(k,:), ...
                 'MarkerSize',6, ...
                 'HandleVisibility','off');

            plotClusterEllipse(mu, Sig, colors(k,:));
        end
    end

    xlabel(sprintf('Feature %d', i));
    ylabel('Output y');
    title('Client Clusters & Data (2D)');

    grid on; hold off;
end
