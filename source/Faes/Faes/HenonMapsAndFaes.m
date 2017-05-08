%based on CNPMR paper Dataset4
iterations = 20000;
%Do an amount of iterations to calculate Henon map
c = [0,0.05,0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1.0];
x1(1) = 0;
x2(1) = 0;
x3(1) = 0;
x1(2) = 0;
x2(2) = 0;
x3(2) = 0;
for i = 1:size(c,2)
    for t = 3:iterations
        x1(t)= 1.4 -x1(t-1)^2 + 0.3*x1(t-2)+0.08*(x1(t-1)^2-x2(t-1)^2);
        x2(t)= 1.4 -x2(t-1)^2 + 0.3*x2(t-2)+0.08*(x2(t-1)^2-x1(t-1)^2);
        x3(t) = 1.4 - (c(i)*x1(t-1) + (1-c(i))*x3(t-1))*x3(t-1)+0.1*x2(t-2);
    end
end