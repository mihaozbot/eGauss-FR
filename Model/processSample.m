function [client, params] = processSample(client, u_k, y_k)
% Process a single new sample  (u_k ∈ ℝ^m, y_k scalar)  for client j,

clusters = client.clusters;
buffers  = client.buffers;
params   = client.params;
m        = client.m;
client.k = client.k + 1;

phi_k = [1; u_k(:)];          % (m+1)×1   regressor
z_k   = [u_k(:); y_k];        % (m+2)×1   data for covariance

c = numel(clusters);
if c > 0
    % find closest cluster in prediction
    d2 = nan(1, c);
    for j = 1:c
        y_pred = phi_k' * clusters{j}.theta;
        d2(j)  = (y_k - y_pred)^2;
    end
    [d2_min, w] = min(d2);

    %distance in joint space
    v_w   = clusters{w}.v;
    r2_min = (z_k - v_w)' * (z_k - v_w);

    % eigen value decomposition
    Sigma_w  = clusters{w}.Sigma;
    Sigma_wR = Sigma_w + eps * eye(m+1);      % ridge
    eigvals  = sort(eig(Sigma_wR), 'descend');
    sig1     = eigvals(1);     % largest
    sig2     = eigvals(2);     % 2nd largest

    cond1 = (d2_min < params.lambda_d * sig2 + params.epsilon_tolD);
    cond2 = (r2_min < params.lambda_r * sig1 + params.epsilon_tolR);
    
    %update existing cluster 
    if cond1 && cond2 

        %RLS update
        Pw = clusters{w}.P + eps * eye(m+1); 
        e_wk   = y_k - phi_k' * clusters{w}.theta;
        K_w    = (Pw * phi_k) / (params.ipsilon + phi_k' * Pw * phi_k);
        theta_w = clusters{w}.theta + K_w * e_wk;
        P_w     = (1/params.ipsilon) * (eye(m+1) - K_w * phi_k') * Pw;

        %Incremental covariance update
        n_w = clusters{w}.n;
        v_w_new = v_w + (1/(n_w+1)) * (z_k - v_w);
        Sigma_star  = Sigma_w*n_w + (z_k - v_w) * (z_k - v_w_new)';
        Sigma_w_new = Sigma_star / (n_w+1);
        Sigma_w_new = Sigma_w_new + eps * eye(m+1);

        %Save updates
        clusters{w}.theta = theta_w;
        clusters{w}.P     = P_w;
        clusters{w}.v     = v_w_new;
        clusters{w}.Sigma = Sigma_w_new;
        clusters{w}.n     = n_w + 1;
        clusters{w}.age   = 0;
        
        %Update age
        for i = 1:c
            if i ~= w, clusters{i}.age = clusters{i}.age + 1; end
        end
        client.clusters = clusters;
        return;
    end
end

%The sample was not near a cluster so the buffer is checked
cB = numel(buffers);
if cB > 0
    q2 = zeros(1, cB);
    for q = 1:cB
        q2(q) = (z_k - buffers{q}.b)' * (z_k - buffers{q}.b);
    end
    [q2_min, wB] = min(q2);
    
    %Check if near an existing buffer
    if q2_min < params.epsilon_tolR
        
        buffers{wB}.data(:, end+1) = z_k;
        buffers{wB}.n   = buffers{wB}.n + 1;
        buffers{wB}.b   = mean(buffers{wB}.data, 2);
        
        %min_obs = max(m+1, 10);                 % ≥ full-rank chance
        if buffers{wB}.n < m+1
            client.buffers = buffers;
            return;
        end
        
        %Check the stability of the potential new cluster
        U_aug = [ ones(1,size(buffers{wB}.data(1:m, :),2)); buffers{wB}.data(1:m, :) ];
        if  cond(U_aug*U_aug') > (1/(100*(eps)))
            client.buffers = buffers;
            return;
        end
            %Create a new cluster
            clusters{end+1} = initClusterFromData(buffers{wB}.data, params, m);
            buffers(wB) = [];
            client.clusters = clusters;
            client.buffers  = buffers;
            if numel(client.clusters) >= params.c_merge
                client = mergeClusters(client);
            end
            return;

        end
    end
    
    %The sample is not near a cluster or a buffer, so add the sample as a new buffer
    newBuf.b    = z_k;
    newBuf.n    = 1;
    newBuf.data = z_k;
    buffers{end+1} = newBuf;

    client.buffers = buffers;
    client.params  = params;
end
