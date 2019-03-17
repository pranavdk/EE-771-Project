function [reconstructed] = reconstruct(Dictionary,coded_img,samp_mat,temporal_depth,patchsize,stride)

    output = double(zeros([size(coded_img), temporal_depth]));
    count = double(zeros([size(coded_img), temporal_depth]));
    size(coded_img)
    for i = 1:stride:size(coded_img,1)
        for j = 1:stride:size(coded_img,2)

            patch = coded_img(i:i+patchsize-1,j:j+patchsize-1);
            patch_sensing_matrix = samp_mat(i:i+patchsize-1,j:j+patchsize-1,:,:);
            
            theta = omp(patch_sensing_matrix*Dictionary,patch(:),[],sparsity);
            f = Dictionary * theta;
            f = reshape(f,[coded_img_size, temporal_depth]);
            output(i:i+patchsize-1,j:j+patchsize-1,:,:) = output(i:i+patchsize-1,j:j+patchsize-1,:,:) + f;
            count(i:i+patchsize-1,j:j+patchsize-1,:,:) = count(i:i+patchsize-1,j:j+patchsize-1,:,:) + 1.0;  
            
        end 
    end
    
    reconstructed = imdivide(output,count);
    
end

