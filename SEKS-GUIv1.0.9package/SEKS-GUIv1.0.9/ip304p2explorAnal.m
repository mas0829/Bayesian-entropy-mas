function varargout = ip304p2explorAnal(varargin)
%IP304P2EXPLORANAL M-file for ip304p2explorAnal.fig
%      IP304P2EXPLORANAL, by itself, creates a new IP304P2EXPLORANAL or raises the existing
%      singleton*.
%
%      H = IP304P2EXPLORANAL returns the handle to a new IP304P2EXPLORANAL or the handle to
%      the existing singleton*.
%
%      IP304P2EXPLORANAL('Property','Value',...) creates a new IP304P2EXPLORANAL using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to ip304p2explorAnal_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      IP304P2EXPLORANAL('CALLBACK') and IP304P2EXPLORANAL('CALLBACK',hObject,...) call the
%      local function named CALLBACK in IP304P2EXPLORANAL.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE'sDistEdit Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ip304p2explorAnal

% Last Modified by GUIDE v2.5 01-Feb-2006 15:56:36

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ip304p2explorAnal_OpeningFcn, ...
                   'gui_OutputFcn',  @ip304p2explorAnal_OutputFcn, ...
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


% --- Executes just before ip304p2explorAnal is made visible.
function ip304p2explorAnal_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

% Choose default command line output for ip304p2explorAnal
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

% UIWAIT makes ip304p2explorAnal wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ip304p2explorAnal_OutputFcn(hObject, eventdata, handles)
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
global ch zh cs ck ckIn2D totalCoordinatesUsed totalSpCoordinatesUsed
global sdCategory softpdftype nl limi probdens softApprox
global displayString
global usingGrid
global zhTemp limiTemp softApproxTemp
global allOkDtr
global zeroInLogScale
global trendDataSaved
global prevExtFigState
global maskKnown prevMaskState
global timePresent
global xMin dx xMax yMin dy yMax zMin dz zMax dataCoordMin dataCoordMax
global minTdata maxTdata dataTimeSpan
global chAtInst zhAtInst
global csAtInst nlAtInst limiAtInst probdensAtInst
global ckAtInst
global zhTempAtInst limiTempAtInst softApproxTempAtInst
global zhTempDetrended limiTempDetrended softApproxTempDetrended
global maxSdataSearchRadius maxTdataSearchRadius stMetricPar
global prevAlltState
global cPt cPtValues
global useSoftApproximations
global firstTrendInst lastTrendInst

zhTempDetrended = [];                         % Initialize
softApproxTempDetrended = [];                 % Initialize
limiTempDetrended = [];                       % Initialize
firstTrendInst = [];                          % Initialize. To be set in trend function
lastTrendInst = [];                           % Initialize. To be set in trend function

allOkDtr = 0;       % An indicator to allow user to continue to next stage.
trendDataSaved = 0; % Remains 0 if trend not saved or trend file not present. 

% Represent soft data as single values in exploratory analysis?
% FUTURE DEVELOPER NOTE:
% In future versions of the SEKS-GUI, there can be a button in this screen for
% the user to decide on this.
% Based on this decision, the mean trend and covariance will be calculated based
% either solely on the hard data or on the additional assistance from sodf data 
% approximations. When no hard data will be present, these tasks will be purely
% undertaken by the soft data approximations.
%
if ~hardDataPresent
  useSoftApproximations = 1;  % Should always be 1 if no hard data are present.
else
  useSoftApproximations = 1;  % Can be left to user choice at a later implementation.
end

if softDataPresent && useSoftApproximations
  % Represent soft data as single values. Use this feature in the calculation
  % of the mean trend. The approximations will not be used in the estimations.
  % 
  % Obtain mean of soft distribution
  [softApprox,dummy] = proba2stat(softpdftype,nl,limi,probdens);
  %% Obtain midpoint of intervals/uniform distr., or the mode of soft distributions
  %if sdCategory==2 || sdCategory==4  % A) Uniform distribution or Interval
  %  for il=1:size(limi,1)           % If interval, obtain midpoint
  %      softApprox(il,1) = (limi(il,2)+limi(il,1))/2;
  %  end
  %else                              % B) Any other PDF        
  %  for il=1:size(limi,1)           % If PDF, obtain most probable soft PDF value (mode)
  %      softApprox(il,1) = ...      
  %          limi(il, find(probdens(il,1:nl(il))==max(probdens(il,1:nl(il))),1) );
  %  end
  %end
else
  softApprox = [];   % Proper definition in case of no soft data
end

if useSoftApproximations
    cPt = [ch;cs];               % Provides for in case of no HD, too.
    cPtValues = [zh;softApprox];   
else
    cPt = ch;
    cPtValues = zh;
end

% Break down data based on time reference.
% Cell arrays will hold each temporal instance information in separate cells.
%
if timePresent
  if hardDataPresent
    % For all instances in study find the indices where each appears
    for ith=1:dataTimeSpan     
      indx = find(ch(:,end)==(minTdata+ith-1));
      chAtInst{ith} = ch(indx,1:end-1);  % Create cell array for instance coords
      zhAtInst{ith} = zh(indx,:);        % Create cell array for instance data
    end
  else
    for ith=1:dataTimeSpan     
      chAtInst{ith} = [];
      zhAtInst{ith} = [];
    end
  end
  if softDataPresent
    % For all instances in study find the indices where each appears
    for ith=1:dataTimeSpan   
      indx = find(cs(:,end)==(minTdata+ith-1));
      csAtInst{ith} = cs(indx,1:end-1);  % Create cell array for instance data
      nlAtInst{ith} = nl(indx,:);
      limiAtInst{ith} = limi(indx,:);
      probdensAtInst{ith} = probdens(indx,:);
    end
  else
    for ith=1:dataTimeSpan     
      csAtInst{ith} = [];
      nlAtInst{ith} = [];
      limiAtInst{ith} = [];
      probdensAtInst{ith} = [];
    end
  end
  for ith=1:dataTimeSpan     
    %indx = find(ck(:,end)==(minTdata+ith-1));
    %ckAtInst{ith} = ck(indx,1:end-1);    % Create cell array for instance coords
    ckAtInst{ith} = ckIn2D;               % Obtain grid net at all instances
  end
else             % Account for spatial-only investigations
  if hardDataPresent
    chAtInst{1} = ch;
    zhAtInst{1} = zh;
  else
    chAtInst{1} = [];
    zhAtInst{1} = [];
  end
  if softDataPresent
    csAtInst{1} = cs;
    nlAtInst{1} = nl;
    limiAtInst{1} = limi;
    probdensAtInst{1} = probdens;
  else
    csAtInst{1} = [];
    nlAtInst{1} = [];
    limiAtInst{1} = [];
    probdensAtInst{1} = [];
  end
  ckAtInst{1} = ck;
end

set(handles.detrendButton, 'Value', 0); 
set(handles.invokeDetrendedButton, 'Value', 0);
displayString = 'No trend Data MAT-file present';
set(handles.feedbackEdit,'String',displayString);
set(handles.barsMenu,'Value',3);      % Begin by showing histogram w/ 15 bars.
set(handles.graphTypeMenu,'Value',6); % Begin by showing non-detrended data distr.

% Make copies of variables. The copies can be used for transformations later,
% if necessary. Spatial-only version code.
if hardDataPresent        % First, for hard data
  zhTemp = zh;
  zhTempAtInst{1} = zhTemp;
else
  zhTemp = [];
  zhTempAtInst{1} = [];
end

if softDataPresent        % Then, for soft data
  limiTemp = limi; 
  limiTempAtInst{1} = limiTemp;
  softApproxTemp = softApprox;
  softApproxTempAtInst{1} = softApproxTemp;
else
  limiTemp = [];
  limiTempAtInst{1} = [];
  softApproxTemp = [];
  softApproxTempAtInst{1} = [];
end

% Gather all point data into a variable.
% Also provides correct set (HD only) in case where no SD approximations are used.
cPtValuesTemp = [zhTemp;softApproxTemp];
for ith=1:dataTimeSpan  % Be it a single (S only) or many (S/T) instances
  cPtValuesTempAtInst{ith} = [zhTempAtInst{ith} ; softApproxTempAtInst{ith}];
end

axes(handles.dataTrendAxes)
hist(cPtValuesTemp,15);
hFig = findobj(gca,'Type','patch');
set(hFig,'FaceColor','y','EdgeColor','k');
xlabel('Data');
ylabel('Frequency');

% Initialize the maximum data search radius in space
%
% Arbitrarily, in space ask to look into a size of half the largest grid dimension
switch totalSpCoordinatesUsed
  case 1
    if usingGrid
      maxSdataSearchRadius = (xMax-xMin)/2;
    else
      maxSdataSearchRadius = (max(chcs,1)-min(chcs,1))/2;
    end
  otherwise % In 2 and 3 spatial dimension cases
    if usingGrid
      maxSdataSearchRadius = max( (yMax-yMin)/2, (xMax-xMin)/2 );
    else
      maxSdataSearchRadius = (max(chcs,1)-min(chcs,1))/2;
    end
end
maxTdataSearchRadius = [];               % Initialize for consistency

