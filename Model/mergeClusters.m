function container = mergeClusters(container)

    Kappa   = container.params.kappa_m;
    c_min   = container.params.c_merge;
    clusters = container.clusters;

    if numel(clusters) < c_min
        return;   
    end

    merged_any = true;
    while merged_any && numel(clusters) >= c_min
        merged_any  = false;
        startCount  = numel(clusters); 
        %Estimate computational complexity for the covariance matrix
        dSwitch = (numel(clusters)^2)*(length(clusters{1}.v)^3); 
        for p = 1:startCount
            if numel(clusters) < c_min || p > numel(clusters)
                break;
            end

            bestR = inf;  bestQ = 0;
            for q = 1:numel(clusters)
                if q == p, continue; end
           
                r = mergeRatioDetDiag(clusters{p}, clusters{q}, dSwitch); 
                if r < bestR
                    bestR = r;  bestQ = q;
                end
            end

            if bestR < Kappa
                Cnew = mergeTwoClusters(clusters{p}, clusters{bestQ});
                clusters(sort([p bestQ],'descend')) = [];        % delete p/q
                clusters{end+1} = Cnew;                          %#ok<AGROW>
                merged_any = true;
            end
        end
    end

    container.clusters = clusters;
end
% -------------------------------------------------------------------------
function r = mergeRatioDetDiag(Ci, Cj, dSwitch)
% In large dimensions the covariance explodes or vanishes. 
% The determinant volume is computed for small dimensions (m+1 ≤ dSwitch)
% and √prod(diag(Σ)) for larger dimensions.
%   • determinant (exact) if dim ≤ dSwitch   [O(m^3)]
%   • diag-product        if dim > dSwitch   [O(m)]
%   r = vol(Σ_pq) / (vol(Σ_p)+vol(Σ_q))

    np = Ci.n;  nq = Cj.n;
    vp = Ci.v;  vq = Cj.v;
    Sigmap = Ci.Sigma;   Sigmaq = Cj.Sigma;

    m  = size(Sigmap,1);                      % = inputs+output

    % merge covariance (rank-1 update)
    npq   = np + nq;
    vpq   = (np*vp + nq*vq) / npq;
    Sigmapq = (np*Sigmap + nq*Sigmaq)/npq + ...
              (np*nq)/(npq^2) * (vp - vq)*(vp - vq).';

    if dSwitch <= 1e5   
        vol_pq = sqrt(det(Sigmapq));
        vol_p  = sqrt(det(Sigmap ));
        vol_q  = sqrt(det(Sigmaq ));
    else                                           % diagonal product
        vol_pq = sqrt(prod(diag(Sigmapq)));
        vol_p  = sqrt(prod(diag(Sigmap )));
        vol_q  = sqrt(prod(diag(Sigmaq )));
    end

    r = vol_pq / (vol_p + vol_q + eps);            % eps avoids /0
end
