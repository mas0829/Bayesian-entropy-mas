function varargout = ip306predictionWiz(varargin)
%IP306PREDICTIONWIZ M-file for ip306predictionWiz.fig
%      IP306PREDICTIONWIZ, by itself, creates a new IP306PREDICTIONWIZ or raises the existing
%      singleton*.
%
%      H = IP306PREDICTIONWIZ returns the handle to a new IP306PREDICTIONWIZ or the handle to
%      the existing singleton*.
%
%      IP306PREDICTIONWIZ('Property','Value',...) creates a new IP306PREDICTIONWIZ using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to ip306predictionWiz_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      IP306PREDICTIONWIZ('CALLBACK') and IP306PREDICTIONWIZ('CALLBACK',hObject,...) call the
%      local function named CALLBACK in IP306PREDICTIONWIZ.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ip306predictionWiz

% Last Modified by GUIDE v2.5 08-Feb-2006 17:50:08

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ip306predictionWiz_OpeningFcn, ...
                   'gui_OutputFcn',  @ip306predictionWiz_OutputFcn, ...
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


% --- Executes just before ip306predictionWiz is made visible.
function ip306predictionWiz_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

% Choose default command line output for ip306predictionWiz
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

% UIWAIT makes ip306predictionWiz wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ip306predictionWiz_OutputFcn(hObject, eventdata, handles)
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
global displayString
global confIntSliderValue
global ck ch cs usingPolygon ck4estFlag
global ck4est ch4est cs4est zh4est nl4est limi4est probdens4est
global covmodel covparam dmax nhmax nsmax order bmeoptions
global bmeMod bmeMom bmePdf bmeCin
global covModelS covParamS maxCorrRangeS
global covModelST covParamST maxCorrRangeT
global correlationFactor
global timePresent dataTimeSpan minTdata maxTdata
global minTout maxTout outputTimeSpan
global maxSdataSearchRadius maxTdataSearchRadius stMetricPar
global outGrid totalCoordinatesUsed
global chAtInst zhAtInst
global csAtInst nlAtInst limiAtInst probdensAtInst
global ckAtInst
global zhTempAtInst limiTempAtInst softApproxTempAtInst
global zhDataToProcessAtInst limiDataToProcessAtInst
global softApproxDataToProcessAtInst probdensFromDetrendedAtInst
global zhDataToProcess limiDataToProcess softApproxDataToProcess
global softpdftype nl probdens
global initialNhmax initialNsmax

axes(handles.estScreenAxes)
image(imread('guiResources/ithinkPic.png'));
axis image
axis off

% VERY IMPORTANT
% The output cell matrices bmeMod bmeMom bmePdf bmeCin
% are all initialized in :ip002chooseTask.m".
% Should any changes occur in their size the programmer must update the above.
% Also, in the above file the elements {1,1} are all set to 0 initially.

set(handles.estSelectionMenu,'Value',1) % Initialize

if size(ch,1)<50      % This value is first set here. Allow for enough HD
  initialNhmax = size(ch,1);
else
  initialNhmax = 50;   
end
initialNsmax = 3;      % This value is first set here
nhmax = initialNhmax;  % Initialize: Consider the closest nhmax hard data for estimations
nsmax = initialNsmax;  % Initialize: Consider the closest nsmax soft data for estimations
order = NaN;           % Zero mean trend
if hardDataPresent
  set(handles.maxHdEdit,'String',num2str(initialNhmax));
else
  set(handles.maxHdEdit,'String','N/A');
end
if softDataPresent
  set(handles.maxSdEdit,'String',num2str(initialNsmax));
else
  set(handles.maxSdEdit,'String','N/A');
end
    
% The following initializations handle BMElib options.
% We make them as general as possible. In later versions some/all could
% be added to the screen for custom configuration.
%
% This one handles BMElib options(20) (default: 0.68) 
% For future versions: More than 1 confid. intervals can be estimated at a time.
% BMElib options(20:29) handle this. FOr added functionality, there can be more
% sliders, or additional levels could be stored in a variable.
confIntSliderValue = 0.68;                                    % Initialize
set(handles.confIntSlider,'Value',confIntSliderValue);        % Initialize
set(handles.confIntEdit,'String','68');                       % Initialize
bmeoptions(20) = confIntSliderValue;

bmeoptions(3) = 200000; % BMElib integral calcs allowed. Default: 50000.
bmeoptions(4) = 0.005;  % BMElib max relative error allowed in above. Default: 0.0001.

bmeoptions(6) = 30;     % BMElib bins for output PDF. Default: 25.
bmeoptions(7) = 0.001;  % BMElib controller of the output grid range. Default: 0.001.
bmeoptions(8) = 3;      % BMElib controller: Calculate all moments.

% Prepare the BME parameters to enter the estimation functions.
ch4est = [];            % Initialize
cs4est = [];            % Initialize
ck4est = [];            % Initialize
zh4est = [];            % Initialize
nl4est = [];            % Initialize
limi4est = [];          % Initialize
probdens4est = [];      % Initialize

correlationFactor = 1.25; % For search: Use correlationFactor*100% of the ranges


%% Add by H-L to define the default dmax based on the estimation of
%% the parameters of covariance functions

[isST,isSTsep,modelS,modelT]=isspacetime(covmodel);
if isST && isSTsep 
  for i=1:length(modelS)
    if length(covparam{i})==3
      covSill(i)=covparam{i}(1);
      covRangeS(i)=covparam{i}(2);
      covRangeT{i}=covparam{i}(3);
    else
      break;
    end;
  end;
  MaxSillIdx=find(covSill==max(covSill));
  maxCorrRangeS=2*covparam{MaxSillIdx}(2);
  maxCorrRangeT=2*covparam{MaxSillIdx}(3);
end;
  

if timePresent
  maxCorS=covParamST{1}(2);
  maxCorT=covParamST{1}(3);
  for i=1:length(covParamST)
    if covParamST{i}(2)>maxCorS
      maxCorS=covParamST{i}(2);
    end;
    if covParamST{i}(3)>maxCorT
       maxCorT=covParamST{i}(3);
    end;     
  end;
  % Search for data as far away in S/T as correlation goes
  dmax(1)=maxCorS;
  dmax(2)=maxCorT;
  dmax(3)=maxCorS/maxCorT;
%  dmax(1) = correlationFactor*maxCorrRangeS;                  % Initialize
%  dmax(2) = floor(correlationFactor*maxCorrRangeT);           % Initialize
%  dmax(3) = stMetricPar;                                      % Initialize
  set(handles.sRangeEdit,'String',num2str(dmax(1)));          % Initialize
  set(handles.tRangeEdit,'String',num2str(dmax(2)));          % Initialize
  set(handles.stMetricEdit,'String',num2str(dmax(3)));        % Initialize
  
  covmodel = covModelST;                        % Set covariance models
  covparam = covParamST;                        % Set covariance parameters

  for iInst=1:dataTimeSpan                      % Use data at all t
    % Make use of BMElib function to assign proper probability densities
    % to transformed limits. Eventually, the limiDataToProcessAtInst values
    % will be used for the BME estimations, and these are employed to get
    % the updated, normalized prob densities in probdensFromDetrendedAtInst.
    if ~isempty(nlAtInst{iInst})  % Soft data may or may not be available at instance
      [tempVariable,norm] = proba2probdens(softpdftype,nlAtInst{iInst},...
        limiDataToProcessAtInst{iInst},probdensAtInst{iInst});
      probdensFromDataToProcessAtInst{iInst} = tempVariable;
    else                          % If no SD at instance, provide appropriately
      probdensFromDataToProcessAtInst{iInst} = [];
    end

    % Aggregate all input data in the format BMElib needs them
    ch4est = [ch4est; chAtInst{iInst} ...
             (minTdata+iInst-1)*ones(size(chAtInst{iInst},1),1)];
    cs4est = [cs4est; csAtInst{iInst} ...
             (minTdata+iInst-1)*ones(size(csAtInst{iInst},1),1)];
    zh4est = [zh4est; zhDataToProcessAtInst{iInst}];
    nl4est = [nl4est; nlAtInst{iInst}];
    limi4est = [limi4est; limiDataToProcessAtInst{iInst}];
    probdens4est = [probdens4est; probdensFromDataToProcessAtInst{iInst}];
  end
  
  if isempty(outGrid)
    ck4est=ck;
  else
    for iInst=1:outputTimeSpan       % Obtain output at designated t
      tIndx = outGrid{totalCoordinatesUsed}(iInst);
      % Aggregate output locations in the format BMElib needs them
      ck4est = [ck4est; ckAtInst{iInst} ones(size(ckAtInst{iInst},1),1)*tIndx];
    end    
  end;
  


