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

store = 0;
colored = 0;  %change for colored
Dictionary = generate_dictionary(video_mat_path,patchsize,stride,n_basis_per_video_segment,dictionary_path,sparsity,store,colored);

%% Generate coded aperture images

separated_videos_path = '../data/separated_videos20/';
vfiles = dir (strcat(separated_videos_path,'/*.mat'));

samp_mat_array = [];
coded_image_array = [];
video_segment_array = [];
for file_index = 1:length(vfiles)

    file_path = strcat(separated_videos_path,vfiles(file_index).name);
    video_segment = load(file_path);
    video_segment = video_segment.array;
    if (~colored)
        video_segment = mean(video_segment,3);
    end
    [sampling_matrix, coded_image] = gen_sampling_matrix(video_segment, bump_length);
    
    samp_mat_array = [samp_mat_array sampling_matrix];
    coded_image_array = [coded_image_array coded_image];
    video_segment_array = [video_segment_array video_segment];
end

samp_mat_array_path = '../data/samp_mat_array.mat';
coded_image_array_path = '../data/coded_image_array.mat';

% save(samp_mat_array_path,'samp_mat_array','-v7.3');
% save(coded_image_array_path,'coded_image_array','-v7.3');

%% Patchwise Reconstruction

% uncomment if want to load saved dictionary
% Dictionary_obj = load(dictionary_path);
% Dictionary = Dictionary_obj.Dictionary;

% uncomment if want to load coded images and sampling matrices
% samp_mat_obj = load(samp_mat_array_path);
% samp_mat_array = samp_mat_obj.samp_mat_array;
% coded_image_obj = load(coded_image_array_path);
% coded_image_array = coded_image_obj.samp_mat_array;

reconstructed = [];
rmse = [];
for vindex = 1:length(coded_image_array,1)

    reconstructed = [reconstructed reconstruct(coded_image_array(vindex),samp_mat_array(vindex))];
    rmse = [rmse sum((reconstructed - video_segment_array(vindex)).^2,'all')/sum(video_segment_array(vindex).^2,'all');];
    sprintf('The Relative MSE for reconstruction of %d th video is %f', vindex ,rmse);
end
