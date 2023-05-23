function [outputArg1] = mymean2(image)
%UNTITLED9 此处显示有关此函数的摘要
%   此处显示详细说明
image=image.*image;
outputArg1 = sum(image(:));

end