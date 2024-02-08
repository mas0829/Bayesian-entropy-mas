function [backtransf] = nscoreBack(toBackTr,ntransfTable,ylow,ymax)
%
% Compute backtransformed values based on the Normal Scores of a Data Set
%
% INPUT :
%
% toBackTr     n by 1  vector of values to be backtransformed to original space
% ntransfTable n by 2  ascending-ranked vectors of the original (1st column)
%                      and the n-transformed (2nd column) values
% ylow         1 by 1  minimum acceptable value in original space
% ymax         1 by 1  maximum acceptable value in original space
%
% OUTPUT :
%
% backtransf   n by 1  vector of the backtransformed values.
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                        %
% Based on the GSLIB backtr.f program                                    %
% GSLIB Copyright (C) 1996, The Board of Trustees of the Leland Stanford %
% Junior University.  All rights reserved.                               %
%                                                                        %
% The programs in GSLIB are distributed in the hope that they will be    %
% useful, but WITHOUT ANY WARRANTY.  No author or distributor accepts    %
% responsibility to anyone for the consequences of using them or for     %
% whether they serve any particular purpose or work at all, unless he    %
% says so in writing.  Everyone is granted permission to copy, modify    %
% and redistribute the programs in GSLIB, but only under the condition   %
% that this notice and the above copyright notice remain intact.         %
%                                                                        %
% Matlab adoption from GSLIB code: Alexander Kolovos, March 2006         %
%                                                                        %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~isempty(toBackTr)

  if ~isvector(toBackTr)
    error('nscoreBack.f: Input values must be in a vector');
  end

  nTrsf = length(toBackTr);

  for i=1:nTrsf

    % If value is in the lower tail, implement a power model interpolation to scale the output value
    % to the corresponding position between the data minimum and the acceptable minimum value set.
    % The power used in the model is based on the ratio 1/omega, where omega=2.5
    if toBackTr(i) <= ntransfTable(1,2)
      backtransf(i) = ntransfTable(1,1);
  	  cdflo = gcum(ntransfTable(1,2));
	  cdfbt = gcum(toBackTr(i));
	  backtransf(i) = dpowint(-10,cdflo,ylow,ntransfTable(1,1),cdfbt,0.4);

    % If value is in the upper tail, implement a power model interpolation to scale the output value 
    % to the corresponding position between the data maximum and the acceptable maximum value set.
    % The power used in the model is based on the ratio 1/omega, where omega=0.25
    elseif toBackTr(i) >= ntransfTable(end,2)
      backtransf(i) = ntransfTable(end,1);
	  cdfhi = gcum(ntransfTable(end,2));
	  cdfbt = gcum(toBackTr(i));
	  backtransf(i) = dpowint(cdfhi,10,ntransfTable(end,1),ymax,cdfbt,4);

    % If value is within the transformation table, use the Matlab built-in interpolation function.
    else
      backtransf(i) = interp1(ntransfTable(:,2),ntransfTable(:,1),toBackTr(i),'pchip','extrap');
	
    end
	
  end

  if size(toBackTr,1) >= size(toBackTr,2)    % If original vector is a column
    backtransf = backtransf';                % then honor the format
  end

else

  backtransf = [];

end





function [cdfarea] = gcum(x)
%
% Evaluate the standard normal cdf given a normal deviate x.  
% cdfarea is the area under a unit normal curve to the left of x.
% The results are accurate only to about 5 decimal places.
%
z = x;
if (z<0)
  z = -z;
end
t = 1/(1+0.2316419*z);
cdfarea = t*(0.31938153 + t*(-0.356563782 + ...
          t*(1.781477937 + t*(-1.821255978 + t*1.330274429))));
e2 = 0;
% 6 standard deviations or more get treatment as infinity
if (z<=6)
  e2 = exp(-z*z/2.)*0.3989422803;
end
cdfarea = 1 - e2*cdfarea;
if x<0
  cdfarea = 1-cdfarea;
end





function [result] = dpowint(xlow,xhigh,ylow,yhigh,xval,pow)
%
% Power interpolate the value of y between (xlow,ylow) and (xhigh,yhigh)
% for a value of x and a power pow.
%

if ((xhigh-xlow)<eps)
  result = (yhigh+ylow)/2.0;
else
  result = ylow + (yhigh-ylow)*(((xval-xlow)/(xhigh-xlow))^pow);
end


