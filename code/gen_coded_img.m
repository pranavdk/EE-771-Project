function [coded_img] = gen_coded_img(video, sampling_matrix)
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here
    coded_img = sampling_matrix.*video;
    coded_img = mean(coded_img, 4);
end

