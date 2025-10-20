function [allClusters, bestPair] = gatherAndScoreClusters(clients, m)
    allClusters = {};
    for j=1:numel(clients)
        if isfield(clients{j},'clusters')
            allClusters = [allClusters, clients{j}.clusters];
        end
    end
    Ctot = numel(allClusters);
    if Ctot<1, error('Need ≥1 clusters'); end
    sz = zeros(1,Ctot); mu = zeros(m,Ctot); covs = zeros(m,m,Ctot);
    for c=1:Ctot
        Cc = allClusters{c}; sz(c)=Cc.n;
        mu(:,c)=Cc.v(1:m);
        covs(:,:,c)=Cc.Sigma(1:m,1:m);
    end
    muG = (mu*sz')/sum(sz);
    bestScore=-inf; bestPair=[1,2];
    for i=1:m-1, for j=i+1:m
        Sb=zeros(2); Sw=zeros(2);
        for c=1:Ctot
            delta = mu([i,j],c)-muG([i,j]); Sb=Sb+sz(c)*(delta*delta');
            Sw=Sw+sz(c)*covs([i,j],[i,j],c);
        end
        score = trace(Sb)/max(trace(Sw),eps);
        if score>bestScore, bestScore=score; bestPair=[i,j]; end
    end,end
end