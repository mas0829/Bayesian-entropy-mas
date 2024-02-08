function varargout = ip304p3TexplorAnal(varargin)
%IP304P3TEXPLORANAL M-file for ip304p3TexplorAnal.fig
%      IP304P3TEXPLORANAL, by itself, creates a new IP304P3TEXPLORANAL or raises the existing
%      singleton*.
%
%      H = IP304P3TEXPLORANAL returns the handle to a new IP304P3TEXPLORANAL or the handle to
%      the existing singleton*.
%
%      IP304P3TEXPLORANAL('Property','Value',...) creates a new IP304P3TEXPLORANAL using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to ip304p3TexplorAnal_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      IP304P3TEXPLORANAL('CALLBACK') and IP304P3TEXPLORANAL('CALLBACK',hObject,...) call the
%      local function named CALLBACK in IP304P3TEXPLORANAL.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE'sDistEdit Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ip304p3TexplorAnal

% Last Modified by GUIDE v2.5 03-Apr-2006 17:03:45

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ip304p3TexplorAnal_OpeningFcn, ...
                   'gui_OutputFcn',  @ip304p3TexplorAnal_OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
   gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before ip304p3TexplorAnal is made visible.
function ip304p3TexplorAnal_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

% Choose default command line output for ip304p3TexplorAnal
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% Insert custom Title and Text if specified by the user
% Hint: when choosing keywords, be sure they are not easily confused 
% with existing figure properties.  See the output of set(figure) for
% a list of figure properties.
if(nargin > 3)
    for index = 1:2:(nargin-3),
        if nargin-3==index, break, end
        switch lower(varargin{index})
         case 'title'
          set(hObject, 'Name', varargin{index+1});
         case 'string'
          set(handles.text1, 'String', varargin{index+1});
        end
    end
end

% UIWAIT makes ip304p3TexplorAnal wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ip304p3TexplorAnal_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% PRELIMINARY SETTINGS
%
% Set any known information in the appropriate edit boxes.
% Check and correct any issues with duplicate coordinates in the data provided.
% The updated datasets are passed as global variables from the following
% function. Fill out the remaining boxes with the outcome.
%
global hardDataPresent softDataPresent
global ch zh cs ck totalCoordinatesUsed totalSpCoordinatesUsed
global sdCategory nl limi probdens softApprox
global displayString
global outGrid
global zhTemp limiTemp softApproxTemp
global allOkDtr
global trendDataSaved
global prevExtFigState
global timePresent
global xMin dx xMax yMin dy yMax zMin dz zMax dataCoordMin dataCoordMax
global minTdata maxTdata dataTimeSpan
global chAtInst zhAtInst
global csAtInst nlAtInst limiAtInst probdensAtInst
global ckAtInst
global zhTempAtInst limiTempAtInst softApproxTempAtInst
global maxSdataSearchRadius maxTdataSearchRadius
global prevAlltState
global cPt cPtValues
global useSoftApproximations
global zhTempDetrended limiTempDetrended softApproxTempDetrended
global zhTempDetrendedAtInst limiTempDetrendedAtInst
global softApproxTempDetrendedAtInst
global zhTempDetrNscTrsf limiTempDetrNscTrsf softApproxTempDetrNscTrsf
global zhTempDetrNscTrsfAtInst limiTempDetrNscTrsfAtInst 
global softApproxTempDetrNscTrsfAtInst
global zhTempDetrBcxTrsf limiTempDetrBcxTrsf softApproxTempDetrBcxTrsf
global zhTempDetrBcxTrsfAtInst limiTempDetrBcxTrsfAtInst 
global softApproxTempDetrBcxTrsfAtInst
global transfLimit
global applyTransform transformTypeStr
global positiveDataOnly
global bcxLambda zeroInLogScale nscMinAcceptOutput nscMaxAcceptOutput

% Gather all point data into a variable.
% Also provides correct set (HD only) in case where no SD approximations are used.
cPtValuesTemp = [zhTemp;softApproxTemp];

set(handles.dataStatsMenu,'Value',1); % Begin by showing original data statistics.
set(handles.countNoEdit,'String',num2str(size(cPtValues,1)));
set(handles.minValNoEdit,'String',num2str(min(cPtValues)));
set(handles.maxValNoEdit,'String',num2str(max(cPtValues)));
set(handles.meanNoEdit,'String',num2str(mean(cPtValues)));
set(handles.stDevNoEdit,'String',num2str(std(cPtValues)));
set(handles.medianNoEdit,'String',num2str(median(cPtValues)));
set(handles.skewnessNoEdit,'String',num2str(skewness(cPtValues)));
set(handles.kurtosisNoEdit,'String',num2str(kurtosis(cPtValues)));

set(handles.graphTypeMenu,'Value',1); % Begin by showing original data vs. normal CDF.
set(handles.barsMenu,'Value',3);      % Begin by showing histogram w/ 15 bars.

% If the maximum deviation of the original data from normality is larger than
% transfLimit, suggest that the user proceeds with normal score transformation.
transfLimit = 10;

% Upon loading, prepare and display a plot comparing the CDFs of the detrended 
% data set from the previous stage and the normal distribution that has the 
% corresponding set mean and variance.
%
% The following obtains the CDF for the detrended data distribution at the chosen
% instances, as in the remaining instances there is no trend information.
% In the spatial-only case the following works as well.
cDataValuesTempDetrended = [zhTempDetrended;softApproxTempDetrended];
[ycdfTemp,xcdfTemp] = cdfcalcgui(cDataValuesTempDetrended);
cPtXCdf = [xcdfTemp; inf];            % Suitably manipulate the CDF x-set
cPtYCdf = [ycdfTemp];                 % Suitably manipulate the CDF y-set
meanOfDetrDistr = mean(cDataValuesTempDetrended);
stdvOfDetrDistr = std(cDataValuesTempDetrended);
% Obtain the CDF for a normal distribution that has the user data characteristics
theorCdf = gausscdf(cPtXCdf,[meanOfDetrDistr stdvOfDetrDistr]);
% Create plot
axes(handles.dataDistribAxes)
h1 = plot(cPtXCdf,theorCdf,'--');          % Normal distribution CDF
hold on;
h2 = plot(cPtXCdf,cPtYCdf,'r-');      % Original data distribution CDF (red line)
hold off;
plotLimits = axis;
axis([min(xcdfTemp) max(xcdfTemp) plotLimits(3) plotLimits(4)]);
legend([h1 h2],'Normal','Detr Non-Trsf Data','Location','Best');
xlabel('Data');
ylabel('Probability');

theorCdf2comp = theorCdf(2:end);
cDataCdf2comp = cPtYCdf(2:end);
[maxCdfDevNonTrsf,indxMaxCdfDevNonTrsf] = max(100*abs(cDataCdf2comp-theorCdf2comp));

if maxCdfDevNonTrsf >= transfLimit
  string2 = ' Data suggest use of transformation.';
  set(handles.transfChoiceMenu,'Value',2);        % Prompt transformation.
  applyTransform = 1;
  transformTypeStr = 'N-scores';
else
  string2 = ' Transformation not necessary.';
  set(handles.transfChoiceMenu,'Value',1);        % Prompt to stay with original data.
  applyTransform = 0;
  transformTypeStr = 'None';
end
displayString = ['Max deviation from CDF of normal is ' num2str(maxCdfDevNonTrsf) ...
                 '% at data value ' num2str(cPtXCdf(indxMaxCdfDevNonTrsf+1)) '.' ...
                 string2];
set(handles.feedbackEdit,'String',displayString);
pause(0.1);

% The following are set as defaults when the figure launches. Initialize.

% Based on how the BoxCox transform is defined below, it is highly likely
% that all values to undergo transformation will be above 0. However, some
% extra security is always welcome. Set an initial value in the following
% few lines and let the user have the final word.
set(handles.zeroInBoxcoxEdit,'String','0.001');
set(handles.zeroInBoxcoxSlider,'Value',3);
zeroInLogScale = 0.001;     % The slider value of 3 corresponds to 0.001.

bcxLambda = [];             % Initialize the Boxcox transformation parameter.

% Initialize matrices to be used for transformed values storage
zhTempDetrNscTrsf = [];                       % Initialize
limiTempDetrNscTrsf = [];                     % Initialize
softApproxTempDetrNscTrsf = [];               % Initialize
zhTempDetrNscTrsfAtInst = [];                 % Initialize
limiTempDetrNscTrsfAtInst = [];               % Initialize
softApproxTempDetrNscTrsfAtInst = [];         % Initialize
zhTempDetrBcxTrsf = [];                       % Initialize
limiTempDetrBcxTrsf = [];                     % Initialize
softApproxTempDetrBcxTrsf = [];               % Initialize
zhTempDetrBcxTrsfAtInst = [];                 % Initialize
limiTempDetrBcxTrsfAtInst = [];               % Initialize
softApproxTempDetrBcxTrsfAtInst = [];         % Initialize
%
% Obtain normal score transformed values
[nScoreTransformDataOk] = getNscoreTransform;
%
% Obtain BoxCox transformed values
[boxcoxTransformDataOk] = getBoxCoxTransform;




