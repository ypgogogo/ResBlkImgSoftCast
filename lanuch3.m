clc;
clear all;
close all;
% image_ori=double(rgb2gray(imread('E:\Code\SoftCast\code\allCode\Remote\24.tiff')));%读取原图
% imgge_digital_down=double(imread('E:\Code\SoftCast\code\allCode\Remote\digital32Remote24.bmp'));%读取下采样图像经过H.264/H.265编码解码后图像
% image_ori=double(imread('E:\Code\SoftCast\code\allCode\image\256\clock\clock.pgm'));%读取原图
% imgge_digital_down=double(imread('E:\Code\SoftCast\code\allCode\image\256\cameraman\cameraman.pgm'));%读取下采样图像经过H.264/H.265编码解码后图像
%% % % imgge_digital_down=double(imread('E:\Code\SoftCast\code\allCode\image\51\lena\peppers8.bmp'));%读取下采样图像经过H.264/H.265编码解码后图像
% imgge_digital_down2=double(imread('E:\Code\SoftCast\code\allCode\image\256\clock\clock8.bmp'));%读取下采样图像经过H.264/H.265编码解码后图像
% image_ori=double(rgb2gray(imread('airport.bmp')));%读取原图
%新图是否需要下采样
% k=16;      %设置缩小放大倍数  
% tt=imresize(t1,1/k,'bicubic')%缩小k倍,默认bicubic;抗锯齿，注意：有一部分默认参数值，例如抗锯齿等
% imwrite(uint8(tt),'E:\Code\SoftCast\code\allCode\1.bmp')

% imgge_digital_down=double(rgb2gray(imread('digital265airportqp28.bmp')));%读取下采样图像经过H.264/H.265编码解码后图像
img_digital_up =imresize(imgge_digital_down2,8,'bicubic');%将H.264/H.265编码解码后图像上采样至原图大小
% img_digital_up=imgge_digital_down2;
img_can=double(image_ori)-double(img_digital_up);%残差=原图-上采样后图像，此残差为softcast输入图像
% imwrite(uint8(img_can),'E:\Code\SoftCast\code\digital\Remote12_can.bmp')
% snr=0;%SNR
iter=1%求平均PSNR时迭代次数
%  跑10次求PSNR均值
%  PSNR的值与残差softcast后的PSNR值一致：因为残差为上采样图像与原图的差，与原图求PSNR时，仅有残差部分经SNR变化
%  img_can=uint8(img_can);%图像不清晰，因为uint8后img_can与原can差距大，恢复后差距大，其PSNR不仅是softcast部分决定了
PSNRrecOriSoftAvg=[];PSNRrecGlobalAvg=[];PSNRrecBlockAvg=[];PSNRrecDepthAvg=[];
SSIMrecOriSoftAvg=[];SSIMrecGlobalAvg=[];SSIMrecBlockAvg=[];SSIMrecDepthAvg=[];
discard=0;
nnSNR=10;
snrindex= 5:5:25;
for kk=1:length(snrindex)%看图时，此层for不要
    snr=snrindex(kk);
    PSNRallOriSoft=0;PSNRallGlobal=0;PSNRallBlock=0;PSNRallDepth=0;
    SSIMallOriSoft=0;SSIMallGlobal=0;SSIMallBlock=0;SSIMallDepth=0;
    for ii=1:iter
        [psnr0,ssim0,img_rec0]=softcast_func(image_ori,snr,discard);%原始softcast，注意：输入为原图
        [psnr1,ssim1,img_rec1]=softcastGlobal_func(img_can,snr,discard);%分层+原始softcast
