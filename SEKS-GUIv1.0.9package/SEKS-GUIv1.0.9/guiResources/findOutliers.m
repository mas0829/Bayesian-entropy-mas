function [sortOrder,mildOutlId,mildOutliers,extrOutlId,extrOutliers,...
          noExtrOutl,noMildOutl] = findOutliers(x)
%
% Function used to identify potential outliers in a data distribution using
% the box plot graphical technique. According to this technique, fences are
% defined using the data distribution along the 25th and 75 percentiles.
% Outliers are deemed to be data extending beyond the defined fences. Two
% different types of outliers are identified: Mild and extreme outliers.
% The characterization depends on the type of fence the outliers go beyond.
%
% INPUT:
% x            nx1       Vector of values to be scanned for outliers
%
% sortOrder    nx1       x is sorted in the function so that sortedx=x(sortOrder)
% mildOutlId   kx1       Positions of mild outliers in original vector x
% mildOutliers kx1       Vector of mild outliers corresponding to mildOutlId
% extrOutlId   lx1       Positions of extreme outliers in original vector x
% extrOutliers lx1       Vector of extreme outliers corresponding to extrOutlId
% noExtrOutl   (n-l)x1   Vector of x values cleared of extreme outliers
% noMildOutl   (n-l-k)x1 Vector of x values cleared of mild and extreme outliers
%

% Last modified by Alexander Kolovos on March 7, 2006.

% Example matrix...
% x = [30, 171, 184, 201, 212, 250, 265, 270, 272, ...
%      289, 305, 306, 322, 322, 336, 346, 351, 370, ...
%      390, 404, 409, 411, 436, 437, 439, 441, 444, ...
%      448, 451, 453, 470, 480, 482, 487, 494, 495, ...
%      499, 503, 514, 521, 522, 527, 548, 550, 559, ...
%      560, 570, 572, 574, 578, 585, 592, 592, 607, ...
%      616, 618, 621, 629, 637, 638, 640, 656, 668, ...
%      707, 709, 719, 737, 739, 752, 758, 766, 792, ...
%      792, 794, 802, 818, 830, 832, 843, 858, 860, ...
%      869, 918, 925, 953, 991, 1000, 1005, 1068, 1441];

if ~isvector(x)
  error('findOutliers: Input array must be a vector.');
else
  
[x,sortOrder] = sort(x);

% Lower quartile (25 percentile)
lquaPt = 0.25*(length(x)+1);  % Ordered point
lqua = x(floor(lquaPt))+mod(lquaPt,floor(lquaPt))*...
       ( x(floor(lquaPt)+1)-x(floor(lquaPt)) );

% Upper quartile (75 percentile)
uquaPt = 0.75*(length(x)+1); % Ordered point
uqua = x(floor(uquaPt))+mod(uquaPt,floor(uquaPt))*...
       ( x(floor(uquaPt)+1)-x(floor(uquaPt)) );

% Interquartile range
iq = uqua-lqua;

% Lower inner fence
lif = lqua - 1.5*iq;
% Upper inner fence
uif = uqua + 1.5*iq;

% Lower outer fence
lof = lqua - 3*iq;
% Upper outer fence
uof = uqua + 3*iq;

mildOutlId = x>uif & x<=uof;
mildOutliers = x(mildOutlId);
noMildOutl = x(x<=uif);           % Tighter restriction

extrOutlId = x>uof;
extrOutliers = x(extrOutlId);
noExtrOutl = x(x<=uof);           % Milder restriction

end