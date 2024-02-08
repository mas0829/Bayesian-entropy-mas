function [bmeMean,bmeVar,bmeSkew] = backNscTrsfMomentsVec(bmeMeanTrsf,bmeVarTrsf,bmeSkewTrsf,ntransfTable,nscMinAcceptOutput,nscMaxAcceptOutput);
%
% Provide the back-transformed value of BMEmean
bmeMean = nscoreBackVec(bmeMeanTrsf,ntransfTable,...
                     nscMinAcceptOutput,nscMaxAcceptOutput);
                        
% Direct back-transformation of the BME variance is improper. 
% Instead, a measure of the variance in the original space 
% is provided using the variance in the transformed space:
% See how far standard deviation extends in transformed space
% and convert the limits of this span in original space values
bmeStdTrsf = sqrt(bmeVarTrsf);                % Get standard deviation
bmeMeanPlusStdTrsf = bmeMeanTrsf+bmeStdTrsf;  % Add it to BMEmean
bmeMeanPlusStd = nscoreBackVec(bmeMeanPlusStdTrsf,ntransfTable,...
                     nscMinAcceptOutput,nscMaxAcceptOutput);
bmeMeanMinStdTrsf = bmeMeanTrsf-bmeStdTrsf;   % Subtract it from BMEmean
bmeMeanMinStd = nscoreBackVec(bmeMeanMinStdTrsf,ntransfTable,...
                         nscMinAcceptOutput,nscMaxAcceptOutput);
% Provide a measure of variance by means of a standard deviation
% measure in the original space. 
bmeVar = (0.5*(bmeMeanPlusStd-bmeMeanMinStd)).^2;
clear bmeMeanTrsf bmeVarTrsf bmeMeanPlusStdTrsf bmeMeanMinStdTrsf ...
      bmeMeanPlusStd bmeMeanMinStd
    
% There can not be a measure of skewness in original space
bmeSkew = NaN*ones(size(bmeSkewTrsf,1),1);
    