%         [psnr2,ssim2,img_rec2]=softcastBlock_func(img_can,snr,discard);%分层+改变：块DCT变换，大块变换后切割为小块，不减块均值
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
        
        img1=img_rec1+img_digital_up;%恢复图像=残差原始softcast后（循环最后一次）+上采样图像
        img2=img_rec2+img_digital_up;%恢复图像=残差块softcast后（循环最后一次）  +上采样图像
        %y:分层 b:分层(块) r:分层(块) 提取了ROI不等功率分配
        %         imwrite(uint8(img2),['E:\Code\SoftCast\code\ROI结果\b' num2str(snr) '.bmp']);
    end
    PSNRrecOriSoftAvg=[PSNRrecOriSoftAvg,double(PSNRallOriSoft/iter)];%原始DCT变换后PSNR
    PSNRrecGlobalAvg=[PSNRrecGlobalAvg,double(PSNRallGlobal/iter)];%全局DCT变换后PSNR
    PSNRrecBlockAvg=[PSNRrecBlockAvg,double(PSNRallBlock/iter)];%块DCT变换后PSNR
    PSNRrecDepthAvg=[PSNRrecDepthAvg,double(PSNRallDepth/iter)];%深度图DCT变换后PSNR
    SSIMrecOriSoftAvg=[SSIMrecOriSoftAvg double(SSIMallOriSoft/iter)];%原始DCT变换后SSIM
    SSIMrecGlobalAvg=[SSIMrecGlobalAvg,double(SSIMallGlobal/iter)];%全局DCT变换后SSIM
    SSIMrecBlockAvg=[SSIMrecBlockAvg,double(SSIMallBlock/iter)];%块DCT变换后SSIM
    SSIMrecDepthAvg=[SSIMrecDepthAvg,double(SSIMallBlock/iter)];%深度图DCT变换后SSIM
end
img0=img_rec0;%原始SoftCast
img1=img_rec1+img_digital_up;%恢复图像=残差原始softcast后（循环最后一次）+上采样图像
img2=img_rec2+img_digital_up;%恢复图像=残差块softcast后（循环最后一次）  +上采样图像
img3=img_rec3;
lastPSNRrecOriSoft = 20*log10(255/sqrt(mean((double((image_ori(:))-img0(:)).^2))));%最后一次全局DCT变换后PSNR
lastPSNRrecGlobal = 20*log10(255/sqrt(mean((double((image_ori(:))-img1(:)).^2))));%最后一次全局DCT变换后PSNR
lastPSNRrecBlock = 20*log10(255/sqrt(mean((double((image_ori(:))-img2(:)).^2))));%最后一次块DCT变换后PSNR
lastPSNRrecDepth = 20*log10(255/sqrt(mean((double((image_ori(:))-img3(:)).^2))));%最后一次块DCT变换后PSNR

figure
subplot(1,3,1)
imshow(uint8(image_ori));title('原图');
subplot(1,3,2)
imshow(uint8(img_digital_up));title('上采样');
subplot(1,3,3)
imshow(uint8(img_can));title('残差');
% imwrite(uint8(img_can),'E:\Code\SoftCast\code\allCode\cameraman_can.bmp')
% % imwrite(uint8(img0),['E:\Code\SoftCast\code\allCode\TotalResult\视觉效果\cameraman\丢块' num2str(discard) '\' num2str(nnSNR) '\softcast' num2str(lastPSNRrecOriSoft) '.bmp'])
% % imwrite(uint8(img1),['E:\Code\SoftCast\code\allCode\TotalResult\视觉效果\cameraman\丢块' num2str(discard) '\' num2str(nnSNR) '\2018Layerd' num2str(lastPSNRrecGlobal) '.bmp'])
% % imwrite(uint8(img2),['E:\Code\SoftCast\code\allCode\TotalResult\视觉效果\cameraman\丢块' num2str(discard) '\' num2str(nnSNR) '\proposed' num2str(lastPSNRrecBlock) '.bmp'])
% % imwrite(uint8(img3),['E:\Code\SoftCast\code\allCode\TotalResult\视觉效果\cameraman\丢块' num2str(discard) '\' num2str(nnSNR) '\2019Block' num2str(lastPSNRrecDepth) '.bmp'])
figure
subplot(2,3,1)
imshow(uint8(image_ori));title('原图');
subplot(2,3,2)
imshow(uint8(img0));title(strcat(['softcast恢复图像',num2str(lastPSNRrecOriSoft),'dB']));
subplot(2,3,3)
imshow(uint8(img1));title(strcat(['2018分层全局DCT恢复图像',num2str(lastPSNRrecGlobal),'dB']));
subplot(2,3,4)
imshow(uint8(img2));title(strcat(['proposed分层块DCT恢复图像',num2str(lastPSNRrecBlock),'dB']));
subplot(2,3,5)
imshow(uint8(img3));title(strcat(['2019分块DCT恢复图像',num2str(lastPSNRrecDepth),'dB']));