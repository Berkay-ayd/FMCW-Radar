fs = 1e3;
tmax = 15;
tt = 0:1/fs:tmax-1/fs;
f0 = 10;
T = 1;
t = 0:1/fs:T-1/fs;
pls = cos(2*pi*f0*t);

t0 = 5;
dt = 2*T;
lgs = t0:dt:tmax;
att = 1.1;
ref = 0.2;
rpls = pulstran(tt,[lgs;ref*att.^-(lgs-t0)]',pls,fs);

SNR = 15;
r = randn(size(tt))*std(pls)/db2mag(SNR);
rplsnoise = r+rpls;

pls = chirp(t,0,T,f0,'complex');
rpls = pulstran(tt,[lgs;ref*att.^-(lgs-t0)]',pls,fs);
r = randn(size(tt))*std(pls)/db2mag(SNR);
rplsnoise = r + rpls;

[m,lg] = xcorr(rplsnoise,pls);
m = m(lg>=0);
tm = lg(lg>=0)/fs;

subplot(2,1,1)
plot(tt,real(r),t,real(pls),tt,real(rpls))
xticks(lgs)
legend('Noisy Received','Initial Pulse','Noiseless Received')
title('Transmitted/Received Signals')
ylabel('Magnitude (L.U.)')

subplot(2,1,2)
plot(tm,abs(m))
xticks(lgs)
title('Matched Filter Output')
xlabel('Time (s)')
ylabel('Magnitude (L.U.)')