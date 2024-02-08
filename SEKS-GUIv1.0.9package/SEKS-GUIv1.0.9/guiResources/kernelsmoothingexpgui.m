function [zk,numNow]=kernelsmoothingexpgui(handles,ck,ch,zh,v,nhmax,dmax,numNow,totalSize,displayString,options);

% kernelsmoothing           - prediction using a Exponential kernel smoothing (Jun 14,2008)
%
% Estimate at a set of locations the values of a variable, based on
% the knowledge of the hard data values at another set of locations.
% The method used here is a Exponential kernel smoothing. The estimated 
% value at a location is a weighted linear combination of hard data
% values at surrounding locations. The weights are positive and 
% proportional to the values of a Exponential function evaluated at
% the Euclidean distances between the estimation locations and the
% locations where hard data values are known.  
%
% SYNTAX :
%
% [zk]=kernelsmoothing(ck,ch,zh,v,nhmax,dmax,options); 
%
% INPUT :
%
% ck       nk by d   matrix of coordinates for the estimation locations.
%                    A line corresponds to the vector of coordinates at
%                    an estimation location, so the number of columns in
%                    ck corresponds to the dimension of the space. There
%                    is no restriction on the dimension of the space.
% ch       nh by d   matrix of coordinates for the hard data locations,
%                    with the same convention as for ck.
% zh       nh by 1   vector of values for the hard data at the coordinates
%                    specified in ch.
% v        scalar    variance of the isotropic Gaussian kernel distribution.
%                    A higher values for v provides a higher smoothing for
%                    the zk estimates.
% nhmax    scalar    maximum number of hard data values that are considered for the
%                    computations at each estimation location.
% dmax     scalar    maximum distance between an estimation location and existing hard
%                    data locations. All hard data locations separated by a distance
%                    smaller than dmax from an estimation location will be included in
%                    the estimation process for that location, whereas other hard data
%                    locations are neglected.
% options  scalar    optional parameter that can be used if default value is not
%                    satisfactory (otherwise this vector can simply be omitted from the
%                    input list of variables). options is equal to 1 or 0, depending if
%                    the user wants or does not want to display the order number of the
%                    location which is currently processed by the function. 
%
% OUTPUT :
%
% zk       nk by 1   vector of estimated values at the estimation locations. Values coded
%                    as NaN mean that no estimation has been performed at that location,
%                    due to the lack of available data in the neighbourhood.

%%%%%% Initialize the parameters

if nargin<11,
  options(1)=0;
end;

if size(ck,1)==0
  zk=[];
  return;
else
  nk=size(ck,1);           % nk is the number of estimation points
  nh=size(ch,1);           % nh is the number of hard data
  zk=zeros(nk,1)*NaN;
end

if options(1)==1,
  num2strnk=num2str(nk);
end;

isST = (length(dmax)==3);

%%%%%% Main loop starts here
count=0;

if (isST)      % IF an S-T case

  for i=1:nk,
    if count>15
      numNow=numNow+count;
      processPercentDisplay(handles,displayString,numNow/totalSize*100);
      count=0;
    end;
    
    ck0=ck(i,:);
    [chlocal,zhlocal,dh,sumnhlocal]=neighbours(ck0,ch,zh,nhmax,dmax);
    if sumnhlocal>0,
      dhst = dh(:,1) + dmax(3)*dh(:,2);
      lam=exp(-dhst/v);
      lam=lam/sum(lam);
      zk(i)=lam'*zhlocal;
    end;
    if options(1)==1,
      disp([num2str(i),'/',num2strnk]);
    end;
  end;

else

  for i=1:nk,
    if count>15
      numNow=numNow+count;
      processPercentDisplay(handles,displayString,numNow/totalSize*100);
      count=0;
    end;
    
    ck0=ck(i,:);
    [chlocal,zhlocal,dh,sumnhlocal]=neighbours(ck0,ch,zh,nhmax,dmax);
    if sumnhlocal>0,
      lam=exp(-dh/v);
      lam=lam/sum(lam,1);   % 2009-04-08: Corrected from lam=lam/sum(lam)
      zk(i)=lam'*zhlocal;
    end;
    if options(1)==1,
      disp([num2str(i),'/',num2strnk]);
    end;
    count=count+1;
  end;

end

%%
function processPercentDisplay(handles,displayString,percentNow)
displayString=[displayString ':  ' num2str(floor(percentNow)) '%'];
set(handles.feedbackEdit,'String',displayString);
pause(0.01);

