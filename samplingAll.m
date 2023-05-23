clc;
clear all;
close all;
for i=1:1
%     picname=['E:\Code\SoftCast\code\allCode\image\allImage\Remote\image\' num2str(i) '.tif'];
 picname=['E:\Code\SoftCast\code\allCode\image\512\lake\lake.tiff'];
t=imread('E:\Code\SoftCast\code\allCode\image\512\lake\lake.tif');
% t=rgb2gray(imread('E:\Code\SoftCast\code\allCode\Remote\24.tiff'));
t1=t;%�Ҷ�ͼ��
% t1=rgb2gray(t)%��ɫͼ��
% imshow(t1),title('ԭͼ') %ԭͼ�� ��Ҫ������ת��Ϊ�Ҷ�ͼ��
k=8;      %������С�Ŵ���  
tt=imresize(t1,1/k,'bicubic')%��Сk��,Ĭ��bicubic;����ݣ�ע�⣺��һ����Ĭ�ϲ���ֵ�����翹��ݵ�

% imwrite(uint8(tt),['E:\Code\SoftCast\code\allCode\image\allImage\Remote\downImage\' num2str(i) '.bmp'])
imwrite(uint8(tt),['E:\Code\SoftCast\code\allCode\image\512\lake\lake8.bmp'])
end
% k=2,4,8,16
% tt=t1(1:k:end,1:k:end)
% figure,subplot(2,2,1),imshow(t2),title('1:2����')
% subplot(2,2,2),imshow(t3),title('1:4����')
% subplot(2,2,3),imshow(t4),title('1:8����')
% subplot(2,2,4),imshow(t5),title('1:16����')
% % % % % % % % % % % % % % % % % % % % % 

f=tt;                 %���÷Ŵ���  
nearest =imresize(f,k,'nearest');%����ڲ�ֵ�㷨 f����k��
bilinear =imresize(f,k,'bilinear');%˫���Բ�ֵ����Ƚ�  
bicubic =imresize(f,k,'bicubic');%˫���β�ֵ�㷨

nearest =uint8(nearest); 
bilinear =uint8(bilinear); 
bicubic =uint8(bicubic); 

figure
subplot(2,2,1)
imshow(t1),title('ԭͼ')

subplot(2,2,2)
PSNRnearest = 20*log10(255/sqrt(mean((nearest(:)-t1(:)).^2)));
imshow(nearest,[]);title(strcat(['����ڲ�ֵ�㷨',num2str(PSNRnearest),'dB']));

subplot(2,2,3)
PSNRbilinear = 20*log10(255/sqrt(mean((bilinear(:)-t1(:)).^2)));
imshow(bilinear,[]);title(strcat(['˫���Բ�ֵ����Ƚ�',num2str(PSNRbilinear),'dB']));

subplot(2,2,4)
PSNRbicubic = 20*log10(255/sqrt(mean((bicubic(:)-t1(:)).^2)));
imshow(bicubic,[]);title(strcat(['˫���β�ֵ�㷨',num2str(PSNRbicubic),'dB']));

%�в�
figure;
imgH=t1-bicubic;
imshow(imgH);
%DCT�任
J = dct2(t1);
figure
imshow(log(abs(J)),[])
title('ԭͼDCT');
%colormap(gca,jet(64))
colormap(gray(4))
colorbar

J1 = dct2(imgH);
figure
imshow(log(abs(J1)),[])
title('�в�DCT');
%colormap(gca,jet(64))
colormap(gray(4))
colorbar

