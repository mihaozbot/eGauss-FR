function serverStruct = trainFuzzyRegression(serverStruct, U_aux, Y_aux, m)
%TRAINFUZZYREGRESSION  Estimate cluster-specific thetas via weighted least squares.
    M = numel(serverStruct.clusters);
    N = size(U_aux,2);
    Phi = zeros(M,N);
    for j = 1:M
        c = serverStruct.clusters{j}; v=c.v;
        c_j = v(1:m);
        Sig = c.Sigma(1:m,1:m);
        sigma_j = sqrt(mean(diag(Sig)));
        for i = 1:N
            d2 = (U_aux(:,i)-c_j)'*(U_aux(:,i)-c_j);
            Phi(j,i) = exp(-d2/(2*sigma_j^2));
        end
    end
    Phi = (Phi+ eps)./(sum((Phi+ eps),1));
    Psi = [ones(1,N); U_aux];
    theta = zeros(m+1,M);
    for j=1:M
        W = diag(Phi(j,:)); A = Psi*W*Psi'; b = Psi*(W*Y_aux');
        theta(:,j) = A\b;
        serverStruct.clusters{j}.theta = theta(:,j);
    end
end