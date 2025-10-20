function [U_aux, Y_aux] = generateAuxiliaryPoints(serverStruct, p_gate)
% Generate auxiliary points ± along all but smallest principal component.
% Uses fixed chi²-scale sqrt(m) for all clusters.

    C = numel(serverStruct.clusters);
    D = numel(serverStruct.clusters{1}.v);
    m = D - 1; % input dimension

    chi2_scale = sqrt(m);  % fixed, dimension-aware distance

    U_aux = [];
    Y_aux = [];

    for j = 1:C
        c = serverStruct.clusters{j};
        v = c.v;
        Sig = c.Sigma;

        % Full eigen-decomposition
        [V, Dmat] = eig(Sig);
        eigvals = diag(Dmat);
        [~, minIdx] = min(eigvals);  % find index of smallest eigenvalue

        % Remove smallest principal component
        V(:, minIdx) = [];
        eigvals(minIdx) = [];

        % Generate points along each retained principal axis
        for k = 1:size(V, 2)
            direction = V(:, k);
            scale = sqrt(eigvals(k)) * chi2_scale;

            point_pos = v + scale * direction;
            point_neg = v - scale * direction;

            U_aux = [U_aux, point_pos(1:m), point_neg(1:m)];
            Y_aux = [Y_aux, point_pos(m+1), point_neg(m+1)];
        end
    end
end