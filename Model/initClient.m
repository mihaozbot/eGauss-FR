
function client = initClient(m, params)
    % Initialize a client struct that will hold evolving clusters & buffers.
    % params = struct of meta-parameters: {gamma, lambda_d, lambda_r, epsilon_tolD, epsilon_tolR, Kappa_m, Kappa_n, c_merge}

    client.m      = m;               
    client.clusters = {};       % initially no clusters
    client.buffers  = {};       % initially no buffers
    client.params   = params;   % store forgetting factor, thresholds, etc.
    client.buffer_dists = [];
    client.k = 0;
    
end