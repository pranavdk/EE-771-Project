%% Implementation of the Orthogonal Matching Pursuit Algorithm

function theta = myOMP(y,A,iter)
[~,n] = size(A);
r = y;
theta = zeros(n,1);
T = false(n,1);
A_norm = A ./ sqrt(sum(A.*A));    %This won't work in older versions of matlab. sigh
%A_norm = normc(A);

for i = 1:iter
    [~,j] = max(abs(r' * A_norm));
    T(j) = true;
    A_t = A(:,T);
    theta(T) = A_t \ y;
    r = y - A_t*theta(T);    
end
end
