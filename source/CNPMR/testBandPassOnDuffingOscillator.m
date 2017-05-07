% create multivariate AR model
m=1;
c=0.5;
k1=1;
k3=0.3;
Ts=0.02;
sigma=0.1;
ynext = @(yprevious1,yprevious2,xprevious2)(2-0.5*Ts)*yprevious1-(1-0.5*Ts+Ts^2)*yprevious2-k3*Ts^2*yprevious2^3+Ts^2*xprevious2+normrnd(0,sigma);
xnext = @(k) 5*sin(k/2)+normrnd(0,sigma);

% generate 1000 samples
signalLength = 1000;
historyLength = 2;
y=zeros(1,signalLength + historyLength);
x=zeros(1,signalLength + historyLength);
for i=(historyLength+1):(signalLength + historyLength)
    y(i)=ynext(y(i-1),y(i-2),x(i-2));
    x(i)=xnext(i);
end
y=y((historyLength+1):(signalLength + historyLength));
x=x((historyLength+1):(signalLength + historyLength));

% plot
frequencies = linspace(0,1,signalLength/2);
subplot(2,2,1)
plot(x)
xlabel('t')
title('signal x')
subplot(2,2,2)
plot(y)
xlabel('t')
title('signal y')
subplot(2,2,3)
xfft=fft(x);
plot(frequencies,log(abs(xfft(1:(signalLength/2)))))
xlabel('f')
ylabel('log(A)')
title('fft of x')
subplot(2,2,4)
yfft=fft(y);
plot(frequencies,log(abs(yfft(1:(signalLength/2)))))
xlabel('f')
ylabel('log(A)')
title('fft of y')