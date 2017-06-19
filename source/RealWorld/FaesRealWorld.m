%% script to do significance analysis by trial suffling
% output:
% parameter:
%   1: From Area
%   2: To Area
%   3: From Electrode
%   4: To Electrode
%   5: Window number
%   6: From Trial
%   7: To Trial
%   8: 1 = causalities, 2 = significance

clear
load('data\fullDataSet.mat');

method = 'Faes';

[r, c] = find(isnan(data) > 0);
minIndex = min(c) - 1;

data = data(:,1:minIndex);

% size of each window
windowSize = 100;

doSignificance = true;
% surrogate information for significance testing
numSurrogates = 20;
surrogateMinLag = 20;

% ?maximum lag of model that we want to evaluate?
lag=5;

% Threshold for significance analysis
sigThreshold = 0.05;

% number of windows that should be evaluated
numWindows = floor(minIndex/windowSize);

% Parameters for realworld data selection
Contrast = 1;
Attention = 1;
FromArea = [1,2,4];
ToArea = [1,2,4];

data = data(data(:,1) == Contrast & data(:,2) == Attention, 3:end);

numTrials = max(data(:,3));

%delete(gcp)
%parpool(4);

for fromArea = 1 : size(FromArea,2)
    for toArea = 1 : size(ToArea,2)
        causalityResults = zeros(16,16,numWindows,numTrials,numTrials);
        significanceResults = zeros(16,16,numWindows,numTrials,numTrials);
        for fromE = 1 : 16
        disp(['Calculating Causalities from electrode E', num2str(fromE) ,' in area V', num2str(FromArea(fromArea)), ' to area V', num2str(ToArea(toArea))]);
            for toE = 1 : 16
                disp(['to Electode: ', num2str(toE)])
                
                for window = 1 : numWindows
                    
                    disp('starting computation per trial')
                    for trial = 1 : numTrials
                        disp([' Current trial: ', num2str(trial)]);
                            
                        driver = data(data(:,1) == fromArea & data(:,2) == fromE & data(:,3) == trial, 4:end);
                        driven = data(data(:,1) == toArea & data(:,2) == toE & data(:,3) == trial, 4:end);

                        %select measurements in current trial with current window            
                        intervalStart = windowSize*(window-1)+1;
                        intervalEnd = windowSize*window+1;

                        driver = driver(intervalStart:intervalEnd);
                        driven = driven(intervalStart:intervalEnd);

                        if strcmp(method, 'CNPMR')
                            [causality,xR2_1,isSignificant,sensitivity1] = CNPMR(driven,driver,[],1,lag,1,1,[],false,sigThreshold);

                        elseif strcmp(method, 'Faes')
                            X = [driver',driven'];
                            X = quantize(X, 10);
                            [causality, V, Vj, H_K, H_Kj, H_Kv] = gcausality(X, 1, 2, lag);
                            [significance, CCs, H_Ks] = caussignif(X, 1, 2, numSurrogates, surrogateMinLag, causality, H_Kj, lag);
                            isSignificant = significance <= sigTheshold;
                        end
                        causalityResults(fromE,toE,window,trial,trial) = causality;
                        significanceResults(fromE,toE,window,trial,trial) = isSignificant;
                    end
                end
            end
        end
        saveToFile(causalityResults, [method, 'causalityResultsV',num2str(FromArea(fromArea)),'toV',num2str(ToArea(toArea)),'.mat']);
        saveToFile(significanceResults, [method, 'significanceResultsV',num2str(FromArea(fromArea)),'toV',num2str(ToArea(toArea)),'.mat']);
    end
end