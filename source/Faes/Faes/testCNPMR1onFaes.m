% Faes parameters
Q = 10; % quantization levels
L = 10; % max lag
S = 20; % num surrogates
alpha = 0.05; % alpha for significance (p < alpha -> significant)

% create nonlinear AR model
x1next = @(x1previous,x2previous) 0.8*x1previous +0.65*x2previous^2+normrnd(0,1);
x2next = @(x1previous,x2previous) 0.6*x2previous + normrnd(0,1);

% 50 realizations
x2tox1=zeros(1,2); % only taking causality and significance, rest isn't directly compatible 
x1tox2=zeros(1,2);
realizations = 50;
for realization=1:realizations
    realization
    % generate 1000 samples
    x1=zeros(1,1001);
    x2=zeros(1,1001);
    for i=2:1001
        x1(i)=x1next(x1(i-1),x2(i-1));
        x2(i)=x2next(x1(i-1),x2(i-1));
    end
    x1=x1(2:1001);
    x2=x2(2:1001);

    % compute causality and average
    X = [ x1; x2 ]';        
    X = quantize(X, Q); 

    [CC, V, Vj, H_K, H_Kj, H_Kv] = gcausality(X, 1, 2, L);
    p = caussignif(X, 1, 2, S, 2*L, CC, H_Kj, L);
    sig = 0; 
    if p < alpha
        sig = 1;
    end
    x1tox2 = x1tox2 + 1/realizations * [CC sig]
        
    
    [CC, V, Vj, H_K, H_Kj, H_Kv] = gcausality(X, 2, 1, L);
    p = caussignif(X, 2, 1, S, 2*L, CC, H_Kj, L);
    sig = 0; 
    if p < alpha 
        sig = 1;
    end
    x2tox1 = x2tox1 + 1/realizations * [CC sig];
end

% output
% Faes outputs 0.0035, no causality with 2/50 realizations significant
x1tox2 %the paper states [-0.003,?,?]
% Faes outputs 0.2014, some causality with 50/50 realizations significant
x2tox1 %the paper states [0.357,?,1,0.1095,0.0429,0.0289]