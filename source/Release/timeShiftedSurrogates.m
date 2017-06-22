function [ causalities, significances ] = timeShiftedSurrogates( channelsFrom, channelsTo, windowStarts, windowSize, sigThreshhold, delay, lag, standardize, method, verbose )
%TIMESHIFTEDSURROGATES Summary of this function goes here
%   Detailed explanation goes here

% number of total windows
numWindows = size(windowStarts,2);
% number of trials
numTrials = size(channelsFrom,1);
% number of from channels
numChannelsFrom = size(channelsFrom, 2);
% number of to channels
numChannelsTo = size(channelsTo, 2);

% matrix for storing causalities
causalities = zeros(numTrials, numChannelsFrom, numChannelsTo, numWindows);

% matrix for storing significances
significances = zeros(numTrials, numChannelsFrom, numChannelsTo, numWindows);

% number of surogates to compute
numSurrogates = ceil((1/sigThreshhold) - 1);

% compute all causalities and significances
for fromChannel = 1 : numChannelsFrom
    for toChannel = 1 : numChannelsTo

        for window = 1 : numWindows
            if verbose
                disp(['Calculating Causalities from channel ', num2str(channelsFrom(fromChannel)), ' to channel ', num2str(channelsTo(toChannel)) ,' || in Window: ', num2str(window)])
                disp('starting per trial computation')
            end
            
            % set window start and end indices            
            intervalStart = windowStarts(window);
            intervalEnd = windowStarts(window) + windowSize;
            
            % start of per trial computation for current window
            for trial = 1 : numTrials

                driver = squeeze(channelsFrom(trial, channelsFrom(fromChannel),:))';
                driven = squeeze(channelsTo(trial, channelsTo(toChannel),:))';

                driver = driver(intervalStart:intervalEnd);
                driven = driven(intervalStart:intervalEnd);

                if strcmp(method, 'CNPMR')
                    % standardize data using z-score
                    if standardize
                        driver = zscore(driver')';
                        driven = zscore(driven')';
                    end
                    [causality,~,significance,~] = CNPMR(driven,driver,[],delay,lag,1,1,[],false);
 
                elseif strcmp(method, 'Faes')
                    X = [driver',driven'];
                    X = quantize(X, 10);
                    [causality, ~, ~, ~, H_Kj, ~] = gcausality(X, 1, 2, lag);
                    [significance, ~, ~] = caussignif(X, 1, 2, numSurrogates, ceil(windowSize/3), causality, H_Kj, lag);
                    significance = (significance < sigThreshold);
                end
                causalities(trial, fromChannel , toChannel, window) = causality;
                significances(trial, fromChannel , toChannel, window) = significance;
            end;
        end
    end
end
end
