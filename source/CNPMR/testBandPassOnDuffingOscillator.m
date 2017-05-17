% create multivariate AR model
m=1;
c=0.5;
k1=1;
k3=0.3;
Ts=0.02;
sigma=0.1;

%% AR modeling or sinusoid
t=0:0.02:50;%sample time
xsam=5*sin(t);%sample sinusoid
n=15;%order 15

% calculate autocorrelation
R=zeros(size(xsam));
N=length(xsam);
for cnt=1:length(xsam)
    for k=1:N-(cnt-1)
        R(cnt)=R(cnt)+xsam(k)*xsam(k+(cnt-1));
    end
    R(cnt)=R(cnt)/N;
end
%autocorrelation for positive lags
r=R(2:end);
% autocorrelation at lag 0
r0=R(1);

% levinson algorithm
A=zeros(n,n);
sigma2=zeros(1,n);
A(1,1)=-1*r(1)/r0;
sigma2(1)=(1-A(1,1)^2)*r0;
for k=2:n
    A(k,k)=-1*(r(k)+A(k-1,1:k-1)*fliplr(r(1:k-1))')/sigma2(k-1);
    for i=1:k-1
        A(k,i)=A(k-1,i)+A(k,k)*A(k-1,k-i);
        sigma2(k)=(1-A(k,k)^2)*sigma2(k-1);
    end
end

a=-1*A(end,end:-1:1)'; % put it it the proper format


ynext = @(yprevious1,yprevious2,xprevious2)(2-0.5*Ts)*yprevious1-(1-0.5*Ts+Ts^2)*yprevious2-k3*Ts^2*yprevious2^3+Ts^2*xprevious2+normrnd(0,sigma);
xnext = @(x) x*a+normrnd(0,0.1);%sqrt(sigma2(end)));

% generate 1000 samples
signalLength = 100000;
historyLength = 15;
y=zeros(1,signalLength + historyLength);
x=zeros(1,signalLength + historyLength);
for i=(historyLength+1):(signalLength + historyLength)
    y(i)=ynext(y(i-1),y(i-2),x(i-2));
    x(i)=xnext(x(i-historyLength:i-1));
end
y=y((historyLength+1):(signalLength + historyLength));
x=x((historyLength+1):(signalLength + historyLength));

% plot
frequencies = linspace(0,1,signalLength)/(0.02);% this addition gives you the frequency in Hz
subplot(2,2,1)
plot(x)
subplot(2,2,2)
plot(y)
subplot(2,2,3)
xfft=fft(x);
plot(frequencies,20*log10(abs(xfft)/(signalLength)))
ylabel('Gain (dB)');% gain... but w.r.t. what?
xlabel('Frequency (Hz)')
axis([0,1,-70,10])
subplot(2,2,4)
yfft=fft(y);
plot(frequencies,20*log10(abs(yfft)))
ylabel('Gain (dB)');% gain... but w.r.t. what?
xlabel('Frequency (Hz)')


