function y_hat = fuzzyPredict(u, serverClusters)
    % u: m×1 new input
    m = length(u);
    M = numel(serverClusters);
    psi_new = [1; u];   % (m+1)×1

    % Compute membership μ_j:
    mu = zeros(M,1);
    Theta = zeros(m+1,M);
    for j = 1:M
        
        Theta(:,j) = serverClusters{j}.theta;
        c_j = serverClusters{j}.v(1:m); 
        Sigma_in_j = serverClusters{j}.Sigma(1:m,1:m);
        sigma_j = sqrt(mean(diag(Sigma_in_j)));
        mu(j) = exp( -((u - c_j)'*(u - c_j)) / (2*sigma_j^2) );

    end
    mu = (mu + eps) / (sum(mu+ eps)  );  % normalize membership

    % Weighted sum of local predictions:
    y_hat = 0;
    for j = 1:M
        yj = psi_new' * Theta(:,j);  % local linear prediction
        y_hat = y_hat + mu(j) * yj;
    end
end
