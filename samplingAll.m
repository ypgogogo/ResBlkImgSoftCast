clc;
clear all;
close all;
for i=1:1
%     picname=['E:\Code\SoftCast\code\allCode\image\allImage\Remote\image\' num2str(i) '.tif'];
 picname=['E:\Code\SoftCast\code\allCode\image\512\lake\lake.tiff'];
t=imread('E:\Code\SoftCast\code\allCode\image\512\lake\lake.tif');
% t=rgb2gray(imread('E:\Code\SoftCast\code\allCode\Remote\24.tiff'));
t1=t;%灰度图像
% t1=rgb2gray(t)%彩色图像
% imshow(t1),title('原图') %原图像 需要将其先转换为灰度图像
k=8;      %设置缩小放大倍数  
tt=imresize(t1,1/k,'bicubic')%缩小k倍,默认bicubic;抗锯齿，注意：有一部分默认参数值，例如抗锯齿等

% imwrite(uint8(tt),['E:\Code\SoftCast\code\allCode\image\allImage\Remote\downImage\' num2str(i) '.bmp'])
imwrite(uint8(tt),['E:\Code\SoftCast\code\allCode\image\512\lake\lake8.bmp'])
end
% k=2,4,8,16
% tt=t1(1:k:end,1:k:end)
% figure,subplot(2,2,1),imshow(t2),title('1:2采样')
% subplot(2,2,2),imshow(t3),title('1:4采样')
% subplot(2,2,3),imshow(t4),title('1:8采样')
% subplot(2,2,4),imshow(t5),title('1:16采样')
% % % % % % % % % % % % % % % % % % % % % 

f=tt;                 %设置放大倍数  
nearest =imresize(f,k,'nearest');%最近邻插值算法 f扩大k倍
bilinear =imresize(f,k,'bilinear');%双线性插值结果比较  
bicubic =imresize(f,k,'bicubic');%双三次插值算法

nearest =uint8(nearest); 
bilinear =uint8(bilinear); 
bicubic =uint8(bicubic); 

figure
subplot(2,2,1)
imshow(t1),title('原图')

subplot(2,2,2)
PSNRnearest = 20*log10(255/sqrt(mean((nearest(:)-t1(:)).^2)));
imshow(nearest,[]);title(strcat(['最近邻插值算法',num2str(PSNRnearest),'dB']));

subplot(2,2,3)
PSNRbilinear = 20*log10(255/sqrt(mean((bilinear(:)-t1(:)).^2)));
imshow(bilinear,[]);title(strcat(['双线性插值结果比较',num2str(PSNRbilinear),'dB']));

subplot(2,2,4)
PSNRbicubic = 20*log10(255/sqrt(mean((bicubic(:)-t1(:)).^2)));
imshow(bicubic,[]);title(strcat(['双三次插值算法',num2str(PSNRbicubic),'dB']));

%残差
figure;
imgH=t1-bicubic;
imshow(imgH);
%DCT变换
J = dct2(t1);
figure
imshow(log(abs(J)),[])
title('原图DCT');
%colormap(gca,jet(64))
colormap(gray(4))
colorbar

J1 = dct2(imgH);
figure
imshow(log(abs(J1)),[])
title('残差DCT');
%colormap(gca,jet(64))
colormap(gray(4))
colorbar

