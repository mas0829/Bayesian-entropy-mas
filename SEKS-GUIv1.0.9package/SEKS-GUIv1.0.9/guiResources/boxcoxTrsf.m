function [trsfData,lambda] = boxcoxTrsf(x,lambdaIn)
%
% Function implementing the boxcox transformation of a data distribution
% into a near-normal distribution. Uses Matlab fminsearch.
% User may transform additional data based on a parameter set previously.
% 
% INPUT
% x           nxd  Input data where d=1,2. Must contain positive-only values
% lambdaIn    1x1  Optional input. Used in case a transformation parameter
%                  has already been defined and we wish to transform
%                  additional data based on this parameter.
%
% OUTPUT
% trsfData    nxd  Vector of boxcox transformed data
% lambda      1x1  boxcox transformation parameter
%
  if length(size(x))>2 % Is input a matrix of more than 2-D?
    error('boxcoxTrsf.m: Input can be either a vector or a 2-D matrix.');
  end

  if ~isvector(x)      % Is input a vector?
    noVector = 1;
    xRows = size(x,1);
    xCols = size(x,2);
    x = reshape(x,xRows*xCols,1);
  else
    noVector = 0;
  end
  
  if sum(x<=0)          % Has input vector any negative or zero values?
    error('boxcoxTrsf.m: Input vector must have positive-only values.');
  end
  
  if nargin==1
    % fminsearch looks for the minimum of a function, whereas in the boxcox
    % transformation we want the lambda so that the function LLF is maximized. 
    % We therefore look for the minimum of -LLF (named minusLlf), instead.
    % It is suggested that -2<lambda<2. We start with an initial lambda=0.1
    [lambda] = fminsearch(@minusLlf,0.1);
    trsfData = getBoxcoxTrsfData(x,lambda);
  elseif nargin==2     % User want to transform more data based on previous param 
    trsfData = getBoxcoxTrsfData(x,lambdaIn);
    lambda = lambdaIn; % Do not modify transformation parameter.  
  else  
    error('boxcoxTrsf.m: Invalid number of input arguments.')  
  end

  if noVector
    trsfData = reshape(trsfData,xRows,xCols);
  end
       
  function f = minusLlf(lambda)

    n = length(x);
    f = 0.5*n*log(fx(x,lambda)) - (lambda-1)*sum(log(x));

    function y = fx(x,lambda)

      n = length(x);
      if lambda      % If lambda is non-zero
        sum1 = sum((x.^lambda - 1)/lambda)/n;
        y = sum(((x.^lambda - 1)/lambda - sum1).^2 / n);
      else           % If lambda is 0
        sum1 = sum(log(x))/n;
        y = sum((log(x) - sum1).^2 / n);
      end

    end % Function fx

  end % Function minusLlf

end





function y = getBoxcoxTrsfData(x,lambda)

  epsilon = 1e-6;      % Consider -1e-6 <lambda < 1e-6 to be equal to zero
  if abs(lambda) < epsilon
    y = log(x);
  else
    y = (x.^lambda - 1)/lambda;
  end

end