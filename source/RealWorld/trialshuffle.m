%% script to do significance analysis by trial suffling

clear
load('data\fullDataSet.mat');

[r, c] = find(isnan(data) > 0);
minIndex = min(c) - 1;

data = data(:,1:minIndex);

% size of each window
windowSize = 100;

% number of windows that should be evaluated
numWindows = floor(minIndex/windowSize);

% Parameters for realworld data selection
Contrast = 1;
Attention = 1;
FromArea = [1,2,4];
ToArea = [1,2,4];

data = data(data(:,1) == Contrast & data(:,2) == Attention);



result = zeros(size(FromArea,2),size(ToArea,2),16,16,numWindows,60,2);