function plotClientData(U, Y)
    n_C = numel(U); figure; hold on;
    colors = lines(n_C);
    for j = 1:n_C
        scatter(U{j}, Y{j}, 15, 'MarkerEdgeColor', colors(j,:), ...
                'DisplayName', sprintf('Client %d', j));
    end
    xlabel('u'); ylabel('y'); title('Client Data Distribution');
    grid on; hold off;
end