else
      
  % Search for data as far away in S/T as correlation goes
  dmax = correlationFactor*maxCorrRangeS;                     % Initialize
  set(handles.sRangeEdit,'String',num2str(dmax));             % Initialize
  set(handles.tRangeEdit,'String','N/A');                     % Initialize
  set(handles.stMetricEdit,'String','N/A');                   % Initialize

  covmodel = covModelST;                        % Set covariance models
  covparam = covParamST;                        % Set covariance parameters

  % Make use of BMElib function to assign proper probability densities
  % to transformed limits. Eventually, the limiDataToProcess values
  % will be used for the BME estimations, and these are employed to get
  % the updated, normalized prob densities in probdensFromDetrended.
  if ~isempty(nl)  % Soft data may or may not be available at instance
    [tempVariable,norm] = proba2probdens(softpdftype,nl,...
                            limiDataToProcess,probdens);
    probdensFromDataToProcess = tempVariable;
  else                          % If no SD at instance, provide appropriately
    probdensFromDataToProcess = [];
  end

  ch4est = ch;
  cs4est = cs;
  ck4est = ck;
  zh4est = zhDataToProcess;
  nl4est = nl;
  limi4est = limiDataToProcess;
  probdens4est = probdensFromDataToProcess;
      
end

for i=1:length(covmodel)
  % 20120523-AK: covmodel might consist of cell arrays instead of char
  % arrays. Simplify covmodel{i} to be a char array in all cases.
  if (iscell(covmodel{i}))
    covmodel{i} = covmodel{i}{1};
  end
end

if ~bmeMod{1,1} && ~bmeMom{1,1} && ~bmePdf{1,1} && ~bmeCin{1,1}
  displayString = 'Choose a BME prediction type';
else
  if bmeMod{1,1} && ~bmeMom{1,1} && ~bmePdf{1,1} && ~bmeCin{1,1}
    displayString = ['BME Mode data present'];
  elseif ~bmeMod{1,1} && bmeMom{1,1} && ~bmePdf{1,1} && ~bmeCin{1,1}
    displayString = ['BME Moments data present'];
  elseif ~bmeMod{1,1} && ~bmeMom{1,1} && bmePdf{1,1} && ~bmeCin{1,1}
    displayString = ['BME PDF data present'];
  elseif ~bmeMod{1,1} && ~bmeMom{1,1} && ~bmePdf{1,1} && bmeCin{1,1}
    displayString = ['BME CI data present'];
  elseif bmeMod{1,1} && bmeMom{1,1} && ~bmePdf{1,1} && ~bmeCin{1,1}
    displayString = ['BME Mode, Moments data present'];
  elseif bmeMod{1,1} && ~bmeMom{1,1} && bmePdf{1,1} && ~bmeCin{1,1}
    displayString = ['BME Mode, PDF data present'];
  elseif bmeMod{1,1} && ~bmeMom{1,1} && ~bmePdf{1,1} && bmeCin{1,1}
    displayString = ['BME Mode, CI data present'];
  elseif ~bmeMod{1,1} && bmeMom{1,1} && bmePdf{1,1} && ~bmeCin{1,1}
    displayString = ['BME Moments, PDF data present'];
  elseif ~bmeMod{1,1} && bmeMom{1,1} && ~bmePdf{1,1} && bmeCin{1,1}
    displayString = ['BME Moments, CI data present'];
  elseif ~bmeMod{1,1} && ~bmeMom{1,1} && bmePdf{1,1} && bmeCin{1,1}
    displayString = ['BME PDF, CI data present'];
  elseif bmeMod{1,1} && bmeMom{1,1} && bmePdf{1,1} && ~bmeCin{1,1}
    displayString = ['BME Mode, Moments, PDF data present'];
  elseif bmeMod{1,1} && bmeMom{1,1} && ~bmePdf{1,1} && bmeCin{1,1}
    displayString = ['BME Mode, Moments, CI data present'];
  elseif bmeMod{1,1} && ~bmeMom{1,1} && bmePdf{1,1} && bmeCin{1,1}
    displayString = ['BME Mode, PDF, CI data present'];
  elseif ~bmeMod{1,1} && bmeMom{1,1} && bmePdf{1,1} && bmeCin{1,1}
    displayString = ['BME Moments, PDF, CI data present'];
  elseif bmeMod{1,1} && bmeMom{1,1} && bmePdf{1,1} && bmeCin{1,1}
    displayString = ['BME Mode, Moments, PDF, CI data present'];
  end
  displayString = [displayString '. Choose a BME prediction type'];
end
set(handles.feedbackEdit,'String',displayString);





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




% --- Executes on selection change in estSelectionMenu.
function estSelectionMenu_Callback(hObject, eventdata, handles)
% hObject    handle to estSelectionMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns estSelectionMenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from estSelectionMenu
global displayString

switch get(handles.estSelectionMenu,'Value')
  case 1   
    % Do nothing
  case 2
    displayString = 'Set to calculate BME Mode';
    set(handles.feedbackEdit,'String',displayString);   
  case 3
    displayString = 'Set to calculate BME Moments';
    set(handles.feedbackEdit,'String',displayString);   
  case 4
    displayString = 'Set to calculate BME PDF';
    set(handles.feedbackEdit,'String',displayString);   
  case 5        
    displayString = 'Set to calculate BME Conf. Intervals';
    set(handles.feedbackEdit,'String',displayString);   
end




% --- Executes during object creation, after setting all properties.
function estSelectionMenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to estSelectionMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on slider movement.
function confIntSlider_Callback(hObject, eventdata, handles)
% hObject    handle to confIntSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global displayString
global bmeoptions confIntSliderValue

estType = get(handles.estSelectionMenu,'Value');  % Ranges from 1 to maxModels+1.

if estType~=5   % If the choice is not BME Confidence Intervals
  confIntSliderValue = 0.68;
  set(handles.confIntSlider,'Value',confIntSliderValue);        % Initialize.
  set(handles.confIntEdit,'String','68');                       % Initialize.
  displayString = 'Use only with Conf. Intervals prediction';
  set(handles.feedbackEdit,'String',displayString);
else
  confIntSliderValue = get(handles.confIntSlider,'Value');
  if confIntSliderValue==0
    confIntSliderValue = 0.01;   % Can not accept 0   
  elseif confIntSliderValue==1
    confIntSliderValue = 0.99;   % Can not accept 1
  end
  confIntValue = round(100*confIntSliderValue);
  set(handles.confIntEdit,'String',num2str(confIntValue));
  bmeoptions(20) = confIntSliderValue;
end




% --- Executes during object creation, after setting all properties.
function confIntSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to confIntSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end




function confIntEdit_Callback(hObject, eventdata, handles)
% hObject    handle to confIntEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of confIntEdit as text
%        str2double(get(hObject,'String')) returns contents of confIntEdit as a double
global displayString
global bmeoptions confIntSliderValue

estType = get(handles.estSelectionMenu,'Value');  % Ranges from 1 to maxModels+1.

if estType~=5   % If the choice is not BME Confidence Intervals
  confIntSliderValue = 0.68;
  set(handles.confIntSlider,'Value',confIntSliderValue);        % Initialize.
  set(handles.confIntEdit,'String','68');                       % Initialize.
  displayString = 'Use only with Conf. Intervals prediction';
  set(handles.feedbackEdit,'String',displayString);
else
  confIntEditValue = str2num(get(handles.confIntEdit,'String'));
  
  % Perform some checks and correct unacceptable input.
  if confIntEditValue<1
    confIntEditValue = 1;                       % Low limit is 1
    set(handles.confIntEdit,'String',num2str(confIntEditValue));
    displayString = 'Lower limit for percentiles is 1. Input adjusted';
    set(handles.feedbackEdit,'String',displayString);
  end
  if confIntEditValue>99
    confIntEditValue = 99;                      % Upper limit is 99
    set(handles.confIntEdit,'String',num2str(confIntEditValue));
    displayString = 'Upper limit for percentiles is 99. Input adjusted';
    set(handles.feedbackEdit,'String',displayString);
  end
  if mod(confIntEditValue,floor(confIntEditValue))
    confIntEditValue = round(confIntEditValue); % Round to closest integer
    set(handles.confIntEdit,'String',num2str(confIntEditValue));
    displayString = 'Only integers are accepted. Input adjusted';
    set(handles.feedbackEdit,'String',displayString);
  end
  
  confIntSliderValue = confIntEditValue / 100;
  set(handles.confIntSlider,'Value',confIntSliderValue);
  bmeoptions(20) = confIntSliderValue;
end




% --- Executes during object creation, after setting all properties.
function confIntEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to confIntEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





function maxHdEdit_Callback(hObject, eventdata, handles)
% hObject    handle to maxHdEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of maxHdEdit as text
%        str2double(get(hObject,'String')) returns contents of maxHdEdit as a double
global initialNhmax
global hardDataPresent
global displayString
global nhmax

