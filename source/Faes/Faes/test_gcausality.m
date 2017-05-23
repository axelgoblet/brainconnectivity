clear classes;

%% Case 1: random process shifted in time
tic;
N = 300;
lag = 2;
x1 = rand(N, 1);
x2 = [0.5 * ones(lag, 1); x1(1:end - lag)];

X = [x1, x2, x1 + rand(N, 1)];
X = quantize(X, 20);

%Predictor
j = 1;
%ToPredict
i = 2;
%Lag
L = 5;

[CC, V, Vj, H_K, H_Kj, Causality] = gcausality(X, j, i, L);

%% Sigtest
numSur = 20;
surMinLag = 20;
[Significance, CCs, H_Ks] = caussignif(X, j, i, numSur, surMinLag, CC, H_Kj, L);
toc;
%% Plotting
plot_candvec(V, H_Kv);