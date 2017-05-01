function [causality, xR2, isSignificant, sensitivity] = CNPMR(y, Xi, Z, delay, embeddingDimension, yTolerance, XiTolerance, ZTolerance, includeSensitivity, significanceLevel)
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
%   includeSensitivity defines whether sensitivity should be computed (default true)
%   significanceLevel is the level of significance desired (default 0.05)

if nargin < 10
    significanceLevel = 0.05;
    
    if nargin < 9
        includeSensitivity = true;
    end
end

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

% generate time shifts
numberOfSurrogates = 1/significanceLevel - 1;
shifts = round(unifrnd(0.33,0.66,1,numberOfSurrogates)*length(Xi));

% estimate causalities with shifted predictors
surrogateEstimates = arrayfun(@(i)estimateCausality(y, Xi([i:length(Xi),1:(i-1)]), Z, delay, embeddingDimension, yTolerance, XiTolerance, ZTolerance, false), shifts);

% find threshold
significanceThreshold = max(surrogateEstimates);

% compute unshifted causality
[causality, xR2, sensitivity] = estimateCausality(y, Xi, Z, delay, embeddingDimension, yTolerance, XiTolerance, ZTolerance, includeSensitivity);

isSignificant = causality > significanceThreshold;

end
