function cluster = initClusterFromData(Z, params, m)
    % Z = (m+1) × N_pts  data matrix, N_pts≥(m+1), containing at least (m+1) points
    % that will initialize a new affine cluster. We solve least squares to get theta,
    % set P=large*I, compute center v and Sigma, and set n=|Z|, age=0.
    %Solve theta via standard least squares (affine model: y = theta'·ψ, ψ=[1; u] )
    %    For each column of Z, we interpret first m entries as u, last entry as y.
    
    N_pts = size(Z,2);
    %cond(Z(1:m, :) *Z(1:m, :)') this needs to be stable
    U_aug = [ ones(1,N_pts); Z(1:m, :) ];   % (m+1)×N_pts
    %cond(U_aug*U_aug')
    %U_aug = [Z(1:m, :) ];   % (m+1)×N_pts
    Y_vec = Z(m+1, :);       % 1×N_pts
    theta = (U_aug * U_aug') \ (U_aug * Y_vec'); % (m+1)×1  solution of min ||Y - theta'·U_aug||²

    %Initialize RLS covariance P = alpha_0·I  with alpha_0 large (e.g. 10^3)
    alpha0 = 1e3;
    P  = alpha0 * eye(m+1);

    % Compute center v and Sigma
    v = mean(Z, 2);                     % (m+1)×1
    Zc = Z - v;                         % subtract center
    Sigma = (1/N_pts) * (Zc * Zc');     % covariance

    cluster.theta   = theta;
    cluster.P   = P;
    cluster.v   = v;
    cluster.Sigma   = Sigma;
    cluster.n   = N_pts;
    cluster.age = 0;

end
