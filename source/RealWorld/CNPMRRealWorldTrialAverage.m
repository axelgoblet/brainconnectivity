%% Computing CNPMR causality and significance on Real World data
% Make sure that the entire source/CNPMR folder added to your current Matlab
% path. Also brainconnectivity/data should be added to the path.

clear
load('data\fullDataSet.mat');

% electrodes to be evaluated. the current code evaluates electrode x in V1
% to electrode x in V4
electrodes = 16;

% number of windows that should be evaluated
numWindows = 25;

% surrogate information for significance testing
numSurrogates = 20;
surrogateMinLag = 20;

% ?maximum lag of model that we want to evaluate?
lag=5;

% Threshold for significance analysis
SigThreshold = 0.05;

% Parameters for realworld data selection
Contrast = 1;
Attention = 1;
FromArea = [1,2,4];
ToArea = [1,2,4];
for p = 1:size(FromArea,2)
    for q = 1:size(ToArea,2)
       toData = data(data(:,1) == Contrast & data(:,2) == Attention & data(:,3) == ToArea(q), :);
        fromData = data(data(:,1) == Contrast & data(:,2) == Attention & data(:,3) == FromArea(p), :);

        % remove NaN values
        [r, c] = find(isnan(toData) > 0);
        minIndex = min(c) - 1;
        toData = toData(:, 1:minIndex);

        [r, c] = find(isnan(fromData) > 0);
        minIndex = min(c) - 1;
        fromData = fromData(:, 1:minIndex);

        averageToData = zeros(electrodes, size(toData, 2)-1);
        averageFromData = zeros(electrodes, size(fromData, 2)-1);

        for e = 1 : electrodes
            averageToData(e,:) = [Contrast, Attention, ToArea(q), e, mean(toData(toData(:,4) == e ,6:end))];
            averageFromData(e,:) = [Contrast, Attention, FromArea(p), e, mean(fromData(fromData(:,4) == e ,6:end))];
        end



        % results matrix
        % index 1: which From electrode
        % index 2: which To electrode
        % index 3: window number
        % index 4: 1 = causality, 2 = significance
        results1 = zeros(16,16,25,2);
        results2 = zeros(16,16,25,2);


        % Sometimes data for later electrodes seems to be missing. 
        % This makes sure if later electrodes do not exist, they are not evaluated.
        [r, c] = find(isnan(averageToData) > 0);
        if(isempty(min(r)))
            minToIndex = 16
        else
            minToIndex = min(r) - 1
        end

        [r, c] = find(isnan(averageFromData) > 0);
        if(isempty(min(r)))
            minFromIndex = 16;
        else
            minFromIndex = min(r) - 1;
        end


        for firstE = 1 : minFromIndex
            for secondE = 1 : minToIndex
                for w = 1 : numWindows
                    % put data in format for analysis
                    X = [averageFromData(firstE,5:end)',averageToData(secondE,5:end)'];

                    % size of a window
                    windowSize = floor(size(X,1)/numWindows);
                    %select measurements in current trial with current window            
                    intervalStart = windowSize*(w-1)+1;
                    if windowSize*w+1 > size(X,1)
                        intervalEnd = windowSize*w;
                    else
                        intervalEnd = windowSize*w+1;
                    end
                        windowX = X(intervalStart:intervalEnd,:);          
            
                    % left out a couple of results since the causality computation
                    % would error on these cases:
                    % "Error using histc
                    % Edge vector must be monotonically non-decreasing."
                    if false 
                    else
                    %compute causality for current window FromArea --> ToArea
                    disp(['Calculating Overall Causality from V', num2str(FromArea(p)), ' to V', num2str(ToArea(q)),  ' for window ', num2str(w), ' between electrode ', num2str(firstE), ' in V', num2str(FromArea(p)) ' and ', num2str(secondE), ' in V', num2str(ToArea(q))]);
                    [causality2,xR2_1,isSignificant2,sensitivity1] = CNPMR(windowX(:,2)',windowX(:,1)',[],1,lag,1,1,[],false);
                results1(firstE,secondE,w,1) = causality2;
                results1(firstE,secondE,w,2) = isSignificant2;
            end
            
            % left out a couple of results since the causality computation
            % would error on these cases:
            % "Error using histc
            % Edge vector must be monotonically non-decreasing."
            if false 
            else
                %compute causality for current window  ToArea --> FromArea
                disp(['Calculating Overall Causality from V', num2str(ToArea(q)), ' to V', num2str(FromArea(p)),  ' for window ', num2str(w), ' between electrode ', num2str(secondE), ' in V', num2str(ToArea(q)) ' and ', num2str(firstE), ' in V', num2str(FromArea(p))]);
                [causality2,xR2_1,isSignificant2,sensitivity1] = CNPMR(windowX(:,1)',windowX(:,2)',[],1,lag,1,1,[],false);
                results2(secondE,firstE,w,1) = causality2;
                results2(secondE,firstE,w,2) = isSignificant2;
            end
        end
    end
end

save(['resultsV',num2str(FromArea(p)),'toV',num2str(ToArea(q)),'.mat'], 'results1');
save(['resultsV',num2str(ToArea(q)),'toV',num2str(FromArea(p
+,'.mat'], 'results2'); 
    end
end

