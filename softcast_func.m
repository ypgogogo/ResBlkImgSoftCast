function [outputPSNR,outputSSIM,img_rec] = softcast_func(img,snr_in,lostBlock)
%UNTITLED �˴���ʾ�йش˺�����ժҪ
%   �˴���ʾ��ϸ˵����������ͬsoftcastGlobal
% ����;ԭʼͼ��
% ���:PSNR,SSIM

% 2021.11.1
% test on limit bandwidth0
%% 

img_ori=img;
[height,width] = size(img_ori);
img_ori=double(img_ori);
if height==1024
    blockSize=32;
end
if height==512
    blockSize=8;
end
if height==256
    blockSize=8;
end
bw = blockSize;
bh = blockSize;
blockNum=(width/blockSize)*(height/blockSize);
para=0;%Ԥ����ԭʼͼƬȫ�ּ�ȥpara������ֵ�����ն˼�para;
% discardNum=0;
discardNum=blockNum*lostBlock;%�������������yangpeng  ��SNR�£���PSNR����Ӱ�첻��
psnr=[];psnr_cloud=[];SSIM=[];SSIM1=[];
for lossnum=width/blockSize
    %% encoder
    x_dct = dct2(img_ori-para);
%       x_dct = dct2(img_ori);
    x=[];block_usedNum=lossnum*lossnum;
    for ii = 1:lossnum
         for jj = 1:lossnum
                currentBlock = x_dct((ii-1)*bh+1:ii*bh,(jj-1)*bw+1:jj*bw);
                x = [x;reshape(currentBlock,1,bh*bw)];%64*12288:��currentBlock�������һ��1*��bh*bw��
         end
    end

    % �������G PA
    
% % % % % % % % % % % % % ��    yangpeng  bolok var ��% % % % % % % % % % %% 
    block_mean=mean(x,2);%xÿ�еľ�ֵ������DCTϵ���ľ�ֵ
    block_devia=std(x,0,2)%��DCTϵ���ı�׼��
    block_lamda=block_devia.*block_devia;%��DCTϵ���ķ���       
% % % % % % % % % % % % % ��    yangpeng  bolok var ��% % % % % % % % % % %%   
    
    P1 =  1%mean(mean(x.*x));
    P = P1*lossnum*lossnum;%total power constraint
    lamda = mean((x.*x)');%ÿ��Ԫ���ڸ�λ����ƽ����ת�ú���ÿ�е�ƽ���͵�ƽ��ֵ��ÿ�����ƽ����ƽ��ֵ��
%%%%%%%%%%%%%%  ��   yangpeng add:discard block  �� %%%%%%%%%%%%%%
     [lamda_sort,lamda_index]=sort(lamda);%�Ԧ����򣬱������ǰλ�ã�lamda����DCTϵ��ƽ����ƽ��ֵ
      discardIndex=lamda_index(:,1:discardNum);%����������
%%%%%%%%%%%%%%   ��                            ��   %%%%%%%%%%%%%%
    lamda = lamda';
   
   g =sqrt(P/sum(sqrt(lamda)))./sqrt(sqrt(lamda));%softcastÿ�����gi����=��DCTϵ����ƽ����
%   g = sqrt(P/sum(sqrt(block_lamda)))./sqrt(sqrt(block_lamda));%softcastÿ�����gi����=��DCTϵ���ķ���
 
% % % % % ���ȥ���ֵ-yangpeng
      for ii=1:block_usedNum
          x(ii,:)=x(ii,:)-block_mean(ii);
      end
    C = diag(g);
    y=C*x;
    %% awgn channel
%     snrindex= 10:5:10;
    snrindex=snr_in;
    for kk=1:length(snrindex)
            snr=snrindex(kk);
            Ps = 1%mean(mean(y.*y));
            noise_pow = Ps * 10^(-snr/10);
            noisy = sqrt(noise_pow)*randn(size(y));
            ynoisy = y + noisy;
%             ynoisy=awgn(y,snr);
    %% decoder
%             y_llse = diag(lamda)*C'*inv(C*diag(lamda)*C'+noise_pow)*ynoisy;
            for ii=1:block_usedNum
                y_llse(ii,:)=g(ii)*lamda(ii)/(g(ii)^2*lamda(ii)+noise_pow)*ynoisy(ii,:);%�ָ�DCTϵ��
%                   y_llse(ii,:)=g(ii)*block_lamda(ii)/(g(ii)^2*block_lamda(ii)+noise_pow)*ynoisy(ii,:);%�ָ�DCTϵ��
%                    y_llse(ii,:)=ynoisy(ii,:)/g(ii);
% % % % % % % % % ��yangpeng ���ڶ�����Ŀ��ڽ��ն�DCTϵ��ȫ��Ϊ0��% % % % % % % % % % % %
                for jj=1:discardNum
                     if discardIndex(jj)==ii
                         y_llse(ii,:)=0*ynoisy(ii,:);
                         break;
                     end
                end
% % % % % % % % % �����ڶ�����Ŀ��ڽ��ն�DCTϵ��ȫ��Ϊ0��% % % % % % % % % % % %
            end
% % % % % ����Ͽ��ֵ-yangpeng
            for ii=1:block_usedNum
                y_llse(ii,:)=y_llse(ii,:)+block_mean(ii);
            end
          %% reshape 
            z1 = [];
            tt = [];
            for ii = 1:block_usedNum
                temp = y_llse(ii,:);
                currentBlock = reshape(temp,bh,bw);
                tt = [tt currentBlock];
                if mod(ii,lossnum) == 0 %�������
                    z1 = [z1;tt];
                    tt = [];
                end
            end
            
%             imshow(log(abs(z1)),[])
%             colormap(gca,jet(64))
%             colorbar
            
            xx=idct2(z1)+para;
%            for ii = 1 : size(xx,1)
%                 for jj = 1 : size(xx,2)
%                     if xx(ii,jj)>255
%                         xx1(ii,jj) = 255;
%                     elseif xx(ii,jj)<0
%                         xx1(ii,jj) = 0;
%                     else
%                       xx1(ii,jj)=round(xx(ii,jj));
% %                         xx1(ii,jj)=xx(ii,jj);
%                     end
%                 end
%            end
%            figure;
%            imshow(uint8(xx1));
          %% loc2
%           imwrite(uint8(xx1),['C:\Users\wu\Desktop\TMMimages\softcast\bodleian_1\softcastsnr' num2str(snr) '.bmp']);
           psnr= [psnr 20*log10(255/sqrt(mean((double(img_ori(:))-(xx(:))).^2)))]
           SSIM =[SSIM ssim(uint8(img_ori),uint8(xx))]
%            imwrite(uint8(xx1),'0dbqimg.jpg');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end
end
outputPSNR=psnr;
outputSSIM=SSIM;
img_rec=xx;
end