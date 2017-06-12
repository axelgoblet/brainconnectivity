%load('data\fullDataSet.mat');


electrodes = [2 6 10 14];

numWindows = 25;


numSur = 20;
surMinLag = 20;
lag=5;

for m = 1 : size(electrodes,2)
    causalitiesInTrial = zeros(1,60);
    significanceInTrial = zeros(1,60);
    causalitiesPerWindow = zeros(1,numWindows);
    significancePerWindow = zeros(1,numWindows);
    for w = 1 : numWindows
        causalitiesInWindow = zeros(1,60);
        significanceInWindow = zeros(1,60);
        
        for i = 1 : 60
            
            clearvars B

            Contrast = 1;
            Attention = 1;
            FromArea = 1;
            ToArea = 4;
            Electrode = electrodes(m);
            Trial = i;

            x = data(data(:,1) == Contrast & data(:,2) == Attention & data(:,3) == ToArea & data(:,4) == Electrode & data(:,5) == Trial, 6:end);
            y = data(data(:,1) == Contrast & data(:,2) == Attention & data(:,3) == FromArea & data(:,4) == Electrode & data(:,5) == Trial, 6:end);  

            X = [x',y'];
            for j = 1 : size(X,2)
                B{j} = X(~isnan(X(:,j)), j);
            end

            X = cell2mat(B(1,:));
            
            %select measurements in current trial with current window
            windowSize = floor(size(X,1)/numWindows);
            intervalStart = windowSize*(w-1)+1;
            intervalEnd = windowSize*w;
            windowX = X(intervalStart:intervalEnd,:);
            
            
            windowX = quantize(windowX,20);
            X = quantize(X, 20);
            
            %
            if w == 1
                disp(['Calculating Overall Causality and Significance for Trial ', num2str(i)]);
                [causality1,xR2_1,isSignificant1,sensitivity1] = CNPMR(X(:,1)',X(:,2)',[],1,lag,1,1,[],false);
                causalitiesInTrial(1,i) = causality1;
                significanceInTrial(1,i) = isSignificant1;
                
            end
            
            disp(['Calculating Overall Causality for Trial ', num2str(i), ' and window ', num2str(w)]);
           [causality2,xR2_1,isSignificant2,sensitivity1] = CNPMR(windowX(:,1)',windowX(:,2)',[],1,lag,1,1,[],false);
            causalitiesInWindow(1,i) = causality2;
            significanceInWindow(1,i) = isSignificant2;
        end
        causalitiesPerWindow(1,w) = mean(causalitiesInWindow);
        significancePerWindow(1,w) = mean(significanceInWindow);
    end
    close all;
    figure;
    subplot(1,2,1)
    plot(causalitiesPerWindow);
    hold on
    plot(ones(1,numWindows)*mean(causalitiesInTrial));
    hold off
    
    xlabel('window')
    ylabel('causality')
    
    subplot(1,2,2)
    plot(significancePerWindow)
    hold on
    plot(ones(1,numWindows)*mean(significanceInTrial));
    
    hold off
    xlabel('window')
    ylabel('significance')
    
    saveas(gcf,['imagesCNPMR\PNG\V',num2str(FromArea),' To ','V',num2str(ToArea),' Electrode',num2str(electrodes(m)),' Contrast',num2str(Contrast),' Attention',num2str(Attention),'.png'])
    saveas(gcf,['imagesCNPMR\Figures\V',num2str(FromArea),' To ','V',num2str(ToArea),' Electrode',num2str(electrodes(m)),' Contrast',num2str(Contrast),' Attention',num2str(Attention),'.fig'])
end