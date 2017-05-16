close all;

%% Initialization
% Basic realization
initialConditions = rand(1,6);
rl = RosslerLorenz(initialConditions);

figure;
for i=1:size(rl,1)
   plot3(rl(i,:,4), rl(i,:,5), rl(i,:,6));
   hold on;
end


%% Evaluate x1,x2 coupling using code provided by Pietro
% Replicating the analysis in Fases 2011, page 4/5, fig 1
figure;
selectedTerms = (1:6);
j = 2; % driver x1=z2, index=2
i = 5; % driven x2=y2, index=5
L = 10; % max lag=10
numSur = 40;
surMinLag = 20; % using min 1/3rd of signal length as per Axel didn't change much


% No coupling, fig 1a)
X = squeeze(rl(1,1:500,selectedTerms)); X = quantize(X, 6); 
[CC, V, Vj, H_K, H_Kj, H_Kv] = gcausality(X, j, i, L);
[alpha, CCs, H_Ks] = caussignif(X, j, i, numSur, surMinLag, CC, H_Kj, L);
subplot(2,2,1);
plot_candvec(V, H_Kv);
title(num2str(alpha));

% Coupling strength 1.5, fig 1b)
X = squeeze(rl(4,1:500,selectedTerms)); X = quantize(X, 6); 
[CC, V, Vj, H_K, H_Kj, H_Kv] = gcausality(X, j, i, L);
[alpha, CCs, H_Ks] = caussignif(X, j, i, numSur, surMinLag, CC, H_Kj, L);
subplot(2,2,2);
plot_candvec(V, H_Kv);
title(num2str(alpha));


% Opposite direction, No coupling, fig 1c)
X = squeeze(rl(1,1:500,selectedTerms)); X = quantize(X, 6); 
[CC, V, Vj, H_K, H_Kj, H_Kv] = gcausality(X, i, j, L);
[alpha, CCs, H_Ks] = caussignif(X, i, j, numSur, surMinLag, CC, H_Kj, L);
subplot(2,2,3);
plot_candvec(V, H_Kv);
title(num2str(alpha));

% Opposite direction, Coupling strength 1.5, fig 1d)
X = squeeze(rl(4,1:500,selectedTerms)); X = quantize(X, 6); 
[CC, V, Vj, H_K, H_Kj, H_Kv] = gcausality(X, i, j, L);
[alpha, CCs, H_Ks] = caussignif(X, i, j, numSur, surMinLag, CC, H_Kj, L);
subplot(2,2,4);
plot_candvec(V, H_Kv);
title(num2str(alpha));
