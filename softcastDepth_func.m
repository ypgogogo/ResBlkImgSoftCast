function [outputPSNR,outputSSIM,img_rec] = softcastDepth_func(img,snr_in,lostBlock)
%UNTITLED 此处显示有关此函数的摘要
%   此处显示详细说明
% 输入;原始图像；
% 输出:PSNR,SSIM
img_ori=img;
[height,width] = size(img_ori);
img_ori=double(img_ori);
k=1;
para=0;%预处理，原始图片全局减去para的像素值，接收端加para;
if height==1024
    dctBlockNum=32;%块DCT变换大小dctBlockNum*dctBlockNum%clock 32 cameraman 32  airport 32/64
    blockSize=32;
end
if height==512
    dctBlockNum=8;%块DCT变换大小dctBlockNum*dctBlockNum%clock 32 cameraman 32  airport 32/64
    blockSize=8;
end
if height==256
    dctBlockNum=8;%块DCT变换大小dctBlockNum*dctBlockNum%clock 32 cameraman 32  airport 32/64
    blockSize=8;
end
bw = blockSize;
bh = blockSize;
blockNum=(width/blockSize)*(height/blockSize);

discardNum=0;
discardNum=blockNum*lostBlock;%丢弃块的数量；yangpeng  低SNR下，对PSNR好像影响不大

psnr=[];psnr_cloud=[];SSIM=[];SSIM1=[];
for lossnum=width/blockSize
    %% encoder
    imgBlockMean=blkproc(img_ori,[dctBlockNum dctBlockNum],@blockMean);
    imgSubMean=blkproc(img_ori,[dctBlockNum dctBlockNum],@blockSubMean);
    x_dct=blockDCT_func(imgSubMean-para,dctBlockNum);%做DCT变换的块大小32*32；
% %     做分块Zscan,dctBlockNum*dctBlockNum<=height;
    x_dct=blkproc(x_dct,[dctBlockNum dctBlockNum],@zigzagToone,k,dctBlockNum*dctBlockNum/k);%Z扫描32*32-》1*1024
    x_dct=setSquare2(x_dct,dctBlockNum,height,k);%以8*128为一块重新组装为256*256；
%     x_dct = dct2(img_ori-para);
%       x_dct = dct2(img_ori);
    x=[];block_usedNum=lossnum*lossnum;
    for ii = 1:lossnum
         for jj = 1:lossnum
                currentBlock = x_dct((ii-1)*bh+1:ii*bh,(jj-1)*bw+1:jj*bw);
                x = [x;reshape(currentBlock,1,bh*bw)];%64*12288:把currentBlock按列组成一行1*（bh*bw）
         end
    end

    % 计算矩阵G PA
    
% % % % % % % % % % % % % ↓    yangpeng  bolok var ↓% % % % % % % % % % %% 
    block_mean=mean(x,2);%x每行的均值，即块DCT系数的均值
    block_devia=std(x,0,2)%块DCT系数的标准差
    block_lamda=block_devia.*block_devia;%块DCT系数的方差       
% % % % % % % % % % % % % ↑    yangpeng  bolok var ↑% % % % % % % % % % %%   
    
    P1 =  1;
    P = P1*lossnum*lossnum;%total power constraint
    lamda = mean((x.*x)');%每个元素在该位置做平方，转置后求每列的平方和的平均值：每个块的平方和平均值。
%%%%%%%%%%%%%%  ↓   yangpeng add:discard block  ↓ %%%%%%%%%%%%%%
     [lamda_sort,lamda_index]=sort(lamda);%对λ排序，标记排序前位置；lamda：块DCT系数平方和平均值
      discardIndex=lamda_index(:,1:discardNum);%丢弃块的序号
%%%%%%%%%%%%%%   ↑                            ↑   %%%%%%%%%%%%%%
    lamda = lamda';
   g =sqrt(P/sum(sqrt(lamda)))./sqrt(sqrt(lamda));%softcast每个块的gi：λ=块DCT系数的平方和
%   g = sqrt(P/sum(sqrt(block_lamda)))./sqrt(sqrt(block_lamda));%softcast每个块的gi；λ=块DCT系数的方差
 
  
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
                y_llse(ii,:)=g(ii)*lamda(ii)/(g(ii)^2*lamda(ii)+noise_pow)*ynoisy(ii,:);%恢复DCT系数
% % % % % % % % % ↓yangpeng 属于丢弃块的块在接收端DCT系数全置为0↓% % % % % % % % % % % %
                for jj=1:discardNum
                     if discardIndex(jj)==ii
                         y_llse(ii,:)=0*ynoisy(ii,:);
                         break;
                     end
                end
% % % % % % % % % ↑属于丢弃块的块在接收端DCT系数全置为0↑% % % % % % % % % % % %
            end

          %% reshape 
            z1 = [];
            tt = [];
            for ii = 1:block_usedNum
                temp = y_llse(ii,:);
                currentBlock = reshape(temp,bh,bw);
                tt = [tt currentBlock];
                if mod(ii,lossnum) == 0 %调整宽度
                    z1 = [z1;tt];
                    tt = [];
                end
            end
%             figure
%             imshow(log(abs(z1)),[])
%             colormap(gca,jet(64))
%             colorbar
            
            z1= splitSquare2(z1,height,dctBlockNum,k);
             z1=blkproc(z1,[k dctBlockNum*dctBlockNum/k],@oneToinvzigzag,dctBlockNum,dctBlockNum);%Z扫描
            
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
