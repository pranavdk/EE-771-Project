%% Reading Video and taking time stamps

% Ensure that folder containing mmread.m is in matlab path. Replace file
% path with the path of your cars.avi file

file_path = '../data/cars.avi';

% Uncomment the below line to read video.
video = mmread(file_path,[],[],false,true); %read all frames, disable audio

%movie(video.frames)

T_array = [3 5 7];

for T = T_array
    
    frames_struct = (video.frames(1:T));
    frames = zeros(288,352,T);
    for i = 1 : T
       frames(:,:,i) = rgb2gray(frames_struct(i).cdata);
    end
    X_base = 150;
    Y_base = 100;
    height = 120;
    width =  240;
    crop_frames = frames(X_base+1:X_base + height,Y_base+1 : Y_base + width,:);

    for i = 1:T
        figure('Name',strcat('Original Image: frame no. ',int2str(i)));
        imshow(mat2gray(crop_frames(:,:,i)));
    end 
    %% Creating a random code pattern and calculating coded screenshot.

    [H, W, ~] = size(crop_frames);
    C = randi([0,1],H,W,T);
    prod = crop_frames .* C + normrnd(0,2,[H,W]);
    coded_frame = double(sum(prod,3));
    figure;
    imshow(mat2gray(coded_frame))

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
