function C_pq = mergeTwoClusters(Cp, Cq)
%Merge two cluster structs Cp and Cq into one.

    %Merge samples
    np   = Cp.n;
    nq   = Cq.n;
    n_pq = np + nq;

    %Merge center
    vp = Cp.v;
    vq = Cq.v;
    vpq = (np*vp + nq*vq) / n_pq;

    %Merge covariance 
    Sigmap = Cp.Sigma;
    Sigmaq = Cq.Sigma;
    Sigma_pq = (np*Sigmap + nq*Sigmaq)/n_pq ...
               + (np*nq)/(n_pq^2) * (vp - vq)*(vp - vq)';

    %Merge linear parameters theta
    thetap = Cp.theta;
    thetaq = Cq.theta;
    theta_pq = (np*thetap + nq*thetaq) / n_pq;

    % P and age are only used at the client side, 
    % they are not available at the server
    if isfield(Cp,'P') && isfield(Cq,'P')
        P_pq = max(Cp.P, Cq.P);
    else
        P_pq = [];
    end
    if isfield(Cp,'age') && isfield(Cq,'age')
        age_pq = max(Cp.age, Cq.age);
    else
        age_pq = [];
    end

    %Build output struct
    C_pq.n     = n_pq;
    C_pq.v     = vpq;
    C_pq.Sigma = Sigma_pq;
    C_pq.theta = theta_pq;
    C_pq.P = P_pq;
    C_pq.age = age_pq;

end
