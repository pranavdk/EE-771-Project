function [reconstructed] = reconstruct(Dictionary,coded_img,samp_mat,...
    temporal_depth,patchsize,stride,sparsity)

    output = double(zeros([size(coded_img), temporal_depth]));
    count = double(zeros([size(coded_img), temporal_depth]));
    s = patchsize^2;
    
    for i = 1:stride:size(coded_img,1)-patchsize+1
        for j = 1:stride:size(coded_img,2)-patchsize+1

            patch = coded_img(i:i+patchsize-1,j:j+patchsize-1);
            patch_sensing_matrix = samp_mat(i:i+patchsize-1,j:j+patchsize-1,:,:);
            
            % will this work for colored images????
            Phi =zeros(s,s*temporal_depth);
            for k = 1 : temporal_depth
                temp = patch_sensing_matrix(:,:,k);     
                Phi(:,(k-1)*s+1:k*s) = diag(temp(:)); 
            end
            
            A = Phi * Dictionary;
            col_norm = sum(A.^2,1);
            theta_norm = omp(normc(A),patch(:),[],sparsity); %% Normalisation here!
            theta = theta_norm.*col_norm';
            f = Dictionary * theta;
            f = reshape(f,[patchsize, patchsize, temporal_depth]);
            output(i:i+patchsize-1,j:j+patchsize-1,:,:) = output(...
                i:i+patchsize-1,j:j+patchsize-1,:,:) + f;
            count(i:i+patchsize-1,j:j+patchsize-1,:,:) = count(...
                i:i+patchsize-1,j:j+patchsize-1,:,:) + 1.0;  
            
        end 
    end
    
%     reconstructed = imdivide(output,count);   % Does this remove singleton dimensios?
    reconstructed = output./count;
    
end