function [nScoreTransformDataOk] = getNscoreTransform;
%
% This function is automatically invoked and executed when user reaches this
% screen. It performs a normal score (Nscore) transformation (or anamorphosis)
% on the detrended hard and soft data. The transformed data, as well as the
% transformation tables are returned back as global variables. The values are
% maintained throughout the screen, and by proceeding to the following screen
% they are either kept if the user decides on applying the transformation, or
% they are overwritten by the non-transformed values in the opposite case.
%
global ch cs zh
global sdCategory softpdftype nl limi probdens softApprox
global hardDataPresent softDataPresent
global useSoftApproximations
global minTdata maxTdata dataTimeSpan
global zhTempDetrended limiTempDetrended softApproxTempDetrended
global zhTempDetrendedAtInst limiTempDetrendedAtInst
global ntransf ntransfTable % To be used in backtransformations after estimations
global nscMinAcceptOutput nscMaxAcceptOutput
global zhTempDetrNscTrsf limiTempDetrNscTrsf softApproxTempDetrNscTrsf
global zhTempDetrNscTrsfAtInst limiTempDetrNscTrsfAtInst softApproxTempDetrNscTrsfAtInst
global positiveDataOnly

% Add location of the transformation function into scope
%addpath guiResources;

% The transformation function takes in vectors. Adjust hard and soft data 
% matrices appropriately to account for correct input.
%
if hardDataPresent
  sizeHall = length(zhTempDetrended);
else
  sizeHall = 0;
end
if softDataPresent
  sizeSall = length(softApproxTempDetrended);
else
  sizeSall = 0;
end
% Bring together HD and the means of SD to create the set for nscore transformation
allDataFeed = [zhTempDetrended;softApproxTempDetrended];

% Find the minimium and maximum values in the detrended dataset. These values
% may be the limits of soft data, therefore we want to find the right values
% and include them in the transformation matrix.
if softDataPresent
  minValueUsed = min(min(allDataFeed),min(limiTempDetrended(:,1)));
  maxValueUsed = max(max(allDataFeed),max(max(limiTempDetrended)));
  if ~sum(allDataFeed==minValueUsed)          % If minValueUsed not already in set
    allDataFeed = [allDataFeed;minValueUsed]; % then add it.
  end
  if ~sum(allDataFeed==maxValueUsed)          % If maxValueUsed not already in set
    allDataFeed = [allDataFeed;maxValueUsed]; % then add it.
  end
else
  minValueUsed = min(allDataFeed);
  maxValueUsed = max(allDataFeed);
end  

% In the backtransformation the BME raw output may extend way out of the
% n-score range. In order to avoid unrealistic backtransformed values we
% need to set boundaries in the acceptable backtransformed output.
%
% Allow the results value range to extend up to the following percentage
% above and below the given data range of values. Percentage is in [0,1].
allowedResultExtentPercentage = 0.1;
% The previously-set percentage corresponds to the number in the following line
allowedResultExtent = allowedResultExtentPercentage*(maxValueUsed-minValueUsed);
% Define the min and max acceptable output values in the original space.
% Note that here we are dealing with detrended data.
nscMaxAcceptOutput = maxValueUsed + allowedResultExtent;
nscMinAcceptOutput = minValueUsed - allowedResultExtent;

% Adjust nscMinAcceptOutput in a smarter way in case we need to stay above zero
% and any extreme values render the allowedResultExtent artificially large
if positiveDataOnly
  % We would like to exclude any potential extreme values in the set from
  % artificially extending the acceptable output value range. For that reason
  % the following line puts all non-outlier allDataFeed data in "noExtrOutl"
  [sortOrder,mildOutlId,mildOutliers,extrOutlId,extrOutliers,...
    noExtrOutl,noMildOutl] = findOutliers(allDataFeed);
  % The previously-set percentage corresponds to a different allowedResultExtent
  % in the following line, so as to prevent allowance for negative predictions
  allowedResultExtent = allowedResultExtentPercentage * ...
                        (max(noExtrOutl)-min(noExtrOutl));
  % Define again the min acceptable output value in the original space.
  nscMinAcceptOutput = minValueUsed - allowedResultExtent;
end 

% Perform transformation. The transformed values are in ntransf, and the
% transformation table is in ntransfTable for the backtransformation later.
%
[ntransf,ntransfTable] = nscoreTrsf(allDataFeed);

% Define hard and soft detrended transformed values appropriately.
if hardDataPresent
  startPoint = 1;                                    % Starting at the beginning
  endPoint = sizeHall;                               % Finishing at the right point
  zhTempDetrNscTrsf = ntransf(startPoint:endPoint);  % Get sizeHall HD transf points
else
  zhTempDetrNscTrsf = [];
end
if softDataPresent
  % We will be using the transformed soft data means for the covariance
  % modeling stage. We are extracting these values fron the nscore output
  startPoint = sizeHall+1;                           % Skip the HD points
  endPoint = sizeHall+sizeSall;                      % Finishing at the right point
  softApproxTempDetrNscTrsf = ntransf(startPoint:endPoint); % Get the transf soft means
  % Now transform the soft data limits.
  sizeLx = size(limiTempDetrended,1);
  sizeLy = size(limiTempDetrended,2);
  sizeLall = sizeLx*sizeLy;
  % Feed all given limits into a vector to transform
  softDataFeed = reshape(limiTempDetrended,sizeLall,1);
  % Use the transformation table above on the soft data
  limiTempDetrNscTrsf = interp1(ntransfTable(:,1),ntransfTable(:,2),...
                                softDataFeed,'pchip','extrap');
  % Bring limits back to soft data format
  limiTempDetrNscTrsf = reshape(limiTempDetrNscTrsf,sizeLx,sizeLy);
else
  limiTempDetrNscTrsf = [];
end

% Create sub-matrices for individual temporal instances for both hard and soft
% detrended transformed data.
if hardDataPresent        % First, for hard data
  beginPoint = 0;
  for ith=1:dataTimeSpan  % Be it a single (S only) or many (S/T) instances
    endPoint = beginPoint + size(zhTempDetrendedAtInst{ith},1);
    zhTempDetrNscTrsfAtInst{ith} = zhTempDetrNscTrsf(beginPoint+1:endPoint,:);
    beginPoint = endPoint;
  end
else
  for ith=1:dataTimeSpan
    zhTempDetrNscTrsfAtInst{ith} = [];
  end
end

if softDataPresent        % Then, for soft data
  beginPoint = 0;
  for ith=1:dataTimeSpan  % Be it a single (S only) or many (S/T) instances
    endPoint = beginPoint + size(limiTempDetrendedAtInst{ith},1);
    limiTempDetrNscTrsfAtInst{ith} = limiTempDetrNscTrsf(beginPoint+1:endPoint,:);
    beginPoint = endPoint;
  end
  if useSoftApproximations
    beginPoint = 0;
    for ith=1:dataTimeSpan  % Be it a single (S only) or many (S/T) instances
      endPoint = beginPoint + size(limiTempDetrendedAtInst{ith},1);
      softApproxTempDetrNscTrsfAtInst{ith} = ...
        softApproxTempDetrNscTrsf(beginPoint+1:endPoint,:);
      beginPoint = endPoint;
    end
  else
    for ith=1:dataTimeSpan
      softApproxTempDetrNscTrsfAtInst{ith} = [];
    end 
  end
else
  for ith=1:dataTimeSpan
    limiTempDetrNscTrsfAtInst{ith} = [];
    softApproxTempDetrNscTrsfAtInst{ith} = [];
  end
end
clear beginPoint endPoint

nScoreTransformDataOk = 1;





function [boxcoxTransformDataOk] = getBoxCoxTransform;
%
% This function is automatically invoked and executed when user reaches this
% screen. It performs a Box-Cox transformation on the detrended hard and soft
% data. The transformed data are returned back as global variables. The values
% are maintained throughout the screen, and by proceeding to the following
% screen they are either kept if the user decides on applying the transformation
% or they are overwritten by the non-transformed values in the opposite case.
%
global ch cs zh
global sdCategory softpdftype nl limi probdens softApprox
global hardDataPresent softDataPresent
global useSoftApproximations
global minTdata maxTdata dataTimeSpan
global zhTempDetrended limiTempDetrended softApproxTempDetrended
global zhTempDetrendedAtInst limiTempDetrendedAtInst
global bcxLambda bcxDataShiftConst
global zhTempDetrBcxTrsf limiTempDetrBcxTrsf softApproxTempDetrBcxTrsf
global zhTempDetrBcxTrsfAtInst limiTempDetrBcxTrsfAtInst softApproxTempDetrBcxTrsfAtInst
global zeroInLogScale

% Add location of the transformation function into scope
%addpath guiResources;

% The transformation function takes in vectors. Adjust hard and soft data 
% matrices appropriately to account for correct input.
%
if hardDataPresent
  sizeHall = length(zhTempDetrended);
else
  sizeHall = 0;
