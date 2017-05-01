%%testCNPMR1
% create nonlinear AR model
x1next = @(x1previous,x2previous) 0.8*x1previous +0.65*x2previous^2+normrnd(0,1);
x2next = @(x1previous,x2previous) 0.6*x2previous + normrnd(0,1);

% 50 realizations
x2tox1=zeros(1,6);
x1tox2=zeros(1,3);
realizations = 1;
for realization=1:realizations
    
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
    [causality,xR2,isSignificant,sensitivity] = CNPMR(x1,x2,[],1,3,1,1,[],true);
    x2tox1 = x2tox1 + 1/realizations * [causality,xR2,isSignificant,sensitivity];
    [causality,xR2,isSignificant,sensitivity] = CNPMR(x2,x1,[],1,3,1,1,[],false);
    x1tox2 = x1tox2 + 1/realizations * [causality,xR2,isSignificant,sensitivity];
end

%%Cutting time series
%cut up timeSeries and reculculate causality for the cut up parts
interval = 100;

for i = 1:size(x1,2)
    
    if (size(x1,2)-i*interval < interval)
        
         newX1 = x1(i*interval:end);
        newX2 = x2(i*interval:end);
        % compute causality and average
        if (size(x1,2)-i*interval > 3)
            [causality,xR2,isSignificant,sensitivity] = CNPMR(newX1,newX2,[],1,3,1,1,[],true);
            disp([num2str(i),' Causality1: ',num2str(causality),' xR2 ',num2str(xR2),' isSignificant ',num2str(isSignificant),' sensitivity ',num2str(sensitivity)])
             x2tox1 = x2tox1 + 1/realizations * [causality,xR2,isSignificant,sensitivity];
             [causality,xR2,isSignificant,sensitivity] = CNPMR(newX2,newX1,[],1,3,1,1,[],false);
             disp([num2str(i),' Causality2: ',num2str(causality),' xR2 ',num2str(xR2),' isSignificant ',num2str(isSignificant),' sensitivity ',num2str(sensitivity)])
            x1tox2 = x1tox2 + 1/realizations * [causality,xR2,isSignificant,sensitivity];
        end
        break;
    else
         newX1 = x1(i:interval*i);
        newX2 = x2(i:interval*i);
        % compute causality and average
        [causality,xR2,isSignificant,sensitivity] = CNPMR(newX1,newX2,[],1,3,1,1,[],true);
        disp([num2str(i),' Causality1: ',num2str(causality),' xR2 ',num2str(xR2),' isSignificant ',num2str(isSignificant),' sensitivity ',num2str(sensitivity)])
        x2tox1 = x2tox1 + 1/realizations * [causality,xR2,isSignificant,sensitivity];
        [causality,xR2,isSignificant,sensitivity] = CNPMR(newX2,newX1,[],1,3,1,1,[],false);
        disp([num2str(i),' Causality2: ',num2str(causality),' xR2 ',num2str(xR2),' isSignificant ',num2str(isSignificant),' sensitivity ',num2str(sensitivity)])
        x1tox2 = x1tox2 + 1/realizations * [causality,xR2,isSignificant,sensitivity];
        i = interval*i+1;
    end

end