if hardDataPresent
  inputValue = str2num(get(handles.maxHdEdit,'String'));
  if ~isnan(inputValue)    
    switch 1
      case ( inputValue<=0 || mod(inputValue,floor(inputValue)) ) 
        % If negative, 0, or non-integer
        errordlg({'Please provide a positive integer for';...
                  'max hard data to consider in prediction.';...
                  'The value is reset.'},'Invalid input!')        
        nhmax = initialNhmax;
        set(handles.maxHdEdit,'String',num2str(nhmax));
      case ( inputValue>100) % Over 100... Is this correct input?
        warndlg({['You asked to consider ' num2str(inputValue) ' hard data neighbors.'];...
                 'This seems like a large amount of data to consider.';,...
                 'Proceed, if this was correct, or review your input.'},...
                 'Warning about large input')
        nhmax = inputValue;
        displayString = ['Closest ' num2str(nhmax) ...
                         ' hard data to be now used for prediction'];
        set(handles.feedbackEdit,'String',displayString);
      otherwise              % Accept input
        nhmax = inputValue;
        displayString = ['Closest ' num2str(nhmax) ...
                         ' hard data to be now used for prediction'];
        set(handles.feedbackEdit,'String',displayString);
    end
  else            % A NaN conversion may result either from a letter or no input
    if (isempty(inputValue) || ~isnumeric(inputValue))
      errordlg({'Please provide a positive integer for';...
                'max hard data to consider in prediction.';...
                'The value is reset.'},'Invalid input!')        
      nhmax = initialNhmax;
      set(handles.maxHdEdit,'String',num2str(nhmax));
    end
  end
else
  nhmax = [];
  set(handles.maxHdEdit,'String','N/A');
  displayString = 'Hard data not present: Max hard data input ignored';
  set(handles.feedbackEdit,'String',displayString);
end  





% --- Executes during object creation, after setting all properties.
function maxHdEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to maxHdEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





function maxSdEdit_Callback(hObject, eventdata, handles)
% hObject    handle to maxSdEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of maxSdEdit as text
%        str2double(get(hObject,'String')) returns contents of maxSdEdit as a double
global initialNsmax
global softDataPresent
global displayString
global nsmax

if softDataPresent
  inputValue = str2num(get(handles.maxSdEdit,'String'));
  if ~isnan(inputValue)    
    switch 1
      case ( inputValue<=0 || mod(inputValue,floor(inputValue)) ) 
        % If negative, 0, or non-integer
        errordlg({'Please provide a positive integer for';...
                  'max soft data to consider in prediction.';...
                  'The value is reset.'},'Invalid input!')        
        nsmax = initialNsmax;
        set(handles.maxSdEdit,'String',num2str(nsmax));
      case ( inputValue>5)   % Over 5... Warn the user on time cost
        warndlg({['You asked to consider ' num2str(inputValue) ' soft data neighbors.'];...
                 'Please be advised that the time required for computations';...
                 'increases, in general, exponentially with the amount of';...
                 'soft data used. A number of up to 5 soft data is suggested.';...
                 'Proceed, if you wish to continue, or review your input.'},...
                 'Warning about number of soft data')
        nsmax = inputValue;
        displayString = ['Closest ' num2str(nsmax) ...
                         ' soft data to be now used for prediction'];
        set(handles.feedbackEdit,'String',displayString);
      otherwise              % Accept input
        nsmax = inputValue;
        displayString = ['Closest ' num2str(nsmax) ...
                         ' soft data to be now used for prediction'];
        set(handles.feedbackEdit,'String',displayString);
    end
  else            % A NaN conversion may result either from a letter or no input
    if (isempty(inputValue) || ~isnumeric(inputValue))
      errordlg({'Please provide a positive integer for';...
                'max soft data to consider in prediction.';...
                'The value is reset.'},'Invalid input!')        
      nsmax = initialNsmax;
      set(handles.maxSdEdit,'String',num2str(nsmax));
    end
  end
else
  nsmax = [];
  set(handles.maxSdEdit,'String','N/A');
  displayString = 'Soft data not present: Max soft data input ignored';
  set(handles.feedbackEdit,'String',displayString);
end  





% --- Executes during object creation, after setting all properties.
function maxSdEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to maxSdEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





function sRangeEdit_Callback(hObject, eventdata, handles)
% hObject    handle to sRangeEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of sRangeEdit as text
%        str2double(get(hObject,'String')) returns contents of sRangeEdit as a double
global maxSdataSearchRadius maxTdataSearchRadius stMetricPar dmax
global maxCorrRangeS maxCorrRangeT correlationFactor
global outGrid totalSpCoordinatesUsed
global xMin dx xMax yMin dy yMax zMin dz zMax dataCoordMin dataCoordMax
global timePresent
global displayString

inputValue = str2num(get(handles.sRangeEdit,'String'));
if ~isnan(inputValue)    
  switch 1
    case ( inputValue<=0 ) % If negative or 0
      errordlg({'Please provide a positive value for the';...
                'max spatial range to search for data during prediction.';...
                'The value is reset.'},'Invalid input!')        
      if timePresent
        dmax(1) = correlationFactor*maxCorrRangeS;
      else
        dmax = correlationFactor*maxCorrRangeS;
      end
      set(handles.sRangeEdit,'String',...
          num2str(correlationFactor*maxCorrRangeS));
    case totalSpCoordinatesUsed==1 && inputValue>1.5*(xMax-xMin)
      warndlg({'The input value exceeds by more than 150%';...
        'the output grid size';...
        ['(currently: ' num2str(xMax-xMin) ' spatial units).'];...
        'You may consider providing a smaller value for the';...
        'max spatial range to search for data during prediction.';
        'Input is accepted but not recommended.'},...
        'Large input number');
      if timePresent
        dmax(1) = inputValue;
      else
        dmax = inputValue;
      end
      displayString = 'New value for max spatial range parameter set';
      set(handles.feedbackEdit,'String',displayString);
    case totalSpCoordinatesUsed==2 && inputValue>1.5*(max((xMax-xMin),(yMax-yMin)))
      warndlg({'The input value exceeds by more than 150%';...
        'the output grid maximum side size';...
        ['(currently: ' num2str(max((xMax-xMin),(yMax-yMin))) ' spatial units).'];...
        'You may consider providing a smaller value for the';...
        'max spatial range to search for data during prediction.';
        'Input is accepted but not recommended.'},...
        'Large input number');
      if timePresent
        dmax(1) = inputValue;
      else
        dmax = inputValue;
      end
      displayString = 'New value for max spatial range parameter set';
      set(handles.feedbackEdit,'String',displayString);
    otherwise              % Accept input
      if timePresent
        dmax(1) = inputValue;
      else
        dmax = inputValue;
      end
      displayString = 'New value for max spatial range parameter set';
      set(handles.feedbackEdit,'String',displayString);
  end
else              % A NaN conversion may result either from a letter or no input
  if (isempty(inputValue) || ~isnumeric(inputValue))
    errordlg({'Please provide a positive value for the';...
              'max spatial range to search for data during prediction.';...
              'The value is reset.'},'Invalid input!')        
    if timePresent
      dmax(1) = correlationFactor*maxCorrRangeS;
    else
      dmax = correlationFactor*maxCorrRangeS;
    end
    set(handles.sRangeEdit,'String',num2str(correlationFactor*maxCorrRangeS));
  end
end





% --- Executes during object creation, after setting all properties.
function sRangeEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sRangeEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





function tRangeEdit_Callback(hObject, eventdata, handles)
% hObject    handle to tRangeEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tRangeEdit as text
%        str2double(get(hObject,'String')) returns contents of tRangeEdit as a double
global maxSdataSearchRadius maxTdataSearchRadius stMetricPar dmax
global maxCorrRangeS maxCorrRangeT correlationFactor
global dataTimeSpan
global timePresent
global displayString

if timePresent
  inputValue = str2num(get(handles.tRangeEdit,'String'));
  if ~isnan(inputValue)
    switch 1
      case ( inputValue<=0 || mod(inputValue,floor(inputValue)) )
        % If negative, 0, or non-integer
        errordlg({'Please provide a positive integer value for the';...
          'max temporal range to search for data during prediction.';...
          'The value is reset.'},'Invalid input!')        
      dmax(2) = correlationFactor*maxCorrRangeT;
      set(handles.tRangeEdit,'String',num2str(correlationFactor*maxCorrRangeT));
      case inputValue>dataTimeSpan
        warndlg({'The input value exceeds the current data time span';...
          ['(currently: ' num2str(dataTimeSpan) ' temporal units).'];...
          'You may consider providing a smaller value for the';...
          'max temporal range to search for data during prediction.';
          'Input is accepted but not recommended.'},...
          'Large input number');
        dmax(2) = inputValue;
        displayString = 'New value for max temporal range parameter set';
        set(handles.feedbackEdit,'String',displayString);
      otherwise              % Accept input
        dmax(2) = inputValue;
        displayString = 'New value for max temporal range parameter set';
        set(handles.feedbackEdit,'String',displayString);
    end
  else            % A NaN conversion may result either from a letter or no input
    if (isempty(inputValue) || ~isnumeric(inputValue))
      errordlg({'Please provide a positive integer value for the';...
        'max temporal range to search for data during prediction.';...
        'The value is reset.'},'Invalid input!')        
      dmax(2) = correlationFactor*maxCorrRangeT;
      set(handles.tRangeEdit,'String',num2str(correlationFactor*maxCorrRangeT));
    end
  end
