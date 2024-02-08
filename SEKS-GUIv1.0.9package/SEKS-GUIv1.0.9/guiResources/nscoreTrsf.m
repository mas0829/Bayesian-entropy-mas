function [ntransf,ntransfTable] = nscoreTrsf(z,wg)
%
% Compute Normal Scores of a Data Set
%
% INPUT :
%
% z            n by 1  column vector of values.
% wg           n by 1  optional vector of weights associated with the values
%                      in z (see decluster.m).
% OUTPUT :
%
% ntransf      n by 1  vector of the n-transformed values.
% ntransfTable n by 2  ascending-ranked vectors of the original (1st column)
%                      and the n-transformed (2nd column) values
%
% REMARKS :
%
% 1. A maxdat = 500000 parameter controls the maximum number of values to use
%    in constructing the transformation table
%
% 2. Random Despiking (THIS IS WHY WE NEED A RANDOM NUMBER GENERATOR)
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                        %
% Based on the GSLIB nscore.f program                                    %
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
% Matlab version from GSLIB code: Alexander Kolovos, 20051206            %
%                                                                        %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Example of suggested use:
% figure; histscaled(z,20);          % Check originals
% figure; histscaled(ntransf,20);    % Check n-score
% bck = interp1(ntransfTable(:,2),ntransfTable(:,1),ntransf,'cubic','extrap');
% figure; histscaled(bck,20);        % Check backtransformed

if nargin<2,
  wg = ones(size(z))/length(z); % Default in GSLIB code is 1 
end;

if ~isvector(z)
  error('nscoreTrsf: Input is not a vector.');
else
  if size(z,2)>size(z,1)       % Ensure z is a column vector
    z = z';          
  end
end	

rand('state',sum(100*clock));

epsilon = 1e-6;
lin = 1;
lout = 2;
doubone = 1;                   % The power used for power interpolation

getrank = 0;

tmin = -1e21;                  % Lower trimming limit
tmax = 1e21;                   % Upper trimming limit

indToInclude = (z>=tmin & z<tmax);
nt = sum(~indToInclude);       % How many extreme values?
zTbl = z(indToInclude);        % Trim data in case extreme values are included.
wgTbl = wg(indToInclude);
nd = sum(indToInclude);        % How many values to include?

zvrTbl = zTbl + rand(size(zTbl,1),1)*epsilon;

zeroWghts = wgTbl<1e-10;
zTbl = zTbl(~zeroWghts);       % Reduce included values to ones with non-zero w
wgTbl = wgTbl(~zeroWghts);
nd = nd - sum(zeroWghts);      % Update number of included values
nt = nt + sum(zeroWghts);      % How many zero weights?

twtTbl = sum(wgTbl);           % Sum of weights
wt_nsTbl = wgTbl;

if (nd<=1 || real(twtTbl<=epsilon))
  error('nscore.m: Too few data');
end

[zvrTbl,sortIndx] = sort(zvrTbl);   % Sort transformed table data
wt_nsTbl = wt_nsTbl(sortIndx); % Sort weights according to data

% Compute the cumulative probabilities and write transformation table
%
wtfac = 1/twtTbl;                 
oldcp = 0;
cp = 0;
for j=1:nd
  wTbl = wtfac*wt_nsTbl(j);
  cp = cp + wTbl;
  wt_nsTbl(j) = (cp + oldcp)/2;
  [vrgTbl,ierr] = gauinv(wt_nsTbl(j));
  oldcp = cp;
  % Reset the weight to the normal scores value
  wt_nsTbl(j) = vrgTbl;
end

ntransfTable = [zvrTbl wt_nsTbl];   % OUTPUT: Transformation table

% Now obtain the normal score transform in zvrg
%
zvrg(~indToInclude) = NaN;
zvrr = z + rand(size(z,1),1)*epsilon;
for iLoop=1:size(zvrr,1)
  if indToInclude(iLoop)
    datumPosition = locate(zvrTbl,1,nd,zvrr(iLoop));
    j = min(max(1,datumPosition),(nd-1));
    zvrg(iLoop) = dpowint(zvrTbl(j),zvrTbl(j+1),wt_nsTbl(j),wt_nsTbl(j+1),zvrr(iLoop),doubone);
    if getrank
      zvrg(iLoop) = gcum(real(zvrg));
    end
  end
end

ntransf = zvrg';






function [xp,ierr] = gauinv(p)
%
% Computes the inverse of the standard normal cumulative distribution
% function with a numerical approximation from : Statistical Computing,
% by W.J. Kennedy, Jr. and James E. Gentle, 1980, p. 95.
%
%   p    : cumulative probability value
%   xp   : G^-1(p)
%   ierr : 1 if error situation (p out of range), 0 if OK
%

lim = 1e-15;        % Beyond that point we consider NaNs for the pdf values...
pCoeff = [-0.322232431088 -1.0 -0.342242088547 -0.0204231210245 -0.0000453642210148];
qCoeff = [0.0993484626060 0.588581570495 0.531103462366 0.103537752850 0.0038560700634];

if p<lim            % ...for values either below that limit
  
  xp = -NaN;
  ierr = 1;
  
elseif p>(1-lim)    % ...or for values close to 1 up to that limit
  
  xp = NaN;
  ierr = 1;
  
else
  
  ierr = 0;
  pp = p;
  if p>0.5
    pp = 1-pp;
  end
  xp = 0;
  y = sqrt(log(1/pp/pp));
  xp = real(y + ((((y*pCoeff(5)+pCoeff(4))*y+pCoeff(3))*y+pCoeff(2))*y+pCoeff(1)) / ...
                ((((y*qCoeff(5)+qCoeff(4))*y+qCoeff(3))*y+qCoeff(2))*y+qCoeff(1)) ); 
  if real(p)==real(pp)
    xp = -xp;
  end
  if p==0.5
    xp = 0;
  end
  
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





function [j] = locate(xx,is,ie,x)
%
% Given an array "xx" of length "n", and given a value "x",
% this routine returns a value "j" such that xx(j) <= x <= xx(j+1).
% xx must be monotonic, either increasing or decreasing.
% j=0 or j=n is returned to indicate that x is out of range.
%
% Modified to set the start and end points by "is" and "ie" 
%
% Bisection Concept From "Numerical Recipes", Press et. al. 1986.
%

% Initialize lower and upper methods:
jl = is-1;
ju = ie+1;
ascnd = xx(ie)>=xx(is);
%
% If we are not done then compute a midpoint:
%
while (ju-jl)>1
  jm = floor((ju+jl)/2);
  % Replace the lower or upper limit with the midpoint:
  if ( (x>=xx(jm)) == ascnd )
    jl = jm;
  else
    ju = jm;
  end
end
% Return the array index
if (x==xx(is))
  j = is;
elseif (x==xx(ie))
  j = ie-1;
else
  j = jl;
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


