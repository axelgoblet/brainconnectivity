function [ypred] = NPMR(y, X, i, tolerance, crossValidation)
%This function predicts the next value of y using NPMR.
%   y variable to predict
%   X are the predictor variables
%   i is the index to predict
%   tolerance are the variances of the Gaussian kernel for each predictor
%   crossValidation defines whether cross-validation is used

% extract index
Xi = X(:,i);
if crossValidation
    yWithouti = y([1:(i-1),(i+1):length(y)]);
    XWithouti = X(:,[1:(i-1),(i+1):length(y)]);
else
    yWithouti = y;
    XWithouti = X;
end

% compute weights
differences = (XWithouti-repmat(Xi,1,length(yWithouti)));
normalizedDifferences = differences ./ repmat(tolerance,1,length(yWithouti));
wij = exp(-0.5*normalizedDifferences.^2);
wi = prod(wij,1);

% predict yt
ypred = sum(yWithouti.*wi) / sum(wi);

end