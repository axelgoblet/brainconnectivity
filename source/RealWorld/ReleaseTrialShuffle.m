function [ causalities, significances ] = ReleaseTrialShuffle( channelsFrom, channelsTo, windowStarts, windowSize, standardize, method )
%RELEASETRIALSHUFFLE Summary of this function goes here
%   Detailed explanation goes here

numWindows = size(windowStart,1);
numTrials = size(channelsFrom,1);
numChannelsFrom = size(channelsFrom, 2);
numChannelsTo = size(channelsTo, 2);

causalities = zeros(numTrials, numChannelsFrom, numChannelsTo, numWindows);
significances = zeros(numTrials, numChannelsFrom, numChannelsTo, numWindows);

% surrogate information for significance testing
numSurrogates = 20;

% maximum lag of model that we want to evaluate
lag = 5;

% Threshold for significance analysis
sigThreshold = 0.05;

for fromChannel = 1 : numChannelsFrom
disp(['Calculating Causalities from electrode E', num2str(fromChannel)]);
    for toChannel = 1 : numChannelsTo
        disp(['to Electode: ', num2str(toChannel)])

        sampleFrom = datasample(1:60, numSurrogates, 'Replace', false);               
        sampleTo = datasample(1:60, numSurrogates, 'Replace', false);

        for window = 1 : numWindows
            surrogateResults = zeros(1,numSurrogates);

            disp(['window: ', num2str(window)])
            disp('Starting surrogate computation')
            for surr = 1 : numSurrogates
                %disp(['surrogate: ', num2str(surr)])
                surrFrom = squeeze(channelsFrom(sampleFrom(surr), fromChannel, :));  
                surrTo = squeeze(channelsFrom(sampleTo(surr), toChannel, :));  

                %select measurements in current trial with current window            
                intervalStart = windowStarts(window);
                intervalEnd = windowStarts(window) + windowSize;

                surrFrom = surrFrom(intervalStart:intervalEnd);
                surrTo = surrTo(intervalStart:intervalEnd);

                if strcmp(method, 'CNPMR')
                    [causality, ~, ~, ~] = CNPMR(surrTo,surrFrom,[],1,lag,1,1,[],false,1);
                    surrogateResults(surr) = causality;
                elseif strcmp(method, 'Faes')
                    X = [surrFrom',surrTo'];
                    X = quantize(X, 10);
                    [causality, ~, ~, ~, ~, ~] = gcausality(X, 1, 2, lag);
                    surrogateResults(surr) = causality;
                end
            end

            N = ceil(numSurrogates * sigThreshold);
            sortedSurr = sort(surrogateResults, 'descend');

            numToBeat = min(sortedSurr(1:N+1));

            disp('starting computation per trial')
            for trial = 1 : numTrials
                %disp([' Current trial: ', num2str(trial)]);

                driver = squeeze(channelsFrom(trial, fromChannel,:));
                driven = squeeze(channelsTo(trial, toChannel,:));

                %select measurements in current trial with current window             
                intervalStart = windowStarts(window);
                intervalEnd = windowStarts(window) + windowSize;

                driver = driver(intervalStart:intervalEnd);
                driven = driven(intervalStart:intervalEnd);

                if strcmp(method, 'CNPMR')
                    [causality, ~, ~, ~] = CNPMR(driven,driver,[],1,lag,1,1,[],false,1);
 
                elseif strcmp(method, 'Faes')
                    X = [driver',driven'];
                    X = quantize(X, 10);
                    [causality, ~, ~, ~, ~, ~] = gcausality(X, 1, 2, lag);
                end
                causalities(trial, fromChannel , toChannel, window) = causality;
                significances(trial, fromChannel , toChannel, window) = causality >= numToBeat;
            end
        end
    end
end

end
