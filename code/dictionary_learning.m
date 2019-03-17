%% Dictionanry Learning

clear;
clc;
close all;

%% Global variables

file_path = '../data/final.mp4';
v = VideoReader(file_path);

N_videos = 20;
temporal_depth = 36;
img_height = v.H;
img_width = v.W;
total_frames = floor(v.D*v.FR);
subsampling_rate = 2;
sparsity = 40;

%%

mobj = matfile('../data/Videos20.mat');
Video_Data = mobj.Data;
m = size(Video_Data, 2);
n = size(Video_Data, 3);
patchsize = 8;
stride = patchsize;
num_patches = ((m-patchsize)/stride+1)*((n-patchsize)/stride+1);

Video_Data = mean(Video_Data,4); % grey

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
    params.dictsize = 625;
    [final_basis,sparse_repr] = ksvd(params,'i');
    
    Dictionary = [Dictionary, final_basis];
end

save('../data/Dictionary12500.mat','Dictionary','-v7.3');

