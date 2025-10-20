function [epsR_client, epsR_global] = estimateEpsPerClientAndGlobal(Data,p_target)
% The membership threshold is computed based on each clients data to make sure
% clusters are even formed 
% ε² chosen so that:
%   • expected #clusters ≲ √N
%   • each cluster ≈ 10–30 samples
%   • ≥ p_target fraction of points have ≥ S_goal neighbours inside √ε

    function eps2 = radius_for(U, p_target)
        U = double(U);                     % N×m
        [N,m] = size(U);
        if N < 11                         % can't get 10-sample cluster
            eps2 = inf;  return
        end

        Cmax   = ceil( sqrt(N) );         % #clusters upper bound
        Sgoal  = max(10, min(30, ceil(N / Cmax)));   % target cluster size

        K      = Sgoal + 1;               % self + Sgoal neighbours
        [~,D]  = knnsearch(U,U,'K',min(K,N));  % Euclidean
        kD2    = D(:,end).^2;             % squared dist to Sgoal-NN

        kD2_sorted = sort(kD2);
        idxQ       = max(1, ceil(p_target * N));
        base_eps2  = kD2_sorted(idxQ);

        lambda     = (m + 1)/2;           % centroid-drift compensation
        eps2       = (lambda^2) * base_eps2;
    end

    nC          = numel(Data);
    epsR_client = zeros(1,nC);

    % -------- per-client ------------------------------------------------
    for j = 1:nC
        M   = Data{j};                    % (m+1)×N_j
        U   = M(1:end-1,:)';              % N_j×m
        epsR_client(j) = radius_for(U, p_target);
    end

    % -------- pooled ----------------------------------------------------
    Ucells = cellfun(@(M) M(1:end-1,:)', Data, 'UniformOutput',false);
    Uall   = vertcat(Ucells{:});          % (ΣN_j)×m
    epsR_global = radius_for(Uall, p_target);

end
