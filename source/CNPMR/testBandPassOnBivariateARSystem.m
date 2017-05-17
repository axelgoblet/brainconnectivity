sigma = 0.003;

% create multivariate AR model
ynext = @(yprevious1,yprevious2,xprevious1,xprevious2)0.5*yprevious1-0.3*yprevious2+0.1*xprevious2+0.4*xprevious1*xprevious2+normrnd(0,sigma);
xnext = @(yprevious2,xprevious1,xprevious2)0.3*xprevious1-xprevious2-0.1*yprevious2+normrnd(0,sigma);

% generate 1000 samples
signalLength = 1000;
historyLength = 2;
y=zeros(1,signalLength + historyLength);
x=zeros(1,signalLength + historyLength);
y(1) = 1;
x(1) = 1;
for i=(historyLength+1):(signalLength + historyLength)
    y(i)=ynext(y(i-1),y(i-2),x(i-1),x(i-2));
    x(i)=xnext(y(i-2),x(i-1),x(i-2));
end
y=y((historyLength+1):(signalLength + historyLength));
x=x((historyLength+1):(signalLength + historyLength));

bandwidth = 0.1;
frequencies = linspace(bandwidth/1.99,10-bandwidth/1.99,500);

% plot
figure(1)
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

% find causalities over frequencies
causalities = arrayfun(@(frequency)CNPMR(y,x,[],1,3,1,1,[],false,0.5,[frequency-bandwidth/2,frequency+bandwidth/2],20), frequencies);
figure(2)
plot(frequencies,causalities)
xlabel('f')
ylabel('causality')
title('causality x-->y over frequency')

[c,~,s]=CNPMR(y,x,[],1,3,1,1,[],false,0.05,[4.45,4.55],20)
[c,~,s]=CNPMR(y,x,[],1,3,1,1,[],false,0.05)