end
if softDataPresent
  sizeSall = length(softApproxTempDetrended);
else
  sizeSall = 0;
end
% Bring together HD and the means of SD to create the set for nscore transformation
allDataFeed = [zhTempDetrended;softApproxTempDetrended];

% The following block is dedicated to defining a constant to add to the detrended 
% distribution, so that its log transformation does not encounter negative numbers.
% Do not forget to subtract the constant from the BME estimates after backtransforming
%
% First find the minimium value in the given dataset. This value may be the
% low limit of a soft datum interval. Find the right value.
allDataFeedMin = min(allDataFeed);                    % What is set's smallest?
if softDataPresent
  if min(limiTempDetrended(:,1)) < allDataFeedMin     % If a soft limit even smaller
    allDataFeed = [allDataFeed;min(limiTempDetrended(:,1))]; % Include smallest value
    allDataFeedMin = min(limiTempDetrended(:,1));            % Revise   
  end
end
% In defining the constant we can simply add the smallest value in the set
% to allDataFeed numbers, so that they are >=0. However, we allow a further
% allDataRangePercent to be added, so that we can account for estimations
% that may have values below 0.
allDataRange = max(allDataFeed)-min(allDataFeed);     % Get allDataFeed range
allDataRangePercent = 0.07;                           % Define additional cushion
allDataRangeSafetyMargin = allDataRangePercent*allDataRange;     % and real range
%
% Suitably elevate all data, if necessary, to a set of only positive values
if allDataFeedMin<=0
  bcxDataShiftConst = abs(allDataFeedMin) + allDataRangeSafetyMargin;
  allDataFeedElev = allDataFeed + bcxDataShiftConst;
else                 % If min value is >0
  % If the minimum value is larger enough than 0, the optimization routine
  % in the Box-Cox function has shown that it may fail to converge. In the
  % following, we check this possibility using as a measure the parameter
  % allDataRangeSafetyMargin. If, indeed, the minimum value is too large,
  % then define a negative bcxDataShiftConst to lower the data values.
  if allDataFeedMin > allDataRangeSafetyMargin
    bcxDataShiftConst = allDataRangeSafetyMargin - allDataFeedMin; % Negative
    allDataFeedElev = allDataFeed + bcxDataShiftConst; % Reduce data values
  else                          % Data values are low enough              
    bcxDataShiftConst = 0;
    allDataFeedElev = allDataFeed;
  end
end
allDataFeedElev(allDataFeedElev==0) = zeroInLogScale;  % Remove any zeros.

% Transform data using the Box-Cox transformation. The set consists of the
% hard data, as well as the soft means as guides to the soft data.
% The function also returns tha boxcox transformation parameter lambda.
[allDataFeedTrsf,bcxLambda] = boxcoxTrsf(allDataFeedElev);

% Establish vector of the transformed, detrended hard data.
% The matrix is empty if there are no hard data in the data set.
startPoint = 1;
endPoint = sizeHall;
zhTempDetrBcxTrsf = allDataFeedTrsf(startPoint:endPoint);   % Get sizeHall HD transformed pts

% We will be using the transformed soft data means for the covariance
% modeling stage. We are extracting these values fron the boxcox output
% The matrix is empty if there are no soft data in the data set.
startPoint = sizeHall+1;                                    % Skip the HD points
endPoint = sizeHall+sizeSall;                               % How far the SD span
softApproxTempDetrBcxTrsf = allDataFeedTrsf(startPoint:endPoint);  % SD transformed means

% Suitably elevate SD to be transformed, so that there is a set of only positive values
limiTempDetrendedElev = limiTempDetrended + bcxDataShiftConst;
limiTempDetrendedElev(limiTempDetrendedElev==0) = zeroInLogScale;  % Remove any zeros.
% Transform soft data (of any type) using the given transformation parameter
% In case of pdf-type data, any trailing zeros at the end of each line are
% also transformed, but this does not affect their use in the BME calculations.
[limiTempDetrBcxTrsf] = boxcoxTrsf(limiTempDetrendedElev,bcxLambda);

% Create sub-matrices for individual temporal instances for both hard and soft
% detrended transformed data.
if hardDataPresent        % First, for hard data
  beginPoint = 0;
  for ith=1:dataTimeSpan  % Be it a single (S only) or many (S/T) instances
    endPoint = beginPoint + size(zhTempDetrendedAtInst{ith},1);
    zhTempDetrBcxTrsfAtInst{ith} = zhTempDetrBcxTrsf(beginPoint+1:endPoint,:);
    beginPoint = endPoint;
  end
else
  for ith=1:dataTimeSpan
    zhTempDetrBcxTrsfAtInst{ith} = [];
  end
end

if softDataPresent        % Then, for soft data
  beginPoint = 0;
  for ith=1:dataTimeSpan  % Be it a single (S only) or many (S/T) instances
    endPoint = beginPoint + size(limiTempDetrendedAtInst{ith},1);
    limiTempDetrBcxTrsfAtInst{ith} = limiTempDetrBcxTrsf(beginPoint+1:endPoint,:);
    beginPoint = endPoint;
  end
  if useSoftApproximations
    beginPoint = 0;
    for ith=1:dataTimeSpan  % Be it a single (S only) or many (S/T) instances
      endPoint = beginPoint + size(limiTempDetrendedAtInst{ith},1);
      softApproxTempDetrBcxTrsfAtInst{ith} = ...
        softApproxTempDetrBcxTrsf(beginPoint+1:endPoint,:);
      beginPoint = endPoint;
    end
  else
    for ith=1:dataTimeSpan
      softApproxTempDetrBcxTrsfAtInst{ith} = [];
    end 
  end
else
  for ith=1:dataTimeSpan
    limiTempDetrBcxTrsfAtInst{ith} = [];
    softApproxTempDetrBcxTrsfAtInst{ith} = [];
  end
end
clear beginPoint endPoint

boxcoxTransformDataOk = 1;





function feedbackEdit_Callback(hObject, eventdata, handles)
% hObject    handle to feedbackEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of feedbackEdit as text
%        str2double(get(hObject,'String')) returns contents of feedbackEdit as a double
global displayString

% Disregard any editing by the user
set(handles.feedbackEdit,'String',displayString); 




% --- Executes during object creation, after setting all properties.
function feedbackEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to feedbackEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





% --- Executes on selection change in dataStatsMenu.
function dataStatsMenu_Callback(hObject, eventdata, handles)
% hObject    handle to dataStatsMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns dataStatsMenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from dataStatsMenu

% Gather all point data into a variable.
% Also provides correct set (HD only) in case where no SD approximations are used.
global cPtValues
global zhTempDetrended limiTempDetrended softApproxTempDetrended
global zhTempDetrNscTrsf limiTempDetrNscTrsf softApproxTempDetrNscTrsf
global zhTempDetrBcxTrsf limiTempDetrBcxTrsf softApproxTempDetrBcxTrsf
global timePresent
global outGrid totalCoordinatesUsed 
global firstTrendInst lastTrendInst
global positiveDataOnly

