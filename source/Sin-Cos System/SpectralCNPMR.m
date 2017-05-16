close all;

%% Initialization
% Input (driving) frequencies (u = high, v = low)
% We'll evaluate cos(u)*sin(v) = [sin(u+v) + sin(u-v)]/2, so
% the default setting of u=30 and v=20 gives us input in the
% beta wave band and outputs in the alpha (30-20=10Hz) and
% gamma (30+20=50) wave bands.
u = 30;
v = 20;

% Some further frequencies to test if these yield any causality, picked as 
% prime numbers to ensure we don't inspect harmonics of the inputs/output.
testFrequencies = [ 7, 13, 23, 43, 59 ];

% General parameters
Fs = 128;
T = 1 / Fs;
samples = 1024;
shift = 5;

%% Series generation
x1 = zeros(1, samples);
x2 = zeros(1, samples);
y = zeros(1, samples);
tests = zeros(numel(testFrequencies), samples);

for i=1:samples
 t = (i - 1) * 2 * pi * T;
 x1(i) = cos(u*t)+normrnd(0,0.1);
 x2(i) = sin(v*t)+normrnd(0,0.1);
 
 if (i > 1 + shift)
    y(i) = x1(i-shift) * x2(i-shift);     
        
    % try the line below for a trivial linear causality on x1 and no 
    % dependence on x2, then Faes causality works quite perfectly.
    %y(i) = x1(i-shift) * 5;
    
    % with an additive linear causality depending on x1 and x2, the
    % y signal becomes too predictive by itself and basically becomes
    % autoregressive with the signal being the most significant predictor
    %y(i) = x1(i-shift) + x2(i-shift); 
 end
 
 for j1=1:numel(testFrequencies)
     tests(j1, i) = sin(testFrequencies(j1) * t);
 end
end

%% Series plot
figure;
plot(x1);
hold on;
plot(x2);
plot(y);
legend('x1', 'x2', 'y');

%% Frequency plots
figure;
subplot(3,1,1);
ft = abs(fft(x1));
plot(ft);
hold on;
[pks,locs] = findpeaks(ft, 'MinPeakHeight', 100);
plot(locs,pks,'ro');
text(locs+.02,pks,num2str(round(locs/samples*Fs)'))
subplot(3,1,2);
ft = abs(fft(x2));
plot(ft);
hold on;
[pks,locs] = findpeaks(ft, 'MinPeakHeight', 100);
plot(locs,pks,'ro');
text(locs+.02,pks,num2str(round(locs/samples*Fs)'))
subplot(3,1,3);
ft = abs(fft(y));
plot(ft);
hold on;
[pks,locs] = findpeaks(ft, 'MinPeakHeight', 100);
plot(locs,pks,'ro');
text(locs+.02,pks,num2str(round(locs/samples*Fs)'))

%% x1 -> y
[causality,xR2,isSignificant,sensitivity]=CNPMR(y,x1,x2,1,3,1,1,1,true,0.05)

%% x2 -> y
[causality,xR2,isSignificant,sensitivity]=CNPMR(y,x2,x1,1,3,1,1,1,true,0.05)

%% y -> x1
[causality,xR2,isSignificant,sensitivity]=CNPMR(x1,y,x2,1,3,1,1,1,true,0.05)

%% y -> x2
[causality,xR2,isSignificant,sensitivity]=CNPMR(x2,y,x1,1,3,1,1,1,true,0.05)

%% Now let's cut the signals up into alpha, beta and gamma bands to see
% if the method is able to find causalities across specific bands
order = 384;
alpha = designfilt('bandpassfir','FilterOrder',order,'StopbandFrequency1',7,'PassbandFrequency1',8,'PassbandFrequency2',12,'StopbandFrequency2',13,'SampleRate',Fs);
beta = designfilt('bandpassfir','FilterOrder',order,'StopbandFrequency1',11,'PassbandFrequency1',12,'PassbandFrequency2',40,'StopbandFrequency2',41,'SampleRate',Fs);
gamma = designfilt('bandpassfir','FilterOrder',order,'StopbandFrequency1',39,'PassbandFrequency1',40,'PassbandFrequency2',Fs/2-1,'StopbandFrequency2',Fs/2,'SampleRate',Fs);

x1a = filter(alpha, x1);
x1b = filter(beta, x1);
x1g = filter(gamma, x1);

ya = filter(alpha, y);
yb = filter(beta, y);
yg = filter(gamma, y);

% x1b -> ya, e.g. because of the trig identity, the beta band-filtered
% portion of the x1 signal should be predictive for the alpha band of y
[causality,xR2,isSignificant,sensitivity]=CNPMR(ya,x1b,[x1a;x1g],1,3,1,1,[1;1],true,0.05)

% conditional causality with x2 added to the system. now a significant
% causality is found.
[causality,xR2,isSignificant,sensitivity]=CNPMR(ya,x1b,[x1a;x1g;x2],1,3,1,1,[1;1;1],true,0.05)