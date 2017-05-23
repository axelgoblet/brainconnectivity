% Faes parameters
Q = 10; % quantization levels
L = 10; % max lag
S = 20; % num surrogates
alpha = 0.05; % alpha for significance (p < alpha -> significant)

% create multivariate AR model
x1next = @(x1previous1,x1previous2) 0.95*sqrt(2)*x1previous1 -0.9025*x1previous2+normrnd(0,1);
x2next = @(x1previous) -0.5*x1previous + normrnd(0,1);
x3next = @(x3previous,x2previous) 0.5*x3previous -0.5*x2previous+normrnd(0,1);

% 50 realizations
x1tox2=zeros(1,2); % only taking causality and significance, rest isn't directly compatible 
x1tox3=zeros(1,2);
x2tox1=zeros(1,2);
x2tox3=zeros(1,2);
x3tox1=zeros(1,2);
x3tox2=zeros(1,2);
realizations=50;
%parpool(5)
%parfor realization=1:realizations
for realization=1:realizations
    realization
    % generate 1000 samples
    x1=zeros(1,1002);
    x2=zeros(1,1002);
    x3=zeros(1,1002);
    for i=3:1002
        x1(i)=x1next(x1(i-1),x1(i-2));
        x2(i)=x2next(x1(i-1));
        x3(i)=x3next(x3(i-1),x2(i-1));
    end
    x1=x1(3:1002);
    x2=x2(3:1002);
    x3=x3(3:1002);

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
% Faes 0.1354, 50/50
x1tox2 %the paper states [0.510,?,1,0.194,0.080,0.095]
% Faes -0.0073, 1/50
x1tox3 %the paper states [-0.125,?,?]
% Faes 0.0010, 3/50
x2tox1 %the paper states [-0.003,?,?]
% Faes 0.0461, 42/50
x2tox3 %the paper states [0.064,?,1,0.117,0.079,0.082]
% Faes 0.2155*1e-3, 0/50
x3tox1 %the paper states [-0.055,?,?]
% Faes 0.0110, 1/50
x3tox2 %the paper states [-0.018,?,?]