% Initialize the parameter for Space/Time metric. This parameter is such, that:
% [ST max distance] = [max spatial distance] + [max temporal distance]*[stMetricPar]
% The parameter has an initial value which may turn out to be small - in this
% case errors will occur at the estimation stage when BMElib may not be able to
% find closest neighbors. In such an event the user is allowed to adjust
% stMetricPar in the estimations screen later. Here, stMetricPar is used to
% obtain an estimate of the trend in the current screen.
if timePresent
  stMetricPar = 0.3;
else
  stMetricPar = [];
end

set(handles.sDistEdit,'String',num2str(maxSdataSearchRadius));  % Initialize

prevAlltState = 1;                       % Initialize. Map to show data in all t

set(handles.addMaskBox,'Value',0);       % Initialize
maskKnown = 0;                           % The mask file and its path are unknown 
prevMaskState = 0;                       % Initialize - no mask
prevExtFigState = 0;                     % Initialize - plots in GUI window

set(handles.dataStatsMenu,'Value',1)
set(handles.countNoEdit,'String',num2str(size(cPtValues,1)));
set(handles.minValNoEdit,'String',num2str(min(cPtValues)));
set(handles.maxValNoEdit,'String',num2str(max(cPtValues)));
set(handles.meanNoEdit,'String',num2str(mean(cPtValues)));
set(handles.stDevNoEdit,'String',num2str(std(cPtValues)));
set(handles.medianNoEdit,'String',num2str(median(cPtValues)));
set(handles.skewnessNoEdit,'String',num2str(skewness(cPtValues)));
set(handles.kurtosisNoEdit,'String',num2str(kurtosis(cPtValues)));




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
global timePresent
global outGrid totalCoordinatesUsed 
global allOkDtr
global firstTrendInst lastTrendInst

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
    displayString = ['Boxes now displaying statistics for non-detrended'...
                     ' (original) data set'];
  case 2     % Displays statistics on the original detrended, non-transformed data
    if allOkDtr
      cPtValuesTempDetrended = [zhTempDetrended;softApproxTempDetrended];
      set(handles.countNoEdit,'String',num2str(size(cPtValuesTempDetrended,1)));
      set(handles.minValNoEdit,'String',num2str(min(cPtValuesTempDetrended)));
      set(handles.maxValNoEdit,'String',num2str(max(cPtValuesTempDetrended)));
      set(handles.meanNoEdit,'String',num2str(mean(cPtValuesTempDetrended)));
      set(handles.stDevNoEdit,'String',num2str(std(cPtValuesTempDetrended)));
      set(handles.medianNoEdit,'String',num2str(median(cPtValuesTempDetrended)));
      set(handles.skewnessNoEdit,'String',num2str(skewness(cPtValuesTempDetrended)));
      set(handles.kurtosisNoEdit,'String',num2str(kurtosis(cPtValuesTempDetrended)));
      displayString = ['Boxes now displaying statistics for detrended data set'];
      if timePresent   % Let user know this may be a partial data set
        displayString = [displayString ' in t=['...
          num2str(firstTrendInst) ',' num2str(lastTrendInst) ']'];
      end
    else
      set(handles.countNoEdit,'String','N/A');
      set(handles.minValNoEdit,'String','N/A');
      set(handles.maxValNoEdit,'String','N/A');
      set(handles.meanNoEdit,'String','N/A');
      set(handles.stDevNoEdit,'String','N/A');
      set(handles.medianNoEdit,'String','N/A');
      set(handles.skewnessNoEdit,'String','N/A');
      set(handles.kurtosisNoEdit,'String','N/A');
      displayString = 'No trend Data MAT-file present';
    end
  otherwise
    errordlg({'ip304p2explorAnal.m:dataStatsMenu:';...
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
global allOkDtr

switch get(handles.dataStatsMenu,'Value')
  case 1     % Displays statistics on the detrended, non-transformed data
    set(handles.countNoEdit,'String',num2str(size(cPtValues,1)));
  case 2     % Displays statistics on the detrended, non-transformed data
    if allOkDtr
      cPtValuesTempDetrended = [zhTempDetrended;softApproxTempDetrended];
      set(handles.countNoEdit,'String',num2str(size(cPtValuesTempDetrended,1)));
    else
      set(handles.countNoEdit,'String','N/A');
    end
  otherwise
    errordlg({'ip304p2explorAnal.m:countNoEdit:';...
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
global allOkDtr

switch get(handles.dataStatsMenu,'Value')
  case 1     % Displays statistics on the detrended, non-transformed data
    set(handles.minValNoEdit,'String',num2str(min(cPtValues)));
  case 2     % Displays statistics on the detrended, non-transformed data
    if allOkDtr
      cPtValuesTempDetrended = [zhTempDetrended;softApproxTempDetrended];
      set(handles.minValNoEdit,'String',num2str(min(cPtValuesTempDetrended)));
    else
      set(handles.minValNoEdit,'String','N/A');
    end
  otherwise
    errordlg({'ip304p2explorAnal.m:minValNoEdit:';...
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
global allOkDtr

switch get(handles.dataStatsMenu,'Value')
  case 1     % Displays statistics on the detrended, non-transformed data
    set(handles.maxValNoEdit,'String',num2str(max(cPtValues)));
  case 2     % Displays statistics on the detrended, non-transformed data
    if allOkDtr
      cPtValuesTempDetrended = [zhTempDetrended;softApproxTempDetrended];
      set(handles.maxValNoEdit,'String',num2str(max(cPtValuesTempDetrended)));
    else
      set(handles.maxValNoEdit,'String','N/A');
    end
  otherwise
    errordlg({'ip304p2explorAnal.m:maxValNoEdit:';...
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
global allOkDtr

switch get(handles.dataStatsMenu,'Value')
  case 1     % Displays statistics on the detrended, non-transformed data
    set(handles.meanNoEdit,'String',num2str(mean(cPtValues)));
  case 2     % Displays statistics on the detrended, non-transformed data
    if allOkDtr
      cPtValuesTempDetrended = [zhTempDetrended;softApproxTempDetrended];
      set(handles.meanNoEdit,'String',num2str(mean(cPtValuesTempDetrended)));
    else
      set(handles.meanNoEdit,'String','N/A');
    end
  otherwise
    errordlg({'ip304p2explorAnal.m:meanNoEdit:';...
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
global allOkDtr

switch get(handles.dataStatsMenu,'Value')
  case 1     % Displays statistics on the detrended, non-transformed data
    set(handles.stDevNoEdit,'String',num2str(std(cPtValues)));
  case 2     % Displays statistics on the detrended, non-transformed data
    if allOkDtr
      cPtValuesTempDetrended = [zhTempDetrended;softApproxTempDetrended];
      set(handles.stDevNoEdit,'String',num2str(std(cPtValuesTempDetrended)));
    else
      set(handles.stDevNoEdit,'String','N/A');
    end
  otherwise
    errordlg({'ip304p2explorAnal.m:stDevNoEdit:';...
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
global allOkDtr

switch get(handles.dataStatsMenu,'Value')
  case 1     % Displays statistics on the detrended, non-transformed data
    set(handles.medianNoEdit,'String',num2str(median(cPtValues)));
  case 2     % Displays statistics on the detrended, non-transformed data
    if allOkDtr
      cPtValuesTempDetrended = [zhTempDetrended;softApproxTempDetrended];
      set(handles.medianNoEdit,'String',num2str(median(cPtValuesTempDetrended)));
    else
      set(handles.medianNoEdit,'String','N/A');
    end
  otherwise
    errordlg({'ip304p2explorAnal.m:medianNoEdit:';...
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
global allOkDtr

switch get(handles.dataStatsMenu,'Value')
  case 1     % Displays statistics on the detrended, non-transformed data
    set(handles.skewnessNoEdit,'String',num2str(skewness(cPtValues)));
  case 2     % Displays statistics on the detrended, non-transformed data
    if allOkDtr
      cPtValuesTempDetrended = [zhTempDetrended;softApproxTempDetrended];
      set(handles.skewnessNoEdit,'String',num2str(skewness(cPtValuesTempDetrended)));
    else
      set(handles.skewnessNoEdit,'String','N/A');
    end
  otherwise
    errordlg({'ip304p2explorAnal.m:skewnessNoEdit:';...
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
global allOkDtr

switch get(handles.dataStatsMenu,'Value')
  case 1     % Displays statistics on the detrended, non-transformed data
    set(handles.kurtosisNoEdit,'String',num2str(kurtosis(cPtValues)));
  case 2     % Displays statistics on the detrended, non-transformed data
    if allOkDtr
      cPtValuesTempDetrended = [zhTempDetrended;softApproxTempDetrended];
      set(handles.kurtosisNoEdit,'String',num2str(kurtosis(cPtValuesTempDetrended)));
    else
      set(handles.kurtosisNoEdit,'String','N/A');
    end
  otherwise
    errordlg({'ip304p2explorAnal.m:kurtosisNoEdit:';...
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





% --- Executes on button press in invokeDetrendedButton.
function invokeDetrendedButton_Callback(hObject, eventdata, handles)
% hObject    handle to invokeDetrendedButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of invokeDetrendedButton
global trendFilename trendDataSaved
global zhTempDetrended limiTempDetrended softApproxTempDetrended
global zhTempDetrendedAtInst limiTempDetrendedAtInst
global softApproxTempDetrendedAtInst
global meanTrendAtk meanTrendAtkAtInst trendTInsts
global allOkDtr
global maxSdataSearchRadius maxTdataSearchRadius
global currentDir;

set(handles.detrendButton, 'Value', 0); 
set(handles.invokeDetrendedButton, 'Value', 1); 

initialDir = pwd;                    % Save the current directory path
cd(currentDir);

[trendFilename,trendPathname] = uigetfile('*.mat','Select trend Data MAT-file');
%
% If user presses 'Cancel' then 0 is returned.
% Should anything go wrong, we use the following criterion
%
if ~ischar(trendFilename)
    set(handles.feedbackEdit,'String','No trend Data MAT-file present');
    set(handles.invokeDetrendedButton, 'Value', 0); 
else
    cd (trendPathname);              % Go where the trend file resides
    currentDir=trendPathname;

    if ~isnan(str2double(textread(trendFilename,'%s',1)))
        warndlg({'Trend data are to be read from an existing MAT-file.';...
            'It seems that it is not a Matlab MAT-file.';,...
            'Please check again your input';...
            'or opt to calculate the trend again.'},...
            'Not a MAT-file!')
        set(handles.invokeDetrendedButton,'Value', 0);    % Bring user to screen start
        allOkDtr = 0;      % Detrending information is not yet gathered.
    else    
        set(handles.feedbackEdit,'String',['Using trend data in: ' trendFilename]);
        allTrendVariables = load('-mat',trendFilename);   % Load data from file
        zhTempDetrendedAtInst = allTrendVariables.zhTempDetrendedAtInst;
        limiTempDetrendedAtInst = allTrendVariables.limiTempDetrendedAtInst;
        softApproxTempDetrendedAtInst = allTrendVariables.softApproxTempDetrendedAtInst;
        meanTrendAtkAtInst = allTrendVariables.meanTrendAtkAtInst;
        trendTInsts = allTrendVariables.trendTInsts;
        zhTempDetrended = allTrendVariables.zhTempDetrended;
        limiTempDetrended = allTrendVariables.limiTempDetrended;
        softApproxTempDetrended = allTrendVariables.softApproxTempDetrended;
        maxSdataSearchRadius = allTrendVariables.maxSdataSearchRadius;
        clear allTrendVariables;
        allOkDtr = checkDetrendedGiven(handles);   % Data applicable to current study?
        if allOkDtr
          trendDataSaved = 1;      % Since we use existing saved data
          displayString = ['Using trend data from file ' trendFilename];
          set(handles.feedbackEdit,'String',displayString);
          set(handles.sDistEdit,'String',num2str(maxSdataSearchRadius));
          
          set(handles.dataStatsMenu,'Value',2);
          cPtValuesTempDetrended = [zhTempDetrended;softApproxTempDetrended];
          set(handles.countNoEdit,'String',num2str(size(cPtValuesTempDetrended,1)));
          set(handles.minValNoEdit,'String',num2str(min(cPtValuesTempDetrended)));
          set(handles.maxValNoEdit,'String',num2str(max(cPtValuesTempDetrended)));
          set(handles.meanNoEdit,'String',num2str(mean(cPtValuesTempDetrended)));
          set(handles.stDevNoEdit,'String',num2str(std(cPtValuesTempDetrended)));
          set(handles.medianNoEdit,'String',num2str(median(cPtValuesTempDetrended)));
          set(handles.skewnessNoEdit,'String',num2str(skewness(cPtValuesTempDetrended)));
          set(handles.kurtosisNoEdit,'String',num2str(kurtosis(cPtValuesTempDetrended)));

        else
          trendDataSaved = 0;
          % Data do not match current study and user has been notified in function call
          set(handles.invokeDetrendedButton,'Value', 0); % Bring user to screen start
          displayString = 'Invalid trend file input';
          set(handles.feedbackEdit,'String',displayString);
        end
    end
    
    cd (initialDir);             % Finally, return to where this function was evoked from
    
    set(handles.invokeDetrendedButton, 'Value', 0); 

end

 



% --- Executes on button press in detrendButton.
function detrendButton_Callback(hObject, eventdata, handles)
% hObject    handle to detrendButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of detrendButton
global allOkDtr
global zhTempDetrended limiTempDetrended softApproxTempDetrended
global chAtInst chcs 

set(handles.detrendButton, 'Value', 1); 
set(handles.invokeDetrendedButton, 'Value', 0);

user_response = ip104p1getTrendWarning('Title','Confirm Action');
switch lower(user_response)
    case 'no'
        set(handles.detrendButton, 'Value', 0);
    case 'yes'
        set(handles.detrendButton, 'Value', 1); 
        set(handles.invokeDetrendedButton, 'Value', 0); 
        allOkDtr = detrendingDataFunction(handles);
end  
if allOkDtr
  set(handles.dataStatsMenu,'Value',2);
  cPtValuesTempDetrended = [zhTempDetrended;softApproxTempDetrended];
  set(handles.countNoEdit,'String',num2str(size(cPtValuesTempDetrended,1)));
  set(handles.minValNoEdit,'String',num2str(min(cPtValuesTempDetrended)));
  set(handles.maxValNoEdit,'String',num2str(max(cPtValuesTempDetrended)));
  set(handles.meanNoEdit,'String',num2str(mean(cPtValuesTempDetrended)));
  set(handles.stDevNoEdit,'String',num2str(std(cPtValuesTempDetrended)));
  set(handles.medianNoEdit,'String',num2str(median(cPtValuesTempDetrended)));
  set(handles.skewnessNoEdit,'String',num2str(skewness(cPtValuesTempDetrended)));
  set(handles.kurtosisNoEdit,'String',num2str(kurtosis(cPtValuesTempDetrended)));
end





function sDistEdit_Callback(hObject, eventdata, handles)
% hObject    handle to sDistEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of sDistEdit as text
%        str2double(get(hObject,'String')) returns contents of sDistEdit as a double
global outGrid totalSpCoordinatesUsed
global xMin dx xMax yMin dy yMax zMin dz zMax dataCoordMin dataCoordMax
global maxSdataSearchRadius

inputValue = str2num(get(handles.sDistEdit,'String'));

if inputValue<0
  errordlg({'Please provide only a positive value';...
            'to be the maximum spatial data search radius.'},... 
            'Invalid input');
  set(handles.sDistEdit,'String',num2str(maxSdataSearchRadius));     % Initialize.
elseif isempty(inputValue) || ~isnumeric(inputValue)
  errordlg({'Please enter a numeric value for your estimate.'},... 
            'Invalid input');
  set(handles.sDistEdit,'String',num2str(maxSdataSearchRadius));     % Initialize.
elseif totalSpCoordinatesUsed==1 && inputValue>1.5*(xMax-xMin)
  errordlg({'The input value exceeds by more than 150%';...
            'the output grid size';...
            ['(currently: ' num2str(xMax-xMin) ' spatial units).'];...
            'Please provide a smaller value and remember that';...
            'larger radii values result in smoother trends.'},... 
            'Invalid input');
  set(handles.sDistEdit,'String',num2str(maxSdataSearchRadius));     % Initialize.
elseif totalSpCoordinatesUsed==2 && inputValue>1.5*(max((xMax-xMin),(yMax-yMin)))
  errordlg({'The input value exceeds by more than 150%';...
            'the output grid maximum side size';...
            ['(currently: ' num2str(max((xMax-xMin),(yMax-yMin))) ' spatial units).'];...
            'Please provide a smaller value and remember that';...
            'larger radii values result in smoother trends.'},... 
            'Invalid input');
  set(handles.sDistEdit,'String',num2str(maxSdataSearchRadius));     % Initialize.
else
  maxSdataSearchRadius = inputValue;
end




% --- Executes during object creation, after setting all properties.
function sDistEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sDistEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





% --- Executes on button press in saveDataButton.
function saveDataButton_Callback(hObject, eventdata, handles)
% hObject    handle to saveDataButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global zhTempDetrended limiTempDetrended softApproxTempDetrended
global zhTempDetrendedAtInst limiTempDetrendedAtInst 
global softApproxTempDetrendedAtInst
global meanTrendAtkAtInst 
global trendFilename trendDataSaved allOkDtr
global maxSdataSearchRadius maxTdataSearchRadius
global displayString 
global currentDir

if trendDataSaved
  warndlg({['Trend data are already stored in file "' trendFilename '".'];...
          'No action is taken.'},...
          'Data already saved!');
else
  if allOkDtr
    cd(currentDir);
    [trendFilename,trendPathname] = uiputfile( '*.mat', 'Save trend info as MAT-file:');	
    % Construct the full path and save
    if ~isequal([trendFilename,trendPathname],[0,0])
      File = fullfile(trendPathname,trendFilename)
      save(File,'zhTempDetrendedAtInst','softApproxTempDetrendedAtInst',...
                'limiTempDetrendedAtInst','meanTrendAtkAtInst',...
                'zhTempDetrended','softApproxTempDetrended','limiTempDetrended',...
                'maxSdataSearchRadius','maxTdataSearchRadius');
      displayString = ['Detrended data file: ' trendFilename];
      set(handles.feedbackEdit,'String',displayString);
      trendDataSaved = 1;
      currentDir=trendPathname;
    else
      if ~trendDataSaved
        displayString = ['No trend Data MAT-file present'];
        set(handles.feedbackEdit,'String',displayString);
      end
    end
  else
    errordlg({'No trend data are currently present.';...
        'Please either load a trend file, if it exists,';...
        'or push the detrending button to obtain trend information.'},...
        'No data to save!');
  end
end






% --- Executes on button press in clearDataButton.
function clearDataButton_Callback(hObject, eventdata, handles)
% hObject    handle to clearDataButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global zhTempDetrended limiTempDetrended softApproxTempDetrended
global zhTempDetrendedAtInst limiTempDetrendedAtInst 
global softApproxTempDetrendedAtInst
global meanTrendAtkAtInst 
global trendFilename trendDataSaved allOkDtr
global maxSdataSearchRadius maxTdataSearchRadius
global displayString

if allOkDtr
  user_response = ip104p2trendDataWarning('Title','Confirm Action');
  switch lower(user_response)
    case 'no'
      displayString = ['Using trend data in: ' trendFilename];
      set(handles.feedbackEdit,'String',displayString);
    case 'yes'
      clear zhTempDetrended limiTempDetrended softApproxTempDetrended
      clear zhTempDetrendedAtInst limiTempDetrendedAtInst 
      clear meanTrendAtkAtInst softApproxTempDetrendedAtInst
      allOkDtr = 0;
      trendFilename = [];
      trendDataSaved = 0;
      set(handles.sDistEdit,'String',num2str(maxSdataSearchRadius));  % Let as is
      displayString = ['Trend data cleared. No trend Data MAT-file present'];
      set(handles.feedbackEdit,'String',displayString);
      set(handles.detrendButton, 'Value', 0); 
      set(handles.invokeDetrendedButton, 'Value', 0); 
      if get(handles.dataStatsMenu,'Value')==2
        set(handles.countNoEdit,'String','N/A');
        set(handles.minValNoEdit,'String','N/A');
        set(handles.maxValNoEdit,'String','N/A');
        set(handles.meanNoEdit,'String','N/A');
        set(handles.stDevNoEdit,'String','N/A');
        set(handles.medianNoEdit,'String','N/A');
        set(handles.skewnessNoEdit,'String','N/A');
        set(handles.kurtosisNoEdit,'String','N/A');
      end
      
      if get(handles.extFigureBox,'Value')      % Separate figure or not?
        axes(handles.dataTrendAxes)
        image(imread('guiResources/ithinkPic.png'));
        axis image
        axis off
        figure;
      else
        axes(handles.dataTrendAxes)
        image(imread('guiResources/ithinkPic.png'));
        axis image
        axis off
      end
      
  end  
else
  errordlg({'No trend data are currently present for this action.'},...
      'No data to clear!');
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
global zhTempDetrendedAtInst limiTempDetrendedAtInst softApproxTempDetrendedAtInst
global maskFilename maskPathname maskKnown
global prevAlltState
global xAxisName yAxisName zAxisName variableName
global firstTrendInst lastTrendInst

barsOptions = get(handles.barsMenu,'String');
indexChoice = get(handles.barsMenu,'Value');
selectedBars = str2num(barsOptions{indexChoice});

if ~isempty(outGrid)
  firstOutInst = outGrid{totalCoordinatesUsed}(1);
  lastOutInst = outGrid{totalCoordinatesUsed}(size(outGrid{totalCoordinatesUsed},2));
else
  firstOutInst = 1;
  lastOutInst = 1;
end;
withinTlimits = 'firstOutInst<=tNow && tNow<=lastOutInst';


plotChoice = get(handles.graphTypeMenu,'Value');
if get(handles.extFigureBox,'Value')    % Separate figure or not?
  if (~(plotChoice==7 || plotChoice==8 || plotChoice==9) || allOkDtr)  
    axes(handles.dataTrendAxes)
    image(imread('guiResources/ithinkPic.png'));
    axis image
    axis off
    figure;
  end
else
  axes(handles.dataTrendAxes)
end  
switch get(handles.graphTypeMenu,'Value')
  case 1     % Displays map of data locations
    if totalSpCoordinatesUsed==2 
      
      hdPopulation = 0;       % Initialize
      sdPopulation = 0;       % Initialize
      if prevAlltState        % If we want a t-aggregated map
        if ~get(handles.extFigureBox,'Value')  % If plotting in the GUI window
          if hardDataPresent
            h1 = plot(ch(:,1),ch(:,2),'b.');
            hdPopulation = size(ch,1);
            legendhOk = 1;
            hold on;
          else
            legendhOk = 0;
          end
          if softDataPresent
            h2 = plot(cs(:,1),cs(:,2),'r.');
            sdPopulation = size(cs,1);
            legendsOk = 1;
            hold on;
          else
            legendsOk = 0;
          end
        else                                   % If using an external figure
          if hardDataPresent
            h1 = plot(ch(:,1),ch(:,2),'bv');
            hdPopulation = size(ch,1);
            legendhOk = 1;
            hold on;
          else
            legendhOk = 0;
          end
          if softDataPresent
            h2 = plot(cs(:,1),cs(:,2),'ro');
            sdPopulation = size(cs,1);
            legendsOk = 1;
            hold on;
          else
            legendsOk = 0;
          end
        end
      else                   % If we want a map at instance t
        tNow = str2num(get(handles.tInstanceEdit,'String'));
        if ~get(handles.extFigureBox,'Value')  % If plotting in the GUI window
          if hardDataPresent && ~isempty(chAtInst{tNow})      % Are there HD now?
            h1 = plot(chAtInst{tNow}(:,1),chAtInst{tNow}(:,2),'b.');
            hdPopulation = size(chAtInst{tNow},1);           % 0, if empty
            legendhOk = 1;
            hold on;
          else
            legendhOk = 0;
          end
          if softDataPresent && ~isempty(csAtInst{tNow})      % Are there SD now?
            h2 = plot(csAtInst{tNow}(:,1),csAtInst{tNow}(:,2),'r.');
            sdPopulation = size(csAtInst{tNow},1);           % 0, if empty
            legendsOk = 1;
            hold on;
          else
            legendsOk = 0;
          end
        else                                   % If using an external figure
          if hardDataPresent && ~isempty(chAtInst{tNow})      % Are there HD now?
            h1 = plot(chAtInst{tNow}(:,1),chAtInst{tNow}(:,2),'bv');
            hdPopulation = size(chAtInst{tNow},1);           % 0, if empty
            legendhOk = 1;
            hold on;
          else
            legendhOk = 0;
          end
          if softDataPresent && ~isempty(csAtInst{tNow})      % Are there SD now?
            h2 = plot(csAtInst{tNow}(:,1),csAtInst{tNow}(:,2),'ro');
            sdPopulation = size(csAtInst{tNow},1);           % 0, if empty
            legendsOk = 1;
            hold on;
          else
            legendsOk = 0;
          end
        end
      end
      
      hold off;
      axis image;
      if usingGrid
        axis([xMin xMax yMin yMax]);
      end
      xlabel('x-Axis');
      ylabel('y-Axis');
      if get(handles.addMaskBox,'Value')==1
        % Mask adding code. Will execute if masking option is on.
        initialDir = pwd;               % Save the current directory path
        cd (maskPathname);              % Go where the masking file resides
        % Remove the ending ".m" from the filename and execute the contents
        eval(regexprep(maskFilename,'.m',''));
        cd (initialDir)                 % Return to initial directory
      end
      if (legendhOk || legendsOk)
        displayString = ['Showing ' num2str(hdPopulation+sdPopulation) ' data on the map'];
        set(handles.feedbackEdit,'String',displayString);
        if legendhOk && legendsOk
          legend([h1 h2],'Hard Data','Soft Data');
        elseif legendhOk && ~legendsOk
          legend([h1],'Hard Data');
        elseif ~legendhOk && legendsOk
          legend([h2],'Soft Data');
        end
      else
        image(imread('guiResources/ithinkPic.png'));
        axis image
        axis off
        displayString = 'Data not available for this map';
        set(handles.feedbackEdit,'String',displayString);
      end
    else
      storedString = get(handles.feedbackEdit,'String');
      set(handles.feedbackEdit,'String','Only 2-D in space supported graph');
      pause(2);
      set(handles.feedbackEdit,'String',storedString);
    end
  case 2     % Displays map of data locations
    if hardDataPresent
      if totalSpCoordinatesUsed==2
        
        hdPopulation = 0;       % Initialize
        if prevAlltState        % If we want a t-aggregated map
          if ~get(handles.extFigureBox,'Value')  % If plotting in the GUI window
            h1 = plot(ch(:,1),ch(:,2),'b.');
            hdPopulation = size(ch,1);
            legendOk = 1;
          else                                   % If using an external figure
            h1 = plot(ch(:,1),ch(:,2),'bv');
            hdPopulation = size(ch,1);
            legendOk = 1;
          end
        else                   % If we want a map at instance t
          tNow = str2num(get(handles.tInstanceEdit,'String'));
          if ~get(handles.extFigureBox,'Value')  % If plotting in the GUI window
            if ~isempty(chAtInst{tNow})                      % Are there HD now?
              h1 = plot(chAtInst{tNow}(:,1),chAtInst{tNow}(:,2),'b.');
              hdPopulation = size(chAtInst{tNow},1);           % 0, if empty
              legendOk = 1;
             else
              legendOk = 0;
            end
          else                                   % If using an external figure
            if ~isempty(chAtInst{tNow})                      % Are there HD now?
              h1 = plot(chAtInst{tNow}(:,1),chAtInst{tNow}(:,2),'bv');
              hdPopulation = size(chAtInst{tNow},1);           % 0, if empty
              legendOk = 1;
             else
              legendOk = 0;
            end
          end
        end
        
        hold off;
        axis image;
        if usingGrid
          axis([xMin xMax yMin yMax]);
        end
        xlabel('x-Axis');
        ylabel('y-Axis');
        if get(handles.addMaskBox,'Value')==1
          % Mask adding code. Will execute if masking option is on.
          initialDir = pwd;               % Save the current directory path
          cd (maskPathname);              % Go where the masking file resides
          % Remove the ending ".m" from the filename and execute the contents
          eval(regexprep(maskFilename,'.m',''));
          cd (initialDir)                 % Return to initial directory
        end
        if legendOk
          displayString = ['Showing ' num2str(hdPopulation) ' data on the map'];
          set(handles.feedbackEdit,'String',displayString);
          legend([h1],'Hard Data');
        else
          image(imread('guiResources/ithinkPic.png'));
          axis image
          axis off
          displayString = 'Data not available for this map';
          set(handles.feedbackEdit,'String',displayString);
        end
      else
        storedString = get(handles.feedbackEdit,'String');
        set(handles.feedbackEdit,'String','Only 2-D in space supported graph');
        pause(2);
        set(handles.feedbackEdit,'String',storedString);
      end
    else
      displayString = 'Can not plot map: No hard data present';
      set(handles.feedbackEdit,'String',displayString);
    end           
  case 3     % Displays map of soft data locations
    if softDataPresent
      if totalSpCoordinatesUsed==2
        
        sdPopulation = 0;       % Initialize
        if prevAlltState        % If we want a t-aggregated map
          if ~get(handles.extFigureBox,'Value')  % If plotting in the GUI window
            h2 = plot(cs(:,1),cs(:,2),'r.');
            sdPopulation = size(cs,1);
            legendOk = 1;
          else                                   % If using an external figure
            h2 = plot(cs(:,1),cs(:,2),'ro');
            sdPopulation = size(cs,1);
            legendOk = 1;
          end
        else                   % If we want a map at instance t
          tNow = str2num(get(handles.tInstanceEdit,'String'));
          if ~get(handles.extFigureBox,'Value')  % If plotting in the GUI window
            if ~isempty(csAtInst{tNow})                      % Are there SD now?
              h2 = plot(csAtInst{tNow}(:,1),csAtInst{tNow}(:,2),'r.');
              sdPopulation = size(csAtInst{tNow},1);           % 0, if empty
              legendOk = 1;
             else
              legendOk = 0;
            end
          else                                   % If using an external figure
            if ~isempty(csAtInst{tNow})                      % Are there SD now?
              h2 = plot(csAtInst{tNow}(:,1),csAtInst{tNow}(:,2),'ro');
              sdPopulation = size(csAtInst{tNow},1);           % 0, if empty
              legendOk = 1;
             else
              legendOk = 0;
            end
          end
        end

        hold off;
        axis image;
        if usingGrid
          axis([xMin xMax yMin yMax]);
        end
        xlabel('x-Axis');
        ylabel('y-Axis');
        if get(handles.addMaskBox,'Value')==1
          % Mask adding code. Will execute if masking option is on.
          initialDir = pwd;               % Save the current directory path
          cd (maskPathname);              % Go where the masking file resides
          % Remove the ending ".m" from the filename and execute the contents
          eval(regexprep(maskFilename,'.m',''));
          cd (initialDir)                 % Return to initial directory
        end
        if legendOk
          displayString = ['Showing ' num2str(sdPopulation) ' data on the map'];
          set(handles.feedbackEdit,'String',displayString);
          legend([h2],'Soft Data');
        else
          image(imread('guiResources/ithinkPic.png'));
          axis image
          axis off
          displayString = 'Data not available for this map';
          set(handles.feedbackEdit,'String',displayString);
        end
      else
        storedString = get(handles.feedbackEdit,'String');
        set(handles.feedbackEdit,'String','Only 2-D in space supported graph');
        pause(2);
        set(handles.feedbackEdit,'String',storedString);
      end
    else
      displayString = 'Can not plot map: No soft data present';
      set(handles.feedbackEdit,'String',displayString);
    end           
  case 4     % Displays markerplots of hard data and soft data approximations
    if totalSpCoordinatesUsed==2 
      
    hdPopulation = 0;       % Initialize
    sdPopulation = 0;       % Initialize
      if ~get(handles.extFigureBox,'Value')  % If plotting in the GUI window
        if hardDataPresent
          markerplot(ch(:,1:2),zhTemp,[4 30],'MarkerEdgeColor','blue');
          hdPopulation = size(ch,1);
          legendhOk = 1;
          hold on;
        else
          legendhOk = 0;
        end
        if softDataPresent
          markerplot(cs(:,1:2),softApproxTemp,[4 30],'MarkerEdgeColor','red');
          sdPopulation = size(cs,1);
          legendsOk = 1;
          hold on;
        else
          legendsOk = 0;
        end
      else                                   % If using an external figure
        if hardDataPresent
          markerplot(ch(:,1:2),zhTemp,[4 30],'MarkerEdgeColor','blue');
          hdPopulation = size(ch,1);
          legendhOk = 1;
          hold on;
        else
          legendhOk = 0;
        end
        if softDataPresent
          markerplot(cs(:,1:2),softApproxTemp,[4 30],'MarkerEdgeColor','red');
          sdPopulation = size(cs,1);
          legendsOk = 1;
          hold on;
        else
          legendsOk = 0;
        end
      end
      
      hold off;
      axis image;
      if usingGrid
        axis([xMin xMax yMin yMax]);
      end
      xlabel('x-Axis');
      ylabel('y-Axis');
      if get(handles.addMaskBox,'Value')==1
        % Mask adding code. Will execute if masking option is on.
        initialDir = pwd;               % Save the current directory path
        cd (maskPathname);              % Go where the masking file resides
        % Remove the ending ".m" from the filename and execute the contents
        eval(regexprep(maskFilename,'.m',''));
        cd (initialDir)                 % Return to initial directory
      end
      if (legendhOk || legendsOk)
        displayString = ['Showing ' num2str(hdPopulation+sdPopulation) ' markers on the map'];
        set(handles.feedbackEdit,'String',displayString);
      else
        image(imread('guiResources/ithinkPic.png'));
        axis image
        axis off
        displayString = 'Data not available for this map';
        set(handles.feedbackEdit,'String',displayString);
      end
    else
      storedString = get(handles.feedbackEdit,'String');
      set(handles.feedbackEdit,'String','Only 2-D in space supported graph');
      pause(2);
      set(handles.feedbackEdit,'String',storedString);
    end
  case 5     % Displays colorplots of hard data and soft data approximations
    hotrev = hot;
    hotrev = hotrev(end:-1:1,:);  % Change order in hot colormap
    if totalSpCoordinatesUsed==2 
      
    hdPopulation = 0;       % Initialize
    sdPopulation = 0;       % Initialize
      if ~get(handles.extFigureBox,'Value')  % If plotting in the GUI window
        if hardDataPresent
          colorplot(ch(:,1:2),zhTemp,hotrev,'MarkerSize',7); colorbar;
          hdPopulation = size(ch,1);
          legendhOk = 1;
          hold on;
        else
          legendhOk = 0;
        end
        if softDataPresent
          colorplot(cs(:,1:2),softApproxTemp,hotrev,'MarkerSize',7); colorbar;
          sdPopulation = size(cs,1);
          legendsOk = 1;
          hold on;
        else
          legendsOk = 0;
        end
      else                                   % If using an external figure
        if hardDataPresent
          colorplot(ch(:,1:2),zhTemp,hotrev); colorbar;
          hdPopulation = size(ch,1);
          legendhOk = 1;
          hold on;
        else
          legendhOk = 0;
        end
        if softDataPresent
          colorplot(cs(:,1:2),softApproxTemp,hotrev); colorbar;
          sdPopulation = size(cs,1);
          legendsOk = 1;
          hold on;
        else
          legendsOk = 0;
        end
      end
      
      hold off;
      axis image;
      if usingGrid
        axis([xMin xMax yMin yMax]);
      end
      xlabel('x-Axis');
      ylabel('y-Axis');
      if get(handles.addMaskBox,'Value')==1
        % Mask adding code. Will execute if masking option is on.
        initialDir = pwd;               % Save the current directory path
        cd (maskPathname);              % Go where the masking file resides
        % Remove the ending ".m" from the filename and execute the contents
        eval(regexprep(maskFilename,'.m',''));
        cd (initialDir)                 % Return to initial directory
      end
      if (legendhOk || legendsOk)
        displayString = ['Showing ' num2str(hdPopulation+sdPopulation) ' data on the map'];
        set(handles.feedbackEdit,'String',displayString);
      else
        image(imread('guiResources/ithinkPic.png'));
        axis image
        axis off
        displayString = 'Data not available for this map';
        set(handles.feedbackEdit,'String',displayString);
      end
    else
      storedString = get(handles.feedbackEdit,'String');
      set(handles.feedbackEdit,'String','Only 2-D in space supported graph');
      pause(2);
      set(handles.feedbackEdit,'String',storedString);
    end
  case 6     % Displays non-detrended data distribution
    dataPopulation = 0;
    if prevAlltState        % If we want a t-aggregated map
      cPtValuesTemp = [zhTemp;softApproxTemp];
      dataPopulation = size(cPtValuesTemp,1);
      hist(cPtValuesTemp,selectedBars);
      figureOk = 1;
    else                    % If we want a map at instance t
      tNow = str2num(get(handles.tInstanceEdit,'String'));
      if ~isempty(zhTempAtInst{tNow}) || ~isempty(softApproxTempAtInst{tNow})
        tNow = str2num(get(handles.tInstanceEdit,'String'));
        cPtValuesTempAtInst{tNow} = [zhTempAtInst{tNow};softApproxTempAtInst{tNow}];
        dataPopulation = size(cPtValuesTempAtInst{tNow},1);
        hist(cPtValuesTempAtInst{tNow},selectedBars);
        figureOk = 1;
      else                                  % There are no data at this instance
        figureOk = 0;
      end
    end
    if figureOk
      displayString = ['Data used for the plot: ' num2str(dataPopulation)];
      set(handles.feedbackEdit,'String',displayString);
      hFig = findobj(gca,'Type','patch');
      set(hFig,'FaceColor','y','EdgeColor','k');
      xlabel('Data');
      ylabel('Frequency');
    else
      image(imread('guiResources/ithinkPic.png'));
      axis image
      axis off
      displayString = 'Data not available for this map';
      set(handles.feedbackEdit,'String',displayString);
    end
  case 7     % Displays detrended data distribution
    detrDataPopulation = 0;       % Initialize
    if allOkDtr
      cPtValuesTempDetrended = [zhTempDetrended;softApproxTempDetrended];
      detrDataPopulation = size(cPtValuesTempDetrended,1);
      hist(cPtValuesTempDetrended,selectedBars);
      figureOk = 1;
      displayString = ['Data used for the plot: ' num2str(detrDataPopulation)];
      set(handles.feedbackEdit,'String',displayString);
      hFig = findobj(gca,'Type','patch');
      set(hFig,'FaceColor','y','EdgeColor','k');
      xlabel('Data');
      ylabel('Frequency');
    else
      set(handles.feedbackEdit,'String','No trend information to generate graph');
      pause(2)
      set(handles.feedbackEdit,'String','No trend Data MAT-file present');
    end
  case 8     % Displays both, detrended and non-detrended data distributions
    dataPopulation = 0;           % Initialize
    detrDataPopulation = 0;       % Initialize
    if allOkDtr
      cPtValuesTempDetrended = [zhTempDetrended;softApproxTempDetrended];
      cPtValuesTemp = [zhTemp;softApproxTemp];
      dataPopulation = size(cPtValuesTemp,1);
      detrDataPopulation = size(cPtValuesTempDetrended,1);
      [f1,b1] = hist(cPtValuesTemp,selectedBars);          % Plot non-detrended
      h1 = bar(b1',f1',1);
      set(h1,'FaceColor','y','EdgeColor','k','LineStyle',':');
      hold on;
      [f2,b2] = hist(cPtValuesTempDetrended,selectedBars); % Plot detrended
      h2 = bar(b2',f2',1);
      set(h2,'FaceColor',[1 0.75 0],'EdgeColor','w');
      figureOk = 1;
      displayString = ['Data used: Non-detrended:' num2str(dataPopulation) ...
                       '. Detrended:' num2str(detrDataPopulation)];
      set(handles.feedbackEdit,'String',displayString);
      h21 = findobj(h2,'Type','patch');                    % Add transparency to
      set(h21,'FaceAlpha',0.7);                            % compare with other plot
      hold off;
      legend([h1 h2],'Non-detrended','Detrended');
      xlabel('Data');
      ylabel('Frequency');
    else
      set(handles.feedbackEdit,'String','No trend information to generate graph');
      pause(2)
      set(handles.feedbackEdit,'String','No trend Data MAT-file present');
    end
  case 9     % Plots mean trend graph (default space) if we are in spatial 2-D.
    if allOkDtr
      if timePresent
        if prevAlltState
          displayString = 'Please choose one t-Instance to create map';
          set(handles.feedbackEdit,'String',displayString);
          return;
        else
          tNow = str2num(get(handles.tInstanceEdit,'String'));
          meanTrendAtk = meanTrendAtkAtInst{tNow};
        end
      else
        meanTrendAtk = meanTrendAtkAtInst{1};
      end
      if totalSpCoordinatesUsed==2
        %burcontlines = [-2:1:4];
        %labburcontlines = [-2:2:4];
        [xMesh,yMesh] = meshgrid(outGrid{1},outGrid{2});
        [trash1,trash2] = contourf(xMesh,yMesh,meanTrendAtk);
        %[trash1,trash2] = contourf(xMesh,yMesh,meanTrendAtk,burcontlines);
        cmap = hot; cmap = cmap(end:-1:1,:); colormap(cmap);
        colorbar;
        axis image;
        if usingGrid
          axis([xMin xMax yMin yMax]);
        end
        xlabel('x-Axis');
        ylabel('y-Axis');
        if get(handles.addMaskBox,'Value')==1
          % Mask adding code. Will execute if masking option is on.
          initialDir = pwd;               % Save the current directory path
          cd (maskPathname);              % Go where the masking file resides
          % Remove the ending ".m" from the filename and execute the contents
          eval(regexprep(maskFilename,'.m',''));
          cd (initialDir)                 % Return to initial directory
        end
      else
        storedString = get(handles.feedbackEdit,'String');
        set(handles.feedbackEdit,'String','Only 2-D in space supported graph');
        pause(2);
        set(handles.feedbackEdit,'String',storedString);
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
global firstTrendInst lastTrendInst

barsOptions = get(handles.barsMenu,'String');
indexChoice = get(handles.barsMenu,'Value');
selectedBars = str2num(barsOptions{indexChoice});

if ~isempty(outGrid)
  firstOutInst = outGrid{totalCoordinatesUsed}(1);
  lastOutInst = outGrid{totalCoordinatesUsed}(size(outGrid{totalCoordinatesUsed},2));
else
  firstOutInst = 1;
  lastOutInst = 1;
end;

withinTlimits = 'firstOutInst<=tNow && tNow<=lastOutInst';

plotChoice = get(handles.graphTypeMenu,'Value');
if get(handles.extFigureBox,'Value') && ...
   (plotChoice==6 || plotChoice==7 || plotChoice==8)  % Separate figure or not?
  if (~(plotChoice==7 || plotChoice==8) || allOkDtr)  
    axes(handles.dataTrendAxes)
    image(imread('guiResources/ithinkPic.png'));
    axis image
    axis off
    figure;
  end
else
  axes(handles.dataTrendAxes)
  displayString = ['Bars handle has no effect on selected map type'];
  set(handles.feedbackEdit,'String',displayString);
end  
switch get(handles.graphTypeMenu,'Value')
  case 6     % Displays non-detrended data distribution
    dataPopulation = 0;
    if prevAlltState        % If we want a t-aggregated map
      cPtValuesTemp = [zhTemp;softApproxTemp];
      dataPopulation = size(cPtValuesTemp,1);
      hist(cPtValuesTemp,selectedBars);
      figureOk = 1;
    else                    % If we want a map at instance t
      tNow = str2num(get(handles.tInstanceEdit,'String'));
      if ~isempty(zhTempAtInst{tNow}) || ~isempty(softApproxTempAtInst{tNow})
        tNow = str2num(get(handles.tInstanceEdit,'String'));
        cPtValuesTempAtInst{tNow} = [zhTempAtInst{tNow};softApproxTempAtInst{tNow}];
        dataPopulation = size(cPtValuesTempAtInst{tNow},1);
        hist(cPtValuesTempAtInst{tNow},selectedBars);
        figureOk = 1;
      else                                  % There are no data at this instance
        figureOk = 0;
      end
    end
    if figureOk
      displayString = ['Data used for the plot: ' num2str(dataPopulation)];
      set(handles.feedbackEdit,'String',displayString);
      hFig = findobj(gca,'Type','patch');
      set(hFig,'FaceColor','y','EdgeColor','k');
      xlabel('Data');
      ylabel('Frequency');
    else
      image(imread('guiResources/ithinkPic.png'));
      axis image
      axis off
      displayString = 'Data not available for this map';
      set(handles.feedbackEdit,'String',displayString);
    end
  case 7     % Displays detrended data distribution
    detrDataPopulation = 0;       % Initialize
    if allOkDtr
      cPtValuesTempDetrended = [zhTempDetrended;softApproxTempDetrended];
      detrDataPopulation = size(cPtValuesTempDetrended,1);
      hist(cPtValuesTempDetrended,selectedBars);
      figureOk = 1;
      displayString = ['Data used for the plot: ' num2str(detrDataPopulation)];
      set(handles.feedbackEdit,'String',displayString);
      hFig = findobj(gca,'Type','patch');
      set(hFig,'FaceColor','y','EdgeColor','k');
      xlabel('Data');
      ylabel('Frequency');
    else
      set(handles.feedbackEdit,'String','No trend information to generate graph');
      pause(2)
      set(handles.feedbackEdit,'String','No trend Data MAT-file present');
    end
  case 8     % Displays both, detrended and non-detrended data distributions
    dataPopulation = 0;           % Initialize
    detrDataPopulation = 0;       % Initialize
    if allOkDtr
      cPtValuesTempDetrended = [zhTempDetrended;softApproxTempDetrended];
      cPtValuesTemp = [zhTemp;softApproxTemp];
      dataPopulation = size(cPtValuesTemp,1);
      detrDataPopulation = size(cPtValuesTempDetrended,1);
      [f1,b1] = hist(cPtValuesTemp,selectedBars);          % Plot non-detrended
      h1 = bar(b1',f1',1);
      set(h1,'FaceColor','y','EdgeColor','k','LineStyle',':');
      hold on;
      [f2,b2] = hist(cPtValuesTempDetrended,selectedBars); % Plot detrended
      h2 = bar(b2',f2',1);
      set(h2,'FaceColor',[1 0.75 0],'EdgeColor','w');
      figureOk = 1;
      displayString = ['Data used: Non-detrended:' num2str(dataPopulation) ...
                       '. Detrended:' num2str(detrDataPopulation)];
      set(handles.feedbackEdit,'String',displayString);
      h21 = findobj(h2,'Type','patch');                    % Add transparency to
      set(h21,'FaceAlpha',0.7);                            % compare with other plot
      hold off;
      legend([h1 h2],'Non-detrended','Detrended');
      xlabel('Data');
      ylabel('Frequency');
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




% --- Executes on button press in addMaskBox.
function addMaskBox_Callback(hObject, eventdata, handles)
% hObject    handle to addMaskBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of addMaskBox
global displayString
global maskFilename maskPathname maskKnown
global prevMaskState
global currentDir;

% Hint: get(hObject,'Value') returns toggle state of addMaskBox
if ~prevMaskState
   
   
  if maskKnown
    set(handles.addMaskBox,'Value',1);
    prevMaskState = 1;
    displayString = 'Map mask will now be applied in plots to follow';
    set(handles.feedbackEdit,'String',displayString);     
  else                    % Prompt the user to find the file with map mask info
%    initialDir = pwd;     % Save the current directory path
    cd(currentDir);
    [maskFilename,maskPathname] = uigetfile('*.m','Select masking M-file');
    if isequal([maskFilename,maskPathname],[0,0])  % If 'Cancel' selected
      cd (currentDir)     % Finally, return to where this function was evoked from
      displayString = 'Map masking cancelled';
      set(handles.feedbackEdit,'String',displayString);
      set(handles.addMaskBox,'Value',0);
    else
%      cd (initialDir)     % Finally, return to where this function was evoked from
      set(handles.addMaskBox,'Value',1);
      prevMaskState = 1;
      displayString = 'Map mask will now be applied in plots to follow';
      set(handles.feedbackEdit,'String',displayString);     
      maskKnown = 1;   
    end
  end
  
        
else

  set(handles.addMaskBox,'Value',0);
  prevMaskState = 0;
  displayString = 'Map mask to be removed from plots to follow';
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

delete(handles.figure1);                            % Close current window...
ip304p1explorAnal('Title','Exploratory Analysis');  % ...and procede to the previous unit.




% --- Executes on button press in nextButton.
function nextButton_Callback(hObject, eventdata, handles)
% hObject    handle to nextButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global allOkDtr trendDataSaved timePresent dataTimeSpan
global zhTempDetrended limiTempDetrended softApproxTempDetrended
global zhTemp limiTemp softApproxTemp
global zhTempDetrendedAtInst limiTempDetrendedAtInst 
global meanTrendAtkAtInst softApproxTempDetrendedAtInst
global zhTempAtInst limiTempAtInst softApproxTempAtInst
global totalSpCoordinatesUsed outGrid
global ckAtInst

if (~trendDataSaved ||  ~allOkDtr)
  user_response = ip107noMeanTrendWarning('Title','Confirm Action');
  switch lower(user_response)
    case 'no'
      % Do nothing: The user decided to stay with this screen.
    case 'yes'
      % The user decided to use a zero mean trend (not to detrend the data)
      allOkDtr = 1;
      trendFilename = [];
      trendDataSaved = 1;
      displayString = ['Proceeding to next screen...'];
      set(handles.feedbackEdit,'String',displayString);
      % Set as detrended values the existing ones
      zhTempDetrended = zhTemp;
      limiTempDetrended = limiTemp;
      softApproxTempDetrended = softApproxTemp;
      zhTempDetrendedAtInst = zhTempAtInst;
      limiTempDetrendedAtInst = limiTempAtInst;
      softApproxTempDetrendedAtInst = softApproxTempAtInst;
      
      % Produce zero mean trend variables
      if ~isempty(outGrid)
        for it=1:dataTimeSpan
          switch totalSpCoordinatesUsed  % A 1-D in space does not need reshaping
            case 1
              meanTrendAtkAtInst{it} = zeros( size(outGrid{1},2),1 );
            case 2
              meanTrendAtkAtInst{it} = zeros( size(outGrid{2},2),size(outGrid{1},2) );
            otherwise
              errordlg({'ip304p2TexplorAnal.m:nextButton:';...
                'GUI covers only 1 and 2 spatial coordinates.'},...
                'GUI software Error');
          end
        end
      else
        for it=1:dataTimeSpan
          if ~isempty(ckAtInst{it})
            meanTrendAtkAtInst{it} = zeros(size(ckAtInst{it},1));
          else
            meanTrendAtkAtInst{it} = [];
          end;
        end   
      end;      

      delete(handles.figure1);                    % Close current window...
      % Common for S/T and S-only cases
      ip304p3TexplorAnal('Title','Exploratory Analysis'); % ...and proceed.
  end
  
else
  delete(handles.figure1);                        % Close current window...
  % Common for S/T and S-only cases
  ip304p3TexplorAnal('Title','Exploratory Analysis');     % ...and proceed.
end
    



function [allOkDtr] = detrendingDataFunction(handles)
%
% Called after the user has asked to proceed with the given data detrending.
% This function uses previously provided information and calculates
% the detrended sets of hard data, soft PDF spans, and soft data approximations
% as appropriate in the form of global variables.
%
global hardDataPresent softDataPresent
global ch zh cs ck totalCoordinatesUsed totalSpCoordinatesUsed
global sdCategory nl limi probdens softApprox
global usingGrid
global outGrid
global xMin dx xMax yMin dy yMax zMin dz zMax dataCoordMin dataCoordMax
global zhTemp limiTemp softApproxTemp
global zhTempDetrended limiTempDetrended softApproxTempDetrended
global meanTrendAtk trendFilename trendDataSaved
global useSoftApproximations
global timePresent
global minThard maxThard minTsoft maxTsoft minTdata maxTdata dataTimeSpan trendTInsts
global maxSdataSearchRadius maxTdataSearchRadius stMetricPar
global chAtInst zhAtInst
global csAtInst nlAtInst limiAtInst probdensAtInst
global ckAtInst
global zhTempAtInst limiTempAtInst softApproxTempAtInst
global zhTempDetrendedAtInst limiTempDetrendedAtInst
global softApproxTempDetrendedAtInst
global meanTrendAtkAtInst
global firstTrendInst lastTrendInst
global currentDir

if timePresent
  totalInstances = size(outGrid{totalCoordinatesUsed},2);
else
  totalInstances = 1;
end

chcs = [ch;cs];
cPtValuesTemp = [zhTemp;softApproxTemp];

% The following part is used to identify and exclude potential outliers in
% the data set from the mean trend extraction process. In a highly skewed
% data distribution there may exist individual values that are far out from
% the data median. Such values may be potential outliers that can
% artificially contribute to the mean trend calculation. These values are
% identified by means of the "findOutliers" function based on the box plot
% graphical techniques to isolate outliers in a data distribution.
%addpath guiResources;
[sortOrder,mildOutlId,mildOutliers,extrOutlId,extrOutliers,...
  noExtrOutl,noMildOutl] = findOutliers(cPtValuesTemp); % Process data values
cPtValuesTempKept = noExtrOutl;               % Use these values to get trend
chcsSorted = chcs(sortOrder,:);               % Sort all coords as values
% Keep only non-extreme points coordinates for trend extraction
chcsSortedKept = chcsSorted(~extrOutlId,:);

zhTempDetrended = [];                         % Initialize
softApproxTempDetrended = [];                 % Initialize
limiTempDetrended = [];                       % Initialize

firstTrendInst = 1;
lastTrendInst = dataTimeSpan;
trendTInsts = NaN*ones(dataTimeSpan,1);       % Initialize

for it=firstTrendInst:lastTrendInst           % Loop over requested t
  
  if timePresent
    displayString = ['Detrending started for t=' num2str(it) ' ('...
                     num2str(it) '/' num2str(dataTimeSpan) ')'];
  else
    displayString = ['Detrending started'];
  end
  set(handles.feedbackEdit,'String',displayString);
  pause(0.1);

  % Define kernelsmoothing parameters
  %
  % Smoothing radius: The larger it is, the more smooth the trend.
  % Use as size the length of 1/10th of output grid shortest axis.
  % If there is no output grid use the data coordinates for measure.
  if totalSpCoordinatesUsed>=2
    if usingGrid
      smRadius = min( (yMax-yMin)/10, (xMax-xMin)/10 );
    else
      smRadius = (max(chcs,1)-min(chcs,1))/10;
    end
  else
    if usingGrid
      smRadius = (xMax-xMin)/10;
    else
      smRadius = (max(chcs,1)-min(chcs,1))/10;
    end
  end

  % Max hard data to be used for trend calculation.
  % In the present version the soft data approximations are included in this pool.
  maxHd = 300;
  %
  % Max distance within which to consider nearby hard data.
  maxDist = maxSdataSearchRadius;

  % Mean trend extraction using kernel smoothing function.
  % Note that the same data are used to obtain trend at all temporal instances.
  
  if hardDataPresent
    displayString = ['Detrending hard data. Please wait...'];
    set(handles.feedbackEdit,'String',displayString);
    pause(0.1);
    hardMeanTrendAtInst{it} = kernelsmoothing(chAtInst{it}, ...
                              chcsSortedKept,cPtValuesTempKept, ...
                              smRadius^2,maxHd,maxDist);
  else
    hardMeanTrendAtInst{it} = [];
  end
  % Estimate of mean trend at SD locations cs. Use the SD approximations, if
  % present, to do so, by employing the approximation single value to get trend.
  if softDataPresent && useSoftApproximations
    displayString = ['Detrending soft data. Please wait...'];
    set(handles.feedbackEdit,'String',displayString);
    pause(0.1);
    softMeanTrendAtInst{it} = kernelsmoothing(csAtInst{it}, ...
                              chcsSortedKept,cPtValuesTempKept, ...
                              smRadius^2,maxHd,maxDist);
  else
    softMeanTrendAtInst{it} = [];
  end

  % Estimate of mean trend at estimation locations
  displayString = ['Getting trend at estimation loci. Please wait...'];
  set(handles.feedbackEdit,'String',displayString);
  pause(0.1);
  meanTrendAtkAtInst{it} = kernelsmoothing(ckAtInst{it}, ...
                           chcsSortedKept,cPtValuesTempKept, ...
                           smRadius^2,maxHd,maxDist);
  
  if ~isempty(outGrid)  % Condition was missing: BUG FIXED ON 05JUN2010
    switch totalSpCoordinatesUsed  % A 1-D in space does not need reshaping
      case 2
        meanTrendAtkAtInst{it} = reshape(meanTrendAtkAtInst{it}, ...
                                 size(outGrid{2},2),size(outGrid{1},2));
      case 3                       % For future 4-D space and temporal version
        meanTrendAtkAtInst{it} = reshape(meanTrendAtkAtInst{it}, ...
                                 size(outGrid{2},2),size(outGrid{1},2));
    end
  end
  
  % Obtain detrended data. All values reside in the temp variables.
  %
  % The following is empty if no HD are present
  zhTempDetrendedAtInst{it} = zhTempAtInst{it} - hardMeanTrendAtInst{it};
  zhTempDetrended = [zhTempDetrended;zhTempDetrendedAtInst{it}]; % Get t-aggregate, too
  % The following is empty if no SD are present
  softApproxTempDetrendedAtInst{it} = ...
      softApproxTempAtInst{it} - softMeanTrendAtInst{it};
  softApproxTempDetrended = [softApproxTempDetrended; ...        
                             softApproxTempDetrendedAtInst{it}]; % Get t-aggregate, too
      
  % The following one removes the trend from the soft interval/PDF limits.
  % As in the previous, if no SD are present an empty matrix is produced.
  if (isempty(softMeanTrendAtInst{it}))
    limiTempDetrendedAtInst{it} = [];
  else
    limiTempDetrendedAtInst{it} = ...
    limiTempAtInst{it} - kron(ones(1,size(limiTempAtInst{it},2)),softMeanTrendAtInst{it});
    limiTempDetrended = [limiTempDetrended;limiTempDetrendedAtInst{it}];
  end
end           % Loop over all instances

set(handles.feedbackEdit,'String','Detrending completed. Saving data...');
% Prompt user to save trend information data in a MAT-file for future use
%
cd(currentDir);
[trendFilename,trendPathname] = uiputfile( '*.mat', 'Save trend info as MAT-file:');	

if isequal([trendFilename,trendPathname],[0,0])  % If 'Cancel' selected, give second chance
  user_response = ip103fileSaveDialog('Title','Skip Saving Trend Data?');
  switch lower(user_response)
  case 'no'                            % If user changes his/her mind, prompt to save
    [trendFilename,trendPathname] = uiputfile( '*.mat', 'Save trend info as MAT-file:');	
    if ~isequal([trendFilename,trendPathname],[0,0])  % If other than 'Cancel' was selected
        % Construct the full path and save
        File = fullfile(trendPathname,trendFilename);
        save(File,'zhTempDetrendedAtInst','softApproxTempDetrendedAtInst',...
                  'limiTempDetrendedAtInst','meanTrendAtkAtInst',...
                  'zhTempDetrended','softApproxTempDetrended','limiTempDetrended',...
                  'maxSdataSearchRadius','maxTdataSearchRadius',...
                  'firstTrendInst','lastTrendInst','trendTInsts');
        set(handles.feedbackEdit,'String',['Detrended data file: ' trendFilename]);
        trendDataSaved = 1;
        currentDir=trendPathname;
    end
  case 'yes'
    % Do nothing
    trendFilename = [];
    set(handles.feedbackEdit,'String','Detrended data present but not saved');
  end
else                                 % If other than 'Cancel' was selected at first
  % Construct the full path and save
  File = fullfile(trendPathname,trendFilename);
  save(File,'zhTempDetrendedAtInst','softApproxTempDetrendedAtInst',...
            'limiTempDetrendedAtInst','meanTrendAtkAtInst',...
            'zhTempDetrended','softApproxTempDetrended','limiTempDetrended',...
            'maxSdataSearchRadius','maxTdataSearchRadius',...
            'firstTrendInst','lastTrendInst','trendTInsts');
  set(handles.feedbackEdit,'String',['Detrended data file: ' trendFilename]);
  trendDataSaved = 1;
  currentDir=trendPathname;
end

allOkDtr = 1;
set(handles.detrendButton, 'Value', 0); 

% Let user know that trend information is only available where calculated
pause(0.1);
if timePresent
  displayString = ['Trend info available in t=[' num2str(firstTrendInst) ...
                   ',' num2str(lastTrendInst) ']'];
else
  displayString = ['Trend info available now'];
end
set(handles.feedbackEdit,'String',displayString);





function [allOkDtr] = checkDetrendedGiven(handles)
%
% Called after loading a MAT-file that contains data trend information.
% Detrended data have been provided and this function performs a rudimentary check
% on whether they apply to the current study by means of the matrix sizes used.
%
global totalCoordinatesUsed totalSpCoordinatesUsed
global outGrid
global timePresent
global csAtInst nlAtInst limiAtInst probdensAtInst
global zhTempAtInst limiTempAtInst softApproxTempAtInst
global zhTempDetrendedAtInst limiTempDetrendedAtInst
global softApproxTempDetrendedAtInst

% Current module applies to spatial-only case
it = 1;

matrA = size(zhTempAtInst{it});
matrB = size(limiTempAtInst{it});
matrC = size(softApproxTempAtInst{it});

matrAd = size(zhTempDetrendedAtInst{it});
matrBd = size(limiTempDetrendedAtInst{it});
matrCd = size(softApproxTempDetrendedAtInst{it});

allOkDtr = 1;        % Begin assuming everything is fine.
if (size(matrA,2) ~= size(matrAd,2) || ...
    size(matrB,2) ~= size(matrBd,2) || ...
    size(matrC,2) ~= size(matrCd,2) )
  errordlg({'The trend in the file provided refers to data';...
    'of different dimensions in space than of the current study.';...
    'Please start over and choose another input file';...
    'or ask to calculate the trend again.'},...
    'Data do not match current study!');
  allOkDtr = 0;
else
  for iSp = 1:totalSpCoordinatesUsed
    if ( size(zhTempAtInst{it},iSp) ~= ...
        size(zhTempDetrendedAtInst{it},iSp) ||...
        size(limiTempAtInst{it},iSp) ~= ...
        size(limiTempDetrendedAtInst{it},iSp) ||...
        size(softApproxTempAtInst{it},iSp) ~= ...
        size(softApproxTempDetrendedAtInst{it},iSp) )
      errordlg({'The trend in the file provided refers to data';...
        'different than the ones used in the current study.';...
        'Please start over and choose another input file';...
        'or ask to calculate the trend again.'},...
        'Data do not match current study!');
      allOkDtr = 0;
      break
    end
  end
end

