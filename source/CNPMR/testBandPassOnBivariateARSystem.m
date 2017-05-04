% create multivariate AR model
ynext = @(yprevious1,yprevious2,xprevious1,xprevious2)0.5*yprevious1-0.3*yprevious2+0.1*xprevious2+0.4*xprevious1*xprevious2+normrnd(0,.1);
xnext = @(yprevious2,xprevious1,xprevious2)0.3*xprevious1-xprevious2-0.1*yprevious2+normrnd(0,.1);

% generate 1000 samples
y=zeros(1,10002);
x=zeros(1,10002);
for i=3:10002
    y(i)=ynext(y(i-1),y(i-2),x(i-1),x(i-2));
    x(i)=xnext(y(i-2),x(i-1),x(i-2));
end
y=y(5000:10002);
x=x(5000:10002);

xtoycnpmr = CNPMR(y,x,[],1,3,1,1,[],false,0.05,[2,2.5],20)
ytoxcnpmr = CNPMR(x,y,[],1,3,1,1,[],false,0.05,[2,2.5],20)