function [cdfVector,xSorted] = seksguiCdfcalc(x)
%SEKSGUICDFCALC Compute an estimate of the univariate cumulative
%   distribution function from a set of values for a variable.
%   Makes use of the BMELIB function cdfest (statlib/cdfest.m)

% Input data must be a vector.
if (min(size(x)) ~= 1)
    error(sprintf('SEKSGUI error: Expecting vector input.'));
    return;
end

% Remove any NaNs from input vector.
x = x(~isnan(x));
if length(x) == 0
   error(sprintf('SEKSGUI error: Input sample has no valid data'));
   return;
end

[xSorted,cdfVector] = cdfest(x);

cdfVector = [0 ; cdfVector];