else
  set(handles.tRangeEdit,'String','N/A');
  displayString = 'Temporal parameter available only in S/T cases';
  set(handles.feedbackEdit,'String',displayString);
end  





% --- Executes during object creation, after setting all properties.
function tRangeEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tRangeEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





function stMetricEdit_Callback(hObject, eventdata, handles)
% hObject    handle to stMetricEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of stMetricEdit as text
%        str2double(get(hObject,'String')) returns contents of stMetricEdit as a double
global maxSdataSearchRadius maxTdataSearchRadius stMetricPar dmax
global timePresent
global displayString

if timePresent
  inputValue = str2num(get(handles.stMetricEdit,'String'));
  if ~isnan(inputValue)
    switch 1
      case ( inputValue<=0 ) % If non-positive
        errordlg({'Please provide a positive value for the';...
          'spatiotemporal metric parameter for prediction.';...
          'The value is reset.'},'Invalid input!')        
        dmax(3) = stMetricPar;
        set(handles.stMetricEdit,'String',num2str(stMetricPar));
      otherwise              % Accept input
        dmax(3) = inputValue;
        displayString = 'New value for max temporal range parameter set';
        set(handles.feedbackEdit,'String',displayString);
    end
  else                       % A NaN conversion may result either from a letter or no input
    if (isempty(inputValue) || ~isnumeric(inputValue))
      errordlg({'Please provide a positive value for the';...
        'spatiotemporal metric parameter for prediction.';...
        'The value is reset.'},'Invalid input!')        
      dmax(3) = stMetricPar;
      set(handles.stMetricEdit,'String',num2str(stMetricPar));
    end
  end
else
  set(handles.stMetricEdit,'String','N/A');
  displayString = 'S/T parameter available only in S/T cases';
  set(handles.feedbackEdit,'String',displayString);
end  





% --- Executes during object creation, after setting all properties.
function stMetricEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to stMetricEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end






% --- Executes on button press in resetOptionsButton.
function resetOptionsButton_Callback(hObject, eventdata, handles)
% hObject    handle to resetOptionsButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global maxSdataSearchRadius maxTdataSearchRadius stMetricPar dmax
global maxCorrRangeS maxCorrRangeT correlationFactor
global nhmax nsmax
global initialNhmax initialNsmax
global hardDataPresent softDataPresent
global timePresent
global displayString

if hardDataPresent
  nhmax = initialNhmax;
  set(handles.maxHdEdit,'String',num2str(initialNhmax));
else
  set(handles.maxHdEdit,'String','N/A');
end
if softDataPresent
  nsmax = initialNsmax;
  set(handles.maxSdEdit,'String',num2str(initialNsmax));
else
  set(handles.maxSdEdit,'String','N/A');
end

if timePresent
  dmax(1) = correlationFactor*maxCorrRangeS;
  dmax(2) = correlationFactor*maxCorrRangeT;
  dmax(3) = stMetricPar;
  set(handles.sRangeEdit,'String',num2str(correlationFactor*maxCorrRangeS));
  set(handles.tRangeEdit,'String',num2str(correlationFactor*maxCorrRangeT));
  set(handles.stMetricEdit,'String',num2str(stMetricPar));
else
  dmax = correlationFactor*maxCorrRangeS;
  set(handles.sRangeEdit,'String',num2str(correlationFactor*maxCorrRangeS));
end

displayString = 'BME prediction parameters set to initial values';
set(handles.feedbackEdit,'String',displayString);





% --- Executes on button press in beginEstimationButton.
function beginEstimationButton_Callback(hObject, eventdata, handles)
% hObject    handle to beginEstimationButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global softpdftype
global covmodel covparam dmax nhmax nsmax order bmeoptions
global ck4est ch4est cs4est zh4est nl4est limi4est probdens4est
global bmeMod bmeMom bmePdf bmeCin
global displayString
global timePresent dataTimeSpan minTdata maxTdata
global minTout maxTout outputTimeSpan
global applyTransform transformTypeStr
global ntransfTable                          % To be used in backtransformations
global nscMinAcceptOutput nscMaxAcceptOutput % To be used in backtransformations
global bcxLambda bcxDataShiftConst           % To be used in backtransformations
global outGrid usingPolygon ck4estFlag
global totalCoordinatesUsed totalSpCoordinatesUsed
global meanTrendAtkAtInst trendTInsts
global positiveDataOnly

% VERY IMPORTANT
% The output cell matrices bmeMod bmeMom bmePdf bmeCin
% are all initialized in :ip002chooseTask.m".
% Should any changes occur in their size the programmer must update the above.
% Also, in the above file the elements {1,1} are all set to 0 initially.

if get(handles.estSelectionMenu,'Value') == 1  % If the title shows

  displayString = 'Please choose first a prediction type';
  set(handles.feedbackEdit,'String',displayString);
  
