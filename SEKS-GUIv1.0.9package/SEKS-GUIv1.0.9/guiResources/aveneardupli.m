function [pu,za,i,dummyout] = aveneardupli(p,z,gridSpan,proxLimit)
% aveeardupli            - averages values closer than 0.1% that may duplicates
%
%  all the duplicate values (with same s/t p coordinates) are averaged.
%  The returned coordinates pu are unique, while za is the corresponding
%  averaged value.  The index i is such that pu=p(i,:)
%
%  SYNTAX :
% 
%  [pu,za,i] = aveneardupli(p,z,proximityLimit);
% 
%  INPUT :
%
%  p          n by d     matrix of the coordinates of n points in a s/t space of dimension d
%  z          n by 1     vector of z values
%  gridSpan   1 by d     vector of grid size in each of the d directions used
%  proxLimit  1 by 1     scalar that designates the limit below which data are
%                        considered as co-located
%
%  OUTPUT :
%
%  pu         nu by d    matrix of the coordinates of nu unique points in a space of dimension d, 
%                           note that nu<=n
%  za         nu by 1    vector of corresponding z-values obtained by averaging the duplicate points
%  i          nu by 1    index such that pu=p(i,:)

[n,d]=size(p);
if size(z,1)~=n, error('z must have the same number of rows as p'); end
if n==0,  pu=p;  za=z;  i=[]; return; end
if size(z,2)~=1, error('z must have one column'); end

[iu,ir]=findneardupli(p,gridSpan,proxLimit);
pu=p(iu,:);
za=z(iu);
i=iu;
nu=length(iu);
for k=1:length(ir)
  nu=nu+1;
  i(nu,1)=ir{k}(1);
  za(nu,1)=mean(z(ir{k},1));
end  
pu=p(i,:);
