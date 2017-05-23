% Faes parameters
Q = 10; % quantization levels
L = 10; % max lag
S = 20; % num surrogates
alpha = 0.05; % alpha for significance (p < alpha -> significant)


% create multivariate AR model
x1next = @(x1previous) 3.4*x1previous*(1-x1previous^2)*exp(-x1previous^2) + 0.4*normrnd(0,1);
x2next = @(x1previous, x2previous) 3.4*x2previous*(1-x2previous^2)*exp(-x2previous^2) + 0.5*x1previous*x2previous + 0.4*normrnd(0,1);
x3next = @(x1previous, x2previous, x3previous) 3.4*x3previous*(1-x3previous^2)*exp(-x3previous^2) + 0.3*x2previous + 0.5*x1previous^2 + 0.4*normrnd(0,1);


% 50 realizations
x1tox2=zeros(1,2);  % only taking causality and significance, rest isn't directly compatible 
x1tox3=zeros(1,2);
x2tox1=zeros(1,2);
x2tox3=zeros(1,2);
x3tox1=zeros(1,2);
x3tox2=zeros(1,2);
realizations=50;
for realization=1:realizations
    realization
    % generate 1000 samples
    x1=zeros(1,1001);
    x2=zeros(1,1001);
    x3=zeros(1,1001);
    for i=2:1001
        x1(i)=x1next(x1(i-1));
        x2(i)=x2next(x1(i-1),x2(i-1));
        x3(i)=x3next(x1(i-1),x2(i-1),x3(i-1));
    end
    x1=x1(2:1001);
    x2=x2(2:1001);
    x3=x3(2:1001);

    % compute causality and average
    X = [ x1; x2; x3 ]';        
    X = quantize(X, Q); 

    [CC, V, Vj, H_K, H_Kj, H_Kv] = gcausality(X, 1, 2, L);
    p = caussignif(X, 1, 2, S, 2*L, CC, H_Kj, L);
    sig = 0;     if p < alpha        sig = 1;    end
    x1tox2 = x1tox2 + 1/realizations * [CC sig];
        
    [CC, V, Vj, H_K, H_Kj, H_Kv] = gcausality(X, 1, 3, L);
    p = caussignif(X, 1, 3, S, 2*L, CC, H_Kj, L);
    sig = 0;     if p < alpha        sig = 1;    end
    x1tox3 = x1tox3 + 1/realizations * [CC sig];
    
    [CC, V, Vj, H_K, H_Kj, H_Kv] = gcausality(X, 2, 1, L);
    p = caussignif(X, 2, 1, S, 2*L, CC, H_Kj, L);
    sig = 0;     if p < alpha        sig = 1;    end
    x2tox1 = x2tox1 + 1/realizations * [CC sig];
    
    [CC, V, Vj, H_K, H_Kj, H_Kv] = gcausality(X, 2, 3, L);
    p = caussignif(X, 2, 3, S, 2*L, CC, H_Kj, L);
    sig = 0;     if p < alpha        sig = 1;    end
    x2tox3 = x2tox3 + 1/realizations * [CC sig];
    
    [CC, V, Vj, H_K, H_Kj, H_Kv] = gcausality(X, 3, 1, L);
    p = caussignif(X, 3, 1, S, 2*L, CC, H_Kj, L);
    sig = 0;     if p < alpha        sig = 1;    end
    x3tox1 = x3tox1 + 1/realizations * [CC sig];
    
    [CC, V, Vj, H_K, H_Kj, H_Kv] = gcausality(X, 3, 2, L);
    p = caussignif(X, 3, 2, S, 2*L, CC, H_Kj, L);
    sig = 0;     if p < alpha        sig = 1;    end
    x3tox2 = x3tox2 + 1/realizations * [CC sig];
end

% output
% Faes 0.0584, 42/50
x1tox2 %the paper states [0.063,?,1,0.064,0.030,0.026]
% Faes 0.0448, 38/50 
x1tox3 %the paper states [0.049,?,1,0.068,0.029,0.025]
% Faes 0.0113, 4/50
x2tox1 %the paper states [0,?,?]
% Faes 0.0145, 17/50
x2tox3 %the paper states [0.085,?,1,0.103,0.035,0.029]
% Faes -0.4810*1e-3, 0/50
x3tox1 %the paper states [0.002,?,1]
% Faes 0.1912*1e-3, 0/50
x3tox2 %the paper states [0,?,?]