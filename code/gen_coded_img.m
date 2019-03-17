function [coded_img,sampling_matrix] = gen_coded_img(video, bump_length)

    vsize = size(video);
    timemap = randi([1 vsize(4)], [vsize(1) vsize(2)]);
    sampling_matrix = zeros(vsize);
    
    for i=1:vsize(1)
        for j = 1:vsize(2)
            sampling_matrix(i,j,:,mod(timemap(i,j)-1+(0:bump_length-1), temporal_depth) + 1) = 1;
            
%             for k = 1:bump_length
%                 ind = mod(timemap(i,j)-1+k-1, temporal_depth) + 1;
%                 sampling_matrix(i,j,:,ind) = 1;
%             end
        end
    end
    
    coded_img = sampling_matrix.*video;
    coded_img = squeeze(mean(coded_img, 4));
    
end

