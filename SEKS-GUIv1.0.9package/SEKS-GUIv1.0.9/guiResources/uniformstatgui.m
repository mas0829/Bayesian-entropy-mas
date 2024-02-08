function [m,v,q50]=uniformstatgui(param);% uniformstat               - Mean, variance and median of the uniform distribution (Jan 1,2001)%% Return the mean, variance and median for a uniform% distribution with specified lower and upper bounds% parameters.%% SYNTAX :%% [m,v,q50]=uniformstat(param);%% INPUT :%% param    n by 2   parameters of the uniform distribution, where :%                   param(1) is the lower bound of the distribution,%                   param(2) is the upper bound of the distribution,%                   with param(1)<=param(2). %% OUTPUT :%% m        n by 1   mean of the distribution.% v        n by 1   variance of the distribution.% q50      n by 1   mediane of the distribution.%% 20150910-AK: Allowed vector of uniform SD to be sent to the function%a=param(:,1);b=param(:,2);m = (a+b)/2;v = ((b-a).^2)/12;q50 = m;