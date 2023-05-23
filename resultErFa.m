% snr=5,32.89
% 0代表第一级别功率全给第三级别，1代表第一级别功率一点儿也不给第三级别（即等功率分配）
PSNR=[17,18,19,20.2,21.4,22.7,24,25.4,26.8,28.25,29,29.9,30.8,31.3,31.8,32.3,32.6,32.71,32.9,32.8,32.75];
PSNR1=[17,17.9,19,20.2,21.4,22.7,24,25.4,26.8,27.95,29,29.9,30.6,31.3,31.8,32.18,32.52,32.81,32.87,32.80,32.6];
PSNR2=[26.65,28.4,30.1,32,33.95,35.5,36.95,38,39.0,39.78,40.5,41,41.40,41.62,41.74,41.84,41.92,42.0,42.04,41.94,41.83];
% PSNR2=[26.8,27.2,28.4,29.6,31,34,36.2,37.5,39,40,40.25,40.8,41.1,41.4,41.65,41.78,41.88,42.0,42.04,41.80,41.6];
% erfa=[0.02,0.1,0.35];8
% erfa=[24,124,368,1680,1880];
% 
% erfa=[0.02,0.1,0.35];

erfa=0:0.05:1
figure(1);plot(erfa,PSNR2,'-r',erfa,PSNR1,'-b');
 set(get(gca,'XLabel'),'FontSize',12,'FontName','TimesNewRoman');
  set(get(gca,'YLabel'),'FontSize',12,'FontName','TimesNewRoman');
  set(gca,'FontSize',12,'FontName','TimesNewRoman');
  
  legend("FontName","TimesNewRoman","FontSize",12,"LineWidth",1); 
    set(gca,'looseInset',[0.08 0.08 0.08 0.08]);
    axis( [0 1 15 45] )
     set(gca,'xtick',0:0.1:1) 
legend('SNR=15dB','SNR=5dB','Location','southeast');ylabel('平均PSNR');xlabel('\alpha')