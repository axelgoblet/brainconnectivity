function [ causalities, significances ] = shuffledTrialsSurrogates( channelsFrom, channelsTo, windowStarts, windowSize, sigThreshhold, delay, lag, standardize, method, verbose )
% SHUFFLEDTRIALSSURROGATES Summary of this function goes here
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

        % sample which trials are going to be used as surrogates for the
        % current set of channels
        sampleFrom = datasample(1:numTrials, numSurrogates, 'Replace', false);               
        sampleTo = datasample(1:numTrials, numSurrogates, 'Replace', false);

        for window = 1 : numWindows
            
            % matrix to store surrogate resutls
            surrogateResults = zeros(1,numSurrogates);

            % set window start and end indices            
            intervalStart = windowStarts(window);
            intervalEnd = windowStarts(window) + windowSize;

            if verbose
                disp(['Calculating Causalities from channel ', num2str(fromChannel), ' to channel ', num2str(toChannel) ,' || in Window: ', num2str(window)])
                disp('Starting surrogate computation')
            end
            
            % compute the surrogate causalities for the current window
            for surr = 1 : numSurrogates
                % take surrogate data from input
                surrFrom = squeeze(channelsFrom(sampleFrom(surr), fromChannel, :))';  
                surrTo = squeeze(channelsFrom(sampleTo(surr), toChannel, :))';  
                
                surrFrom = surrFrom(intervalStart:intervalEnd);
                surrTo = surrTo(intervalStart:intervalEnd);

                if strcmp(method, 'CNPMR')
                    if standardize
                        surrFrom = zscore(surrFrom')';
                        surrTo = zscore(surrTo')';
                    end
                    [causality, ~, ~, ~] = CNPMR(surrTo,surrFrom,[],delay,lag,1,1,[],false,1);
                    surrogateResults(surr) = causality;
                elseif strcmp(method, 'Faes')
                    X = [surrFrom',surrTo'];
                    X = quantize(X, 10);
                    [causality, ~, ~, ~, ~, ~] = gcausality(X, 1, 2, lag);
                    surrogateResults(surr) = causality;
                end
            end

            % if the eventual computed causalities are bigger than all the
            % surrogate values, the causality is significant
            numToBeat = max(surrogateResults);
            
            if verbose
                disp('starting per trial computation')
            end
            % start of per trial computation for current window
            for trial = 1 : numTrials

                driver = squeeze(channelsFrom(trial, fromChannel,:))';
                driven = squeeze(channelsTo(trial, toChannel,:))';

                driver = driver(intervalStart:intervalEnd);
                driven = driven(intervalStart:intervalEnd);

                if strcmp(method, 'CNPMR')
                    % standardize data using z-score
                    if standardize
                        driver = zscore(driver')';
                        driven = zscore(driven')';
                    end
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