else

  displayString = 'Prediction can take a while. Please wait until done';
  set(handles.feedbackEdit,'String',displayString);
  axes(handles.estScreenAxes);
  % BEGIN: Using part of gifplayer Matlab function code by Vihang Patil
  %        to display iwait.gif during prediction computations.
  [handles.im,handles.map] = imread('iwait.gif','frames','all'); % Read all frames of gif image
  handles.len = size(handles.im,4);                             % Number of frames in gif image
  handles.h1 = imshow(handles.im(:,:,:,1),handles.map);     % Load first image and its colormap
  handles.guifig = gcf;
  handles.count = 1;                               % Intialize counter to update the next frame
  handles.tmr = timer('TimerFcn', {@TmrFcn,handles.guifig},'BusyMode','Queue',...
                      'ExecutionMode','FixedRate','Period',0.2);          % Form a Timer Object
  guidata(handles.guifig, handles);
  start(handles.tmr);                                                            % Starts Timer
  % END: Using part of gifplayer Matlab function code by Vihang Patil
  axis image;
  axis off;
  
  pause(0.01);
  
  totEstPts = size(ck4est,1);        % At how many points do we obtain estimates?
 
  switch get(handles.estSelectionMenu,'Value')
    
    % Estimate BME Mode
    case 2
      for iRep=1:totEstPts            % BEGIN: For all the estimation points
        percentDone = floor(100*iRep/totEstPts);  % Where are we standing?
        displayString = ['BME Mode: Prediction at point ' num2str(iRep) '/' ...
                         num2str(totEstPts) '. Progress: About '...
                         num2str(percentDone) '%'];
        set(handles.feedbackEdit,'String',displayString);
        pause(0.01);                  % Necessary to display msg. Min burden
        ckPoint = ck4est(iRep,:);     % Isolate current estimation point
        if (usingPolygon && ~ck4estFlag(iRep))
          zkTrsf(iRep,1) = NaN;
          info(iRep,1) = NaN;
        else
          [zkTrsf(iRep,1),info(iRep,1)] = BMEprobaMode(ckPoint,ch4est,cs4est,...
                         zh4est,softpdftype,nl4est,limi4est,probdens4est,...
                         covmodel,covparam,nhmax,nsmax,dmax,order,bmeoptions);
        end
      end
      displayString = 'Backtransforming results...';
      set(handles.feedbackEdit,'String',displayString);
      pause(0.01);                % Necessary to display msg. Min burden
      % Back-transform output if transformation has been applied
      switch applyTransform
        case 0     % No transformation was applied
          zk = zkTrsf;
        case 1     % N-scores
          zk = nscoreBackVec(zkTrsf,ntransfTable,nscMinAcceptOutput,nscMaxAcceptOutput);
        case 2     % Boxcox
          zkTemp = boxcoxBack(zkTrsf,bcxLambda);
          zk = zkTemp - bcxDataShiftConst;
        otherwise  % Not specified here
          errordlg({'ip306predictionWiz.m:beginEstimationButton:estItem2:';...
            'No provision in code for requested menu item.'},...
            'GUI software Error')
      end
      displayString = 'Arranging results and finalizing...';
      set(handles.feedbackEdit,'String',displayString);
      pause(0.01);                 % Necessary to display msg. Min burden
      % Distribute output to temporal instances as appropriate
      % The output BME cell arrays extend from {1} to {dataTimeSpan}
      if timePresent && ~isempty(outGrid)
        for iInst=1:outputTimeSpan % Iterate over the output instances
          tNowActual = outGrid{totalCoordinatesUsed}(iInst);
          indx = find(ck4est(:,end)==tNowActual);
          bmeMod{1,iInst} = [];
          bmeMod{2,iInst} = [iInst tNowActual]; % Temporal instance we refer to
          bmeMod{3,iInst} = {zk(indx),zkTrsf(indx)};
          bmeMod{4,iInst} = info(indx);
          bmeMod{5,iInst} = [];
        end  
        bmeMod{1,1} = [1];         % To verify estimation has been performed
        bmeMod{5,1} = {applyTransform,transformTypeStr,...   % Trsf info:
              bcxLambda,ntransfTable,...                     % Refer to as
              [nscMinAcceptOutput,nscMaxAcceptOutput]};      % bmeMod{5,1}{y}
      else
        iInst = 1;
        bmeMod{1,iInst} = [1];     % To verify estimation has been performed
        bmeMod{2,iInst} = [iInst iInst];        % Temporal instance we refer to
        bmeMod{3,iInst} = {zk,zkTrsf};
        bmeMod{4,iInst} = info;
        bmeMod{5,iInst} = {applyTransform,transformTypeStr,...
                           bcxLambda,ntransfTable,...                
                           [nscMinAcceptOutput,nscMaxAcceptOutput]}; 
      end
      
    % Estimate BME Moments
    case 3
      for iRep=1:totEstPts            % BEGIN: For all the estimation points
        percentDone = floor(100*iRep/totEstPts);  % Where are we standing?
        displayString = ['BME Moments: Prediction at point ' num2str(iRep) '/' ...
                         num2str(totEstPts) '. Progress: About '...
                         num2str(percentDone) '%'];
        set(handles.feedbackEdit,'String',displayString);
        pause(0.01);                  % Necessary to display msg. Min burden
        ckPoint = ck4est(iRep,:);     % Isolate current estimation point
        if (usingPolygon && ~ck4estFlag(iRep))
          momentsTrsf(iRep,1:3) = [NaN NaN NaN];
          info(iRep,1) = NaN;
        else
          [momentsTrsf(iRep,1:3),info(iRep,1:3)] = BMEprobaMoments(ckPoint,ch4est,...
                             cs4est,zh4est,softpdftype,nl4est,limi4est,probdens4est,...
                             covmodel,covparam,nhmax,nsmax,dmax,order,bmeoptions);
        end
      end

      % The variances returned must be positive numbers. If any negatives
      % are returned, this may suggest a serious problem with the user data
      % or the processing. Check for negatives. If any exist, replace the
      % results for the correspondgin nodes with NaNs and continue, but
      % issue a warning to the user for potential condition with their data.
      suspiciousResults = find(momentsTrsf(:,2)<0);
      if ~isempty(suspiciousResults)
        % Replace unacceptable values with NaNs.
        momentsTrsf(suspiciousResults,:) = NaN;  
        warndlg({'Negative variances were detected in prediction';...
          'at the output locations reported below.';...
          'This outcome is not acceptable and suggests potential serious issues';...
          'with the user data set or the investigation course.';...
          'However, the GUI will continue its regular flow of operations';...
          'by isolating the suspicious prediction locations.';...
          'As this may be a situation that reflects on all predicted values,';...
          'you are strongly recommended to display caution with these results,';...
          'to examine your data set and repeat the investigation again.';' ';...
          'Output grid nodes where negative variances were obtained:';...
          num2str(ck4est(suspiciousResults,:))},...         
          'Unacceptable results in prediction!');
      end

      displayString = 'Backtransforming results...';
      set(handles.feedbackEdit,'String',displayString);
      pause(0.01);                    % Necessary to display msg. Min burden
      % Back-transform output if transformation has been applied
      bmeMeanTrsf = momentsTrsf(:,1);
      bmeVarTrsf = momentsTrsf(:,2);
      bmeSkewTrsf = momentsTrsf(:,3);

      [bmeMean,bmeVar,bmeSkew] = backTrBmeRes(bmeMeanTrsf,bmeVarTrsf,bmeSkewTrsf);
      
      displayString = 'Arranging results and finalizing...';
      set(handles.feedbackEdit,'String',displayString);
      pause(0.01);                % Necessary to display msg. Min burden
      % Distribute output to temporal instances as appropriate
      % The output BME cell arrays extend from {1} to {dataTimeSpan}
      if timePresent && ~isempty(outGrid)
        for iInst=1:outputTimeSpan % Iterate over the output instances
          tNowActual = outGrid{totalCoordinatesUsed}(iInst);
          indx = find(ck4est(:,end)==tNowActual);
          bmeMom{1,iInst} = [];
          bmeMom{2,iInst} = [iInst tNowActual]; % Temporal instance we refer to
          bmeMom{3,iInst} = {bmeMean(indx,:),bmeMeanTrsf(indx)};
          bmeMom{4,iInst} = {bmeVar(indx,:),bmeVarTrsf(indx)};
          bmeMom{5,iInst} = {bmeSkew(indx,:),bmeSkewTrsf(indx)};
          bmeMom{6,iInst} = info(indx,:);
          bmeMom{7,iInst} = [];
        end  
        bmeMom{1,1} = [1];         % To verify estimation has been performed
        bmeMom{7,1} = {applyTransform,transformTypeStr,...   % Trsf info:
              bcxLambda,ntransfTable,...                     % Refer to as
              [nscMinAcceptOutput,nscMaxAcceptOutput]};      % bmeMom{6,1}{y}
      else
        iInst = 1;
        bmeMom{1,iInst} = [1];   % To verify estimation has been performed
        bmeMom{2,iInst} = [iInst iInst];        % Temporal instance we refer to
        bmeMom{3,iInst} = {bmeMean,bmeMeanTrsf};
        bmeMom{4,iInst} = {bmeVar,bmeVarTrsf};
        bmeMom{5,iInst} = {bmeSkew,bmeSkewTrsf};
        bmeMom{6,iInst} = info;
        bmeMom{7,iInst} = {applyTransform,transformTypeStr,...
                           bcxLambda,ntransfTable,...                
                           [nscMinAcceptOutput,nscMaxAcceptOutput]}; 
      end
      
    % Estimate BME PDF
    case 4
      
      %%% For tests
      %save myBMEPDFtestInput ck4est ch4est cs4est zh4est softpdftype ...
      %     nl4est limi4est probdens4est covmodel covparam nhmax ...
      %     nsmax dmax order bmeoptions ntransfTable

      for iRep=1:totEstPts            % BEGIN: For all the estimation points
        percentDone = floor(100*iRep/totEstPts);  % Where are we standing?
        displayString = ['BME PDF: Prediction at point ' num2str(iRep) '/' ...
                         num2str(totEstPts) '. Progress: About '...
                         num2str(percentDone) '%'];
        set(handles.feedbackEdit,'String',displayString);
        pause(0.01);                  % Necessary to display msg. Min burden
        ckPoint = ck4est(iRep,:);     % Isolate current estimation point
        if (usingPolygon && ~ck4estFlag(iRep))
          zTrsf = [NaN NaN NaN];
          pdfTrsf = [NaN NaN NaN];
          info = NaN;
        else
          [zTrsf,pdfTrsf,info] = BMEprobaPdf([],ckPoint,ch4est,cs4est,zh4est,...
                               softpdftype,nl4est,limi4est,probdens4est,...
                               covmodel,covparam,nhmax,nsmax,dmax,order,bmeoptions);
        end
        %%% For tests
        %save myBMEPDFtestOut ck4est ch4est cs4est zh4est softpdftype ...
        %     nl4est limi4est zTrsf pdf probdens4est covmodel covparam ...
        %     nhmax nsmax dmax order bmeoptions ntransfTable

        % Calculate moments from BME PDF
        [bmeMeanTrsf(iRep,1),bmeVarTrsf(iRep,1),bmeSkewTrsf(iRep,1),A] = ...
                                                pdfstat(zTrsf,pdfTrsf);
        % Back-transform output if transformation has been applied
        switch applyTransform
          case 0     % No transformation was applied
            z = zTrsf;
          case 1     % N-scores
            z = nscoreBackVec(zTrsf,ntransfTable,...
                                 nscMinAcceptOutput,nscMaxAcceptOutput);
            % Use backtransformed PDF to get 3rd mom (skewness) for original space.
            [trash1,trash2,bmeSkewTemp(iRep,1),A] = pdfstat(z,pdfTrsf);
            clear trash1 trash2
          case 2     % Boxcox
            zTemp = boxcoxBack(zTrsf,bcxLambda);
            z = zTemp - bcxDataShiftConst;
            % Use backtransformed PDF to get 3rd mom (skewness) for original space.
            [trash1,trash2,bmeSkewTemp(iRep,1),A] = pdfstat(z,pdfTrsf);
            clear trash1 trash2
          otherwise  % Not specified here
            errordlg({'ip306predictionWiz.m:beginEstimationButton:estItem3:';...
              'No provision in code for requested menu item.'},...
              'GUI software Error')
        end
        zOut{iRep} = z;
        pdfOutTrsf{iRep} = pdfTrsf;
        infoOut{iRep} = info;
        zOutTrsf{iRep} = zTrsf;
        
      end                             % END: For all the estimation points
      
      % Back-transform moments from PDF if transformation has been applied
      displayString = 'Task 1/2: Backtransforming results...';
      set(handles.feedbackEdit,'String',displayString);
      pause(0.01);                % Necessary to display msg. Min burden
      [bmeMean,bmeVar,bmeSkew] = backTrBmeRes(bmeMeanTrsf,bmeVarTrsf,bmeSkewTrsf);
      % Use appropriate skewness in case transformation has been applied
      if applyTransform
        bmeSkew = bmeSkewTemp;
      end
      clear bmeSkewTemp
      
      displayString = 'Task 2/2: Arranging results and finalizing...';
      set(handles.feedbackEdit,'String',displayString);
      pause(0.01);                % Necessary to display msg. Min burden
      % Distribute output to temporal instances as appropriate
      % Where applicable, keep both results in original and transform space
      % Refer to, e.g., the mean as bmePdf{7,iInst}{1} for the original space
      % and bmePdf{7,iInst}{2} for the transformed values at instance iInst
      % The output BME cell arrays extend from {1} to {dataTimeSpan}
      if timePresent && ~isempty(outGrid)
        for iInst=1:outputTimeSpan % Iterate over the output instances
          tNowActual = outGrid{totalCoordinatesUsed}(iInst);
          indx = find(ck4est(:,end)==tNowActual);
          bmePdf{1,iInst} = [];
          bmePdf{2,iInst} = [iInst tNowActual]; % Temporal instance we refer to
          bmePdf{3,iInst} = {zOut(indx),zOutTrsf(indx)};
          bmePdf{4,iInst} = pdfOutTrsf(indx);
          bmePdf{5,iInst} = infoOut(indx);
          bmePdf{6,iInst} = [];
          bmePdf{7,iInst} = {bmeMean(indx),bmeMeanTrsf(indx)};
          bmePdf{8,iInst} = {bmeVar(indx),bmeVarTrsf(indx)};
          bmePdf{9,iInst} = {bmeSkew(indx),bmeSkewTrsf(indx)};
        end
        bmePdf{1,1} = [1];         % To verify estimation has been performed
        bmePdf{6,1} = {applyTransform,transformTypeStr,...   % Trsf info:
              bcxLambda,ntransfTable,...                     % Refer to as
              [nscMinAcceptOutput,nscMaxAcceptOutput]};      % bmePdf{6,1}{y}
      else
        iInst = 1;
        bmePdf{1,iInst} = [1];     % To verify estimation has been performed
        bmePdf{2,iInst} = [iInst iInst];        % Temporal instance we refer to
        bmePdf{3,iInst} = {zOut,zOutTrsf};
        bmePdf{4,iInst} = pdfOutTrsf;
        bmePdf{5,iInst} = infoOut;
        bmePdf{6,iInst} = {applyTransform,transformTypeStr,...
                           bcxLambda,ntransfTable,...
                           [nscMinAcceptOutput,nscMaxAcceptOutput]};
        bmePdf{7,iInst} = {bmeMean,bmeMeanTrsf};
        bmePdf{8,iInst} = {bmeVar,bmeVarTrsf};
        bmePdf{9,iInst} = {bmeSkew,bmeSkewTrsf};
      end

    % Estimate BME CI
    case 5

      %%% For tests
      %save myBMECItestInput ck4est ch4est cs4est zh4est softpdftype ...
      %     nl4est limi4est probdens4est covmodel covparam nhmax ...
      %     nsmax dmax order bmeoptions ntransfTable

      % Use modified version of BMElib's BMEprobaCI. The version used is
      % called BMEprobaCIgui and used a corrected version of pdf2CI called
      % pdf2CIgui. All modified versions are located in the guiResources
      % folder.
      zTrsf = cell(totEstPts,1);
      pdfTrsf = cell(totEstPts,1);
      zlCITrsf = zeros(totEstPts,1);
      zuCITrsf = zeros(totEstPts,1);
      pdfCITrsf = zeros(totEstPts,1);
      for iRep=1:totEstPts            % BEGIN: For all the estimation points
        percentDone = floor(100*iRep/totEstPts);  % Where are we standing?
        displayString = ['BME CI: Prediction at point ' num2str(iRep) '/' ...
                         num2str(totEstPts) '. Progress: About '...
                         num2str(percentDone) '%'];
        set(handles.feedbackEdit,'String',displayString);
        pause(0.01);                  % Necessary to display msg. Min burden
        ckPoint = ck4est(iRep,:);     % Isolate current estimation point
        if (usingPolygon && ~ck4estFlag(iRep))
          zlCITrsf(iRep,1) = NaN;
          zuCITrsf(iRep,1) = NaN;
          pdfCITrsf(iRep,1) = NaN;
          PCI = NaN;
          zTrsf{iRep} = [NaN;NaN];
          pdfTrsf{iRep} = [NaN;NaN];
        else
          [zlCITrsf(iRep,1),zuCITrsf(iRep,1),pdfCITrsf(iRep,1),PCI,...
            zTrsf(iRep,1),pdfTrsf(iRep,1)] = BMEprobaCIgui(ckPoint,ch4est,cs4est,...
                        zh4est,softpdftype,nl4est,limi4est,probdens4est,...
                        covmodel,covparam,nhmax,nsmax,dmax,order,bmeoptions);
 
        end
      end
      %%% For tests
      %save myBMECItestOut zlCITrsf zuCITrsf pdfCI PCI zTrsf pdf ntransfTable

      for iRep=1:size(zTrsf,1)   % Can not process a cell array at once
        % Calculate moments from BME CI transformed-space output at each node
        [bmeMeanTrsf(iRep,1),bmeVarTrsf(iRep,1),bmeSkewTrsf(iRep,1),A] = ...
                                       pdfstat(zTrsf{iRep},pdfTrsf{iRep});
        percentDone = floor(100*iRep/size(zTrsf,1));  % Where are we standing?
        displayString = ['Task 1/4: Calculating moments. Progress: About '...
                         num2str(percentDone) '%'];
        set(handles.feedbackEdit,'String',displayString);
        pause(0.01);                % Necessary to display msg. Min burden
      end

      % Back-transform output if transformation has been applied
      switch applyTransform
        case 0     % No transformation was applied
          zlCI = zlCITrsf;
          zuCI = zuCITrsf;
          z = zTrsf;
          displayString = 'Task 2/4: Backtransforming results...';
          set(handles.feedbackEdit,'String',displayString);
          pause(0.01);                % Necessary to display msg. Min burden
        case 1     % N-scores
          for iRep=1:size(zTrsf,1)   % Can not process a cell array at once
            zlCI(iRep,1) = nscoreBackVec(zlCITrsf(iRep),ntransfTable,...
                                      nscMinAcceptOutput,nscMaxAcceptOutput);
            zuCI(iRep,1) = nscoreBackVec(zuCITrsf(iRep),ntransfTable,...
                                      nscMinAcceptOutput,nscMaxAcceptOutput);
            if ~isempty(zTrsf{iRep})
              z{iRep,1} = nscoreBackVec(zTrsf{iRep},ntransfTable,...
                                   nscMinAcceptOutput,nscMaxAcceptOutput);
            else
              z{iRep,1}=[];
            end;
            % Use backtransformed PDF to get 3rd mom (skewness) for original space.
            [trash1,trash2,bmeSkewTemp(iRep,1),A] = pdfstat(z{iRep},pdfTrsf{iRep});
            displayString = ['Task 2/4: Backtransforming results at point ' ...
                             num2str(iRep) '/' num2str(totEstPts) '...'];
            set(handles.feedbackEdit,'String',displayString);
            pause(0.01);                % Necessary to display msg. Min burden
          end
          clear trash1 trash2
        case 2     % Boxcox
          for iRep=1:size(zTrsf,1)   % Can not process a cell array at once
            zTemp = boxcoxBack(zlCITrsf(iRep),bcxLambda);
            zlCI(iRep,1) = zTemp - bcxDataShiftConst;
            zTemp = boxcoxBack(zuCITrsf(iRep),bcxLambda);
            zuCI(iRep,1) = zTemp - bcxDataShiftConst;
            zTemp = boxcoxBack(zTrsf{iRep},bcxLambda);
            z{iRep,1} = zTemp - bcxDataShiftConst;
            % Use backtransformed PDF to get 3rd mom (skewness) for original space.
            [trash1,trash2,bmeSkewTemp(iRep,1),A] = pdfstat(z{iRep},pdfTrsf{iRep});
            displayString = ['Task 2/4: Backtransforming results at point ' ...
                             num2str(iRep) '/' num2str(totEstPts) '...'];
            set(handles.feedbackEdit,'String',displayString);
            pause(0.01);                % Necessary to display msg. Min burden
          end
          clear trash1 trash2
        otherwise  % Not specified here
          errordlg({'ip306predictionWiz.m:beginEstimationButton:estItem4:';...
            'No provision in code for requested menu item.'},...
            'GUI software Error')
      end

      displayString = ['Task 3/4: Backtransforming moments...'];
      set(handles.feedbackEdit,'String',displayString);
      pause(0.01);                % Necessary to display msg. Min burden
      % Back-transform moments from CI results if transformation has been applied
      [bmeMean,bmeVar,bmeSkew] = backTrBmeRes(bmeMeanTrsf,bmeVarTrsf,bmeSkewTrsf);
      % Use appropriate skewness in case transformation has been applied
      if applyTransform
        bmeSkew = bmeSkewTemp;
      end
      clear bmeSkewTemp
      
      displayString = 'Task 4/4: Arranging results and finalizing...';
      set(handles.feedbackEdit,'String',displayString);
      pause(0.01);                % Necessary to display msg. Min burden
      % Distribute output to temporal instances as appropriate
      % Where applicable, keep both results in original and transform space
      % Refer to, e.g., the mean as bmeCin{7,iInst}{1} for the original space
      % and bmeCin{7,iInst}{2} for the transformed values at instance iInst
      % The output BME cell arrays extend from {1} to {dataTimeSpan}
      if timePresent && ~isempty(outGrid)
        bmeCin = cell(12,outputTimeSpan);
        for iInst=1:outputTimeSpan % Iterate over the output instances
          tNowActual = outGrid{totalCoordinatesUsed}(iInst);
          indx = find(ck4est(:,end)==tNowActual);
          % In the following, (indx) is used instead of {indx} for the cell
          % variables z ans pdf. The first expression (indx) implies the
          % corresponding cell, whereas the second only refers to the values
          bmeCin{1,iInst} = [];
          bmeCin{2,iInst} = [iInst tNowActual]; % Temporal instance we refer to
          bmeCin{3,iInst} = {zlCI(indx,:),zlCITrsf(indx)};
          bmeCin{4,iInst} = {zuCI(indx,:),zuCITrsf(indx)};
          bmeCin{5,iInst} = pdfCITrsf(indx,:);
          bmeCin{6,iInst} = [];
          bmeCin{7,iInst} = {z(indx),zTrsf(indx)};
          bmeCin{8,iInst} = pdfTrsf(indx);
          bmeCin{9,iInst} = [];
          bmeCin{10,iInst} = {bmeMean(indx),bmeMeanTrsf(indx)};
          bmeCin{11,iInst} = {bmeVar(indx),bmeVarTrsf(indx)};
          bmeCin{12,iInst} = {bmeSkew(indx),bmeSkewTrsf(indx)};
        end
        bmeCin{1,1} = [1];         % To verify estimation has been performed
        bmeCin{6,1} = PCI;
        bmeCin{9,1} = {applyTransform,transformTypeStr,...   % Trsf info:
              bcxLambda,ntransfTable,...                     % Refer to as
              [nscMinAcceptOutput,nscMaxAcceptOutput]};      % bmePdf{6,1}{y}
      else
        bmeCin = cell(12,1);
        iInst = 1;
        bmeCin{1,iInst} = [1];   % Test element to verify estimation has been performed
        bmeCin{2,iInst} = [iInst iInst];        % Temporal instance we refer to
        bmeCin{3,iInst} = {zlCI,zlCITrsf};
        bmeCin{4,iInst} = {zuCI,zuCITrsf};
        bmeCin{5,iInst} = pdfCITrsf;
        bmeCin{6,iInst} = PCI;
        bmeCin{7,iInst} = {z,zTrsf};
        bmeCin{8,iInst} = pdfTrsf;
        bmeCin{9,iInst} = {applyTransform,transformTypeStr,...
                           bcxLambda,ntransfTable,...
                           [nscMinAcceptOutput,nscMaxAcceptOutput]};
        bmeCin{10,iInst} = {bmeMean,bmeMeanTrsf};
        bmeCin{11,iInst} = {bmeVar,bmeVarTrsf};
        bmeCin{12,iInst} = {bmeSkew,bmeSkewTrsf};
      end
  end
  
  % BEGIN: Using part of gifplayer Matlab function code by Vihang Patil
  if (isvalid(handles.tmr))
    stop(handles.tmr); delete(handles.tmr); clear handles.tmr; % Removes timer from memory
  end
  % END: Using part of gifplayer Matlab function code by Vihang Patil
  % Restore standard thinker pic in image area
  axes(handles.estScreenAxes)
  image(imread('guiResources/ithinkPic.png'));
  axis image
  axis off

  displayString = 'Prediction task is complete. ';
  if bmeMod{1,1} && ~bmeMom{1,1} && ~bmePdf{1,1} && ~bmeCin{1,1}
    displayString = [displayString 'BME Mode data present'];
  elseif ~bmeMod{1,1} && bmeMom{1,1} && ~bmePdf{1,1} && ~bmeCin{1,1}
    displayString = [displayString 'BME Moments data present'];
  elseif ~bmeMod{1,1} && ~bmeMom{1,1} && bmePdf{1,1} && ~bmeCin{1,1}
    displayString = [displayString 'BME PDF data present'];
  elseif ~bmeMod{1,1} && ~bmeMom{1,1} && ~bmePdf{1,1} && bmeCin{1,1}
    displayString = [displayString 'BME CI data present'];
  elseif bmeMod{1,1} && bmeMom{1,1} && ~bmePdf{1,1} && ~bmeCin{1,1}
    displayString = [displayString 'BME Mode, Moments data present'];
  elseif bmeMod{1,1} && ~bmeMom{1,1} && bmePdf{1,1} && ~bmeCin{1,1}
    displayString = [displayString 'BME Mode, PDF data present'];
  elseif bmeMod{1,1} && ~bmeMom{1,1} && ~bmePdf{1,1} && bmeCin{1,1}
    displayString = [displayString 'BME Mode, CI data present'];
  elseif ~bmeMod{1,1} && bmeMom{1,1} && bmePdf{1,1} && ~bmeCin{1,1}
    displayString = [displayString 'BME Moments, PDF data present'];
  elseif ~bmeMod{1,1} && bmeMom{1,1} && ~bmePdf{1,1} && bmeCin{1,1}
    displayString = [displayString 'BME Moments, CI data present'];
  elseif ~bmeMod{1,1} && ~bmeMom{1,1} && bmePdf{1,1} && bmeCin{1,1}
    displayString = [displayString 'BME PDF, CI data present'];
  elseif bmeMod{1,1} && bmeMom{1,1} && bmePdf{1,1} && ~bmeCin{1,1}
    displayString = [displayString 'BME Mode, Moments, PDF data present'];
  elseif bmeMod{1,1} && bmeMom{1,1} && ~bmePdf{1,1} && bmeCin{1,1}
    displayString = [displayString 'BME Mode, Moments, CI data present'];
  elseif bmeMod{1,1} && ~bmeMom{1,1} && bmePdf{1,1} && bmeCin{1,1}
    displayString = [displayString 'BME Mode, PDF, CI data present'];
  elseif ~bmeMod{1,1} && bmeMom{1,1} && bmePdf{1,1} && bmeCin{1,1}
    displayString = [displayString 'BME Moments, PDF, CI data present'];
  elseif bmeMod{1,1} && bmeMom{1,1} && bmePdf{1,1} && bmeCin{1,1}
    displayString = [displayString 'BME Mode, Moments, PDF, CI data present'];
  end
  set(handles.feedbackEdit,'String',displayString);
  set(handles.estSelectionMenu,'Value',1)     % Return to title display

  % Prompt the user to save the data. User can save them later while on the
  % same screen, too.
  initialDir = pwd;     % Save the current directory path

  bmeOutFilename = 'BMEpredictionOut.mat';
  % Prompt user to save trend information data in a MAT-file for future use
  %
  [bmeOutFilename,bmeOutPathname] = uiputfile( '*.mat', 'Save BME output info as MAT-file:');	

  if isequal([bmeOutFilename,bmeOutPathname],[0,0])  % If 'Cancel' selected, give second chance
    user_response = ip103fileSaveDialog('Title','Skip Saving BME output Data?');
    switch lower(user_response)
      case 'no'                 % If user changes his/her mind, prompt to save
        [bmeOutFilename,bmeOutPathname] = uiputfile( '*.mat', 'Save BME output info as MAT-file:');	
        if ~isequal([bmeOutFilename,bmeOutPathname],[0,0])  % If other than 'Cancel' was selected
          % Construct the full path and save
          validOutputData = 1;  % Control variable. Validates this as an output file
          File = fullfile(bmeOutPathname,bmeOutFilename);
          save(File,'bmeMod','bmeMom','bmePdf','bmeCin','timePresent','outGrid',...
                    'totalCoordinatesUsed','totalSpCoordinatesUsed',...
                    'minTout','maxTout','minTdata','maxTdata','trendTInsts',...
                    'meanTrendAtkAtInst','positiveDataOnly','validOutputData');
          displayString1 = ['BME output in: ' bmeOutFilename];
        else
          displayString1 = 'BME output data present but not saved';
        end
      case 'yes'
        % Do nothing
        bmeOutFilename = [];
        displayString1 = 'BME output data present but not saved';
    end
  else                  % If other than 'Cancel' was selected at first
    % Construct the full path and save
    validOutputData = 1;  % Control variable. Validates this as an output file
    File = fullfile(bmeOutPathname,bmeOutFilename);
    save(File,'bmeMod','bmeMom','bmePdf','bmeCin','timePresent','outGrid',...
              'totalCoordinatesUsed','totalSpCoordinatesUsed',...
              'minTout','maxTout','minTdata','maxTdata','trendTInsts',...
              'meanTrendAtkAtInst','positiveDataOnly','validOutputData');
    displayString1 = ['BME output in: ' bmeOutFilename];
  end

  cd (initialDir);      % Finally, return to where this function was evoked from

  set(handles.feedbackEdit,'String',displayString1);
  pause(0.5);
  set(handles.feedbackEdit,'String',displayString);

