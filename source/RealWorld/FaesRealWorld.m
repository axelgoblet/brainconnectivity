%% Computing Faes causality and significance on Real World data
% Make sure that the entire source/Faes folder added to your current Matlab
% path. Also brainconnectivity/data should be added to the path.

clear
load('data\fullDataSet.mat');

% electrodes to be evaluated. the current code evaluates electrode x in V1
% to electrode x in V4
electrodes = [2 6 10 14];

% number of windows that should be evaluated
numWindows = 25;

% surrogate information for significance testing
numSurrogates = 20;
surrogateMinLag = 20;

% ?maximum lag of model that we want to evaluate?
lag=5;

% The average causality taken over the entire time series for each electrode
causalitiesAverageInTrialPerElectrode = zeros(size(electrodes,2), numWindows);
% The average significance taken over the entire time series for each electrode
significanceAverageInTrialPerElectrode = zeros(size(electrodes,2), numWindows);
%the average causality for each window for each electrode
causalitiesPerWindowPerElectrode = zeros(size(electrodes,2), numWindows);
%the average significance for each window for each electrode
significancePerWindowPerElectrode = zeros(size(electrodes,2), numWindows);

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
            FromElectrode = electrodes(m);
            ToElectrode = electrodes(m);
            Trial = i;

            x = data(data(:,1) == Contrast & data(:,2) == Attention & data(:,3) == ToArea & data(:,4) == ToElectrode & data(:,5) == Trial, 6:end);
            y = data(data(:,1) == Contrast & data(:,2) == Attention & data(:,3) == FromArea & data(:,4) == FromElectrode & data(:,5) == Trial, 6:end);  

            % put data in format for Faes analysis
            X = [x',y'];
            
            % remove NaN values
            for j = 1 : size(X,2)
                B{j} = X(~isnan(X(:,j)), j);
            end
            X = cell2mat(B(1,:));
            
            %select measurements in current trial with current window
            windowSize = floor(size(X,1)/numWindows);
            intervalStart = windowSize*(w-1)+1;
            if windowSize*w+1 > size(X,1)
                intervalEnd = windowSize*w;
            else
                intervalEnd = windowSize*w+1;
            end
            windowX = X(intervalStart:intervalEnd,:);
            
            % dicretize data for Faes analysis
            windowX = quantize(windowX, 10);
            X = quantize(X, 10);
            
            % only for first window, calculate total causality and
            % significance (only needs to happen once since it is window
            % independent)
            if w == 1
                disp(['Calculating Overall Causality from V', num2str(FromArea), ' to V', num2str(ToArea), ' for Trial ', num2str(i), ' between electrodes ', num2str(FromElectrode), ' in V', num2str(FromArea) ' and ', num2str(ToElectrode), ' in V', num2str(ToArea)]);
                [CC, V, Vj, H_K, H_Kj, H_Kv] = gcausality(X, 2, 1, lag);
                causalitiesInTrial(1,i) = CC;
            
                % There were some problems regarding these trials (randperm
                % error where K was greater than N) so I took them out for now
                if i == 14 || i == 26
                    
                else
                    disp(['Calculating Overall Significance for Trial ', num2str(i)]);
                    [significance, CCs, H_Ks] = caussignif(X, 2, 1, numSurrogates, surrogateMinLag, CC, H_Kj, lag);
                    significanceInTrial(1,i) = significance;
                end
                
            end
            
            %compute causality for current window and trial
            disp(['Calculating Overall Causality from V', num2str(FromArea), ' to V', num2str(ToArea), ' for Trial ', num2str(i), ' and window ', num2str(w), ' between electrodes ', num2str(FromElectrode), ' in V', num2str(FromArea) ' and ', num2str(ToElectrode), ' in V', num2str(ToArea)]);
            [CC, V, Vj, H_K, H_Kj, H_Kv] = gcausality(windowX, 2, 1, lag);
            causalitiesInWindow(1,i) = CC;
            
            % There were some problems regarding these trials (randperm
            % error where K was greater than N) so I took them out for now
            if i ==  14 || i == 26
                
            else
                %compute significance for current window and trial
                disp(['Calculating Overall Significance for Trial ', num2str(i), ' and window ', num2str(w)]);
                [significance, CCs, H_Ks] = caussignif(windowX, 2, 1, numSurrogates, surrogateMinLag, CC, H_Kj, lag);
                significanceInWindow(1,i) = significance;
            end
        end
        causalitiesPerWindow(1,w) = mean(causalitiesInWindow);
        significancePerWindow(1,w) = mean(significanceInWindow);
    end
    causalitiesAverageInTrialPerElectrode(m,:) = ones(1,numWindows)*mean(causalitiesInTrial);
    significanceAverageInTrialPerElectrode(m,:) = ones(1,numWindows)*mean(significanceInTrial);
    causalitiesPerWindowPerElectrode(m,:) = causalitiesPerWindow;
    significancePerWindowPerElectrode(m,:) = significancePerWindow;
