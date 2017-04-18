function [causality] = CNPMR(y, Xi, Z, delay, embeddingDimension, yTolerance, XiTolerance, ZTolerance)
%This function computes the (conditional) Granger causality from Xi to Y/Z,
%where Z are all predictors in X, except Xi
%   y is the variable to predict
%   Xi is the predictor used for conditional Granger causality
%   Z are the predictors that are not used for conditional Granger causality
%   delay is the delay of the time-delay embedding
%   embeddingDimension is the dimension of the time-delay embedding
%   yTolerance is the variance of the Gaussian kernel for variable y
%   XiTolerance is the variance of the Gaussian kernel for variable Xi
%   ZTolerance are the variances of the Gaussian kernel for variable Z

% find best parameters for time-delay embedding
if isempty(delay)
    
    %find best delay
    
end
if isempty(embeddingDimension)
    
    %find best embeddingDimension

end
if isempty(yTolerance)
    
    %find best yTolerance

end
if isempty(XiTolerance)
    
    %find best XiTolerance

end
if isempty(ZTolerance) && not(isempty(Z))
    
    %find best ZTolerance

end

% create time-delay embedding
indicesToPredict = ((embeddingDimension-1) * delay + 1):length(y);
yTarget = y(indicesToPredict);
yPredictors = cell2mat(arrayfun(@(i)y(indicesToPredict-i*delay)', 1:(embeddingDimension-1), 'UniformOutput', false))';
XiPredictors = cell2mat(arrayfun(@(i)Xi(indicesToPredict-i*delay)', 1:(embeddingDimension-1), 'UniformOutput', false))';
if isempty(Z)
    ZPredictors = Z;
else
    ZPredictors = cell2mat(arrayfun(@(i)Z(:,indicesToPredict-i*delay)', 1:(embeddingDimension-1), 'UniformOutput', false))';
end

% predict y with and without Xi
toleranceWithoutXi = [repmat(yTolerance,embeddingDimension-1,1);repmat(ZTolerance,embeddingDimension-1,1)];
ypredWithoutXi = arrayfun(@(i)NPMR(yTarget, [yPredictors;ZPredictors], i, toleranceWithoutXi), 1:length(yTarget));
toleranceWithXi = [toleranceWithoutXi;repmat(XiTolerance,embeddingDimension-1,1)];
ypredWithXi = arrayfun(@(i)NPMR(yTarget, [yPredictors;ZPredictors;XiPredictors], i, toleranceWithXi), 1:length(yTarget));

% compute error variances
varWithoutXi = var(yTarget-ypredWithoutXi);
varWithXi = var(yTarget-ypredWithXi);

% compute causality
causality = log(varWithoutXi/varWithXi);