switch get(handles.dataStatsMenu,'Value')
  case 1     % Displays statistics on the original, non-detrended, non-transformed data
    set(handles.countNoEdit,'String',num2str(size(cPtValues,1)));
    set(handles.minValNoEdit,'String',num2str(min(cPtValues)));
    set(handles.maxValNoEdit,'String',num2str(max(cPtValues)));
    set(handles.meanNoEdit,'String',num2str(mean(cPtValues)));
    set(handles.stDevNoEdit,'String',num2str(std(cPtValues)));
    set(handles.medianNoEdit,'String',num2str(median(cPtValues)));
    set(handles.skewnessNoEdit,'String',num2str(skewness(cPtValues)));
    set(handles.kurtosisNoEdit,'String',num2str(kurtosis(cPtValues)));
    displayString = ['Boxes now displaying statistics for non-detrended, '...
                     'non-transformed (original-space) data set'];
  case 2     % Displays statistics on the original detrended, non-transformed data
    cPtValuesTempDetrended = [zhTempDetrended;softApproxTempDetrended];
    set(handles.countNoEdit,'String',num2str(size(cPtValuesTempDetrended,1)));
    set(handles.minValNoEdit,'String',num2str(min(cPtValuesTempDetrended)));
    set(handles.maxValNoEdit,'String',num2str(max(cPtValuesTempDetrended)));
    set(handles.meanNoEdit,'String',num2str(mean(cPtValuesTempDetrended)));
    set(handles.stDevNoEdit,'String',num2str(std(cPtValuesTempDetrended)));
    set(handles.medianNoEdit,'String',num2str(median(cPtValuesTempDetrended)));
    set(handles.skewnessNoEdit,'String',num2str(skewness(cPtValuesTempDetrended)));
    set(handles.kurtosisNoEdit,'String',num2str(kurtosis(cPtValuesTempDetrended)));
    displayString = ['Boxes now displaying statistics for detrended, '...
                     'non-transformed (original-space) data set'];
    if timePresent   % Let user know this may be a partial data set
      displayString = [displayString ' in t=['...
                       num2str(firstTrendInst) ',' num2str(lastTrendInst) ']'];
    end
  case 3     % Displays statistics on the detrended, Nsc-transformed data
    cPtValuesTempDetrNscTrsf = [zhTempDetrNscTrsf;softApproxTempDetrNscTrsf];
    set(handles.countNoEdit,'String',num2str(size(cPtValuesTempDetrNscTrsf,1)));
    set(handles.minValNoEdit,'String',num2str(min(cPtValuesTempDetrNscTrsf)));
    set(handles.maxValNoEdit,'String',num2str(max(cPtValuesTempDetrNscTrsf)));
    set(handles.meanNoEdit,'String',num2str(mean(cPtValuesTempDetrNscTrsf)));
    set(handles.stDevNoEdit,'String',num2str(std(cPtValuesTempDetrNscTrsf)));
    set(handles.medianNoEdit,'String',num2str(median(cPtValuesTempDetrNscTrsf)));
    set(handles.skewnessNoEdit,'String',num2str(skewness(cPtValuesTempDetrNscTrsf)));
    set(handles.kurtosisNoEdit,'String',num2str(kurtosis(cPtValuesTempDetrNscTrsf)));
    displayString = ['Boxes now displaying statistics for detrended, '...
                     'N-score-space transformed data set'];
    if timePresent   % Let user know this may be a partial data set
      displayString = [displayString ' in t=['...
                       num2str(firstTrendInst) ',' num2str(lastTrendInst) ']'];
    end
  case 4     % Displays statistics on the detrended, Bcx-transformed data
    cPtValuesTempDetrBcxTrsf = [zhTempDetrBcxTrsf;softApproxTempDetrBcxTrsf];
    set(handles.countNoEdit,'String',num2str(size(cPtValuesTempDetrBcxTrsf,1)));
    set(handles.minValNoEdit,'String',num2str(min(cPtValuesTempDetrBcxTrsf)));
    set(handles.maxValNoEdit,'String',num2str(max(cPtValuesTempDetrBcxTrsf)));
    set(handles.meanNoEdit,'String',num2str(mean(cPtValuesTempDetrBcxTrsf)));
    set(handles.stDevNoEdit,'String',num2str(std(cPtValuesTempDetrBcxTrsf)));
    set(handles.medianNoEdit,'String',num2str(median(cPtValuesTempDetrBcxTrsf)));
    set(handles.skewnessNoEdit,'String',num2str(skewness(cPtValuesTempDetrBcxTrsf)));
    set(handles.kurtosisNoEdit,'String',num2str(kurtosis(cPtValuesTempDetrBcxTrsf)));
    displayString = ['Boxes now displaying statistics for detrended, '...
                     'Box-Cox-space transformed data set'];
    if timePresent   % Let user know this may be a partial data set
      displayString = [displayString ' in t=['...
                       num2str(firstTrendInst) ',' num2str(lastTrendInst) ']'];
    end
  otherwise
    errordlg({'ip304p3TexplorAnal.m:dataStatsMenu:';...
      'The menu contains more options than coded for.'},...
      'GUI software Error')
end
set(handles.feedbackEdit,'String',displayString);





% --- Executes during object creation, after setting all properties.
function dataStatsMenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dataStatsMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





function countNoEdit_Callback(hObject, eventdata, handles)
% hObject    handle to countNoEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of countNoEdit as text
%        str2double(get(hObject,'String')) returns contents of countNoEdit as a double
global cPtValues
global zhTempDetrended limiTempDetrended softApproxTempDetrended
global zhTempDetrNscTrsf limiTempDetrNscTrsf softApproxTempDetrNscTrsf
global zhTempDetrBcxTrsf limiTempDetrBcxTrsf softApproxTempDetrBcxTrsf
global positiveDataOnly

switch get(handles.dataStatsMenu,'Value')
  case 1     % Displays statistics on the detrended, non-transformed data
    set(handles.countNoEdit,'String',num2str(size(cPtValues,1)));
  case 2     % Displays statistics on the detrended, non-transformed data
    cPtValuesTempDetrended = [zhTempDetrended;softApproxTempDetrended];
    set(handles.countNoEdit,'String',num2str(size(cPtValuesTempDetrended,1)));
  case 3     % Displays statistics on the detrended, Nsc-transformed data
    cPtValuesTempDetrNscTrsf = [zhTempDetrTrsf;softApproxTempDetrNscTrsf];
    set(handles.countNoEdit,'String',num2str(size(cPtValuesTempDetrNscTrsf,1)));
  case 4     % Displays statistics on the detrended, Bcx-transformed data
    cPtValuesTempDetrBcxTrsf = [zhTempDetrBcxTrsf;softApproxTempDetrBcxTrsf];
    set(handles.countNoEdit,'String',num2str(size(cPtValuesTempDetrBcxTrsf,1)));
  otherwise
    errordlg({'ip304p3TexplorAnal.m:countNoEdit:';...
      'No provision for additional dataStatsMenu menu items.'},...
      'GUI software Error')
end




% --- Executes during object creation, after setting all properties.
function countNoEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to countNoEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




function minValNoEdit_Callback(hObject, eventdata, handles)
% hObject    handle to minValNoEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of minValNoEdit as text
%        str2double(get(hObject,'String')) returns contents of minValNoEdit as a double
global cPtValues
global zhTempDetrended limiTempDetrended softApproxTempDetrended
global zhTempDetrNscTrsf limiTempDetrNscTrsf softApproxTempDetrNscTrsf
global zhTempDetrBcxTrsf limiTempDetrBcxTrsf softApproxTempDetrBcxTrsf
global positiveDataOnly

switch get(handles.dataStatsMenu,'Value')
  case 1     % Displays statistics on the detrended, non-transformed data
    set(handles.minValNoEdit,'String',num2str(min(cPtValues)));
  case 2     % Displays statistics on the detrended, non-transformed data
    cPtValuesTempDetrended = [zhTempDetrended;softApproxTempDetrended];
    set(handles.minValNoEdit,'String',num2str(min(cPtValuesTempDetrended)));
  case 3     % Displays statistics on the detrended, Nsc-transformed data
    cPtValuesTempDetrNscTrsf = [zhTempDetrTrsf;softApproxTempDetrNscTrsf];
    set(handles.minValNoEdit,'String',num2str(min(cPtValuesTempDetrNscTrsf)));
  case 4     % Displays statistics on the detrended, Bcx-transformed data
    cPtValuesTempDetrBcxTrsf = [zhTempDetrBcxTrsf;softApproxTempDetrBcxTrsf];
    set(handles.minValNoEdit,'String',num2str(min(cPtValuesTempDetrBcxTrsf)));
  otherwise
    errordlg({'ip304p3TexplorAnal.m:minValNoEdit:';...
      'No provision for additional dataStatsMenu menu items.'},...
      'GUI software Error')
end




% --- Executes during object creation, after setting all properties.
function minValNoEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to minValNoEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




function maxValNoEdit_Callback(hObject, eventdata, handles)
% hObject    handle to maxValNoEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of maxValNoEdit as text
%        str2double(get(hObject,'String')) returns contents of maxValNoEdit as a double
global cPtValues
global zhTempDetrended limiTempDetrended softApproxTempDetrended
global zhTempDetrNscTrsf limiTempDetrNscTrsf softApproxTempDetrNscTrsf
global zhTempDetrBcxTrsf limiTempDetrBcxTrsf softApproxTempDetrBcxTrsf
global positiveDataOnly

switch get(handles.dataStatsMenu,'Value')
  case 1     % Displays statistics on the detrended, non-transformed data
    set(handles.maxValNoEdit,'String',num2str(max(cPtValues)));
  case 2     % Displays statistics on the detrended, non-transformed data
    cPtValuesTempDetrended = [zhTempDetrended;softApproxTempDetrended];
    set(handles.maxValNoEdit,'String',num2str(max(cPtValuesTempDetrended)));
  case 3     % Displays statistics on the detrended, Nsc-transformed data
    cPtValuesTempDetrNscTrsf = [zhTempDetrTrsf;softApproxTempDetrNscTrsf];
    set(handles.maxValNoEdit,'String',num2str(max(cPtValuesTempDetrNscTrsf)));
  case 4     % Displays statistics on the detrended, Bcx-transformed data
    cPtValuesTempDetrBcxTrsf = [zhTempDetrBcxTrsf;softApproxTempDetrBcxTrsf];
    set(handles.maxValNoEdit,'String',num2str(max(cPtValuesTempDetrBcxTrsf)));
  otherwise
    errordlg({'ip304p3TexplorAnal.m:maxValNoEdit:';...
      'No provision for additional dataStatsMenu menu items.'},...
      'GUI software Error')
end




% --- Executes during object creation, after setting all properties.
function maxValNoEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to maxValNoEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




