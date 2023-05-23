function [outputSquare] =setSquare2(image,dctBlockNum,height,k)
%UNTITLED10 此处显示有关此函数的摘要
%   此处显示详细说明
if (dctBlockNum==32)&&(height==1024)
    [h,w] = size(image);
    nn=k;
    bh=k;
    bw=dctBlockNum*dctBlockNum/k;
    x=[];
    y=[];
    lossnum1=h/bh;
    lossnum2=w/bw;
    for ii = 1:lossnum1
        for jj = 1:lossnum2
            currentBlock = image((ii-1)*bh+1:ii*bh,(jj-1)*bw+1:jj*bw);
            x = [x,currentBlock];%64*12288:把currentBlock按列组成一行1*（bh*bw）
            if mod(jj,nn)==0
                y = [y;x];
                x = [];
            end
        end
    end
    outputSquare = y;
end

if (dctBlockNum==8||dctBlockNum==16||dctBlockNum==4)&&(height==256||height==512||height==1024)
    [h,w] = size(image);
    nn=height/(dctBlockNum*dctBlockNum);
    bh=k;
    bw=dctBlockNum*dctBlockNum/k;
    x=[];
    y=[];
    lossnum1=h/bh;
    lossnum2=w/bw;
    for ii = 1:lossnum1
        for jj = 1:lossnum2
            currentBlock = image((ii-1)*bh+1:ii*bh,(jj-1)*bw+1:jj*bw);
            x = [x,currentBlock];%64*12288:把currentBlock按列组成一行1*（bh*bw）
            if mod(jj,nn)==0
                y = [y;x];
                x = [];
            end
        end
    end
    outputSquare = y;
end

end

