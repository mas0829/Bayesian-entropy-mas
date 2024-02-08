function [V]=modeleval(model,D,param)

% To function to obtain the covariance/variogram values
% from the models; the function is the substitution of
% the eval function in matlab which is not accepted by
% matlab compiler

switch model
  case 'exponentialV'
    [V]=exponentialV(D,param);
  case 'exponentialC' 
    [V]=exponentialC(D,param);
  case 'gaussianV'
    [V]=gaussianV(D,param);
  case 'gaussianCST'
    [V]=gaussianCST(D,param);
  case 'gaussianC'
    [V]=gaussianC(D,param);
  case 'holecosC'
    [V]=holecosC(D,param);
  case 'holecosV'
    [V]=holecosV(D,param);
  case 'holesinC'
    [V]=holesinC(D,param);
  case 'holesinV'
    [V]=holesinV(D,param);
  case 'linearV'
    [V]=linearV(D,param);
  case 'nuggetC'
    [V]=nuggetC(D,param);
  case 'nuggetV'
    [V]=nuggetV(D,param);
  case 'powerV'
    [V]=powerV(D,param);
  case 'sphericalV'
    [V]=sphericalV(D,param);
  case 'sphericalC'
    [V]=sphericalC(D,param);
  case 'nuggetCST'
    [V]=nuggetCST(D,param);
  case 'mexicanhatC'
    [V]=mexicanhatC(D,param);
end;