function [outputPSNR,outputSSIM,img_rec] = softcastDepth_func(img,snr_in,lostBlock)
%UNTITLED �˴���ʾ�йش˺�����ժҪ
%   �˴���ʾ��ϸ˵��
% ����;ԭʼͼ��
% ���:PSNR,SSIM
img_ori=img;
[height,width] = size(img_ori);
img_ori=double(img_ori);
k=1;
para=0;%Ԥ����ԭʼͼƬȫ�ּ�ȥpara������ֵ�����ն˼�para;
if height==1024
    dctBlockNum=32;%��DCT�任��СdctBlockNum*dctBlockNum%clock 32 cameraman 32  airport 32/64
    blockSize=32;
end
if height==512
    dctBlockNum=8;%��DCT�任��СdctBlockNum*dctBlockNum%clock 32 cameraman 32  airport 32/64
    blockSize=8;
end
if height==256
    dctBlockNum=8;%��DCT�任��СdctBlockNum*dctBlockNum%clock 32 cameraman 32  airport 32/64
    blockSize=8;
end
bw = blockSize;
bh = blockSize;
blockNum=(width/blockSize)*(height/blockSize);

discardNum=0;
discardNum=blockNum*lostBlock;%�������������yangpeng  ��SNR�£���PSNR����Ӱ�첻��

psnr=[];psnr_cloud=[];SSIM=[];SSIM1=[];
for lossnum=width/blockSize
    %% encoder
    imgBlockMean=blkproc(img_ori,[dctBlockNum dctBlockNum],@blockMean);
    imgSubMean=blkproc(img_ori,[dctBlockNum dctBlockNum],@blockSubMean);
    x_dct=blockDCT_func(imgSubMean-para,dctBlockNum);%��DCT�任�Ŀ��С32*32��
% %     ���ֿ�Zscan,dctBlockNum*dctBlockNum<=height;
    x_dct=blkproc(x_dct,[dctBlockNum dctBlockNum],@zigzagToone,k,dctBlockNum*dctBlockNum/k);%Zɨ��32*32-��1*1024
    x_dct=setSquare2(x_dct,dctBlockNum,height,k);%��8*128Ϊһ��������װΪ256*256��
%     x_dct = dct2(img_ori-para);
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
    
    P1 =  1;
    P = P1*lossnum*lossnum;%total power constraint
    lamda = mean((x.*x)');%ÿ��Ԫ���ڸ�λ����ƽ����ת�ú���ÿ�е�ƽ���͵�ƽ��ֵ��ÿ�����ƽ����ƽ��ֵ��
%%%%%%%%%%%%%%  ��   yangpeng add:discard block  �� %%%%%%%%%%%%%%
     [lamda_sort,lamda_index]=sort(lamda);%�Ԧ����򣬱������ǰλ�ã�lamda����DCTϵ��ƽ����ƽ��ֵ
      discardIndex=lamda_index(:,1:discardNum);%����������
%%%%%%%%%%%%%%   ��                            ��   %%%%%%%%%%%%%%
    lamda = lamda';
   g =sqrt(P/sum(sqrt(lamda)))./sqrt(sqrt(lamda));%softcastÿ�����gi����=��DCTϵ����ƽ����
%   g = sqrt(P/sum(sqrt(block_lamda)))./sqrt(sqrt(block_lamda));%softcastÿ�����gi����=��DCTϵ���ķ���
 
  
    C = diag(g);
    y=C*x;
    %% awgn channel
    snrindex=snr_in;
    for kk=1:length(snrindex)
            snr=snrindex(kk);
            Ps = 1;
            noise_pow = Ps * 10^(-snr/10);
            noisy = sqrt(noise_pow)*randn(size(y));
            ynoisy = y + noisy;
    %% decoder
%             y_llse = diag(lamda)*C'*inv(C*diag(lamda)*C'+noise_pow)*ynoisy;
            for ii=1:block_usedNum
                y_llse(ii,:)=g(ii)*lamda(ii)/(g(ii)^2*lamda(ii)+noise_pow)*ynoisy(ii,:);%�ָ�DCTϵ��
% % % % % % % % % ��yangpeng ���ڶ�����Ŀ��ڽ��ն�DCTϵ��ȫ��Ϊ0��% % % % % % % % % % % %
                for jj=1:discardNum
                     if discardIndex(jj)==ii
                         y_llse(ii,:)=0*ynoisy(ii,:);
                         break;
                     end
                end
% % % % % % % % % �����ڶ�����Ŀ��ڽ��ն�DCTϵ��ȫ��Ϊ0��% % % % % % % % % % % %
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
%             figure
%             imshow(log(abs(z1)),[])
%             colormap(gca,jet(64))
%             colorbar
            
            z1= splitSquare2(z1,height,dctBlockNum,k);
             z1=blkproc(z1,[k dctBlockNum*dctBlockNum/k],@oneToinvzigzag,dctBlockNum,dctBlockNum);%Zɨ��
            
            xx=blockIDCT_func(z1,dctBlockNum)+para;
            fillMean=blkproc(imgBlockMean,[1 1],@fillMatrix,dctBlockNum,dctBlockNum);
            xx=xx+fillMean;
%            figure
%            imshow(uint8(xx));
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
