% create nonlinear AR model
x1next = @(x1previous,x2previous) 0.8*x1previous +0.65*x2previous^2+normrnd(0,1);
x2next = @(x1previous,x2previous) 0.6*x2previous + normrnd(0,1);

% 50 realizations
x2tox1=0;
x1tox2=zeros(1,4);
for realization=1:50
    
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
    [causality,sensitivity] = CNPMR(x1,x2,[],1,3,1,1,[],true);
    x2tox1 = x2tox1 + 1/50 * [causality,sensitivity];
    [causality,sensitivity] = CNPMR(x2,x1,[],1,3,1,1,[],false);
    x1tox2 = x1tox2 + 1/50 * [causality,sensitivity];
end

% output
x1tox2 %the paper states -0.003
x2tox1 %the paper states [0.357,0.1095,0.0429,0.0289]