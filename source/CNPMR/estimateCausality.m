function [causality, xR2, sensitivity] = estimateCausality(y, Xi, Z, delay, embeddingDimension, yTolerance, XiTolerance, ZTolerance, includeSensitivity)
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
%   includeSensitivity defines whether sensitivity should be computed

% create time-delay embedding
indicesToPredict = (embeddingDimension * delay + 1):length(y);
yTarget = y(indicesToPredict);
yPredictors = cell2mat(arrayfun(@(i)y(indicesToPredict-i*delay)', 1:embeddingDimension, 'UniformOutput', false))';
XiPredictors = cell2mat(arrayfun(@(i)Xi(indicesToPredict-i*delay)', 1:embeddingDimension, 'UniformOutput', false))';
if isempty(Z)
    ZPredictors = Z;
else
    ZPredictors = cell2mat(arrayfun(@(i)Z(:,indicesToPredict-i*delay)', 1:embeddingDimension, 'UniformOutput', false))';
end

% predict y with and without Xi
fitModel = @(y,X,tolerance,crossValidation)arrayfun(@(i)NPMR(y, X, i, tolerance, crossValidation), 1:length(yTarget));
toleranceWithoutXi = [repmat(yTolerance,embeddingDimension,1);repmat(ZTolerance,embeddingDimension,1)];
ypredWithoutXi = fitModel(yTarget, [yPredictors;ZPredictors], toleranceWithoutXi, true);
toleranceWithXi = [toleranceWithoutXi;repmat(XiTolerance,embeddingDimension,1)];
predictorsWithXi = [yPredictors;ZPredictors;XiPredictors];
ypredWithXi = fitModel(yTarget, predictorsWithXi, toleranceWithXi, true);

% compute error variances
varWithoutXi = var(yTarget-ypredWithoutXi);
varWithXi = var(yTarget-ypredWithXi);

% compute causality
causality = log(varWithoutXi/varWithXi);

% compute xR2
xR2 = 1 - varWithoutXi / var(yTarget);

% compute sensitivity
if includeSensitivity
    sensitivity = arrayfun(@(i)computeSensitivity(yTarget,predictorsWithXi,i+(1+length(ZTolerance))*embeddingDimension,toleranceWithXi),1:embeddingDimension);
else
    sensitivity = [];
end
    
end
