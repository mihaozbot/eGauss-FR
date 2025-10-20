function plotClusterEllipse(v, Sigma, col)
% Draw a 2D covariance ellipse for cluster in (u,y)-space.
%  v     = 2×1 vector [u_center; y_center]
%  Sigma = 2×2 covariance matrix
%  col   = 1×3 RGB color or color char; defaults to blue if omitted

    if nargin < 3
        col = [0 0 1];  % default to blue
    end

    Ncirc = 100;
    tol = 1e-12 * max(1, norm(Sigma, 'fro'));
    [V, D] = eig(Sigma);
    % Sort eigenvalues descending
    [eigvals, idx_e] = sort(diag(D), 'descend');
    V = V(:, idx_e);
    r1 = sqrt(eigvals(1));
    r2 = sqrt(eigvals(2));
    
    theta = linspace(0, 2*pi, Ncirc);
    circle = [cos(theta); sin(theta)];  % 2×Ncirc
    scaleMat    = diag([r1, r2]);
    ellipseLocal = scaleMat * circle;   % 2×Ncirc
    ellipseRot   = V * ellipseLocal;    % 2×Ncirc
    ellipsePts   = ellipseRot + v(:);   % translate by center

    plot(real(ellipsePts(1,:)), real(ellipsePts(2,:)), 'Color', col, 'LineWidth', 1.2)

end
