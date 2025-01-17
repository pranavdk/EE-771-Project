%% Implementation of K-SVD algorithm

function [final_basis,sparse_repr] = myKSVD(current_basis,data,max_iter,omp_iter)
% OMP iter is T0

num_basis = size(current_basis,2);   
num_data_points = size(data,2);
curr_sparse_repr = zeros(num_basis,num_data_points);

for iter = 1:max_iter
    iter
    %step 1 : Sparse coding
    for data_index = 1:num_data_points
        size(current_basis);
        size(data(:,data_index));
        r = myOMP(data(:,data_index),current_basis,omp_iter);
        curr_sparse_repr(:,data_index) = r;
    end

    %step 2 : Codebook update
    for basis_index = 1:num_basis
        data_used = find(curr_sparse_repr(basis_index,:)); 
       
        Ek = data;
        for i = 1:num_basis
            if (i ~= basis_index)
                Ek = Ek -  current_basis(:,i)*curr_sparse_repr(i,:);
            end
        end
        Ekr = Ek (:,data_used);
       
        [Us,Ss,Vs] = svds(Ekr,1);
       
        current_basis(:,basis_index) = Us;
       
        curr_sparse_repr(basis_index,data_used) = Ss*Vs';

    end
    
    current_basis = normc(current_basis);
    sum(sum((data - current_basis*curr_sparse_repr).^2) / sum(data.^2))

end

final_basis = current_basis;
sparse_repr = curr_sparse_repr;

end