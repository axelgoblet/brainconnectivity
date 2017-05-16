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
 x1(i) = cos(u*t);
 x2(i) = sin(v*t);
 
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

%% Global 'easy' Faes causality on x1, x2, y
series = [x1; x2; y; tests]';
selectedTerms = (1:8);
j1 = 1; % driver x1
j2 = 2; % driver x2
i = 3; % driven y
L = 2*shift; % max lag=10
quant = 20;
numSur = 20;
surMinLag = 20; 
figure;

%% x1 -> y
X = squeeze(series(shift+1:end,selectedTerms)); X = quantize(X, quant); 
[CC, V, Vj, H_K, H_Kj, H_Kv] = gcausality(X, j1, i, L);
[alpha, CCs, H_Ks] = caussignif(X, j1, i, numSur, surMinLag, CC, H_Kj, L);
subplot(2,2,1);
plot_candvec(V, H_Kv);
title(num2str(alpha));

%% x2 -> y
X = squeeze(series(shift+1:end,selectedTerms)); X = quantize(X, quant); 
[CC, V, Vj, H_K, H_Kj, H_Kv] = gcausality(X, j2, i, L);
[alpha, CCs, H_Ks] = caussignif(X, j2, i, numSur, surMinLag, CC, H_Kj, L);
subplot(2,2,2);
plot_candvec(V, H_Kv);
title(num2str(alpha));


%% y -> x1
X = squeeze(series(shift+1:end,selectedTerms)); X = quantize(X, quant); 
[CC, V, Vj, H_K, H_Kj, H_Kv] = gcausality(X, i, j1, L);
[alpha, CCs, H_Ks] = caussignif(X, i, j1, numSur, surMinLag, CC, H_Kj, L);
subplot(2,2,3);
plot_candvec(V, H_Kv);
title(num2str(alpha));

%% y -> x2
X = squeeze(series(shift+1:end,selectedTerms)); X = quantize(X, quant); 
[CC, V, Vj, H_K, H_Kj, H_Kv] = gcausality(X, i, j2, L);
[alpha, CCs, H_Ks] = caussignif(X, i, j2, numSur, surMinLag, CC, H_Kj, L);
subplot(2,2,4);
plot_candvec(V, H_Kv);
title(num2str(alpha));


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

series = [x1a; x1b; x1g; ya; yb; yg]';
series = series(order+1:end,:);
figure;
subplot(2,1,1);
plot(series(:,1:3));
legend('alpha', 'beta', 'gamma');
subplot(2,1,2);
plot(series(:,4:6));
legend('alpha', 'beta', 'gamma');

selectedTerms = (1:6);
j1 = 2; % driver x1b
i = 4; % driven ya
L = 2*shift; % max lag=10
quant = 20;
numSur = 20;
surMinLag = 20; 
figure;

% x1b -> ya, e.g. because of the trig identity, the beta band-filtered
% portion of the x1 signal should be predictive for the alpha band of y
X = squeeze(series(shift+1:end,selectedTerms)); X = quantize(X, quant); 
[CC, V, Vj, H_K, H_Kj, H_Kv] = gcausality(X, j1, i, L);
[alpha, CCs, H_Ks] = caussignif(X, j1, i, numSur, surMinLag, CC, H_Kj, L);
plot_candvec(V, H_Kv);
title(num2str(alpha));
