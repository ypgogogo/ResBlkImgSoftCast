function [outputSquare] =setSquare(image)
%UNTITLED10 此处显示有关此函数的摘要
%   此处显示详细说明
bh=8;
bw=128;
    x=[];
    y=[];
    lossnum=8;
    for ii = 1:lossnum
         for jj = 1:lossnum
                currentBlock = image((ii-1)*bh+1:ii*bh,(jj-1)*bw+1:jj*bw);
                x = [x,currentBlock];%64*12288:把currentBlock按列组成一行1*（bh*bw）
                if mod(jj,2)==0
                    y = [y;x];
                    x = [];
                end
         end
    end
outputSquare = y;
end

