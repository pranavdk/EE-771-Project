%% Implementation of K-SVD algorithm

function [D,X] = myKSVD(D_init,Y,max_iter,omp_iter)
% OMP iter is T0

K = size(D_init,2);
N = size(Y,2);
S = zeros(K,N);

for iter = 1:max_iter
    iter
%step 1 : Sparse coding
    for j = 1:N
        size(D_init);
        size(Y(:,j));
        r = myOMP(Y(:,j),D_init,omp_iter);
        S(:,j) = r;
    end

%step 2 : Codebobk update

    for k = 1:K
        sup = find(S(k,:)); 
       
       Ek = Y;
       for i = 1:K
           if (i ~= k)
               Ek = Ek -  D_init(:,i)*S(i,:);
           end
       end
       Ekr = Ek (:,sup);
       
       [Us,Ss,Vs] = svds(Ekr,1);
       
       D_init(:,k) = Us;
       
       S(k,sup) = Ss*Vs';

    end
    
    D_init = normc(D_init);
    sum(sum((Y - D_init*S).^2) / sum(Y.^2))

end

D = D_init;
X = S;

end