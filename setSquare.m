function [outputSquare] =setSquare(image)
%UNTITLED10 �˴���ʾ�йش˺�����ժҪ
%   �˴���ʾ��ϸ˵��
bh=8;
bw=128;
    x=[];
    y=[];
    lossnum=8;
    for ii = 1:lossnum
         for jj = 1:lossnum
                currentBlock = image((ii-1)*bh+1:ii*bh,(jj-1)*bw+1:jj*bw);
                x = [x,currentBlock];%64*12288:��currentBlock�������һ��1*��bh*bw��
                if mod(jj,2)==0
                    y = [y;x];
                    x = [];
                end
         end
    end
outputSquare = y;
end

