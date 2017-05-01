%%Implementation of Henon Map
%Set initial values
a = 1.4;
b = 0.3;
x(1) = 0;
y(1) = 0;
iterations = 5000
%Do an amount of iterations to calculate Henon map
for i = 2:iterations
   x(i)=1-a*(x(i-1)^2)+y(i-1);
   y(i)=b*x(i-1); 
end
plot(x,y,'.')