function [ds,dt,c,o,vals]=crosscovarioSTgui(c1,c2,z1,z2,cls,clt,options);

% crosscovarioST            - space/time cross covariance estimation (Jan 1,2001)
%
% Single space/time covariance or cross covariance estimation.
% The function can be used when the values of the two variables
% are given for two sets of partially or totally different
% space/time locations. 
%
% SYNTAX :
%
% [ds,dt,c,o]=crosscovarioST(c1,c2,z1,z2,cls,clt,options);
%
% INPUT : 
%
% c1       n1 by d+1     matrix of space/time coordinates for the locations
%                        where the values of the first variable are known. A
%                        line corresponds to the vector of space/time coordinates
%                        at a location, so the number of columns is equal to the
%                        dimension of the space plus one, where the last column
%                        refers to the temporal coordinate. There is no restriction
%                        on the dimension of the space.
% c2       n2 by d+1     matrix of space/time coordinates for the locations where
%                        the values of the second variable are known, using the same
%                        conventions as for c1.
% z1       n1 by 1       column vector of values for the first variable at the
%                        coordinates specified in c1.
% z2       n2 by 1       column vector of values for the second variable at the
%                        coordinates specified in c2.
% cls      ncs+1 by 1    vector giving the limits of the spatial distance classes that
%                        are used for estimating the covariance or cross covariance. The
%                        distance classes are inclusive of the lower limit and excludes
%                        the upper limit. The lower limit for the first class is >=0.
% clt      nct+1 by 1    vector giving the limits of the temporal "distance" classes
%                        that are used for estimating the covariance or cross covariance.
%                        As with cls, the classes are inclusive of the lower limit and excludes
%                        the upper limit. The lower limit for the first class is >=0.
% options  1 by 1,3 or 4 vector of optional parameters that can be used if default
%                        values are not satisfactory (otherwise this vector can simply
%                        be omitted from the input list of variables), where :
%                        options(1) displays the estimated cross covariance if the value
%                        is set to one (default value is 0),
%                        options(2) and options(3) are the minimum and maximum values
%                        for the angles to be considered, using the same conventions as
%                        for the pairsplot.m function. Angles can only be specified for
%                        spatial planar coordinates, i.e. when the number of columns in
%                        c1 and c2 is equal to three,
%                        options(4) is equal to 0 if the mean is null and equal to 1 if
%                        the mean is constant but non null (default value is 1).
%
% OUTPUT :
%
% ds       ncs by nct    matrix giving the sorted values of the mean spatial distance
%                        separating the pairs of points that belong to the same space/time
%                        distance class. Each line of ds correspond to the same spatial
%                        class, where each column of ds correspond to the same temporal class.
% dt       ncs by nct    matrix giving the sorted values of the mean temporal distance
%                        separating the pairs of points that belong to the same space/time
%                        distance class, with same conventions as for ds.
% c        ncs by nct    matrix of estimated space/time covariance or cross covariance
%                        values (if z1 and z2 are identical, the function computes the
%                        space/time covariance), with same dimensions as ds and dt.
% o        ncs by nct    matrix giving the number of pairs of points that belong to the
%                        corresponding space/time distance classes, with same dimensions
%                        as ds and dt.
%
% NOTE :
%
% Due to the nature of the problem itself, it is generally expected that
% a large number of locations are involved in the computation of the
% space/time covariance or cross covariance. For that reason and to the
% opposite of the crosscovario.m function, only the loop method has been
% implemented in the function.

%%%%%% Initialize the parameters

cls=sort(cls);
clt=sort(clt);
if (cls(1)<0)||(clt(1)<0),
  error('Minimum space/time class distances must be >=0');
end;
n1=size(c1,1);
n2=size(c2,1);
ncs=length(cls)-1;
nct=length(clt)-1;
minims=cls(1);
maxims=cls(ncs+1);
minimt=clt(1);
maximt=clt(nct+1);
dim=size(c1,2)-1;

if nargin==6,
  options(1)=0;
  noptions=1;
else
  noptions=length(options);
end;

