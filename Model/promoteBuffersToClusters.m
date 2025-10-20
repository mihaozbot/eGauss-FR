function clients = promoteBuffersToClusters(clients)
    perturb_v   = 0.1;
    perturb_Sig = 0.1;
    for j = 1:numel(clients)
        client = clients{j};
        if isfield(client,'buffers') && ~isempty(client.buffers)
            for b = 1:numel(client.buffers)
                buf = client.buffers{b}; Zb = buf.data;
                v_raw = mean(Zb,2);
                if size(Zb,2)>1, Sigma_raw = cov(Zb');
                else, Sigma_raw = eye(size(Zb,1))*1e-6; end
                sigma_v = perturb_v*sqrt(trace(Sigma_raw));
                noise_v = sigma_v*randn(size(v_raw));
                eigvals = eig(Sigma_raw);
                Sigma_pert = Sigma_raw + eye(numel(v_raw))*perturb_Sig*max(eigvals);
                newC.v = v_raw+noise_v;
                newC.Sigma = Sigma_pert;
                newC.n = buf.n; newC.age=0;
                newC.theta=zeros(numel(v_raw),1);
                newC.P = eye(numel(v_raw))*1e-3;
                client.clusters{end+1} = newC;
            end
            client.buffers = {};
            clients{j} = client;
        end
    end
    end