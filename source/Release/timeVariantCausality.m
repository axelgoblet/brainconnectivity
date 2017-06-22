function [] = timeVariantCausality(timelock, fromChannels, toChannels, windowSize, stepSize, varargin)
    
    

    % set defaults
    standardize = 1; 
    causalityMethod = 'CNPMR';
    significanceMethod = 'shuffledTrialsSurrogates';
    delay = 1;
    lag = 5;
    sigThreshold = 0.05;
    verbose = 1;
    
    % check key value pairs
    if nargin < 5
       error('Not enough input arguments.') 
    end
    if mod(nargin,2) ~= 1
        error('Please insert an even number arguments in the key-value pair section')
    end
    for arg = 1:(length(varargin)/2)
        key = varargin{arg*2-1};
        value = varargin{arg*2};
        switch key
            case 'standardize'
                standardize = value;
            case 'causalityMethod'
                causalityMethod = value;
            case 'significanceMethod'
                significanceMethod = value;
            case 'delay'
                delay = value;
            case 'lag'
                lag = value;
            case 'sigThreshold'
                sigThreshold = value;
            case 'verbose'
                verbose = value;
        end
    end

    % find minimum number of samples
    [~,nanIndices] = find(isnan(squeeze(timelock.trial(:,1,:))));
    nsamples = min(nanIndices)-1;
    
    % compute start points of windows
    windowStarts = timelock.time(1):stepSize:timelock.time(nsamples);
    
    % remove windows that exceed the length of the experiment
    windowsToTruncate = find((windowStarts+windowSize) > timelock.time(nsamples));
    windowStarts = windowStarts(1:min(windowsToTruncate-1));
        
    % compute time interval between samples (1/sampling frequency)
    timestep = timelock.time(2) - timelock.time(1);
    
    % find array indices where windows start
    windowStartIndices = round((windowStarts - windowStarts(1)) / timestep) + 1;
    
    % find number of samples per window
    samplesPerWindow = round(windowSize / timestep);
    
    % extract diver and driven variables from timelock structure
    drivers = timelock.trial(:,fromChannels,1:nsamples);
    drivens = timelock.trial(:,toChannels,1:nsamples);
    
    % compute causalities and significances over time
    if significanceMethod == 'shuffledTrialsSurrogates'
        [causalities, significances] = shuffledTrialsSurrogates(drivers, drivens, windowStartIndices, samplesPerWindow, sigThreshold, delay, lag, standardize, causalityMethod, verbose);
    elseif significanceMethod == 'timeShiftedSurrogates'
        [causalities, significances] = timeShiftedSurrogates(drivers, drivens, windowStartIndices, samplesPerWindow, sigThreshold, delay, lag, standardize, causalityMethod, verbose);
    end  
    
    % visualize output
    visualizeCausalities([drivers,drivens],causalities,significances,stepSize/timestep,fromChannels,toChannels,timelock.time(1:nsamples))
end