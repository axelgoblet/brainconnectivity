function [ causalities, significances ] = timeShiftedSurrogates( channelsFrom, channelsTo, windowStarts, windowSize, standardize, method )
%TRIALBASEDSURROGATE Summary of this function goes here
%   Detailed explanation goes here

numWindows = size(windowStarts,2);
numTrials = size(channelsFrom,1);
numChannelsFrom = size(channelsFrom, 2);
numChannelsTo = size(channelsTo, 2);

causalities = zeros(numTrials, numChannelsFrom, numChannelsTo, numWindows);
significances = zeros(numTrials, numChannelsFrom, numChannelsTo, numWindows);


%Trial Threshold for significance analysis
sigThreshold = 0.05;

% surrogate information for significance testing
numSurrogates = 20;
surrogateMinLag = 20;

% maximum lag of model that we want to evaluate
lag = 5;


for fromChannel = 1 : numChannelsFrom
    for toChannel = 1 : numChannelsTo

        for window = 1 : numWindows
            disp(['Calculating Causalities from channel ', num2str(fromChannel), ' to channel ', num2str(toChannel) ,' || in Window: ', num2str(window)])
            disp('starting per trial computation')
            for trial = 1 : numTrials
                %disp([' Current trial: ', num2str(trial)]);

                driver = squeeze(channelsFrom(trial, fromChannel,:))';
                driven = squeeze(channelsTo(trial, toChannel,:))';

                %select measurements in current trial with current window             
                intervalStart = windowStarts(window);
                intervalEnd = windowStarts(window) + windowSize;

                driver = driver(intervalStart:intervalEnd);
                driven = driven(intervalStart:intervalEnd);

                if strcmp(method, 'CNPMR')
                    [causality,~,significance,~] = CNPMR(driven,driver,[],1,lag,1,1,[],false);
 
                elseif strcmp(method, 'Faes')
                    X = [driver',driven'];
                    X = quantize(X, 10);
                    [causality, V, Vj, H_K, H_Kj, H_Kv] = gcausality(X, 1, 2, lag);
                    [significance, CCs, H_Ks] = caussignif(X, 1, 2, numSurrogates, surrogateMinLag, causality, H_Kj, lag);
                    significance = (significance < sigThreshold)
                end
                causalities(trial, fromChannel , toChannel, window) = causality;
                significances(trial, fromChannel , toChannel, window) = significance;
            end;
        end
    end
end
end