function meanNoEdit_Callback(hObject, eventdata, handles)
% hObject    handle to meanNoEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of meanNoEdit as text
%        str2double(get(hObject,'String')) returns contents of meanNoEdit as a double
global cPtValues
global zhTempDetrended limiTempDetrended softApproxTempDetrended
global zhTempDetrNscTrsf limiTempDetrNscTrsf softApproxTempDetrNscTrsf
global zhTempDetrBcxTrsf limiTempDetrBcxTrsf softApproxTempDetrBcxTrsf
global positiveDataOnly

switch get(handles.dataStatsMenu,'Value')
  case 1     % Displays statistics on the detrended, non-transformed data
    set(handles.meanNoEdit,'String',num2str(mean(cPtValues)));
  case 2     % Displays statistics on the detrended, non-transformed data
    cPtValuesTempDetrended = [zhTempDetrended;softApproxTempDetrended];
    set(handles.meanNoEdit,'String',num2str(mean(cPtValuesTempDetrended)));
  case 3     % Displays statistics on the detrended, Nsc-transformed data
    cPtValuesTempDetrNscTrsf = [zhTempDetrTrsf;softApproxTempDetrNscTrsf];
    set(handles.meanNoEdit,'String',num2str(mean(cPtValuesTempDetrNscTrsf)));
  case 4     % Displays statistics on the detrended, Bcx-transformed data
    cPtValuesTempDetrBcxTrsf = [zhTempDetrBcxTrsf;softApproxTempDetrBcxTrsf];
    set(handles.meanNoEdit,'String',num2str(mean(cPtValuesTempDetrBcxTrsf)));
  otherwise
    errordlg({'ip304p3TexplorAnal.m:meanNoEdit:';...
      'No provision for additional dataStatsMenu menu items.'},...
      'GUI software Error')
end




% --- Executes during object creation, after setting all properties.
function meanNoEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to meanNoEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




function stDevNoEdit_Callback(hObject, eventdata, handles)
% hObject    handle to stDevNoEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of stDevNoEdit as text
%        str2double(get(hObject,'String')) returns contents of stDevNoEdit as a double
global cPtValues
global zhTempDetrended limiTempDetrended softApproxTempDetrended
global zhTempDetrNscTrsf limiTempDetrNscTrsf softApproxTempDetrNscTrsf
global zhTempDetrBcxTrsf limiTempDetrBcxTrsf softApproxTempDetrBcxTrsf
global positiveDataOnly

switch get(handles.dataStatsMenu,'Value')
  case 1     % Displays statistics on the detrended, non-transformed data
    set(handles.stDevNoEdit,'String',num2str(std(cPtValues)));
  case 2     % Displays statistics on the detrended, non-transformed data
    cPtValuesTempDetrended = [zhTempDetrended;softApproxTempDetrended];
    set(handles.stDevNoEdit,'String',num2str(std(cPtValuesTempDetrended)));
  case 3     % Displays statistics on the detrended, Nsc-transformed data
    cPtValuesTempDetrNscTrsf = [zhTempDetrTrsf;softApproxTempDetrNscTrsf];
    set(handles.stDevNoEdit,'String',num2str(std(cPtValuesTempDetrNscTrsf)));
  case 4     % Displays statistics on the detrended, Bcx-transformed data
    cPtValuesTempDetrBcxTrsf = [zhTempDetrBcxTrsf;softApproxTempDetrBcxTrsf];
    set(handles.stDevNoEdit,'String',num2str(std(cPtValuesTempDetrBcxTrsf)));
  otherwise
    errordlg({'ip304p3TexplorAnal.m:stDevNoEdit:';...
      'No provision for additional dataStatsMenu menu items.'},...
      'GUI software Error')
end




% --- Executes during object creation, after setting all properties.
function stDevNoEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to stDevNoEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




function medianNoEdit_Callback(hObject, eventdata, handles)
% hObject    handle to medianNoEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of medianNoEdit as text
%        str2double(get(hObject,'String')) returns contents of medianNoEdit as a double
global cPtValues
global zhTempDetrended limiTempDetrended softApproxTempDetrended
global zhTempDetrNscTrsf limiTempDetrNscTrsf softApproxTempDetrNscTrsf
global zhTempDetrBcxTrsf limiTempDetrBcxTrsf softApproxTempDetrBcxTrsf
global positiveDataOnly

switch get(handles.dataStatsMenu,'Value')
  case 1     % Displays statistics on the detrended, non-transformed data
    set(handles.medianNoEdit,'String',num2str(median(cPtValues)));
  case 2     % Displays statistics on the detrended, non-transformed data
    cPtValuesTempDetrended = [zhTempDetrended;softApproxTempDetrended];
    set(handles.medianNoEdit,'String',num2str(median(cPtValuesTempDetrended)));
  case 3     % Displays statistics on the detrended, Nsc-transformed data
    cPtValuesTempDetrNscTrsf = [zhTempDetrTrsf;softApproxTempDetrNscTrsf];
    set(handles.medianNoEdit,'String',num2str(median(cPtValuesTempDetrNscTrsf)));
  case 4     % Displays statistics on the detrended, Bcx-transformed data
    cPtValuesTempDetrBcxTrsf = [zhTempDetrBcxTrsf;softApproxTempDetrBcxTrsf];
    set(handles.medianNoEdit,'String',num2str(median(cPtValuesTempDetrBcxTrsf)));
  otherwise
    errordlg({'ip304p3TexplorAnal.m:medianNoEdit:';...
      'No provision for additional dataStatsMenu menu items.'},...
      'GUI software Error')
end




% --- Executes during object creation, after setting all properties.
function medianNoEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to medianNoEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




function skewnessNoEdit_Callback(hObject, eventdata, handles)
% hObject    handle to skewnessNoEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of skewnessNoEdit as text
%        str2double(get(hObject,'String')) returns contents of skewnessNoEdit as a double
global cPtValues
global zhTempDetrended limiTempDetrended softApproxTempDetrended
global zhTempDetrNscTrsf limiTempDetrNscTrsf softApproxTempDetrNscTrsf
global zhTempDetrBcxTrsf limiTempDetrBcxTrsf softApproxTempDetrBcxTrsf
global positiveDataOnly

switch get(handles.dataStatsMenu,'Value')
  case 1     % Displays statistics on the detrended, non-transformed data
    set(handles.skewnessNoEdit,'String',num2str(skewness(cPtValues)));
  case 2     % Displays statistics on the detrended, non-transformed data
    cPtValuesTempDetrended = [zhTempDetrended;softApproxTempDetrended];
    set(handles.skewnessNoEdit,'String',num2str(skewness(cPtValuesTempDetrended)));
  case 3     % Displays statistics on the detrended, Nsc-transformed data
    cPtValuesTempDetrNscTrsf = [zhTempDetrTrsf;softApproxTempDetrNscTrsf];
    set(handles.skewnessNoEdit,'String',num2str(skewness(cPtValuesTempDetrNscTrsf)));
  case 4     % Displays statistics on the detrended, Bcx-transformed data
    cPtValuesTempDetrBcxTrsf = [zhTempDetrBcxTrsf;softApproxTempDetrBcxTrsf];
    set(handles.skewnessNoEdit,'String',num2str(skewness(cPtValuesTempDetrBcxTrsf)));
  otherwise
    errordlg({'ip304p3TexplorAnal.m:skewnessNoEdit:';...
      'No provision for additional dataStatsMenu menu items.'},...
      'GUI software Error')
end




% --- Executes during object creation, after setting all properties.
function skewnessNoEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to skewnessNoEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




function kurtosisNoEdit_Callback(hObject, eventdata, handles)
% hObject    handle to sdFinNoEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of sdFinNoEdit as text
%        str2double(get(hObject,'String')) returns contents of sdFinNoEdit as a double
global cPtValues
global zhTempDetrended limiTempDetrended softApproxTempDetrended
global zhTempDetrNscTrsf limiTempDetrNscTrsf softApproxTempDetrNscTrsf
global zhTempDetrBcxTrsf limiTempDetrBcxTrsf softApproxTempDetrBcxTrsf
global positiveDataOnly

switch get(handles.dataStatsMenu,'Value')
  case 1     % Displays statistics on the detrended, non-transformed data
    set(handles.kurtosisNoEdit,'String',num2str(kurtosis(cPtValues)));
  case 2     % Displays statistics on the detrended, non-transformed data
    cPtValuesTempDetrended = [zhTempDetrended;softApproxTempDetrended];
    set(handles.kurtosisNoEdit,'String',num2str(kurtosis(cPtValuesTempDetrended)));
  case 3     % Displays statistics on the detrended, Nsc-transformed data
    cPtValuesTempDetrNscTrsf = [zhTempDetrNscTrsf;softApproxTempDetrNscTrsf];
    set(handles.kurtosisNoEdit,'String',num2str(kurtosis(cPtValuesTempDetrNscTrsf)));
  case 4     % Displays statistics on the detrended, Bcx-transformed data
    cPtValuesTempDetrBcxTrsf = [zhTempDetrBcxTrsf;softApproxTempDetrBcxTrsf];
    set(handles.kurtosisNoEdit,'String',num2str(kurtosis(cPtValuesTempDetrBcxTrsf)));
  otherwise
    errordlg({'ip304p3TexplorAnal.m:kurtosisNoEdit:';...
      'No provision for additional dataStatsMenu menu items.'},...
      'GUI software Error')
