%% Implementation of K-SVD algorithm

function [D,X] = myKSVD(D_init,Y,phi,max_iter,omp_iter)

K = size(D_init,2);
p = size(D_init,1);
m = size(Y,1);
N = size(Y,2);
S = zeros(K,N);
D_prev = D_init;
for iter = 1:max_iter
%step 1
    for j = 1:N
        size(D_init);
        size(Y(:,j));
        r = myOMP(Y(:,j),phi(:,:,j)*D_init,omp_iter);
        S(:,j) = r;
    end

%step 2

    for k = 1:K
       sup = find(S(k,:));
       M = zeros(size(Y));
       G = zeros(p,p);
       b = zeros(p,1);
       for i = sup
          M(:,i) = Y(:,i) - phi(:,:,i) * (D_init*S(:,i) -  D_init(:,k)*S(k,i));
          G = G + (S(k,i)^2) * phi(:,:,i)' * phi(:,:,i); 
          b = b +  S(k,i) * phi(:,:,i)' * M(:,i);
       end
       D_init(:,k) = G\b;
       for i = sup
          S(k,i) = (M(:,i)' * phi(:,:,i) * D_init(:,k))/(sum((phi(:,:,i)*D_init(:,k)).^2));
       end

    end
%     D_init = normc(D_init);
    sum(sum((D_init - D_prev).^2));
    D_prev = D_init;
end

D = D_init;
X = S;

end