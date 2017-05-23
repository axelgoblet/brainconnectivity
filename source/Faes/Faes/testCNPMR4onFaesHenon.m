%based on CNPMR paper Dataset4
iterations = 20000;
% Faes parameters
Q = 10; % quantization levels
L = 10; % max lag
S = 10; % num surrogates

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
    xtoySig = zeros(1,25);
    ytox = zeros(1,25);
    ytoxSig = zeros(1,25);
    
    for w = 1:25
        w
        indices = (w*750:((w+1)*750)-1);
        X = [ x(indices); y(indices) ]';        
        X = quantize(X, Q); 
        
        [CC, V, Vj, H_K, H_Kj, H_Kv] = gcausality(X, 1, 2, L);
        xtoy(w) = CC;
        xtoySig(w) = caussignif(X, 1, 2, S, 2*L, CC, H_Kj, L);
        
        [CC, V, Vj, H_K, H_Kj, H_Kv] = gcausality(X, 2, 1, L);
        ytox(w) = CC;
        ytoxSig(w) = caussignif(X, 2, 1, S, 2*L, CC, H_Kj, L);
    end
    
    subplot(3,4,i)
    plot(xtoy)
    hold on
    plot(ytox)
    plot(xtoySig)
    plot(ytoxSig)
    axis([1,25,0,1.5])
    title(['c = '  num2str(c(i))])
    xlabel('Window')
    ylabel('Causality')
    legend('x->y', 'y->x', 'xy sig', 'yx sig')
    hold off
end