end




% --- Executes during object creation, after setting all properties.
function kurtosisNoEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sdFinNoEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





% --- Executes on selection change in transfChoiceMenu.
function transfChoiceMenu_Callback(hObject, eventdata, handles)
% hObject    handle to transfChoiceMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns transfChoiceMenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from transfChoiceMenu
global applyTransform transformTypeStr
global displayString
global positiveDataOnly
global bcxLambda probdens limi

switch get(handles.transfChoiceMenu,'Value')
  case 1
    applyTransform = 0;
    transformTypeStr = 'None';
    displayString = ['Transformation will not be applied for the estimation process'];
    set(handles.feedbackEdit,'String',displayString);
  case 2
    applyTransform = 1;
    transformTypeStr = 'N-scores';
    displayString = ['N-scores transformation will be applied for the estimation process'];
    set(handles.feedbackEdit,'String',displayString);
  case 3
    applyTransform = 2;
    transformTypeStr = 'Box-Cox';
    displayString = ['BoxCox transformation will be applied with optimal lambda=' ...
                      num2str(bcxLambda)];
    set(handles.feedbackEdit,'String',displayString);
  otherwise
    errordlg({'ip304p3TexplorAnal.m:transfChoiceMenu:';...
      'No provision in code for requested menu item.'},...
      'GUI software Error')
end





% --- Executes during object creation, after setting all properties.
function transfChoiceMenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to transfChoiceMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





% --- Executes on slider movement.
function zeroInBoxcoxSlider_Callback(hObject, eventdata, handles)
% hObject    handle to zeroInBoxcoxSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global zeroInLogScale
global displayString

allowedOptions = [1e-1 1e-2 1e-3 1e-4 1e-5 1e-6 1e-7 1e-8 1e-9 1e-10];
chosenIndex = round(get(hObject,'Value'));
zeroInLogScale = allowedOptions(chosenIndex);
set(handles.zeroInBoxcoxEdit,'String',num2str(zeroInLogScale));
displayString2 = ['Zero-values to be replaced by ' num2str(zeroInLogScale) ...
                 ' in BoxCox transformation. Please wait...'];
set(handles.feedbackEdit,'String',displayString2);
[boxcoxTransformDataOk] = getBoxCoxTransform;     % Transform again w/ new info
pause(2.5);
set(handles.feedbackEdit,'String',displayString); % Return to previous msg





% --- Executes during object creation, after setting all properties.
function zeroInBoxcoxSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to zeroInBoxcoxSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end





function zeroInBoxcoxEdit_Callback(hObject, eventdata, handles)
% hObject    handle to zeroInBoxcoxEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of zeroInBoxcoxEdit as text
%        str2double(get(hObject,'String')) returns contents of zeroInBoxcoxEdit as a double
global displayString

allowedOptions = [1e-1 1e-2 1e-3 1e-4 1e-5 1e-6 1e-7 1e-8 1e-9 1e-10];
chosenIndex = round(get(handles.zeroInBoxcoxSlider,'Value'));
set(hObject,'String',num2str(allowedOptions(chosenIndex)));
displayString2 = ['Edit box is read-only. Please use the slider to change value'];
set(handles.feedbackEdit,'String',displayString2);
sleep(2.5);
set(handles.feedbackEdit,'String',displayString); % Return to previous msg





% --- Executes during object creation, after setting all properties.
function zeroInBoxcoxEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to zeroInBoxcoxEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





% --- Executes on selection change in graphTypeMenu.
function graphTypeMenu_Callback(hObject, eventdata, handles)
% hObject    handle to graphTypeMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns graphTypeMenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from graphTypeMenu
global ch cs ck hardDataPresent softDataPresent 
global zhTemp limiTemp softApproxTemp
global meanTrendAtk
global zhTempDetrended limiTempDetrended softApproxTempDetrended
global allOkDtr
global outGrid totalSpCoordinatesUsed totalCoordinatesUsed
global usingGrid
global timePresent
global xMin dx xMax yMin dy yMax zMin dz zMax dataCoordMin dataCoordMax
global chAtInst zhAtInst ckAtInst
global csAtInst nlAtInst limiAtInst probdensAtInst
global zhTempAtInst limiTempAtInst softApproxTempAtInst
global meanTrendAtkAtInst
global zhTempDetrended limiTempDetrended softApproxTempDetrended
global zhTempDetrNscTrsf limiTempDetrNscTrsf softApproxTempDetrNscTrsf
global zhTempDetrBcxTrsf limiTempDetrBcxTrsf softApproxTempDetrBcxTrsf
global zhTempDetrendedAtInst limiTempDetrendedAtInst softApproxTempDetrendedAtInst
global maskFilename maskPathname maskKnown
global prevAlltState
global xAxisName yAxisName zAxisName variableName
global transfLimit
global enhAllDataFeed
global positiveDataOnly

barsOptions = get(handles.barsMenu,'String');
indexChoice = get(handles.barsMenu,'Value');
selectedBars = str2num(barsOptions{indexChoice});

if get(handles.extFigureBox,'Value') && allOkDtr  % Separate figure or not?
  axes(handles.dataDistribAxes)
  image(imread('guiResources/ithinkPic.png'));
  axis image
  axis off
  figure;
else
  axes(handles.dataDistribAxes)
