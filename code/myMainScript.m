%% EE 771 Project : Reducing Spatio-temporal tradeoff

clear;
clc;
close all;

%% Global Variables

file_path = '../data/final.mp4';
v = VideoReader(file_path);
temporal_depth = 36;
img_height = v.H;
img_width = v.W;
total_frames = floor(v.D*v.FR);
subsampling_rate = 2;
sparsity = 40;
patchsize = 8;
stride = patchsize;
N_videos = 20;

% img_height = v.H/subsampling_rate;
% img_width = v.W/subsampling_rate;

%% Reading Video Segments and Data Preprocessing

% file_path = '../data/final.mp4';
% v = VideoReader(file_path);
% C = randi([0,total_frames-temporal_depth],1,N_videos);
% Data = zeros(N_videos,img_height/subsmapling_rate,img_width/subsmapling_rate,3,temporal_depth);
% 
% for i = 1:N_videos
%     i
%     video_segment = read(v,[C(i),C(i)+temporal_depth-1]);
%     Data(i,:,:,:,:) = video_segment(1:subsampling_rate:end,1:subsampling_rate:end,:,:);    
% end
% 
% save('../data/Videos20.mat','Data','-v7.3');

%% Genrate Dictionary


%% Generate coded aperture images



%% 



%% Patchwise Reconstruction

dictionary_path = '../data/Dictionary12500.mat';
Dictionary = load(dictionary_path);
Dictionary = Dictionary.Dictionary;
    
coded_images_path = '../data/bp2/';
files = dir (strcat(coded_images_path,'/*.mat'));

for file_indedx = 1:length(files)
    
    output = double(zeros(img_height,img_width,temporal_depth));
    count = double(zeros(img_height,img_width,temporal_depth));

    file_path = strcat(coded_images_path,files(file_indedx).name);
    coded_frame = load(file_path);
    coded_frame = mean(coded_frame.coded(1:subsampling_rate:end,1:subsampling_rate:end,:),3);   %grey
%     coded_frame = mean(coded_frame.coded,3);
    
%     Video_Data = ;

    for i = 1:stride:m
        for j = 1:stride:n
            
            % change these two lines
            temp = Video_Data(file_indedx,i:i+patchsize-1,j:j+patchsize-1,:,:);
            temp_size = size(temp);
            
            patch = coded_frame(i:i+patchsize-1,j:j+patchsize-1);
            patch_sensing_matrix = C(i:i+patchsize-1,j:j+patchsize-1,:); %% Yet to change
            
            theta = omp(Dictionary,patch(:),[],sparsity);
            f = Dictionary * theta;
            f = reshape(f,[patchsize,patchsize,1,temporal_depth]);  %1 for grey
            output(i:i+patchsize-1,j:j+patchsize-1,:) = output(i:i+patchsize-1,j:j+patchsize-1,:) + f;
            count(i:i+patchsize-1,j:j+patchsize-1,:) = count(i:i+patchsize-1,j:j+patchsize-1,:) + 1.0;  
            
        end 
    end
    
    reconstructed = imdivide(output,count);

end

% finding RMSE
MSE = sum(sum(sum((output - crop_frames).^2)))/(H*W*T);
X_bar = sum(sum(sum(crop_frames.^2)))/(H*W*T);

sprintf('The Relative MSE for reconstruction is %f' ,MSE / X_bar)




    %% Patchwise Reconstruction

    p = 8;
    iter = 40;
    D1 = dctmtx(p);
    D3 = dctmtx(T);
    output = double(zeros(H,W,T));
    output_2d = double(zeros(H,W,T));
    count = double(zeros(H,W,T));
    Psi_2d = kron(D1',D1');
    Psi = kron(D3',Psi_2d);
    s = p*p;
    for i = 1 : H - p + 1
        for j = 1 : W - p +1
            patch = coded_frame(i:i+p-1,j:j+p-1);
            patch_sensing_matrix = C(i:i+p-1,j:j+p-1,:);
            Phi =zeros(s,s*T);
            A_2d = zeros(s,s*T);
            for k = 1 : T
                temp = patch_sensing_matrix(:,:,k);
                Phi(:,(k-1)*s+1:k*s) = diag(temp(:)); 
                A_2d(:,(k-1)*s+1:k*s) = diag(temp(:)) * Psi_2d;
            end
            A = Phi * Psi;
            theta = myOMP(patch(:),A,iter);
            theta_2d = myOMP(patch(:),A_2d,iter);
            f_2d = reshape(theta_2d,[p,p,T]);
            for k = 1:T
               temp = f_2d(:,:,k);
               temp1 = Psi_2d * temp(:);
               f_2d(:,:,k) = reshape(temp1,[p,p]);
            end
            f = Psi * theta;
            f = reshape(f,[p,p,T]);
            output(i:i+p-1,j:j+p-1,:) = output(i:i+p-1,j:j+p-1,:) + f;
            output_2d(i:i+p-1,j:j+p-1,:) = output_2d(i:i+p-1,j:j+p-1,:) + f_2d;
            count(i:i+p-1,j:j+p-1,:) = count(i:i+p-1,j:j+p-1,:) + 1.0;        
        end
    end

    output = imdivide(output,count);
    output_2d = imdivide(output_2d,count);
    for i = 1:T
       figure('Name',strcat('Reconstructed Image using 3d DCT: frame no. ',int2str(i)));
       imshow(mat2gray(output(:,:,i)));
    end
    for i = 1:T
       figure('Name',strcat('Reconstructed Image using 2d DCT: frame no. ',int2str(i)));
       imshow(mat2gray(output(:,:,i)));
    end
    
    % finding MSE
    MSE = sum(sum(sum((output - crop_frames).^2)))/(H*W*T);
    X_bar = sum(sum(sum(crop_frames.^2)))/(H*W*T);
    sprintf('The Relative MSE for reconstruction using 3d DCT for T = %d is %f',T,MSE / X_bar)
    MSE = sum(sum(sum((output_2d - crop_frames).^2)))/(H*W*T);
    sprintf('The Relative MSE for reconstruction using 2d DCT for T = %d is %f',T,MSE / X_bar)
end
