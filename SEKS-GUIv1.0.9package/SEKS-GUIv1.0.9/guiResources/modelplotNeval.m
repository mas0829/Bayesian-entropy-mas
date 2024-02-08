function [v]=modelplotNeval(d,model,param,Property,Value);% modelplot                 - plot variogram or covariance models (Jan 1,2001)%% Plot the values of single variogram and covariance models,% as well as for nested variogram and covariance models.% Nested models are defined as linear combinations of several% basic models.%% SYNTAX :%% [v]=modelplot(d,model,param,Property,Value);%% INPUT :%% d         n by 1   vector of sorted distance values for which the%                    variogram or covariance model must be computed%                    or displayed.% model     string   that contains the name of the variogram/covariance %                    model.% param     1 by k   vector of parameters for model, according to the%                    conventions for the corresponding variogram or %                    covariance model.% Property  1 by p   cell array where each cell cell is a string that contains%                    a legal name of a plot object property. This variable is%                    optional, as default values are used if Property is missing%                    from the input list of variables. Execute get(H), where H is%                    a plot handle, to see a list of plot object properties and%                    their current values. Execute set(H) to see a list of plot%                    object properties and legal property values. See also the help%                    for plot.m.% Value     1 by p   cell array where each cell is a legal value for the corresponding%                    plot object property as specified in Property.%% OUPUT :%% v         n by 1   optional vector of estimated variogram or covariance values at%                    the distances specified in d.%% NOTE :%% 1- For example, when Property={'Color','Linewidth'} and Value={'[0.5 0.5 1]',1},% the model will be displayed as a purple broken line with a width of 1 pixel.% By default, modelplot.m will use the default properties for plot.m.%% 2- When the output variable is specified, the graphic is not displayed and% modelplot.m simply returns the values for this variable instead. %% 3- If nested models must be displayed, the model variable is a cell array% such that each cell is a string that contains the name of a model. E.g.,% for a nested variogram model including a nugget effect model and an % exponential model, model={'nuggetV','exponentialV'}. In that case, the param % variable is a cell array too, where each cell contains the parameters of% the corresponding model. E.g., if the nugget effect is equal to 0.2 and the% exponential model has a sill equal to 0.8 and a range equal to 1,% param={0.2,[0.8 1]}.%%%%%% Initialize the parametersif iscell(model)==0,  nm=1;  model={model};  param={param}; else  nm=length(model);end;if nargin>3,  if ~iscell(Property),    Property={Property};    Value={Value};    noptions=1;  else    noptions=length(Property);  end;else  noptions=0;end;%%%%%% Compute the variogram/covariance model valuesv=zeros(size(d));for i=1:nm,  % v=v+eval([model{i},'(d,param{i})']);  v=v+modeleval(model{i},d,param{i});end;%%%%%% Display the variogram/covariance model values if requiredif nargout==0,  test=(ishold==1);  a=plot(d,v);  for j=1:noptions,    set(a,Property{j},Value{j});  end;  xlabel('Distance');  ylabel('Variogram/Covariance');  if test==0,    hold off;  end;end;        