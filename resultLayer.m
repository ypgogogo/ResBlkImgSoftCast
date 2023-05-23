%% 不丢块
% SNR=5;PSNR=32.89
% min: 31.72
PSNR1=[31.49,32.12,32.71,32.75,30.80];
% PSNR2=[36.1,37,37.3,37.35,35.73];
PSNR3=[40.60,41.42,41.83,41.86,40.82];

% O(tmnK) ;

On=[1,2,3,4,5]

figure(1);plot(On,PSNR3,'-r',On,PSNR1,'-b');
legend('SNR=15dB','SNR=5dB','Location','southeast');ylabel('PSNR');xlabel('级数');
On=[2,3,4,5]
O=[2,3,4,5];
set(get(gca,'XLabel'),'FontSize',7.5,'FontName','TimesNewRoman');
  set(get(gca,'YLabel'),'FontSize',7.5,'FontName','TimesNewRoman');
  set(gca,'FontSize',7.5,'FontName','TimesNewRoman');
  legend("FontName","TimesNewRoman","FontSize",7.5,"LineWidth",1); 
figure(2);plot(On,O,'-r');
ylabel('O(x)');xlabel('级数')






