%based on CNPMR paper Dataset4
iterations = 20000;
%Do an amount of iterations to calculate Henon map
c = [0,0.05,0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1.0];
x(1) = 0;
y(1) = 0;
x(2) = 0;
y(2) = 0;
for i = 1:size(c,2)
    for t = 3:iterations
        x(t)=1.4-(x(t-1)^2)+0.3*y(t-2);
        y(t)=1.4-(c(i)*x(t-1)+(1-c(i))*y(t-1))*y(t-1)+0.1*y(t-2); 
    end
     [causality,xR2,isSignificant,sensitivity] = CNPMR(x,y,[],1,3,1,1,[],true);
    
    [causality,xR2,isSignificant,sensitivity] = CNPMR(y,x,[],1,3,1,1,[],false);
    
end