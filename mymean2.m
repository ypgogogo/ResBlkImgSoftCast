function [outputArg1] = mymean2(image)
%UNTITLED9 �˴���ʾ�йش˺�����ժҪ
%   �˴���ʾ��ϸ˵��
image=image.*image;
outputArg1 = sum(image(:));

end