end





function [bmeMean,bmeVar,bmeSkew] = backTrBmeRes(bmeMeanTrsf,bmeVarTrsf,bmeSkewTrsf);
%
global applyTransform
global ntransfTable                          % To be used in backtransformations
global nscMinAcceptOutput nscMaxAcceptOutput % To be used in backtransformations
global bcxLambda bcxDataShiftConst           % To be used in backtransformations


switch applyTransform
  case 0     % No transformation was applied
    bmeMean = bmeMeanTrsf;
    bmeVar = bmeVarTrsf;
    bmeSkew = bmeSkewTrsf;
  case 1     % N-scores
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
  case 2     % Boxcox
    zTemp = boxcoxBack(bmeMeanTrsf,bcxLambda);
    bmeMean = zTemp - bcxDataShiftConst;        % Complete backtransformation
          
    % Direct back-transformation of the BME variance is improper. 
    % Instead, a measure of the variance in the original space 
    % is provided using the variance in the transformed space:
    % See how far standard deviation extends in transformed space
    % and convert the limits of this span in original space values
    bmeStdTrsf = sqrt(bmeVarTrsf);                % Get standard deviation
    bmeMeanPlusStdTrsf = bmeMeanTrsf+bmeStdTrsf;  % Add it to BMEmean
    bmeMeanPlusStd = boxcoxBack(bmeMeanPlusStdTrsf,bcxLambda);
    bmeMeanMinStdTrsf = bmeMeanTrsf-bmeStdTrsf;   % Subtract it from BMEmean
    bmeMeanMinStd = boxcoxBack(bmeMeanMinStdTrsf,bcxLambda);
    % Provide a measure of variance by means of a standard deviation
    % measure in the original space. 
    bmeVar = (0.5*(bmeMeanPlusStd-bmeMeanMinStd)).^2;
    clear bmeMeanTrsf bmeVarTrsf bmeMeanPlusStdTrsf bmeMeanMinStdTrsf ...
          bmeMeanPlusStd bmeMeanMinStd
          
    % There can not be a measure of skewness in original space
    bmeSkew = NaN*ones(size(bmeSkewTrsf,1),1);
    clear zTemp;
  otherwise  % Not specified here
    errordlg({'ip306predictionWiz.m:beginEstimationButton:backTrBmeRes:';...
      'No provision in code for requested menu item.'},...
      'GUI software Error')
