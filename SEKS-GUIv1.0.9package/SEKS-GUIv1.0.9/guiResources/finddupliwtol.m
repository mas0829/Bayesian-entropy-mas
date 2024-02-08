function [iu,ir]=finddupliwtol(p,stFlag,tol)
%  finddupliwtol         - find the duplicate coordinates             
%
%  Find in a set of points those that are in duplicates (i.e. having the same
%  coordinates). Extended version of finddupli.m. In present version:
%  a) noncollocated data are found by input data analysis, rather than the
%     built-in "unique" function
%  b) a flag specifies whether the incoming data are spatiotemporal. This helps 
%     identify collocation better when data are spatially collocated but at
%     different time instances.
%  c) a tolerance value tol is specified by the user to designate specific
%     distance threshold below which a pair of observations is deemed to be
%     spatially collocated. If tol not specified, default tol value is 1e-8. 
%
%  SYNTAX :
% 
%  [iu,ir]=finddupli(p);
% 
%  INPUT :
%
%  p          n by d     matrix of the coordinates of n points in a space of dimension d
%  stFlag     double     If nonzero, p has d-1 spatial coordinates plus time
%  tol        double     tolerance below which coordinates are deemed duplicate
%                        Has a default value of 1e-8. A double or NaN must be specified. 
% 
%  OUTPUT :
%
%  iu        nu by 1    vector with the indices of the points that are not in duplicates
%                       When there are no duplicates, then p(iu,:) is equal to p
%                       otherwise nu<n and p(iu,:) is the subset of p that do not have duplicate
%                       coordinates
%  ir        1 by nr    cell array of the duplicate points.  
%                       When there are no duplicates, then ir is empty
%                       Otherwise ir{k} is a k=th cluster of duplicate points, so that
%                       p(ir{k},:) is the k-th subset of p having all the same coordinates

if (isnan(tol))
  tol = 1.e-8;  % Default value
end
iu=[1:size(p,1)]';
[n d]=size(p);
i = (1:n)';
spi = sortrows([p i],1:d);
ps = spi(:,1:d);
is = spi(:,d+1);
ind = abs(ps(2:end,1) - ps(1:end-1,1)) < tol;
for k=2:d-1
  ind = ind & (abs(ps(2:end,k) - ps(1:end-1,k)) < tol);
end

if (~stFlag)

  ind = ind & (abs(ps(2:end,d) - ps(1:end-1,d)) < tol);
  ind = [0; ind; 0];
  if sum(ind)  % If there are non-zero elements, ie, if near duplicates exist
    fs = find(ind(1:end-1) == 0 & ind(2:end) == 1);
    fe = find(ind(1:end-1) == 1 & ind(2:end) == 0);
    irv=[];
    for k = 1 : length(fs)
      ir{k}=is(fs(k):fe(k));
      irv=[irv;ir{k}];
    end
    iu=setdiff(iu,irv);
    if isempty(iu), iu=[]; end
  else
    ir = [];
  end
  
else

  iDupCnt = 0;
  ind = [0; ind; 0];
  if sum(ind)  % If there are non-zero elements, ie, if near duplicates exist
    fs = find(ind(1:end-1) == 0 & ind(2:end) == 1);
    fe = find(ind(1:end-1) == 1 & ind(2:end) == 0);
    irv=[];
    emptyirFlag = 1;
    for k = 1 : length(fs)
 
      iSrch = fs(k):fe(k);
      psPart = ps(iSrch,:);
      nt = size(psPart,1);
      isPart = is(iSrch,:);  % Locate original indices
      i1 = (1:nt)';       % Create index for subset
      
      spi1 = sortrows([psPart i1 isPart],d);
      ps1 = spi1(:,1:d);
      is1 = spi1(:,d+1);

      indt = (abs(ps1(2:end,d) - ps1(1:end-1,d)) < tol);

      indt = [0; indt; 0];
      if sum(indt)  % If there are non-zero elements, ie, if near duplicates exist
        fts = find(indt(1:end-1) == 0 & indt(2:end) == 1);
        fte = find(indt(1:end-1) == 1 & indt(2:end) == 0);
        for kt = 1 : length(fts)
          iDupCnt = iDupCnt + 1;
          % Assign original indices of duplicate points
          ir{iDupCnt} = isPart( is1(fts(kt):fte(kt)) );
          irv = [irv;ir{iDupCnt}];
          emptyirFlag = 0;
        end
      end
      
    end
    iu = setdiff(iu,irv);
    if isempty(iu), iu=[]; end
    if (emptyirFlag)
      ir = [];
    end
  else
    ir = [];
  end
  
end