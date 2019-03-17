function [Dictionary, dictionary_path] = generate_dictionary(video_mat_path,patchsize,stride,n_basis_per_video_segment,dictionary_path,sparsity,store,colored)

mobj = matfile(video_mat_path);
Video_Data = mobj.Data;
m = size(Video_Data, 2);
n = size(Video_Data, 3);
temporal_depth = size(Video_Data, 5);
% patchsize = 8;
% stride = patchsize;
num_patches = ((m-patchsize)/stride+1)*((n-patchsize)/stride+1);

if(~colored)
    Video_Data = mean(Video_Data,4); % grey
end

Dictionary = [];
for vid_seg_index= 1:size(Video_Data,1)
    vid_seg_index
    data_array = zeros(8*num_patches,(patchsize^2)*temporal_depth);
    count = 1;

    for i = 1:stride:m
        for j = 1:stride:n

            temp = Video_Data(vid_seg_index,i:i+patchsize-1,j:j+patchsize-1,:,:);
            temp_size = size(temp);

            temp = reshape(temp,temp_size(2:end));
            temp_flip = flip(temp,4);
            data_array(count,:) = temp(:);
            count = count +1;
            data_array(count,:) = temp_flip(:);
            count = count +1;

            for rot_index = 1:3
                temp = rot90(temp);
                temp_flip = flip(temp,4);
                data_array(count,:) = temp(:);
                count = count +1;
                data_array(count,:) = temp_flip(:);
                count = count +1;
            end      
        end
    end

    params.data = data_array';
    params.Tdata = sparsity;
    params.dictsize = n_basis_per_video_segment;
    [final_basis,sparse_repr] = ksvd(params,'i');
    
    Dictionary = [Dictionary, final_basis];
end

if(store)
    save(dictionary_path,'Dictionary','-v7.3');
end

end