end





% --- Executes on button press in saveButton.
function saveButton_Callback(hObject, eventdata, handles)
% hObject    handle to saveButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global bmeMod bmeMom bmePdf bmeCin timePresent
global displayString
global outGrid
global totalCoordinatesUsed totalSpCoordinatesUsed
global meanTrendAtkAtInst trendTInsts
global positiveDataOnly
global minTout maxTout minTdata maxTdata
global currentDir;

if (bmeMod{1,1} || bmeMom{1,1} || bmePdf{1,1} || bmeCin{1,1})  % If there is material to save
    
%  initialDir = pwd;     % Save the current directory path

  bmeOutFilename = 'BMEpredictionOut.mat';
  % Prompt user to save trend information data in a MAT-file for future use
  %
  cd(currentDir);
  [bmeOutFilename,bmeOutPathname] = uiputfile( '*.mat', 'Save BME output info as MAT-file:');	

  if isequal([bmeOutFilename,bmeOutPathname],[0,0])  % If 'Cancel' selected, give second chance
    user_response = ip103fileSaveDialog('Title','Skip Saving BME output Data?');
    switch lower(user_response)
    case 'no'                 % If user changes his/her mind, prompt to save
      [bmeOutFilename,bmeOutPathname] = uiputfile( '*.mat', 'Save BME output info as MAT-file:');	
      if ~isequal([bmeOutFilename,bmeOutPathname],[0,0])  % If other than 'Cancel' was selected
        % Construct the full path and save
        validOutputData = 1;  % Control variable. Validates this as an output file
        File = fullfile(bmeOutPathname,bmeOutFilename);
        save(File,'bmeMod','bmeMom','bmePdf','bmeCin','timePresent','outGrid',...
                  'totalCoordinatesUsed','totalSpCoordinatesUsed',...
                  'minTout','maxTout','minTdata','maxTdata','trendTInsts',...
                  'meanTrendAtkAtInst','positiveDataOnly','validOutputData');
        displayString = ['BME output in: ' bmeOutFilename];
        set(handles.feedbackEdit,'String',displayString);
        currentDir=bmeOutPathname;
      end
    case 'yes'
      % Do nothing
      bmeOutFilename = [];
      displayString = 'BME output data present but not saved';
      set(handles.feedbackEdit,'String',displayString);
    end
  else                  % If other than 'Cancel' was selected at first
    % Construct the full path and save
    validOutputData = 1;  % Control variable. Validates this as an output file
    File = fullfile(bmeOutPathname,bmeOutFilename);
    save(File,'bmeMod','bmeMom','bmePdf','bmeCin','timePresent','outGrid',...
              'totalCoordinatesUsed','totalSpCoordinatesUsed',...
              'minTout','maxTout','minTdata','maxTdata','trendTInsts',...
              'meanTrendAtkAtInst','positiveDataOnly','validOutputData');
    displayString = ['BME output in: ' bmeOutFilename];
    set(handles.feedbackEdit,'String',displayString);
    currentDir=bmeOutPathname;
  end

