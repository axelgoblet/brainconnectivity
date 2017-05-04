% create multivariate AR model
x1next = @(x1previous) 3.4*x1previous*(1-x1previous^2)*exp(-x1previous^2) + 0.4*normrnd(0,1);
x2next = @(x1previous, x2previous) 3.4*x2previous*(1-x2previous^2)*exp(-x2previous^2) + 0.5*x1previous*x2previous + 0.4*normrnd(0,1);
x3next = @(x1previous, x2previous, x3previous) 3.4*x3previous*(1-x3previous^2)*exp(-x3previous^2) + 0.3*x2previous + 0.5*x1previous^2 + 0.4*normrnd(0,1);

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

% compute causalities for created samples (between x1 and x2)
x1tox2cnpmr = CNPMR(x2,x1,[],1,3,1,1,[],false,0.05,[10,15],100)
x2tox1cnpmr = CNPMR(x1,x2,[],1,3,1,1,[],false,0.05,[10,15],100)
[~,~,x1tox2geweke,x2tox1geweke]=pwcausal([x1;x2],1,length(x1),15,100,12.5)