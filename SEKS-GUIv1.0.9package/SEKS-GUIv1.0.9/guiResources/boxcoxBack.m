function [bktrsfData] = boxcoxBack(x,lambda)
%
% Function implementing the boxcox backtransformation of a transformed
% data set to the original space. Uses the transformation parameter lambda.
% 
% INPUT
% x           nxd  Matrix in d-D of boxcox transformed values
% lambda      1x1  boxcox parameter that was used in the transformation
%
% OUTPUT
% trsfData    nxd  Matrix in d-D of backtransformed data
%

epsilon = 1e-6;      % Consider -1e-6 <lambda < 1e-6 to be equal to zero
if abs(lambda) < epsilon
  bktrsfData = exp(x);
else
  % 20150710 AK: If lambda<0, then we should prevent raising any values
  % (lambda*x + 1) < 0 to the negative exponent (1/lambda) to avoid
  % imaginary numbers.
  if (lambda<0) % IF negative lambda
    % We must have lambda*x+1>0 or x<-1/lambda (because lambda<0).
    % Note that x=-1/lambda backtransforms to Inf.
    factor = -1/lambda;
    unacceptableIndx = (x>=factor);
    if (sum(unacceptableIndx) > 0) % IF exist bad values to backtransform
      % Use the max of permissible transformed values as a cap for those
      % vector elements that would otherwise go too high to backtransform
      xUnacceptable = x(unacceptableIndx); % Isolate, if needed for debugging
      maxOfRest = max(x(~unacceptableIndx));
      x(unacceptableIndx) = maxOfRest;
    end % END IF exist bad values to backtransform
  end % END IF negative lambda
  bktrsfData = (lambda*x + 1).^(1/lambda);
end
