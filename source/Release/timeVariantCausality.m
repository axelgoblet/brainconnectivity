function [] = timeVariantCausality(timelock, fromChannels, toChannels, windowSize, stepSize, varargin)
    % TIMEVARIANTCAUSALITY Computes the causality over time for a set of
    % trials.
    %   Parameters:
    %       timelock takes a struct of the type timelock
    %
    %       fromChannels is a vector specifying the timelock channels that
    %       should be used as driver variables.
    %
    %       toChannels is a vector specifiying the timelock channels that
    %       should be used as driven variables.
    %
    %       windowSize specifies the size of the window (in the unit of the
    %       timelock time).
    %
    %       stepSize specifies the time difference between two windows.
    %
    %       varargin can take various key-value pairs to modify the
    %       behaviour of the method:
    %           'standardize' (default 1) defines whether the data should 
    %           be normalized (z-score).
    %
    %           'causalityMethod' (default 'CNPMR') defines which causality 
    %           method should be used (either 'CNPMR' or 'Faes').
    %
    %           'significanceMethod' (default 'shuffledTrialsSurrogates')
    %           defines which significance method should be used (either
    %           'shuffledTrialsSurragates' or 'timeShiftedSurrogates').
    %
    %           'delay' (default 1) defines the delay between 2 time delay 
    %           embedding vectors.
    %
    %           'lag' (default 5) defines the number of time delay 
    %           embedding vectors used.
    %
    %           'sigThreshold' (default 0.05) defines the significance 
    %           threshold for the surrogate analysis.
    %
    %           'verbose' (default 1) defines whether output should be
    %           printed.
    % 
    %       Example: TIMEVARIANTCAUSALITY(timelock,[1 2],[3 4],0.1,0.05)
    %       computes the causality from channel 1 and 2 to channel 3 and 4,
    %       using a window of 0.1 time unit and a step size of 0.05 time
    %       unit, with all other parameters set to default.
    

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
    if ~isempty(windowsToTruncate)
        windowStarts = windowStarts(1:min(windowsToTruncate-1));
    end
        
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
    if strcmp(significanceMethod,'shuffledTrialsSurrogates')
        [causalities, significances] = shuffledTrialsSurrogates(drivers, drivens, windowStartIndices, samplesPerWindow, sigThreshold, delay, lag, standardize, causalityMethod, verbose);
    elseif strcmp(significanceMethod,'timeShiftedSurrogates')
        [causalities, significances] = timeShiftedSurrogates(drivers, drivens, windowStartIndices, samplesPerWindow, sigThreshold, delay, lag, standardize, causalityMethod, verbose);
    end  
    
    % visualize output
    visualizeCausalities([drivers,drivens],causalities,significances,stepSize/timestep,fromChannels,toChannels,timelock.time(1:nsamples))
end