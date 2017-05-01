% create multivariate AR model
x1next = @(x1previous) 3.4*x1previous*(1-x1previous^2)*exp(-x1previous^2) + 0.4*normrnd(0,1);
x2next = @(x1previous, x2previous) 3.4*x2previous*(1-x2previous^2)*exp(-x2previous^2) + 0.5*x1previous*x2previous + 0.4*normrnd(0,1);
x3next = @(x1previous, x2previous, x3previous) 3.4*x3previous*(1-x3previous^2)*exp(-x3previous^2) + 0.3*x2previous + 0.5*x1previous^2 + 0.4*normrnd(0,1);


% 50 realizations
x1tox2=zeros(1,6);
x1tox3=zeros(1,3);
x2tox1=zeros(1,3);
x2tox3=zeros(1,6);
x3tox1=zeros(1,3);
x3tox2=zeros(1,3);
realizations=1;
for realization=1:realizations
    
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
    [causality,xR2,isSignificant,sensitivity] = CNPMR(x2,x1,x3,1,3,1,1,1,true);
    x1tox2=x1tox2 + 1/realizations * [causality,xR2,isSignificant,sensitivity];
    [causality,xR2,isSignificant,sensitivity] = CNPMR(x3,x1,x2,1,3,1,1,1,false);
    x1tox3=x1tox3 + 1/realizations * [causality,xR2,isSignificant,sensitivity];
    [causality,xR2,isSignificant,sensitivity] = CNPMR(x1,x2,x3,1,3,1,1,1,false);
    x2tox1=x2tox1 + 1/realizations * [causality,xR2,isSignificant,sensitivity];
    [causality,xR2,isSignificant,sensitivity] = CNPMR(x3,x2,x1,1,3,1,1,1,true);
    x2tox3=x2tox3 + 1/realizations * [causality,xR2,isSignificant,sensitivity];
    [causality,xR2,isSignificant,sensitivity] = CNPMR(x1,x3,x2,1,3,1,1,1,false);
    x3tox1=x3tox1 + 1/realizations * [causality,xR2,isSignificant,sensitivity];
    [causality,xR2,isSignificant,sensitivity] = CNPMR(x2,x3,x1,1,3,1,1,1,false);
    x3tox2=x3tox2 + 1/realizations * [causality,xR2,isSignificant,sensitivity];    
end

% output
x1tox2 %the paper states [0.510,?,1,0.194,0.080,0.095]
x1tox3 %the paper states [-0.125,?,?]
x2tox1 %the paper states [-0.003,?,?]
x2tox3 %the paper states [0.064,?,1,0.117,0.079,0.082]
x3tox1 %the paper states [-0.055,?,?]
x3tox2 %the paper states [-0.018,?,?]

% compute causalities for created samples (between x1 and x2)
% [freq1, freq2] = bandPassCNPMR(x1,x2,50,[1 20], 100, 0.5, 5);