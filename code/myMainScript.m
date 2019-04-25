%% EE 771 Project : Reducing Spatio-temporal tradeoff

clear;
clc;
close all;

%% Global Variables / Parameters/ Hyperparameters

file_path = '../data/final.mp4';
v = VideoReader(file_path);
temporal_depth = 36;
subsampling_rate = 2;
img_height = floor(v.H/subsampling_rate);
img_width = floor(v.W/subsampling_rate);
img_size = [img_height, img_width,];
total_frames = floor(v.D*v.FR);
sparsity = 40;
epsilon = 1e-6;
patchsize = 8;
stride = patchsize/2;
N_videos = 20;
bump_length = 3;
n_basis_per_video_segment = 625;

video_mat_path = '../data/Videos20.mat';
separated_videos_path = '../data/separated_videos20/';
video_segments_list_path = '../data/video_segments_list.mat';
vfiles = dir (strcat(separated_videos_path,'/*.mat'));

store = 1;    % change to store generated dictionary, coded images etc
colored = 0;  % change for colored images

%% Reading Video Segments and Data Preprocessing

% C = randi([0,total_frames-temporal_depth],1,N_videos);
% Data = zeros(N_videos,img_height,img_width,3,temporal_depth);
% 
% for i = 1:N_videos
%     i
%     video_segment = read(v,[C(i),C(i)+temporal_depth-1]);
%     Data(i,:,:,:,:) = double(video_segment(1:subsampling_rate:end,...
%         1:subsampling_rate:end,:,:))/255;
%     array = double(video_segment(1:subsampling_rate:end,...
%         1:subsampling_rate:end,:,:))/255;
%     separated_filename = strcat(separated_videos_path, num2str(i), '.mat');
%     save(separated_filename, 'array', '-v7.3');
% end
% 
% save(video_mat_path,'Data','-v7.3');

%%

experiment_path = '../data/1/';
dictionary_path = '../data/1/Dictionary12500.mat';
experiment_result_path = strcat(experiment_path,'result.mat');

%% Generate Dictionary

Dictionary = generate_dictionary(video_mat_path,patchsize,stride,...
    n_basis_per_video_segment,dictionary_path,sparsity,store,colored);

%%
    
video_segment_list = cell(1,length(vfiles));

for file_index = 1:length(vfiles)
    disp('file_index: ');
    disp(file_index)
    
    file_path = strcat(separated_videos_path,vfiles(file_index).name);
    video_segment = load(file_path);
    video_segment = video_segment.array;
    if (~colored)
        video_segment = mean(video_segment,3);
    end
    video_segment_list{file_index} = video_segment;

end

%%
sigma_vec = [0 1 4 8 15 40]/255;
bump_length_vec = 1:5;

% uncomment if want to load saved dictionary
Dictionary_obj = load(dictionary_path);
Dictionary = Dictionary_obj.Dictionary;

mean_rmse_array = zeros(length(bump_length_vec),length(sigma_vec));
std_rmse_array = zeros(length(bump_length_vec),length(sigma_vec));

for bump_length_index = 1:length(bump_length_vec)
    bump_length = bump_length_vec(bump_length_index);
    
    for sigma_index = 1:length(sigma_vec)
        sigma = sigma_vec(sigma_index);
        
        disp('bump_length: ')
        disp(bump_length);
        disp('sigma: ')
        disp(sigma);
        
        subexp_path = strcat(experiment_path,num2str(bump_length),'_',int2str(sigma_index),'/');
        mkdir(subexp_path)
        coded_image_list = cell(1,length(vfiles));
        reconstructed = cell(1,length(vfiles));
        rmse = cell(1,length(vfiles));
        val = zeros(length(reconstructed),1);
        
        coded_image_list_path = strcat(subexp_path,'/coded_image_list.mat');
        reconstructed_list_path = strcat(subexp_path,'/reconstructed_list.mat');
        rmse_list_path = strcat(subexp_path,'/rmse_list.mat');

        for file_index = 1:length(vfiles)
            disp('file_index: ')
            disp(file_index);
            
            [coded_image, sampling_matrix] = gen_coded_img(video_segment_list{file_index}, bump_length, sigma);
            coded_image_list{file_index} = coded_image;
        
            vd = reconstruct(Dictionary,coded_image,sampling_matrix,...
                temporal_depth,patchsize,stride,sparsity);

            reconstructed{file_index} = reshape(vd.*(vd>0),size(video_segment_list{file_index}))/...
                 max(vd,[],'all');

            rmse{file_index} = sum((reconstructed{file_index} - video_segment_list{file_index})...
                .^2,'all')/sum(video_segment_list{file_index}.^2,'all');
            val(file_index)=rmse{file_index}
        end
        
        if (store)
            save(coded_image_list_path,'coded_image_list','-v7.3');
            save(reconstructed_list_path,'reconstructed_list','-v7.3');
            save(rmse_list_path,'rmse_list','-v7.3');
        end
        
        mean_rmse_array(bump_length_index,sigma_index) = mean(val);
        std_rmse_array(bump_length_index,sigma_index) = std(val);
    end
end

save(experiment_result_path,'mean_rmse_array','std_rmse_array','-v7.3');


