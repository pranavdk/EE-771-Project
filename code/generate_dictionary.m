function [Dictionary, dictionary_path] = generate_dictionary(video_mat_path,...
    patchsize,stride,n_basis_per_video_segment,dictionary_path,sparsity,store,colored)

mobj = matfile(video_mat_path);
Video_Data = mobj.Data;

if(~colored)
    Video_Data = mean(Video_Data,4); % grey
end

n_videos = size(Video_Data,1);
img_width = size(Video_Data, 2);
img_height = size(Video_Data, 3);
color_depth = size(Video_Data, 4);
temporal_depth = size(Video_Data, 5);

num_patches = ((img_width-patchsize)/stride+1)*((img_height-patchsize)/stride+1);

Dictionary = zeros(patchsize^2*color_depth*temporal_depth,...
    n_basis_per_video_segment*n_videos);

for vid_seg_index= 1:n_videos
    vid_seg_index
    data_array = zeros(8*num_patches,(patchsize^2)*temporal_depth);
    count = 1;

    for i = 1:stride:img_width
        for j = 1:stride:img_height

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

    Dictionary(:,(vid_seg_index-1)*n_basis_per_video_segment+1:...
        vid_seg_index*n_basis_per_video_segment) = final_basis;
end

if(store)
    save(dictionary_path,'Dictionary','-v7.3');
end

end