%  cd (initialDir);      % Finally, return to where this function was evoked from

else
    
  displayString = ['No BME output is present to save'];
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
    ip002chooseTask('Title','Welcome to SeksGUI!');
end




% --- Executes on button press in previousButton.
function previousButton_Callback(hObject, eventdata, handles)
% hObject    handle to previousButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global timePresent

delete(handles.figure1);                            % Close current window...
ip305p1TcovarAnal('Title','Covariance Analysis'); % ...and procede to the previous unit.




% --- Executes on button press in nextButton.
function nextButton_Callback(hObject, eventdata, handles)
% hObject    handle to nextButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global timePresent

% The same visualization screen applies to S/T and S-only cases.
delete(handles.figure1);                           % Close current window...
ip307v1Tvisuals('Title','Visualization Wizard');   % ...and procede to following screen.




% BEGIN: Using part of gifplayer Matlab function code by Vihang Patil
%        to display iwait.gif during prediction computations.
function TmrFcn(src,event,handles)
% Timer Function to animate the GIF
handles = guidata(handles);
set(handles.h1,'CData',handles.im(:,:,:,handles.count)); % Update frame in the axis
handles.count = handles.count + 1;                        % Increment to next frame
if handles.count > handles.len      % If last frame shown, intialise to first frame
    handles.count = 1;
end
guidata(handles.guifig, handles);
% END: Using part of gifplayer Matlab function code by Vihang Patil
