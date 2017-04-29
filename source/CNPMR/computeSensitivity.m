function [sensitivity] = computeSensitivity(y,X,k,tolerance)
%Computes the sensitivity of the response variable to the kth predictor
%   y is the response variable
%   X are the predictors
%   k is the index of the predictor for which sensitivity should be measured
%   tolerance are the tolerances for the Gaussian kernel used in NPMR

% estimate response variable without cross-validation
ypred = arrayfun(@(i)NPMR(y, X, i, tolerance, false), 1:length(y));

% find dk
delta = 0.05;
dk = abs(max(X(k,:))-min(X(k,:))) * delta;

% nudge Xk up and down
ynudged = [y,y];
Xnudged = [X,X];
Xnudged(k,1:length(y)) = Xnudged(k,1:length(y)) - dk;
Xnudged(k,length(y)+1:length(ynudged)) = Xnudged(k,length(y)+1:length(ynudged)) + dk;

% estimate response ynudged
yprednudged = arrayfun(@(i)NPMR(ynudged, Xnudged, i, tolerance, false), 1:length(ynudged));

% estimate sensitivity 
sensitivity = sum(abs(yprednudged-[ypred,ypred]))/(length(ynudged)*abs(max(y)-min(y))*delta);

end

