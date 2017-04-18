% 50 realizations
x2tox1=0;
x1tox2=0;
for realization=1:50
    
    % create nonlinear AR model
    x1next = @(x1previous,x2previous) 0.8*x1previous +0.65*x2previous^2+normrnd(0,1);
    x2next = @(x1previous,x2previous) 0.6*x2previous + normrnd(0,1);
    x1=zeros(1,1000);
    x2=zeros(1,1000);
    x1(1)=x1next(0,0);
    x2(1)=x2next(0,0);
    
    % generate 1000 samples
    for i=2:1000
        x1(i)=x1next(x1(i-1),x2(i-1));
        x2(i)=x2next(x1(i-1),x2(i-1));
    end

    % compute causality and average
    x2tox1=x2tox1 + 1/50 * CNPMR(x1,x2,[],1,3,1,1,[]);
    x1tox2=x1tox2 + 1/50 * CNPMR(x2,x1,[],1,3,1,1,[]);
end