end

%% Create csv with results (so we don't need to run this stuff again)

%csvwrite('FaesTotalCausality', causalitiesAverageInTrialPerElectrode);
%csvwrite('FaesTotalSignificance', significanceAverageInTrialPerElectrode);
%csvwrite('FaesWindowedCausality', causalitiesPerWindowPerElectrode);
%csvwrite('FaesWindowedSignificance', causalitiesAverageInTrialPerElectrode);

%% plot for first electrode
figure(1);
subplot(1,2,1)
plot(causalitiesPerWindowPerElectrode(1,:));
hold on
plot(causalitiesAverageInTrialPerElectrode(1,:));
hold off
title('Causality Electrode 2')
xlabel('window')
ylabel('causality')
ylim([0 inf])
legend('average causality over 60 trials per window','average total causality','Location','southeast')

subplot(1,2,2)
plot(significancePerWindowPerElectrode(1,:))
hold on
plot(significanceAverageInTrialPerElectrode(1,:));
hold off
title('Significance Electrode 2')
xlabel('window')
ylabel('significance')
ylim([0 inf])
legend('average significance over 60 trials per window','average total significance','Location','southeast')

%% plot for second electrode
figure(2);
subplot(1,2,1)
plot(causalitiesPerWindowPerElectrode(2,:));
hold on
plot(causalitiesAverageInTrialPerElectrode(2,:));
hold off
title('Causality Electrode 6')
xlabel('window')
ylabel('causality')
ylim([0 inf])
legend('average causality over 60 trials per window','average total causality','Location','southeast')


subplot(1,2,2)
plot(significancePerWindowPerElectrode(2,:))
hold on
plot(significanceAverageInTrialPerElectrode(2,:));
hold off
title('Significance Electrode 6')
xlabel('window')
ylabel('significance')
ylim([0 inf])
legend('average significance over 60 trials per window','average total significance','Location','southeast')


%% plot for third electrode
figure(3);
subplot(1,2,1)
plot(causalitiesPerWindowPerElectrode(3,:));
hold on
plot(causalitiesAverageInTrialPerElectrode(3,:));
hold off
title('Causality Electrode 10')
xlabel('window')
ylabel('causality')
ylim([0 inf])
legend('average causality over 60 trials per window','average total causality','Location','southeast')


subplot(1,2,2)
plot(significancePerWindowPerElectrode(3,:))
hold on
plot(significanceAverageInTrialPerElectrode(3,:));
hold off
title('Significance Electrode 10')
xlabel('window')
ylabel('significance')
ylim([0 inf])
legend('average significance over 60 trials per window','average total significance','Location','southeast')


%% plot for fourth electrode
figure(4);
subplot(1,2,1)
plot(causalitiesPerWindowPerElectrode(4,:));
hold on
plot(causalitiesAverageInTrialPerElectrode(4,:));
hold off
title('Causality Electrode 14')
xlabel('window')
ylabel('causality')
ylim([0 inf])
legend('average causality over 60 trials per window','average total causality','Location','southeast')


subplot(1,2,2)
plot(significancePerWindowPerElectrode(4,:))
hold on
plot(significanceAverageInTrialPerElectrode(4,:));
hold off
title('Significance Electrode 14')
xlabel('window')
ylabel('significance')
ylim([0 inf])
legend('average significance over 60 trials per window','average total significance','Location','southeast')
