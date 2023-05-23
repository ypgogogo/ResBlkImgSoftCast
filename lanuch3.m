clc;
clear all;
close all;
% image_ori=double(rgb2gray(imread('E:\Code\SoftCast\code\allCode\Remote\24.tiff')));%��ȡԭͼ
% imgge_digital_down=double(imread('E:\Code\SoftCast\code\allCode\Remote\digital32Remote24.bmp'));%��ȡ�²���ͼ�񾭹�H.264/H.265��������ͼ��
% image_ori=double(imread('E:\Code\SoftCast\code\allCode\image\256\clock\clock.pgm'));%��ȡԭͼ
% imgge_digital_down=double(imread('E:\Code\SoftCast\code\allCode\image\256\cameraman\cameraman.pgm'));%��ȡ�²���ͼ�񾭹�H.264/H.265��������ͼ��
%% % % imgge_digital_down=double(imread('E:\Code\SoftCast\code\allCode\image\51\lena\peppers8.bmp'));%��ȡ�²���ͼ�񾭹�H.264/H.265��������ͼ��
% imgge_digital_down2=double(imread('E:\Code\SoftCast\code\allCode\image\256\clock\clock8.bmp'));%��ȡ�²���ͼ�񾭹�H.264/H.265��������ͼ��
% image_ori=double(rgb2gray(imread('airport.bmp')));%��ȡԭͼ
%��ͼ�Ƿ���Ҫ�²���
% k=16;      %������С�Ŵ���  
% tt=imresize(t1,1/k,'bicubic')%��Сk��,Ĭ��bicubic;����ݣ�ע�⣺��һ����Ĭ�ϲ���ֵ�����翹��ݵ�
% imwrite(uint8(tt),'E:\Code\SoftCast\code\allCode\1.bmp')

% imgge_digital_down=double(rgb2gray(imread('digital265airportqp28.bmp')));%��ȡ�²���ͼ�񾭹�H.264/H.265��������ͼ��
img_digital_up =imresize(imgge_digital_down2,8,'bicubic');%��H.264/H.265��������ͼ���ϲ�����ԭͼ��С
% img_digital_up=imgge_digital_down2;
img_can=double(image_ori)-double(img_digital_up);%�в�=ԭͼ-�ϲ�����ͼ�񣬴˲в�Ϊsoftcast����ͼ��
% imwrite(uint8(img_can),'E:\Code\SoftCast\code\digital\Remote12_can.bmp')
% snr=0;%SNR
iter=1%��ƽ��PSNRʱ��������
%  ��10����PSNR��ֵ
%  PSNR��ֵ��в�softcast���PSNRֵһ�£���Ϊ�в�Ϊ�ϲ���ͼ����ԭͼ�Ĳ��ԭͼ��PSNRʱ�����вв�־�SNR�仯
%  img_can=uint8(img_can);%ͼ����������Ϊuint8��img_can��ԭcan���󣬻ָ��������PSNR������softcast���־�����
PSNRrecOriSoftAvg=[];PSNRrecGlobalAvg=[];PSNRrecBlockAvg=[];PSNRrecDepthAvg=[];
SSIMrecOriSoftAvg=[];SSIMrecGlobalAvg=[];SSIMrecBlockAvg=[];SSIMrecDepthAvg=[];
discard=0;
nnSNR=10;
snrindex= 5:5:25;
for kk=1:length(snrindex)%��ͼʱ���˲�for��Ҫ
    snr=snrindex(kk);
    PSNRallOriSoft=0;PSNRallGlobal=0;PSNRallBlock=0;PSNRallDepth=0;
    SSIMallOriSoft=0;SSIMallGlobal=0;SSIMallBlock=0;SSIMallDepth=0;
    for ii=1:iter
        [psnr0,ssim0,img_rec0]=softcast_func(image_ori,snr,discard);%ԭʼsoftcast��ע�⣺����Ϊԭͼ
        [psnr1,ssim1,img_rec1]=softcastGlobal_func(img_can,snr,discard);%�ֲ�+ԭʼsoftcast
%         [psnr2,ssim2,img_rec2]=softcastBlock_func(img_can,snr,discard);%�ֲ�+�ı䣺��DCT�任�����任���и�ΪС�飬�������ֵ
        [psnr3,ssim3,img_rec3]=softcastDepth_func(image_ori,snr,discard);
      [psnr2,ssim2,img_rec2]=softcastBlockWithROI_func(img_can,snr,0.25);