if noptions==3,
  a=options(2)*2*pi/360;
  b=options(3)*2*pi/360;
  if dim~=2,
    error('Angle limits are specified only for planar coordinates');
  end;
  if (a==b)||(min([a,b])<-pi/2)||(max([a,b])>pi/2),
    error('Angle limits must be different and between or equal to -90 and 90');
  end;
end;

%%%%%% Substract the means

if noptions==4,
  options4=options(4);
else 
  options4=1;
end;

if options4==1,
  z1=z1-mean(z1);
  z2=z2-mean(z2);
end;

%%%%% Uses a loop over the data for computing distances

ds=zeros(ncs,nct);
dt=zeros(ncs,nct);
o=zeros(ncs,nct);
c=zeros(ncs,nct);
 
for i=1:n1, 
  for j=1:n2,
    dists=sqrt(sum((c1(i,1:dim)-c2(j,1:dim)).^2));
    distt=abs(c1(i,dim+1)-c2(j,dim+1));
    conds = (dists>=max([0 minims])) & (dists<maxims);
    condt = (distt>=max([0 minimt])) & (distt<maximt);
    cond=(conds & condt);
    if noptions==3,
      dc=c1(i,1:2)-c2(j,1:2);
      if dc(1)==0,
        ang=(pi/2)*sign(dc(2));
      else
        ang=atan(dc(2)/dc(1));
      end;
      conda=(ang>=a);                  % Original crosscovarioST: "conda=(ang>a);"
      condb=(ang<b);                   % Original crosscovarioST: "condb=(ang<=b);"
      if a<b,
        cond=cond & (conda && condb);
      else
        cond=cond & (conda || condb);
      end;
    end;
    if cond==1,
      indexs=find(dists<cls(find(dists>=cls(:))+1));    % Original crosscovarioST: "indexs=sum(dists>cls);"
      indext=find(distt<clt(find(distt>=clt(:))+1));    % Original crosscovarioST: "indext=sum(distt>clt);"
      if ((indexs>=1) && (indexs<=ncs) && (indext>=1) && (indext<=nct)),
        ds(indexs,indext)=ds(indexs,indext)+dists;
        dt(indexs,indext)=dt(indexs,indext)+distt;
        o(indexs,indext)=o(indexs,indext)+1;
        c(indexs,indext)=c(indexs,indext)+z1(i)*z2(j);
      end;
    end;  
  end;
end;
 
for i=1:ncs,
  for j=1:nct,
    if o(i,j)==0,
      ds(i,j)=NaN;
      dt(i,j)=NaN;
      c(i,j)=NaN;
    else
      ds(i,j)=ds(i,j)/o(i,j);
      dt(i,j)=dt(i,j)/o(i,j);
      c(i,j)=c(i,j)/o(i,j);                        % Original crosscovarioST: "c(i,j)=c(i,j)/(2*o(i,j));"
      o(i,j)=o(i,j)/2;
    end;
  end;
end;

%%%%%% display the computed cross-covariance if options(1)=1

if options(1)==1,
  test=(ishold==1);
  minc=min(c(:));
  maxc=max(c(:));
  posx=(cls(1:ncs)+cls(2:ncs+1))/2;
  posy=(clt(1:nct)+clt(2:nct+1))/2;
  maxx=max(ds(:));
  maxy=max(dt(:));

  subplot(1,2,1);
    obj1=contour(posx,posy,c');
    clabel(obj1,'FontSize',8);
    set(gca,'FontSize',8);
    axis([0 maxx 0 maxy]);
    xlabel('Space distance','FontSize',8);
    ylabel('Time distance','FontSize',8);
    axis('square');
  subplot(1,2,2);
    mesh(posx,posy,c');
    set(gca,'FontSize',8);
    axis([0 maxx 0 maxy min([0;-1.1*sign(minc)*minc]) max([0;1.1*sign(maxc)*maxc])]);
    xlabel('Space distance','FontSize',8);
    ylabel('Time distance','FontSize',8);
    zlabel('Cross-covariance','FontSize',8);
    axis('square');

  if test==0,
    hold off;
  end;
end;

%%%%%% Check if there are no NaN

if length(find(isnan([ds;dt])))~=0,
  disp('Warning : some space/time classes do not contain pairs of points');
end;

 