%% EE 771 Project : Reducing Spatio-temporal tradeoff

clear;
clc;
close all;

%% Global Variables

file_path = '../data/final.mp4';
v = VideoReader(file_path);
temporal_depth = 36;
subsampling_rate = 2;
img_height = floor(v.H/subsampling_rate);
img_width = floor(v.W/subsampling_rate);
img_size = [img_height, img_width,];
total_frames = floor(v.D*v.FR);
sparsity = 40;
patchsize = 8;
stride = patchsize;
N_videos = 20;
bump_length = 3;
n_basis_per_video_segment = 625;

video_mat_path = '../data/Videos20.mat';
dictionary_path = '../data/Dictionary12500.mat';

store = 0;    % change to store generated dictionare, coded images etc
colored = 0;  % change for colored images

%% Reading Video Segments and Data Preprocessing

% C = randi([0,total_frames-temporal_depth],1,N_videos);
% Data = zeros(N_videos,img_height,img_width,3,temporal_depth);
% 
% for i = 1:N_videos
%     i
%     video_segment = read(v,[C(i),C(i)+temporal_depth-1]);
%     Data(i,:,:,:,:) = video_segment(1:subsampling_rate:end,1:subsampling_rate:end,:,:);    
% end
% 
% save(video_mat_path,'Data','-v7.3');

%% Genrate Dictionary

Dictionary = generate_dictionary(video_mat_path,patchsize,stride,n_basis_per_video_segment,dictionary_path,sparsity,store,colored);

%% Generate coded aperture images

separated_videos_path = '../data/separated_videos20/';
vfiles = dir (strcat(separated_videos_path,'/*.mat'));

samp_mat_list = cell(1,length(vfiles));
coded_image_list = cell(1,length(vfiles));
video_segment_list = cell(1,length(vfiles));

for file_index = 1:length(vfiles)
    file_index
    file_path = strcat(separated_videos_path,vfiles(file_index).name);
    video_segment = load(file_path);
    video_segment = video_segment.array;
    if (~colored)
        video_segment = mean(video_segment,3);
    end
    [coded_image, sampling_matrix] = gen_coded_img(video_segment, bump_length);
    
    samp_mat_list{file_index} = sampling_matrix;
    coded_image_list{file_index} = coded_image;
    video_segment_list{file_index} = video_segment;
end

samp_mat_array_path = '../data/samp_mat_array.mat';
coded_image_array_path = '../data/coded_image_array.mat';

% save(samp_mat_array_path,'samp_mat_array','-v7.3');
% save(coded_image_array_path,'coded_image_array','-v7.3');

%% Patchwise Reconstruction

% uncomment if want to load saved dictionary
Dictionary_obj = load(dictionary_path);
Dictionary = Dictionary_obj.Dictionary;

% uncomment if want to load coded images and sampling matrices
% samp_mat_obj = load(samp_mat_array_path);
% samp_mat_array = samp_mat_obj.samp_mat_array;
% coded_image_obj = load(coded_image_array_path);
% coded_image_array = coded_image_obj.samp_mat_array;

reconstructed = cell(1,length(vfiles));
rmse = cell(1,length(vfiles));
for vindex = 1:length(coded_image_list)
    vindex
    reconstructed{vindex} = reconstruct(Dictionary,coded_image_list{vindex},samp_mat_list{vindex},temporal_depth,patchsize,stride,sparsity);
    rmse{vindex} = sum((reconstructed{vindex} - video_segment_list{vindex}).^2,'all')/sum(video_segment_list{vindex}.^2,'all');
    sprintf('The Relative MSE for reconstruction of %d th video is %f', vindex ,rmse{vindex});
end

