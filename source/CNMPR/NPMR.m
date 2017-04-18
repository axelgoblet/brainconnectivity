function [ypred] = NPMR(y, X, i, tolerance)
%This function predicts the next value of y using NPMR.
%   y variable to predict
%   X are the predictor variables
%   i is the index to predict
%   tolerance are the variances of the Gaussian kernel for each predictor

% extract index
Xi = X(:,i);
yWithouti = y([1:(i-1),(i+1):length(y)]);
XWithouti = X(:,[1:(i-1),(i+1):length(X)]);

% compute weights
differences = (XWithouti-repmat(Xi,1,length(X)-1));
normalizedDifferences = differences ./ repmat(tolerance,1,length(X)-1);
wij = exp(-0.5*normalizedDifferences.^2);
wi = prod(wij,1);

% predict yt
ypred = sum(yWithouti.*wi) / sum(wi);