end  
switch get(handles.graphTypeMenu,'Value')
  case 1     % Displays the CDFs of original, detrended data and the gaussian.
    % Get all detrended, non-transformed data values.
    cDataValuesTempDetrended = [zhTempDetrended;softApproxTempDetrended];
    % Get CDF for the detrended data distribution at the chosen instances
    % (in the remaining instances there is no trend information).
    [ycdfTemp,xcdfTemp] = cdfcalcgui(cDataValuesTempDetrended);
    cPtXCdf = [xcdfTemp; inf];            % Suitably manipulate the CDF x-set
    cPtYCdf = [ycdfTemp];                 % Suitably manipulate the CDF y-set
    meanOfDetrDistr = mean(cDataValuesTempDetrended);
    stdvOfDetrDistr = std(cDataValuesTempDetrended);
    % Obtain the CDF for a normal distribution that has the user data characteristics
    theorCdf = gausscdf(cPtXCdf,[meanOfDetrDistr stdvOfDetrDistr]);
    h1 = plot(cPtXCdf,theorCdf,'--');     % Normal distribution CDF
    hold on;
    h2 = plot(cPtXCdf,cPtYCdf,'r-');      % Original data distribution CDF (red line)
    hold off;
    plotLimits = axis;
    axis([min(xcdfTemp) max(xcdfTemp) plotLimits(3) plotLimits(4)]);
    legend([h1 h2],'Normal','Detr Non-Trsf Data','Location','Best');
    xlabel('Data');
    ylabel('Probability');

    theorCdf2comp = theorCdf(2:end);
    cDataCdf2comp = cPtYCdf(2:end);
    [maxCdfDevNonTrsf,indxMaxCdfDevNonTrsf] = max(100*abs(cDataCdf2comp-theorCdf2comp));

    if maxCdfDevNonTrsf >= transfLimit
      string2 = ' Use of transformation recommended.';
    else
      string2 = ' Transformation not necessary.';
    end
    displayString = ['Max deviation from CDF of normal N(' ...
        num2str(meanOfDetrDistr) ',' num2str(stdvOfDetrDistr) ...
        ') is ' num2str(maxCdfDevNonTrsf) ...
        '% at data value ' num2str(cPtXCdf(indxMaxCdfDevNonTrsf+1)) '.'];
    set(handles.feedbackEdit,'String',displayString);
  case 2     % Displays the CDFs of detrended Nsc-transformed data and the gaussian N(0,1).
    % Get all detrended, transformed data values. Note that we plot the data 
    % using the soft approximations that were used in the tansformation.
    cDataValuesTempDetrNscTrsf = [zhTempDetrNscTrsf;softApproxTempDetrNscTrsf];
    % Get CDF for the detrended, transformed data distribution at the chosen instances
    % (in the remaining instances there is no trend information).
    [ycdfTemp,xcdfTemp] = cdfcalcgui(cDataValuesTempDetrNscTrsf);
    cPtXCdf = [xcdfTemp; inf];
    cPtYCdf = [ycdfTemp];
    % Obtain the CDF for a normal distribution N(0,1)
    theorCdf = gausscdf(cPtXCdf,[0 1]);
    h1 = plot(cPtXCdf,theorCdf,'--');     % Normal distribution CDF
    hold on;
    h2 = plot(cPtXCdf,cPtYCdf,'r-');      % Original data distribution CDF (red line)
    hold off;
    plotLimits = axis;
    axis([min(xcdfTemp) max(xcdfTemp) plotLimits(3) plotLimits(4)]);
    legend([h1 h2],'Normal','Detr Nsc-Trsf Data','Location','Best');
    xlabel('Data');
    ylabel('Probability');

    theorCdf2comp = theorCdf(2:end);
    cDataCdf2comp = cPtYCdf(2:end);
    [maxCdfDevNonTrsf,indxMaxCdfDevNonTrsf] = max(100*abs(cDataCdf2comp-theorCdf2comp));

    displayString = ['Max deviation from CDF of normal N(0,1) is ' num2str(maxCdfDevNonTrsf) ...
      '% at data value ' num2str(cPtXCdf(indxMaxCdfDevNonTrsf+1)) '.'];
    set(handles.feedbackEdit,'String',displayString);
  case 3     % Displays the CDFs of detrended bcx-transformed data and the gaussian N(0,1).
    if positiveDataOnly
      % Get all detrended, transformed data values. Note that we plot the data 
      % using the soft approximations that were used in the tansformation.
      cDataValuesTempDetrBcxTrsf = [zhTempDetrBcxTrsf;softApproxTempDetrBcxTrsf];
      % Get CDF for the detrended, transformed data distribution at the chosen instances
      % (in the remaining instances there is no trend information).
      [ycdfTemp,xcdfTemp] = cdfcalcgui(cDataValuesTempDetrBcxTrsf);
      cPtXCdf = [xcdfTemp; inf];
      cPtYCdf = [ycdfTemp];
      meanOfBcxDistr = mean(cDataValuesTempDetrBcxTrsf);
      stdvOfBcxDistr = std(cDataValuesTempDetrBcxTrsf);
      % Obtain the CDF for a normal distribution N(meanOfBcxDistr,stdvOfBcxDistr)
      theorCdf = gausscdf(cPtXCdf,[meanOfBcxDistr stdvOfBcxDistr]);
      h1 = plot(cPtXCdf,theorCdf,'--');     % Normal distribution CDF
      hold on;
      h2 = plot(cPtXCdf,cPtYCdf,'r-');      % Original data distribution CDF (red line)
      hold off;
      plotLimits = axis;
      axis([min(xcdfTemp) max(xcdfTemp) plotLimits(3) plotLimits(4)]);
      legend([h1 h2],'Normal','Detr Bcx-Trsf Data','Location','Best');
      xlabel('Data');
      ylabel('Probability');

      theorCdf2comp = theorCdf(2:end);
      cDataCdf2comp = cPtYCdf(2:end);
      [maxCdfDevNonTrsf,indxMaxCdfDevNonTrsf] = max(100*abs(cDataCdf2comp-theorCdf2comp));

      displayString = ['Max deviation from CDF of normal N(' ...
        num2str(meanOfBcxDistr) ',' num2str(stdvOfBcxDistr) ...
        ') is ' num2str(maxCdfDevNonTrsf) ...
        '% at data value ' num2str(cPtXCdf(indxMaxCdfDevNonTrsf+1)) '.'];
      set(handles.feedbackEdit,'String',displayString);
    else
      axes(handles.dataDistribAxes)
      image(imread('guiResources/ithinkPic.png'));
      axis image
      axis off
      set(handles.feedbackEdit,'String','No Box-Cox transformation data to plot');
    end
  case 4     % Displays detrended, non-transformed data distribution
    detrDataPopulation = 0;       % Initialize
    if allOkDtr
      cPtValuesTempDetrended = [zhTempDetrended;softApproxTempDetrended];
      detrDataPopulation = size(cPtValuesTempDetrended,1);
      hist(cPtValuesTempDetrended,selectedBars);
      figureOk = 1;
      if figureOk>0
        displayString = ['Data used for the plot: ' ...
          num2str(detrDataPopulation) ' (detrended non-transformed population)'];
        set(handles.feedbackEdit,'String',displayString);
        hFig = findobj(gca,'Type','patch');
        set(hFig,'FaceColor','y','EdgeColor','k');
        xlabel('Data');
        ylabel('Frequency');
      elseif figureOk==0
        image(imread('guiResources/ithinkPic.png'));
        axis image
        axis off
        displayString = 'Data not available for this map';
        set(handles.feedbackEdit,'String',displayString);
      else   % figureOk<0
        image(imread('guiResources/ithinkPic.png'));
        axis image
        axis off
      end
    else
      set(handles.feedbackEdit,'String','No trend information to generate graph');
      pause(2)
      set(handles.feedbackEdit,'String','No trend Data MAT-file present');
    end
  case 5     % Displays detrended, Nsc-transformed data distribution
    detrTrsfDataPopulation = 0;       % Initialize
    if allOkDtr
      cPtValuesTempDetrNscTrsf = [zhTempDetrNscTrsf;softApproxTempDetrNscTrsf];
      detrNscTrsfDataPopulation = size(cPtValuesTempDetrNscTrsf,1);
      hist(cPtValuesTempDetrNscTrsf,selectedBars);
      figureOk = 1;
      if figureOk>0
        displayString = ['Data used for the plot: ' ...
          num2str(detrNscTrsfDataPopulation) ' (detrended N-score-space population)'];
        set(handles.feedbackEdit,'String',displayString);
        hFig = findobj(gca,'Type','patch');
        set(hFig,'FaceColor','y','EdgeColor','k');
        xlabel('Data');
        ylabel('Frequency');
      elseif figureOk==0
        image(imread('guiResources/ithinkPic.png'));
        axis image
        axis off
        displayString = 'Data not available for this map';
        set(handles.feedbackEdit,'String',displayString);
      else   % figureOk<0
        image(imread('guiResources/ithinkPic.png'));
        axis image
        axis off
      end
    else
      set(handles.feedbackEdit,'String','No trend information to generate graph');
      pause(2)
      set(handles.feedbackEdit,'String','No trend Data MAT-file present');
    end    
  case 6     % Displays detrended, Bcx-transformed data distribution
    detrTrsfDataPopulation = 0;       % Initialize
    if allOkDtr
      cPtValuesTempDetrBcxTrsf = [zhTempDetrBcxTrsf;softApproxTempDetrBcxTrsf];
      detrBcxTrsfDataPopulation = size(cPtValuesTempDetrBcxTrsf,1);
      hist(cPtValuesTempDetrBcxTrsf,selectedBars);
      figureOk = 1;
      if figureOk>0
        displayString = ['Data used for the plot: ' ...
          num2str(detrBcxTrsfDataPopulation) ' (detrended Box-Cox-space population)'];
        set(handles.feedbackEdit,'String',displayString);
        hFig = findobj(gca,'Type','patch');
        set(hFig,'FaceColor','y','EdgeColor','k');
        xlabel('Data');
        ylabel('Frequency');
      elseif figureOk==0
        image(imread('guiResources/ithinkPic.png'));
        axis image
        axis off
        displayString = 'Data not available for this map';
        set(handles.feedbackEdit,'String',displayString);
      else   % figureOk<0
        image(imread('guiResources/ithinkPic.png'));
        axis image
        axis off
      end
    else
      set(handles.feedbackEdit,'String','No trend information to generate graph');
      pause(2)
      set(handles.feedbackEdit,'String','No trend Data MAT-file present');
    end
end




% --- Executes during object creation, after setting all properties.
function graphTypeMenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to graphTypeMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on selection change in barsMenu.
function barsMenu_Callback(hObject, eventdata, handles)
% hObject    handle to barsMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns barsMenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from barsMenu
global zhTemp limiTemp softApproxTemp
global zhTempDetrended limiTempDetrended softApproxTempDetrended
global allOkDtr
global zhTempAtInst limiTempAtInst softApproxTempAtInst
global zhTempDetrendedAtInst limiTempDetrendedAtInst softApproxTempDetrendedAtInst
global prevAlltState
global xAxisName yAxisName zAxisName variableName
global outGrid totalSpCoordinatesUsed totalCoordinatesUsed
global zhTempDetrNscTrsf limiTempDetrNscTrsf softApproxTempDetrNscTrsf
global zhTempDetrBcxTrsf limiTempDetrBcxTrsf softApproxTempDetrBcxTrsf
global positiveDataOnly

barsOptions = get(handles.barsMenu,'String');
indexChoice = get(handles.barsMenu,'Value');
selectedBars = str2num(barsOptions{indexChoice});

if get(handles.extFigureBox,'Value') && ...
   (allOkDtr || get(handles.graphTypeMenu,'Value')==4 ...
             || get(handles.graphTypeMenu,'Value')==5 ...
             || get(handles.graphTypeMenu,'Value')==6 ) % Separate figure or not?
  axes(handles.dataDistribAxes)
  image(imread('guiResources/ithinkPic.png'));
  axis image
  axis off
  figure;
else
  axes(handles.dataDistribAxes)