%       [psnr2,ssim2,img_rec2]=softcastBlockWithZscan_func(img_can,snr,0.25);
        PSNRallOriSoft=PSNRallOriSoft+psnr0;
        PSNRallGlobal=PSNRallGlobal+psnr1;
        PSNRallBlock=PSNRallBlock+psnr2;
        PSNRallDepth=PSNRallDepth+psnr3;
        SSIMallOriSoft=SSIMallOriSoft+ssim0;
        SSIMallGlobal=SSIMallGlobal+ssim1;
        SSIMallBlock=SSIMallBlock+ssim2;
        SSIMallDepth=SSIMallDepth+ssim3;
        
        img1=img_rec1+img_digital_up;%�ָ�ͼ��=�в�ԭʼsoftcast��ѭ�����һ�Σ�+�ϲ���ͼ��
        img2=img_rec2+img_digital_up;%�ָ�ͼ��=�в��softcast��ѭ�����һ�Σ�  +�ϲ���ͼ��
        %y:�ֲ� b:�ֲ�(��) r:�ֲ�(��) ��ȡ��ROI���ȹ��ʷ���
        %         imwrite(uint8(img2),['E:\Code\SoftCast\code\ROI���\b' num2str(snr) '.bmp']);
    end
    PSNRrecOriSoftAvg=[PSNRrecOriSoftAvg,double(PSNRallOriSoft/iter)];%ԭʼDCT�任��PSNR
    PSNRrecGlobalAvg=[PSNRrecGlobalAvg,double(PSNRallGlobal/iter)];%ȫ��DCT�任��PSNR
    PSNRrecBlockAvg=[PSNRrecBlockAvg,double(PSNRallBlock/iter)];%��DCT�任��PSNR
    PSNRrecDepthAvg=[PSNRrecDepthAvg,double(PSNRallDepth/iter)];%���ͼDCT�任��PSNR
    SSIMrecOriSoftAvg=[SSIMrecOriSoftAvg double(SSIMallOriSoft/iter)];%ԭʼDCT�任��SSIM
    SSIMrecGlobalAvg=[SSIMrecGlobalAvg,double(SSIMallGlobal/iter)];%ȫ��DCT�任��SSIM
    SSIMrecBlockAvg=[SSIMrecBlockAvg,double(SSIMallBlock/iter)];%��DCT�任��SSIM
    SSIMrecDepthAvg=[SSIMrecDepthAvg,double(SSIMallBlock/iter)];%���ͼDCT�任��SSIM
end
img0=img_rec0;%ԭʼSoftCast
img1=img_rec1+img_digital_up;%�ָ�ͼ��=�в�ԭʼsoftcast��ѭ�����һ�Σ�+�ϲ���ͼ��
img2=img_rec2+img_digital_up;%�ָ�ͼ��=�в��softcast��ѭ�����һ�Σ�  +�ϲ���ͼ��
img3=img_rec3;
lastPSNRrecOriSoft = 20*log10(255/sqrt(mean((double((image_ori(:))-img0(:)).^2))));%���һ��ȫ��DCT�任��PSNR
lastPSNRrecGlobal = 20*log10(255/sqrt(mean((double((image_ori(:))-img1(:)).^2))));%���һ��ȫ��DCT�任��PSNR
lastPSNRrecBlock = 20*log10(255/sqrt(mean((double((image_ori(:))-img2(:)).^2))));%���һ�ο�DCT�任��PSNR
lastPSNRrecDepth = 20*log10(255/sqrt(mean((double((image_ori(:))-img3(:)).^2))));%���һ�ο�DCT�任��PSNR

figure
subplot(1,3,1)
imshow(uint8(image_ori));title('ԭͼ');
subplot(1,3,2)
imshow(uint8(img_digital_up));title('�ϲ���');
subplot(1,3,3)
imshow(uint8(img_can));title('�в�');
% imwrite(uint8(img_can),'E:\Code\SoftCast\code\allCode\cameraman_can.bmp')
% % imwrite(uint8(img0),['E:\Code\SoftCast\code\allCode\TotalResult\�Ӿ�Ч��\cameraman\����' num2str(discard) '\' num2str(nnSNR) '\softcast' num2str(lastPSNRrecOriSoft) '.bmp'])
% % imwrite(uint8(img1),['E:\Code\SoftCast\code\allCode\TotalResult\�Ӿ�Ч��\cameraman\����' num2str(discard) '\' num2str(nnSNR) '\2018Layerd' num2str(lastPSNRrecGlobal) '.bmp'])
% % imwrite(uint8(img2),['E:\Code\SoftCast\code\allCode\TotalResult\�Ӿ�Ч��\cameraman\����' num2str(discard) '\' num2str(nnSNR) '\proposed' num2str(lastPSNRrecBlock) '.bmp'])
% % imwrite(uint8(img3),['E:\Code\SoftCast\code\allCode\TotalResult\�Ӿ�Ч��\cameraman\����' num2str(discard) '\' num2str(nnSNR) '\2019Block' num2str(lastPSNRrecDepth) '.bmp'])
figure
subplot(2,3,1)
imshow(uint8(image_ori));title('ԭͼ');
subplot(2,3,2)
imshow(uint8(img0));title(strcat(['softcast�ָ�ͼ��',num2str(lastPSNRrecOriSoft),'dB']));
subplot(2,3,3)
imshow(uint8(img1));title(strcat(['2018�ֲ�ȫ��DCT�ָ�ͼ��',num2str(lastPSNRrecGlobal),'dB']));
subplot(2,3,4)
imshow(uint8(img2));title(strcat(['proposed�ֲ��DCT�ָ�ͼ��',num2str(lastPSNRrecBlock),'dB']));
subplot(2,3,5)
imshow(uint8(img3));title(strcat(['2019�ֿ�DCT�ָ�ͼ��',num2str(lastPSNRrecDepth),'dB']));