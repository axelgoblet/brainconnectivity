% create multivariate AR model
m=1;
c=0.5;
k1=1;
k3=0.3;
Ts=0.02;
sigma=0.1;
ynext = @(yprevious1,yprevious2,xprevious2)(2-0.5*Ts)*yprevious1-(1-0.5*Ts+Ts^2)*yprevious2-k3*Ts^2*yprevious2^3+Ts^2*xprevious2+normrnd(0,sigma);
xnext = @(k) 5*sin(k*Ts)+normrnd(0,sigma);

% generate 1000 samples
y=zeros(1,1002);
x=zeros(1,1002);
for i=3:1002
    [ynext(y(i-1),y(i-2),x(i-2)),xnext(i)]
    
    y(i)=ynext(y(i-1),y(i-2),x(i-2));
    x(i)=xnext(i);
end
y=y(3:1002);
x=x(3:1002);