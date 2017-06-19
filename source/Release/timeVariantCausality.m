function [] = timeVariantCausality(timelock, fromChannels, toChannels, windowSize, stepSize, standardize, method)
    
    % number of samples
    [~,nanIndices] = find(isnan(squeeze(timelock.trial(:,1,:))));
    nsamples = min(nanIndices)-1;

    % compute start points of windows
    windowStarts = timelock.time(1):stepSize:timelock.time(nsamples);
    
    % remove last window if too small
    if timelock.time(nsamples) - windowStarts(length(windowStarts)) < windowSize
        windowStarts = windowStarts(1:(length(windowStarts)-1));
    end
        
    % time step
    timestep = timelock.time(2) - timelock.time(1);
    
    % indices where windows start
    windowStartIndices = round((windowStarts - windowStarts(1)) / timestep) + 1;
    
    % samples per window
    samplesPerWindow = round(windowSize / timestep);
    
    % extract diver and driven vars
    drivers = timelock.trial(:,fromChannels,1:nsamples);
    drivens = timelock.trial(:,toChannels,1:nsamples);
    
    % compute causalities
    [causalities, significances] = ReleaseTrialShuffle(drivers, drivens, windowStartIndices, samplesPerWindow, standardize, method);
    %[causalities, significances] = TrialBasedSurrogate(drivers, drivens, windowStartIndices, samplesPerWindow, standardize, method);
    
    % visualize causalities
end