end  
switch get(handles.graphTypeMenu,'Value')
  case 4     % Displays detrended data distribution
    detrDataPopulation = 0;       % Initialize
    if allOkDtr
        cPtValuesTempDetrended = [zhTempDetrended;softApproxTempDetrended];
        detrDataPopulation = size(cPtValuesTempDetrended,1);
        hist(cPtValuesTempDetrended,selectedBars);
        figureOk = 1;
      if figureOk>0
        displayString = ['Data used for the plot: ' ...
          num2str(detrDataPopulation) ' (detrended non-transformed population)'];
        set(handles.feedbackEdit,'String',displayString);
        hFig = findobj(gca,'Type','patch');
        set(hFig,'FaceColor','y','EdgeColor','k');
        xlabel('Data');
        ylabel('Frequency');
      elseif figureOk==0
        image(imread('guiResources/ithinkPic.png'));
        axis image
        axis off
        displayString = 'Data not available for this map';
        set(handles.feedbackEdit,'String',displayString);
      else   % figureOk<0
        image(imread('guiResources/ithinkPic.png'));
        axis image
        axis off
      end
    else
      set(handles.feedbackEdit,'String','No trend information to generate graph');
      pause(2)
      set(handles.feedbackEdit,'String','No trend Data MAT-file present');
    end
  case 5     % Displays detrended, Nsc-transformed data distribution
    detrTrsfDataPopulation = 0;       % Initialize
    if allOkDtr
      cPtValuesTempDetrNscTrsf = [zhTempDetrNscTrsf;softApproxTempDetrNscTrsf];
      detrNscTrsfDataPopulation = size(cPtValuesTempDetrNscTrsf,1);
      hist(cPtValuesTempDetrNscTrsf,selectedBars);
      figureOk = 1;
      if figureOk>0
        displayString = ['Data used for the plot: ' ...
          num2str(detrNscTrsfDataPopulation) ' (detrended N-score-space population)'];
        set(handles.feedbackEdit,'String',displayString);
        hFig = findobj(gca,'Type','patch');
        set(hFig,'FaceColor','y','EdgeColor','k');
        xlabel('Data');
        ylabel('Frequency');
      elseif figureOk==0
        image(imread('guiResources/ithinkPic.png'));
        axis image
        axis off
        displayString = 'Data not available for this map';
        set(handles.feedbackEdit,'String',displayString);
      else   % figureOk<0
        image(imread('guiResources/ithinkPic.png'));
        axis image
        axis off
      end
    else
      set(handles.feedbackEdit,'String','No trend information to generate graph');
      pause(2)
      set(handles.feedbackEdit,'String','No trend Data MAT-file present');
    end    
  case 6     % Displays detrended, Bcx-transformed data distribution
    detrTrsfDataPopulation = 0;       % Initialize
    if allOkDtr
      cPtValuesTempDetrBcxTrsf = [zhTempDetrBcxTrsf;softApproxTempDetrBcxTrsf];
      detrBcxTrsfDataPopulation = size(cPtValuesTempDetrBcxTrsf,1);
      hist(cPtValuesTempDetrBcxTrsf,selectedBars);
      figureOk = 1;
      if figureOk>0
        displayString = ['Data used for the plot: ' ...
          num2str(detrBcxTrsfDataPopulation) ' (detrended Box-Cox-space population)'];
        set(handles.feedbackEdit,'String',displayString);
        hFig = findobj(gca,'Type','patch');
        set(hFig,'FaceColor','y','EdgeColor','k');
        xlabel('Data');
        ylabel('Frequency');
      elseif figureOk==0
        image(imread('guiResources/ithinkPic.png'));
        axis image
        axis off
        displayString = 'Data not available for this map';
        set(handles.feedbackEdit,'String',displayString);
      else   % figureOk<0
        image(imread('guiResources/ithinkPic.png'));
        axis image
        axis off
      end
    else
      set(handles.feedbackEdit,'String','No trend information to generate graph');
      pause(2)
      set(handles.feedbackEdit,'String','No trend Data MAT-file present');
    end
otherwise
    % Do nothing.
end




% --- Executes during object creation, after setting all properties.
function barsMenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to barsMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





% --- Executes on button press in extFigureBox.
function extFigureBox_Callback(hObject, eventdata, handles)
% hObject    handle to extFigureBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of extFigureBox
global prevExtFigState

% Hint: get(hObject,'Value') returns toggle state of addMaskBox
if ~prevExtFigState
   
  set(handles.extFigureBox,'Value',1);
  prevExtFigState = 1;
  displayString = 'Plots to follow in separate windows';
  set(handles.feedbackEdit,'String',displayString);
        
else

  set(handles.extFigureBox,'Value',0);
  prevExtFigState = 0;
  displayString = 'Plots to follow in this window';
  set(handles.feedbackEdit,'String',displayString);  

end    




% --- Executes on button press in helpButton.
function helpButton_Callback(hObject, eventdata, handles)
% hObject    handle to helpButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

ip201helpMain('Title','BMElib Help');




% --- Executes on button press in mainButton.
function mainButton_Callback(hObject, eventdata, handles)
% hObject    handle to mainButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global initialDir;

cd(initialDir);
user_response = ip102back2mainDialog('Title','Confirm Action');
switch lower(user_response)
case 'no'
	% take no action
case 'yes'
	delete(handles.figure1);
    clear; clear all; clear memory;
    ip002chooseTask('Title','Choose a Task');
end




% --- Executes on button press in previousButton.
function previousButton_Callback(hObject, eventdata, handles)
% hObject    handle to previousButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global timePresent

delete(handles.figure1);                             % Close current window...
if timePresent
  ip304p2TexplorAnal('Title','Exploratory Analysis'); % ...and proceed to next screen.
else
  ip304p2explorAnal('Title','Exploratory Analysis');  % ...and proceed to next screen.
end




% --- Executes on button press in nextButton.
function nextButton_Callback(hObject, eventdata, handles)
% hObject    handle to nextButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global zhTempDetrended limiTempDetrended softApproxTempDetrended
global zhTempDetrNscTrsf limiTempDetrNscTrsf softApproxTempDetrNscTrsf
global zhTempDetrBcxTrsf limiTempDetrBcxTrsf softApproxTempDetrBcxTrsf
global zhDataToProcess limiDataToProcess softApproxDataToProcess
global zhTempDetrendedAtInst limiTempDetrendedAtInst
global softApproxTempDetrendedAtInst
global zhTempDetrNscTrsfAtInst limiTempDetrNscTrsfAtInst softApproxTempDetrNscTrsfAtInst
global zhTempDetrBcxTrsfAtInst limiTempDetrBcxTrsfAtInst softApproxTempDetrBcxTrsfAtInst
global zhDataToProcessAtInst limiDataToProcessAtInst softApproxDataToProcessAtInst
global applyTransform
global displayString
global dataTimeSpan
global timePresent
global positiveDataOnly

% At this point the data exploratory analysis is complete. Based on the user
% choices we save the data that will be sent for further processing in new
% variables. This may be consuming more memory, but we want to keep all values.
zhDataToProcess = [];                            % Initialize
limiDataToProcess = [];                          % Initialize
softApproxDataToProcess = [];                    % Initialize
for it=1:dataTimeSpan
  zhDataToProcessAtInst{it} = [];                % Initialize
  limiDataToProcessAtInst{it} = [];              % Initialize
  softApproxDataToProcessAtInst{it} = [];        % Initialize
end
switch applyTransform
  case 0    % If transformation skipped, use detrended data
    zhDataToProcess = zhTempDetrended;
    limiDataToProcess = limiTempDetrended;
    softApproxDataToProcess = softApproxTempDetrended;
    for it=1:dataTimeSpan
      zhDataToProcessAtInst{it} = zhTempDetrendedAtInst{it};
      limiDataToProcessAtInst{it} = limiTempDetrendedAtInst{it};
      softApproxDataToProcessAtInst{it} = softApproxTempDetrendedAtInst{it};
    end
  case 1    % If n-scores transformation used, use detrended transformed data
    zhDataToProcess = zhTempDetrNscTrsf;
    limiDataToProcess = limiTempDetrNscTrsf;
    softApproxDataToProcess = softApproxTempDetrNscTrsf;
    for it=1:dataTimeSpan
      zhDataToProcessAtInst{it} = zhTempDetrNscTrsfAtInst{it};
      limiDataToProcessAtInst{it} = limiTempDetrNscTrsfAtInst{it};
      softApproxDataToProcessAtInst{it} = softApproxTempDetrNscTrsfAtInst{it};
    end
  case 2    % If boxcox transformation used, use detrended transformed data
    zhDataToProcess = zhTempDetrBcxTrsf;
    limiDataToProcess = limiTempDetrBcxTrsf;
    softApproxDataToProcess = softApproxTempDetrBcxTrsf;
    for it=1:dataTimeSpan
      zhDataToProcessAtInst{it} = zhTempDetrBcxTrsfAtInst{it};
      limiDataToProcessAtInst{it} = limiTempDetrBcxTrsfAtInst{it};
      softApproxDataToProcessAtInst{it} = softApproxTempDetrBcxTrsfAtInst{it};
    end
  otherwise
    errordlg({'ip304p3TexplorAnal.m:nextButton:';...
      'No provision for requested applyTransform value ' num2str(applyTransform) '.'},...
      'GUI software Error')
end

delete(handles.figure1);                            % Close current window...
ip305p1TcovarAnal('Title','Covariance Analysis'); % ...and proceed to next 