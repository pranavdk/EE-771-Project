function [sampling_matrix] = gen_sampling_matrix(temporal_depth, subsampling_rate, img_size, bump_length)
    %UNTITLED4 Summary of this function goes here
    %   Detailed explanation goes here
    img_size = floor(img_size/subsampling_rate);
    timemap = randi([1 temporal_depth], [img_size(1) img_size(2)]);
    sampling_matrix = zeros(img_size(1), img_size(2), temporal_depth);
    for i=1:img_size(1)
        for j = 1:img_size(2)
            for k = 1:bump_length
                ind = mod(timemap(i,j)-1+k-1, temporal_depth) + 1;
                sampling_matrix(i,j,ind) = 1;
            end
        end
    end
end

