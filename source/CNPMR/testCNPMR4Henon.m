%based on CNPMR paper Dataset4
iterations = 20000;
%Do an amount of iterations to calculate Henon map
c = [0,0.05,0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1.0];
x = zeros(1,iterations);
y = zeros(1,iterations);

figure
for i = 1:size(c,2)
    c(i)
    for t = 3:iterations
        x(t)=1.4-(x(t-1)^2)+0.3*x(t-2);
        y(t)=1.4-(c(i)*x(t-1)+(1-c(i))*y(t-1))*y(t-1)+0.1*y(t-2); 
    end
    
    xtoy = zeros(1,25);
    ytox = zeros(1,25);
    for w = 1:25
        w
        indices = (w*750:((w+1)*750)-1);
        ytox(w) = CNPMR(x(indices),y(indices),[],1,3,1,1,[],false,0.5);
        xtoy(w) = CNPMR(y(indices),x(indices),[],1,3,1,1,[],false,0.5);
    end
    
    subplot(3,4,i)
    plot(xtoy)
    hold on
    plot(ytox)
    axis([1,25,0,1.5])
    title(['c = '  num2str(c(i))])
    xlabel('Window')
    ylabel('Causality')
    legend('x->y', 'y->x')
    hold off
end

