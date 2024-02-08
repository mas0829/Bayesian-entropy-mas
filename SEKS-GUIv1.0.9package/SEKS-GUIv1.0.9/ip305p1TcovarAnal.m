function varargout = ip305p1TcovarAnal(varargin)
%IP305P1TCOVARANAL M-file for ip305p1TcovarAnal.fig
%      IP305P1TCOVARANAL, by itself, creates a new IP305P1TCOVARANAL or raises the existing
%      singleton*.
%
%      H = IP305P1TCOVARANAL returns the handle to a new IP305P1TCOVARANAL or the handle to
%      the existing singleton*.
%
%      IP305P1TCOVARANAL('Property','Value',...) creates a new IP305P1TCOVARANAL using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to ip305p1TcovarAnal_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      IP305P1TCOVARANAL('CALLBACK') and IP305P1TCOVARANAL('CALLBACK',hObject,...) call the
%      local function named CALLBACK in IP305P1TCOVARANAL.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ip305p1TcovarAnal

% Last Modified by GUIDE v2.5 19-Jun-2011 16:21:41

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ip305p1TcovarAnal_OpeningFcn, ...
                   'gui_OutputFcn',  @ip305p1TcovarAnal_OutputFcn, ...
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


% --- Executes just before ip305p1TcovarAnal is made visible.
function ip305p1TcovarAnal_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

% Choose default command line output for ip305p1TcovarAnal
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

% UIWAIT makes ip305p1TcovarAnal wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ip305p1TcovarAnal_OutputFcn(hObject, eventdata, handles)
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
global timePresent
global ch zh cs totalCoordinatesUsed totalSpCoordinatesUsed
global sdCategory nl limi probdens softApprox
global cPt cPtValues
global usingLog
global zhLog limiLog softApproxLog
global zhDataToProcess limiDataToProcess softApproxDataToProcess
global covInputFile covInputPath
global maxCorrRangeS lagsNumberS lagsLimitsS maxCorrRangeT lagsNumberT lagsLimitsT
global covExpST
global displayString
global prevExtFigState
global minTdata maxTdata dataTimeSpan
global viewAzim viewElev

axes(handles.covarianceAxes)
image(imread('guiResources/ithinkPic.png'));
axis image
axis off

% Gather all point data (whether log-transformed or not).
% Also provides correct set (HD only) in case where no SD approximations are used.
cPtValuesDataToProcess = [zhDataToProcess;softApproxDataToProcess];

if timePresent    % Define properly the s-distance between most remote data in space.
    maxEuclDistS = coord2dist( max(cPt(:,1:end-1)),min(cPt(:,1:end-1)) );
    maxEuclDistT = dataTimeSpan; % Define the t-distance between most remote data in time.
else
    maxEuclDistS = coord2dist( max(cPt(:,:)),min(cPt(:,:)) );
    maxEuclDistT = NaN;
end

covExpST = struct('anisotropyString',...
              {'All directions','East - West','North - South'},...
               'sMaxCorrRange',{[],[],[]},...   % 3 spots for info
               'sLagsNumber',{[],[],[]},...     % on each of the 3
               'sLagsLimits',{[],[],[]},...     % available directions.
               'sCovDistance',{[],[],[]},...
               'sPairsNumber',{[],[],[]},...
               'tMaxCorrRange',{[],[],[]},...
               'tLagsNumber',{[],[],[]},...
               'tLagsLimits',{[],[],[]},...
               'tCovDistance',{[],[],[]},...
               'experimCov',{[],[],[]},...
               'tPairsNumber',{[],[],[]},...
               'dirOk',{[0],[0],[0]});

% Initialize max correlation range to half the dist between the most remote data
% This is arbitrary and may be modified
maxCorrRangeS = maxEuclDistS / 2;            %% This approach can cause careless users to
lagsNumberS = 10;                  % Initialize number of lags for s-covariance.
% Initialize the covariance lags based on the previous. Space them out logarithmically.
lagsLimitsS = maxCorrRangeS * (1 - ...     
              log(lagsNumberS+1-[1:lagsNumberS])./log(lagsNumberS) );
if timePresent
  maxCorrRangeT = round(maxEuclDistT / 2);   %% get the bad estimations (Dec 01, 2006 H-L)
  lagsNumberT = 5;                   % Initialize number of lags for t-covariance.
  lagsLimitsT = round( maxCorrRangeT * (1 - ...     
                log(lagsNumberT+1-[1:lagsNumberT])./log(lagsNumberT) ) );
else
  maxCorrRangeT = NaN;
  lagsNumberT = 0;
  lagsLimitsT = [];    
end

set(handles.anisotropyMenu,'Value',1);  % Initialize using all-directions option.

set(handles.maxScorrRngEdit,'String',num2str(maxCorrRangeS));     % Initialize.
set(handles.sLagNumberSlider,'Value',lagsNumberS);                % Initialize.
set(handles.sLagNumberEdit,'String',...
    num2str(get(handles.sLagNumberSlider,'Value')));              % Initialize.
set(handles.sLagNumberSlider,'Max',30);

if timePresent
  set(handles.maxTcorrRngEdit,'String',num2str(maxCorrRangeT));   % Initialize.
  set(handles.tLagNumberSlider,'Value',lagsNumberT);              % Initialize.
  set(handles.tLagNumberSlider,'Max',30);
  set(handles.tLagNumberEdit,'String',...
      num2str(get(handles.tLagNumberSlider,'Value')));            % Initialize.
else
  set(handles.maxTcorrRngEdit,'String','N/A','Enable','off');     % Initialize.
  set(handles.tLagNumberSlider,'Min',0);
  set(handles.tLagNumberSlider,'Max',1);
  set(handles.tLagNumberSlider,'Value',0);                        % Initialize.
  set(handles.tLagNumberEdit,'String','N/A','Enable','off');      % Initialize.
end

  displayString = 'Compute the empirical covariance first';
set(handles.feedbackEdit,'String',displayString);

covInputFile = [];                  % Initialize.

viewAzim = 50;                      % Initialize.
viewElev = 25;                      % Initialize.

%set(handles.modelsPresentEdit,'String',num2str(nestedScounter)); % Initialize.
%set(handles.addModelMenu,'Value',1);     % Initialize using "exponential" option.
%set(handles.currModelMenu,'Value',1);                            % Initialize to show 0.
%set(handles.sillEdit,'String','');                               % Initialize.
%set(handles.rangeEdit,'String','');                              % Initialize.

prevExtFigState = 0;                % Initialize - plots in GUI window




% --- Executes on selection change in anisotropyMenu.
function anisotropyMenu_Callback(hObject, eventdata, handles)
% hObject    handle to anisotropyMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns anisotropyMenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from anisotropyMenu
global thisVersion
global covExpST
global zhDataToProcess softApproxDataToProcess
global displayString
global viewAzim viewElev
global timePresent

% Choice of covariance in all-directions (1), E-W (2), or N-S (3).
choice = get(handles.anisotropyMenu,'Value');
if covExpST(choice).dirOk  % If choice info already stored, load info on screen
  displayString = 'Presenting stored data for this choice';
  set(handles.feedbackEdit,'String',displayString);
  set(handles.maxScorrRngEdit,'String',num2str(covExpST(choice).sMaxCorrRange));
  set(handles.sLagNumberSlider,'Value',covExpST(choice).sLagsNumber);
  set(handles.sLagNumberEdit,'String',...
      num2str(get(handles.sLagNumberSlider,'Value')));
  if timePresent
    set(handles.maxTcorrRngEdit,'String',num2str(covExpST(choice).tMaxCorrRange));
    set(handles.tLagNumberSlider,'Value',covExpST(choice).tLagsNumber);
    set(handles.tLagNumberEdit,'String',...
        num2str(get(handles.tLagNumberSlider,'Value')));
  else
    set(handles.maxTcorrRngEdit,'String','N/A','Enable','off');
    set(handles.tLagNumberSlider,'Value',0);
    set(handles.tLagNumberEdit,'String','N/A','Enable','off');
  end
  
  % Gather all point data (whether log-transformed or not).
  % Also provides correct set (HD only) in case where no SD approximations are used.
  cPtValuesDataToProcess = [zhDataToProcess;softApproxDataToProcess];
  varData = var(cPtValuesDataToProcess);
  
  set(handles.graphTypeMenu,'Value',choice);  
  % Plot the empirical covariance outcome
  % Include in the plot the distance at s=0 where the covariance is the data variance
  %
  if get(handles.extFigureBox,'Value')      % Separate figure or not?
    axes(handles.covarianceAxes)
    image(imread('guiResources/ithinkPic.png'));
    axis image
    axis off
    figure;
  else
    axes(handles.covarianceAxes)
  end
  if timePresent
    dataPts = [covExpST(choice).sCovDistance(:),...
               covExpST(choice).tCovDistance(:),...
               covExpST(choice).experimCov(:)];
    if choice == 1
      set(handles.graphTypeMenu,'Value',1)
      surf(covExpST(choice).sCovDistance,...
           covExpST(choice).tCovDistance,covExpST(choice).experimCov);
      hold on
      hCov = plot3(dataPts(:,1),dataPts(:,2),dataPts(:,3),'ro');
    elseif choice == 2
      set(handles.graphTypeMenu,'Value',2)
      surf(covExpST(choice).sCovDistance,...
           covExpST(choice).tCovDistance,covExpST(choice).experimCov);
      hold on
      hCov = plot3(dataPts(:,1),dataPts(:,2),dataPts(:,3),'m<');
    elseif choice == 3
      set(handles.graphTypeMenu,'Value',3)
      surf(covExpST(choice).sCovDistance,...
           covExpST(choice).tCovDistance,covExpST(choice).experimCov);
      hold on
      hCov = plot3(dataPts(:,1),dataPts(:,2),dataPts(:,3),'m^');
    end
    hold off
    view(viewAzim,viewElev)
    cmap = hot; cmap = cmap(end:-1:1,:); colormap(cmap);
    maxSdistance = max(max(covExpST(choice).sCovDistance));
    maxTdistance = max(max(covExpST(choice).tCovDistance));
    %axis image;
    axis([0 maxSdistance 0 maxTdistance min(min(covExpST(choice).experimCov))...
                                   1.05*max(max(covExpST(choice).experimCov))]);
    if thisVersion<7
      legend(hCov,[covExpST(choice).anisotropyString ' Empirical']);
    else
      legend(hCov,[covExpST(choice).anisotropyString ' Empirical'],'Location','Northeast');
    end
    xlabel('S-lag (in s-units)');
    ylabel('T-lag (in t-units)');
    zlabel('Covariance');
  else
    dataPts = [covExpST(choice).sCovDistance(:),...
               covExpST(choice).experimCov(:)];
    if choice == 1
      set(handles.graphTypeMenu,'Value',1)
      hCov = plot([covExpST(choice).sCovDistance'],...
                  [covExpST(choice).experimCov'],'ro');
    elseif choice == 2
      set(handles.graphTypeMenu,'Value',2)
      hCov = plot([covExpST(choice).sCovDistance'],...
                  [covExpST(choice).experimCov'],'m<');
    elseif choice == 3
      set(handles.graphTypeMenu,'Value',3)
      hCov = plot([covExpST(choice).sCovDistance'],...
                  [covExpST(choice).experimCov'],'m^');
    end
    if thisVersion<7
      legend(hCov,[covExpST(choice).anisotropyString ' Empirical']);
    else
      legend(hCov,[covExpST(choice).anisotropyString ' Empirical'],'Location','Northeast');
    end
    xlabel('Lag (in s-units)');
    ylabel('Covariance');
  end

else
  displayString = 'No information for this direction selection yet';
  set(handles.feedbackEdit,'String',displayString);
end




% --- Executes during object creation, after setting all properties.
function anisotropyMenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to anisotropyMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in loadDataButton.
function loadDataButton_Callback(hObject, eventdata, handles)
% hObject    handle to loadDataButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global thisVersion
global covInputFile covInputPath
global zhDataToProcess limiDataToProcess softApproxDataToProcess
global covDistanceS covDistanceT experimCovST pairsNumberST
global maxCorrRangeS lagsNumberS lagsLimitsS maxCorrRangeT lagsNumberT lagsLimitsT
global covExpST
global displayString
global viewAzim viewElev
global currentDir
global timePresent

% initialDir = pwd;                    % Save the current directory path

cd(currentDir);
[covInputFileNew,covInputPath] = uigetfile('*.mat','Select covariance Data MAT-file');
%
% If user presses 'Cancel' then 0 is returned.
%
% If user cancels, we want to retain the information, if any present. 
% The following IF statement produces a warning if the user cancels AND 
% has no previous data, or otherwise loads the data from a valid file.
%
if ~ischar(covInputFileNew) && ~ischar(covInputFile) % If "Cancel" AND no previous data
    
  displayString = 'No covariance Data MAT-file present';
  set(handles.feedbackEdit,'String',displayString);
  
elseif ischar(covInputFileNew)                      % If new data to be entered
    
  covInputFile = covInputFileNew; % The new one replaces the existing one
  cd (covInputPath);              % Go where the covariance file resides
  currentDir=covInputPath;

  if ~isnan(str2double(textread(covInputFile,'%s',1)))  % Is this a MAT-file?
    warndlg({'Covariance data are to be read from an existing MAT-file.';...
        'It seems that it is not a Matlab MAT-file.';,...
        'Please check again your input';...
        'or opt to calculate the covariance explicitly.'},...
        'Not a MAT-file!')
    displayString = 'No covariance Data MAT-file present';
    set(handles.feedbackEdit,'String',displayString);
  else    
    fileContents = load('-mat',covInputFile);           % Load data from file
    if ~isfield(fileContents,'covExpST')                % Is this the right file?
      set(handles.feedbackEdit,'String','No covariance Data MAT-file present');
      errordlg({'This MAT-file that contains irrelevant information.';...
          'Please check again your input';...
          'or opt to calculate the covariance explicitly.'},...
          'Wrong file!')
      clear fileContents;
    else
      displayString = ['Using saved covariance data in: ' covInputFile];
      set(handles.feedbackEdit,'String',displayString);

      clear fileContents;
      load('-mat',covInputFile);  % Load the covariance information into memory 
 
%      cd (initialDir);            % Return to where this function was evoked from
      if covExpST(1).dirOk && ~covExpST(2).dirOk && ~covExpST(3).dirOk     % All-dir
        displayString = 'Data available for anisotropy option: All-dir';
        set(handles.feedbackEdit,'String',displayString);
        choice = 1;               % So as to display all of the available saved data
      elseif ~covExpST(1).dirOk && covExpST(2).dirOk && ~covExpST(3).dirOk % E-W
        displayString = 'Data available for anisotropy option: E-W';
        set(handles.feedbackEdit,'String',displayString);
        choice = 2;               % So as to display all of the available saved data
      elseif ~covExpST(1).dirOk && ~covExpST(2).dirOk && covExpST(3).dirOk % N-S
        displayString = 'Data available for anisotropy option: N-S';
        set(handles.feedbackEdit,'String',displayString);
        choice = 3;               % So as to display all of the available saved data
      elseif covExpST(1).dirOk && covExpST(2).dirOk && ~covExpST(3).dirOk  % All-dir & E-W
        displayString = 'Data available for anisotropy options: All-dir & E-W';
        set(handles.feedbackEdit,'String',displayString);
        choice = 1;               % So as to display some of the available saved data
      elseif covExpST(1).dirOk && ~covExpST(2).dirOk && covExpST(3).dirOk  % All-dir & N-S
        displayString = 'Data available for anisotropy options: All-dir & N-S';
        set(handles.feedbackEdit,'String',displayString);
        choice = 1;               % So as to display some of the available saved data
      elseif ~covExpST(1).dirOk && covExpST(2).dirOk && covExpST(3).dirOk  % E-W & N-S
        displayString = 'Data available for anisotropy options: E-W & N-S';
        set(handles.feedbackEdit,'String',displayString);
        choice = 2;               % So as to display some of the available saved data
      elseif covExpST(1).dirOk && covExpST(2).dirOk && covExpST(3).dirOk   % All
        displayString = 'Data available for all anisotropy options.';
        set(handles.feedbackEdit,'String',displayString);
        choice = 1;               % So as to display some of the available saved data
      else                                                            % No info
        errordlg({'ip305p1TcovarAnal.m:loadDataButton_Callback Function:';...
              'After loading saved data it is suggested that no information';...
              'is contained in the struct covExpST.dirOk index array:';...
              ['covExpST.dirOk=[' num2str(covExpST(1).dirOk) ' '...
              num2str(covExpST(2).dirOk) ' ' num2str(covExpST(3).dirOk) '].']},...
              'GUI software Error');
      end
      
      maxCorrRangeS = covExpST(choice).sMaxCorrRange;
      maxCorrRangeT = covExpST(choice).tMaxCorrRange;
      lagsNumberS = covExpST(choice).sLagsNumber;
      lagsNumberT = covExpST(choice).tLagsNumber;
      
      set(handles.anisotropyMenu,'Value',choice);  
      set(handles.maxScorrRngEdit,'String',num2str(maxCorrRangeS));
      set(handles.sLagNumberSlider,'Value',lagsNumberS);
      set(handles.sLagNumberEdit,'String',num2str(lagsNumberS));
      if timePresent
        set(handles.maxTcorrRngEdit,'String',num2str(maxCorrRangeT));
        set(handles.tLagNumberSlider,'Value',lagsNumberT);
        set(handles.tLagNumberEdit,'String',num2str(lagsNumberT));
      else
        set(handles.maxTcorrRngEdit,'String','N/A','Enable','off');
        set(handles.tLagNumberSlider,'Value',0);
        set(handles.tLagNumberEdit,'String','N/A','Enable','off');
      end

      % Gather all point data (whether log-transformed or not).
      % Also provides correct set (HD only) in case where no SD approximations are used.
      cPtValuesDataToProcess = [zhDataToProcess;softApproxDataToProcess];
      varData = var(cPtValuesDataToProcess);
      
      set(handles.graphTypeMenu,'Value',choice);  
      % Plot the empirical covariance outcome
      % If we deal with all-directions, include in the plot the distance at s=0 
      % where the covariance is the data variance. Otherwise do not include s=0
      % because the curve may range higher or lower than the average direction.
      %
      if get(handles.extFigureBox,'Value')      % Separate figure or not?
        axes(handles.covarianceAxes)
        image(imread('guiResources/ithinkPic.png'));
        axis image
        axis off
        figure;
      else
        axes(handles.covarianceAxes)
      end
      
      if timePresent
        dataPts = [covExpST(choice).sCovDistance(:),...
          covExpST(choice).tCovDistance(:),...
          covExpST(choice).experimCov(:)];
        if choice == 1
          set(handles.graphTypeMenu,'Value',1)
          surf(covExpST(choice).sCovDistance,...
               covExpST(choice).tCovDistance,covExpST(choice).experimCov);
        hold on
        hCov = plot3(dataPts(:,1),dataPts(:,2),dataPts(:,3),'ro');
        elseif choice == 2
          set(handles.graphTypeMenu,'Value',2)
          surf(covExpST(choice).sCovDistance,...
               covExpST(choice).tCovDistance,covExpST(choice).experimCov);
          hold on
          hCov = plot3(dataPts(:,1),dataPts(:,2),dataPts(:,3),'m<');
        elseif choice == 3
          set(handles.graphTypeMenu,'Value',3)
          surf(covExpST(choice).sCovDistance,...
               covExpST(choice).tCovDistance,covExpST(choice).experimCov);
          hold on
          hCov = plot3(dataPts(:,1),dataPts(:,2),dataPts(:,3),'m^');
        end
        hold off
        view(viewAzim,viewElev)
        cmap = hot; cmap = cmap(end:-1:1,:); colormap(cmap);
        maxSdistance = max(max(covExpST(choice).sCovDistance));
        maxTdistance = max(max(covExpST(choice).tCovDistance));
        %axis image;
        axis([0 maxSdistance 0 maxTdistance min(min(covExpST(choice).experimCov))...
                                       1.05*max(max(covExpST(choice).experimCov))]);
        if thisVersion<7
          legend(hCov,[covExpST(choice).anisotropyString ' Empirical']);
        else
          legend(hCov,[covExpST(choice).anisotropyString ' Empirical'],'Location','Northeast');
        end
        xlabel('S-lag (in s-units)');
        ylabel('T-lag (in t-units)');
        zlabel('Covariance')
      else
        dataPts = [covExpST(choice).sCovDistance(:),...
                   covExpST(choice).experimCov(:)];
        if choice == 1
          set(handles.graphTypeMenu,'Value',1)
          hCov = plot([covExpST(choice).sCovDistance'],...
                      [covExpST(choice).experimCov'],'ro');
        elseif choice == 2
          set(handles.graphTypeMenu,'Value',2)
          hCov = plot([covExpST(choice).sCovDistance'],...
                      [covExpST(choice).experimCov'],'m<');
        elseif choice == 3
          set(handles.graphTypeMenu,'Value',3)
          hCov = plot([covExpST(choice).sCovDistance'],...
                      [covExpST(choice).experimCov'],'m^');
        end
        if thisVersion<7
          legend(hCov,[covExpST(choice).anisotropyString ' Empirical']);
        else
          legend(hCov,[covExpST(choice).anisotropyString ' Empirical'],'Location','Northeast');
        end
        xlabel('Lag (in s-units)');
        ylabel('Covariance');
      end
      
    end
  end    
%  cd (initialDir);     % Finally, return to where this function was evoked from
    
end




% --- Executes on button press in experCovarianceButton.
function experCovarianceButton_Callback(hObject, eventdata, handles)
% hObject    handle to experCovarianceButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global thisVersion
global cPt
global zhDataToProcess limiDataToProcess softApproxDataToProcess
global covExpST 
global experimentalCovOk covDataFilename
global covDistanceS covDistanceT experimCovST pairsNumberST
global covOutFile covOutPath
global displayString
global viewAzim viewElev
global currentDir
global timePresent

% Gather all point data (whether log-transformed or not).
% Also provides correct set (HD only) in case where no SD approximations are used.
cPtValuesDataToProcess = [zhDataToProcess;softApproxDataToProcess];

% Which direction is the covariance calculated in?
directionIndx = get(handles.anisotropyMenu,'Value');

if covExpST(directionIndx).dirOk   % It seems that the requested data are here.
  % Show on screen what is already available.
  if covExpST(1).dirOk && ~covExpST(2).dirOk && ~covExpST(3).dirOk     % All-dir
    displayString = 'Data available for anisotropy option: All-dir';
    set(handles.feedbackEdit,'String',displayString);
  elseif ~covExpST(1).dirOk && covExpST(2).dirOk && ~covExpST(3).dirOk % E-W
    displayString = 'Data available for anisotropy option: E-W';
    set(handles.feedbackEdit,'String',displayString);
  elseif ~covExpST(1).dirOk && ~covExpST(2).dirOk && covExpST(3).dirOk % N-S
    displayString = 'Data available for anisotropy option: N-S';
    set(handles.feedbackEdit,'String',displayString);
  elseif covExpST(1).dirOk && covExpST(2).dirOk && ~covExpST(3).dirOk  % All-dir & E-W
    displayString = 'Data available for anisotropy options: All-dir & E-W';
    set(handles.feedbackEdit,'String',displayString);
  elseif covExpST(1).dirOk && ~covExpST(2).dirOk && covExpST(3).dirOk  % All-dir & N-S
    displayString = 'Data available for anisotropy options: All-dir & N-S';
    set(handles.feedbackEdit,'String',displayString);
  elseif ~covExpST(1).dirOk && covExpST(2).dirOk && covExpST(3).dirOk  % E-W & N-S
    displayString = 'Data available for anisotropy options: E-W & N-S';
    set(handles.feedbackEdit,'String',displayString);
  elseif covExpST(1).dirOk && covExpST(2).dirOk && covExpST(3).dirOk   % All
    displayString = 'Data available for all anisotropy options.';
    set(handles.feedbackEdit,'String',displayString);
  else                                                            % No info
    errordlg({'ip305p1TcovarAnal.m:loadDataButton_Callback Function:';...
          'After loading saved data it is suggested that no information';...
          'is contained in the struct covExpST.dirOk index array:';...
          ['covExpST.dirOk=[' num2str(covExpST(1).dirOk) ' '...
          num2str(covExpST(2).dirOk) ' ' num2str(covExpST(3).dirOk) '].']},...
          'GUI software Error');
  end
  % Check with user whether to continue with calculation or not.  
  user_response = ip105p1getCovWarning('Title','Confirm Action');
  switch lower(user_response)
    case 'no'
        proceedWithCalculation = 0;
    case 'yes'
        proceedWithCalculation = 1;
  end  
else                            % If not, prepare for calculations.
  proceedWithCalculation = 1;
end

if proceedWithCalculation

  % option(4)=1 removes the mean from the data to use for empirical covariance.
  % option(4)=0 assumes zero-mean data: This may not be the case when using
  % the Box-Cox transformation that may have added a constant to the data.
  switch directionIndx          % 1, 2, or 3.
    case 1
      options=[0 0 0 1] ;       % All directions
    case 2
      options=[0 -45 45 1];     % East-West
    case 3
      options=[0 45 -45 1];     % North-South
    otherwise
      errordlg({'ip305p1TcovarAnal.m:experCovarianceButton_Callback Function:';...
            'The switch command detected more options';...
            'than currently available (3) in the Anisotropy menu.'},...
            'GUI software Error')
  end

  % For the following four parameters, make sure they are not empty or invalid.
  % Currently, this check is performed at the corresponding UI handles functions.
  % Also, the handles are initialized whenever this screen is invoked.
  % So at this instance the two UI handles in use below have been assigned values.
  %
  maxCorrRangeS = str2num(get(handles.maxScorrRngEdit,'String'));
  lagsNumberS = get(handles.sLagNumberSlider,'Value');
  lagsLimitsS = maxCorrRangeS * (1 - ... % Space out the lags logarithmically.
                log(lagsNumberS+1-[1:lagsNumberS])./log(lagsNumberS) );
  if timePresent
    maxCorrRangeT = str2num(get(handles.maxTcorrRngEdit,'String'));
    lagsNumberT = get(handles.tLagNumberSlider,'Value');
    % Get temporal limits on rounded temporal instances. Should this lead to
    % multiple identical neighboring limits, identical values are removed.
    lagsLimitsT = unique(round( maxCorrRangeT * (1 - ...     
                  log(lagsNumberT+1-[1:lagsNumberT])./log(lagsNumberT) ) ) );
  else
    maxCorrRangeT = NaN;
    lagsNumberT = 0;
    lagsLimitsT = [];    
  end
  
  % Ensure that the 0 space lag will be included in the covariance calculations
  % as well as a number close to 0 so that there is a value for empirical
  % covariance close to the origin. We take proximity to 0 as maxCorrRangeS/100
  if lagsLimitsS(2) > maxCorrRangeS/100
    for i=length(lagsLimitsS):-1:2       % Shift lags by one position to the right
      lagsLimitsS(i+1) = lagsLimitsS(i);
    end
    lagsLimitsS(1) = 0;
    lagsLimitsS(2) = maxCorrRangeS/100;  % ...to make space for an additional one
  end

  if timePresent
    % Ensure that the 0 time lag will be included in the covariance calculations
    % Is the 1 time lag included in the set? If yes, then the lags limits 0 and 1
    % will yield the 0 time lag in the calculations. The following lines deal with
    % the case where lag 1 is not part of the lagsLimitsT set.
    if ~sum(lagsLimitsT==ones(1,size(lagsLimitsT,2)))   % 1 if '1' is not included
      for i=length(lagsLimitsT):-1:2       % Shift lags by one position to the right
        lagsLimitsT(i+1) = lagsLimitsT(i);
      end
      lagsLimitsT(1) = 0;
      lagsLimitsT(2) = 1;                % ...to make space for an additional one
    end  
  end
  
  covExpST(directionIndx).sMaxCorrRange = maxCorrRangeS;
  covExpST(directionIndx).sLagsNumber = lagsNumberS;
  covExpST(directionIndx).sLagsLimits = lagsLimitsS;
  covExpST(directionIndx).tMaxCorrRange = maxCorrRangeT;
  covExpST(directionIndx).tLagsNumber = lagsNumberT;
  covExpST(directionIndx).tLagsLimits = lagsLimitsT;

  displayString = 'Computing empirical covariance. Please wait...';
  set(handles.feedbackEdit,'String',displayString);
  pause(0.1);
  
%addpath guiResources;                    % Where crosscovarioSTgui resides
%  [covDistanceS,covDistanceT,experimCovST,pairsNumberST] = ...
%      crosscovarioSTgui(cPt,cPt,cPtValuesDataToProcess,cPtValuesDataToProcess,...
%      lagsLimitsS,lagsLimitsT,options);
  if timePresent
    % use stcov be the core of the covariance estimation function (No direction considered)
    [Zs,cMS,tME,nanratio]=valstv2stg(cPt,cPtValuesDataToProcess);
    SLagTol=[0 lagsLimitsS(2:end)-lagsLimitsS(1:length(lagsLimitsS)-1)];
    TLagTol=[0 lagsLimitsT(2:end)-lagsLimitsT(1:length(lagsLimitsT)-1)];
    [experimCovST, pairsNumberST]=stcovgui(Zs,cMS,tME,Zs,cMS,tME,lagsLimitsS,SLagTol,...
                                           lagsLimitsT,TLagTol,handles);
    covDistanceS=kron(lagsLimitsS',ones(1,size(experimCovST,2)));
  else
    [covDistanceS,experimCovST,pairsNumberST] = ...
        crosscovariogui(cPt,cPt,cPtValuesDataToProcess,cPtValuesDataToProcess,...
                        lagsLimitsS,'loop',options);
  end
  % The covariance at the origin (s=0, t=0) is equal to the variance.
  % We force the following value for the purpose of the covariance modeling
  % to follow in the next screen. The actual value that has been calculated
  % differs slightly depending on how far from the origin the first lag goes.
  % We do not force, instead, the first lag to be very narrow (e.g., 1e-10)
  % because artifacts may appear in the covariance calculation above.
  experimCovST(1,1) = var(cPtValuesDataToProcess);
  varData = var(cPtValuesDataToProcess);
  
  % In the following lines we remove any potential NaNs that may exist in the
  % distances and covariance matrices (occurs when there are not enough pairs
  % in a lag to calculate covariance). Any NaNs will be either in the same lines
  % or the same columns. The task is to identify the lines/columns where NaNs
  % may occur in a matrix. The indices are then used to delete the lines/
  % columns in question.
  %
% Modified by Hwa-Lung 2006/06/13  
%  nansInCov = real(isnan(experimCovST));   % Show 1 where exist NaNs.
%  % Check rows (will show whether there are NaNs in any of the s-lags)
%  covDistanceS(find(prod(nansInCov,2)==1),:) = [];  
%  covDistanceT(find(prod(nansInCov,2)==1),:) = [];
%  experimCovST(find(prod(nansInCov,2)==1),:) = [];
%  % Check columns (will show whether there are NaNs in any of the t-lags)
%  covDistanceS(:,find(prod(nansInCov,1)==1)) = [];
%  covDistanceT(:,find(prod(nansInCov,1)==1)) = [];
%  experimCovST(:,find(prod(nansInCov,1)==1)) = [];
  covExpST(directionIndx).sCovDistance = covDistanceS;
  covExpST(directionIndx).experimCov = experimCovST;
  covExpST(directionIndx).pairsNumber = pairsNumberST;
  if timePresent
    covDistanceT=kron(lagsLimitsT,ones(size(experimCovST,1),1));
    covExpST(directionIndx).tCovDistance = covDistanceT;
  end
  covExpST(directionIndx).dirOk = 1;
    
  fewidx=find(covExpST(directionIndx).pairsNumber(:)<30);
  covExpST(directionIndx).dataFewidx = fewidx;
  
  set(handles.graphTypeMenu,'Value',directionIndx);  
  % Plot the empirical covariance outcome
  % If we deal with all-directions, include in the plot the distance at s=0 
  % where the covariance is the data variance. Otherwise do not include s=0
  % because the curve may range higher or lower than the average direction.
  %
  if get(handles.extFigureBox,'Value')      % Separate figure or not?
    axes(handles.covarianceAxes)
    image(imread('guiResources/ithinkPic.png'));
    axis image
    axis off
    figure;
  else
    axes(handles.covarianceAxes)
  end
  
  if timePresent
    dataPts = [covDistanceS(:),covDistanceT(:),covExpST(directionIndx).experimCov(:)];
  
    if ~isempty(fewidx)
      datafew=[covDistanceS(fewidx),covDistanceT(fewidx),covExpST(directionIndx).experimCov(fewidx)];
    else
      datafew=[];
    end;
    if directionIndx == 1
      set(handles.graphTypeMenu,'Value',1)
      surf(covDistanceS,covDistanceT,covExpST(directionIndx).experimCov);
      hold on
      hCov = plot3(dataPts(:,1),dataPts(:,2),dataPts(:,3),'ro');
      if ~isempty(datafew)
        plot3(datafew(:,1),datafew(:,2),datafew(:,3),'ro','MarkerFaceColor','k');
      end;
    elseif directionIndx == 2
      set(handles.graphTypeMenu,'Value',2)
      surf(covDistanceS,covDistanceT,covExpST(directionIndx).experimCov);
      hold on
      hCov = plot3(dataPts(:,1),dataPts(:,2),dataPts(:,3),'m<');
      if ~isempty(datafew)
        plot3(datafew(:,1),datafew(:,2),datafew(:,3),'m<','MarkerFaceColor','k');
      end;
    elseif directionIndx == 3
      set(handles.graphTypeMenu,'Value',3)
      surf(covDistanceS,covDistanceT,covExpST(directionIndx).experimCov);
      hold on
      hCov = plot3(dataPts(:,1),dataPts(:,2),dataPts(:,3),'m^');
      if ~isempty(datafew)
        plot3(datafew(:,1),datafew(:,2),datafew(:,3),'m^','MarkerFaceColor','k');
      end;
    end
    hold off
    cmap = hot; cmap = cmap(end:-1:1,:); colormap(cmap);
    view(viewAzim,viewElev)
    maxSdistance = max(max(covExpST(directionIndx).sCovDistance));
    maxTdistance = max(max(covExpST(directionIndx).tCovDistance));
    %axis image;
    axis([0 maxSdistance 0 maxTdistance min(min(covExpST(directionIndx).experimCov))...
                                   1.05*max(max(covExpST(directionIndx).experimCov))]);
    if thisVersion<7
      legend(hCov,[covExpST(directionIndx).anisotropyString ' Empirical']);
    else
      legend(hCov,[covExpST(directionIndx).anisotropyString ' Empirical'],'Location','Northeast');
    end
    xlabel('S-lag (in s-units)');
    ylabel('T-lag (in t-units)');
    zlabel('Covariance');
    covDataFile = 'empiricalCovST.mat';
  else
    % dataPts and datafew currently not used in spatial-only case  
    dataPts = [covDistanceS(:),covExpST(directionIndx).experimCov(:)];
    if ~isempty(fewidx)
      datafew=[covDistanceS(fewidx),covExpST(directionIndx).experimCov(fewidx)];
    else
      datafew=[];
    end;

    if directionIndx == 1
      set(handles.graphTypeMenu,'Value',1)
      hCov = plot([covExpST(directionIndx).sCovDistance'],...
                  [covExpST(directionIndx).experimCov'],'ro');
    elseif directionIndx == 2
      set(handles.graphTypeMenu,'Value',2)
      hCov = plot([covExpST(directionIndx).sCovDistance'],...
                  [covExpST(directionIndx).experimCov'],'m<');
    elseif directionIndx == 3
      set(handles.graphTypeMenu,'Value',3)
      hCov = plot([covExpST(directionIndx).sCovDistance'],...
                  [covExpST(directionIndx).experimCov'],'m^');
    end
    if thisVersion<7
      legend(hCov,[covExpST(directionIndx).anisotropyString ' Empirical']);
    else
      legend(hCov,[covExpST(directionIndx).anisotropyString ' Empirical'],'Location','Northeast');
    end
    xlabel('Lag (in s-units)');
    ylabel('Covariance');
    
    covDataFile = 'empiricalCovS.mat';
  end
  
  % Prompt user to save covariance information data in a MAT-file for future use
  %
  displayString = ['Done. Saving results in ' covDataFile];
  set(handles.feedbackEdit,'String',displayString);

%  initialDir = pwd;                     % Save the current directory path
  cd(currentDir);
  [covOutFile,covOutPath] = ...
      uiputfile(covDataFile,'Save covariance info as MAT-file:');	

  if isequal([covOutFile,covOutPath],[0,0]) % If 'Cancel' selected, give second chance
    displayString = 'Empirical covariance data present but not saved';
    set(handles.feedbackEdit,'String',displayString);
    user_response = ip103fileSaveDialog('Title','Skip Saving Covariance Data?');
    switch lower(user_response)
    case 'no'                           % If user changes his/her mind, prompt to save
      cd(currentDir);
      [covOutFile,covOutPath] = ...
          uiputfile(covDataFile,'Save covariance info as MAT-file:');	
      if ~isequal([covOutFile,covOutPath],[0,0]) % If other than 'Cancel' was selected
        % Construct the full path and save
        File = fullfile(covOutPath,covOutFile);
        save(File,'covExpST');
        displayString = ['Saved empirical results in ' covOutFile];
        set(handles.feedbackEdit,'String',displayString);
        currentDir=covOutPath;
      end
    case 'yes'
      % Do nothing
    end
  else                                  % If other than 'Cancel' was selected at first
    % Construct the full path and save
    File = fullfile(covOutPath,covOutFile);
    save(File,'covExpST');
    displayString = ['Saved empirical results in ' covOutFile];
    set(handles.feedbackEdit,'String',displayString);
    currentDir=covOutPath;
  end

%  cd (initialDir);                          % Return to working directory

else
    % Do nothing
end




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




function maxScorrRngEdit_Callback(hObject, eventdata, handles)
% hObject    handle to maxScorrRngEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of maxScorrRngEdit as text
%        str2double(get(hObject,'String')) returns contents of maxScorrRngEdit as a double
global outGrid totalSpCoordinatesUsed
global xMin dx xMax yMin dy yMax zMin dz zMax dataCoordMin dataCoordMax
global maxCorrRangeS

inputValue = str2num(get(handles.maxScorrRngEdit,'String'));
% The variable is empty, unless the user provides a numeric value.
if inputValue<=0
  errordlg({'Please provide only a non-zero positive value';...
            'to be the maximum spatial correlation range.'},... 
            'Invalid input');
  set(handles.maxScorrRngEdit,'String',num2str(maxCorrRangeS));     % Initialize.
elseif (isempty(inputValue) || ~isnumeric(inputValue))
  errordlg({'Please enter a numeric value for your estimate';...
            'of the size of the maximum spatial correlation range.'},... 
            'Invalid input');
  set(handles.maxScorrRngEdit,'String',num2str(maxCorrRangeS));     % Initialize.
elseif totalSpCoordinatesUsed==1 && inputValue>1.5*(xMax-xMin)
  warndlg({'The input value exceeds by more than 150%';...
           'the output grid size';...
           ['(currently: ' num2str(xMax-xMin) ' spatial units).'];...
           'Please provide a smaller value and remember that';...
           'larger radii values result in smoother trends.'},... 
           'Input not recommended');
  set(handles.maxScorrRngEdit,'String',num2str(maxCorrRangeS));     % Initialize.
elseif totalSpCoordinatesUsed==2 && inputValue>1.5*(max((xMax-xMin),(yMax-yMin)))
  warndlg({'The input value exceeds by more than 150%';...
           'the output grid maximum side size';...
           ['(currently: ' num2str(max((xMax-xMin),(yMax-yMin))) ' spatial units).'];...
           'Input is accepted but user is informed.'},... 
           'Input not recommended');
  maxCorrRangeS = inputValue;
  set(handles.maxScorrRngEdit,'String',num2str(maxCorrRangeS));     % Initialize.
else
  maxCorrRangeS = inputValue;
end




% --- Executes during object creation, after setting all properties.
function maxScorrRngEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to maxScorrRngEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on slider movement.
function sLagNumberSlider_Callback(hObject, eventdata, handles)
% hObject    handle to sLagNumberSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global lagsNumberS 

lagsNumberS = round(get(handles.sLagNumberSlider,'Value'));
set(handles.sLagNumberEdit,'String',num2str(lagsNumberS));




% --- Executes during object creation, after setting all properties.
function sLagNumberSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sLagNumberSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end




function sLagNumberEdit_Callback(hObject, eventdata, handles)
% hObject    handle to sLagNumberEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of sLagNumberEdit as text
%        str2double(get(hObject,'String')) returns contents of sLagNumberEdit as a double
global lagsNumberS 

minLags = get(handles.sLagNumberSlider,'Min');
maxLags = get(handles.sLagNumberSlider,'Max');
inputValue = str2num(get(handles.sLagNumberEdit,'String'));
if (isempty(inputValue) || ...                     % Reject input if non-numeric,
    mod(inputValue,floor(inputValue)) || ...       % non-integer,
    inputValue<minLags || inputValue>maxLags)      % or out of allowed values.
  errordlg({['Please enter an integer between '...
              num2str(minLags) ' and ' num2str(maxLags) ' for the number of lags'];...
            'to be used in the calculation of the empirical covariance.'},... 
            'Invalid input');
  set(handles.sLagNumberEdit,'String',num2str(lagsNumberS))
else
  lagsNumberS = inputValue;
  set(handles.sLagNumberSlider,'Value',lagsNumberS);
end




% --- Executes during object creation, after setting all properties.
function sLagNumberEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sLagNumberEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




function maxTcorrRngEdit_Callback(hObject, eventdata, handles)
% hObject    handle to maxTcorrRngEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of maxTcorrRngEdit as text
%        str2double(get(hObject,'String')) returns contents of maxTcorrRngEdit as a double
global outGrid totalSpCoordinatesUsed
global xMin dx xMax yMin dy yMax zMin dz zMax dataCoordMin dataCoordMax
global maxCorrRangeT
global dataTimeSpan
global timePresent

if timePresent
  inputValue = str2num(get(handles.maxTcorrRngEdit,'String'));
  % The variable is empty, unless the user provides a numeric value.
  if (inputValue<1 || mod(inputValue,floor(inputValue)))       % Negative or non-integer
    errordlg({'Please provide only a non-zero positive integer value';...
              'to be the maximum temporal correlation range.'},... 
              'Invalid input');
    set(handles.maxTcorrRngEdit,'String',num2str(maxCorrRangeT));     % Initialize.
  elseif (isempty(inputValue) || ~isnumeric(inputValue))
    errordlg({'Please enter a numeric value for your estimate';...
              'of the size of the maximum temporal correlation range.'},... 
              'Invalid input');
    set(handles.maxTcorrRngEdit,'String',num2str(maxCorrRangeT));     % Initialize.
  elseif inputValue>round(1.5*dataTimeSpan)
    warndlg({'The input value exceeds by more than 150%';...
             'the data time span';...
             ['(currently: ' num2str(dataTimeSpan) ' temporal units).'];...
             'Input is accepted but user is informed.'},... 
             'Input not recommended');
    maxCorrRangeT = inputValue;
    set(handles.maxTcorrRngEdit,'String',num2str(maxCorrRangeT));     % Initialize.
  else
    maxCorrRangeT = inputValue;
  end
else
  set(handles.maxTcorrRngEdit,'String','N/A','Enable','off');
  maxCorrRangeT = NaN;
end



% --- Executes during object creation, after setting all properties.
function maxTcorrRngEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to maxTcorrRngEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on slider movement.
function tLagNumberSlider_Callback(hObject, eventdata, handles)
% hObject    handle to tLagNumberSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global lagsNumberT 
global timePresent

if timePresent
  lagsNumberT = round(get(handles.tLagNumberSlider,'Value'));
  set(handles.tLagNumberEdit,'String',num2str(lagsNumberT));
else
  lagsNumberT = 0;
  set(handles.tLagNumberSlider,'Value',0);
  set(handles.tLagNumberEdit,'String','N/A','Enable','off');
end



% --- Executes during object creation, after setting all properties.
function tLagNumberSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tLagNumberSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end




function tLagNumberEdit_Callback(hObject, eventdata, handles)
% hObject    handle to tLagNumberEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tLagNumberEdit as text
%        str2double(get(hObject,'String')) returns contents of tLagNumberEdit as a double
global lagsNumberT 
global timePresent

if timePresent
  minLags = get(handles.tLagNumberSlider,'Min');
  maxLags = get(handles.tLagNumberSlider,'Max');
  inputValue = str2num(get(handles.tLagNumberEdit,'String'));
  if (isempty(inputValue) || ...                     % Reject input if non-numeric,
      mod(inputValue,floor(inputValue)) || ...       % non-integer,
      inputValue<minLags || inputValue>maxLags)      % or out of allowed values.
    errordlg({['Please enter an integer between '...
              num2str(minLags) ' and ' num2str(maxLags) ' for the number of lags'];...
              'to be used in the calculation of the empirical covariance.'},... 
              'Invalid input');
    set(handles.tLagNumberEdit,'String',num2str(lagsNumberT))
  else
    lagsNumberT = inputValue;
    set(handles.tLagNumberSlider,'Value',lagsNumberT);
  end
else
  lagsNumberT = 0;
  set(handles.tLagNumberSlider,'Value',0);
  set(handles.tLagNumberEdit,'String','N/A','Enable','off');
end



% --- Executes during object creation, after setting all properties.
function tLagNumberEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tLagNumberEdit (see GCBO)
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
global thisVersion
global zhDataToProcess limiDataToProcess softApproxDataToProcess
global covExpST
global displayString
global viewAzim viewElev
global timePresent

% Gather all point data (whether log-transformed or not).
% Also provides correct set (HD only) in case where no SD approximations are used.
cPtValuesDataToProcess = [zhDataToProcess;softApproxDataToProcess];
varData = var(cPtValuesDataToProcess);

% Plot the empirical covariance outcome
% If we deal with all-directions, include in the plot the distance at s=0 
% where the covariance is the data variance. Otherwise do not include s=0
% because the curve may range higher or lower than the average direction.
%
choice = get(handles.graphTypeMenu,'Value');

if timePresent
%%% Plot options for space-time study

switch choice
  case 1     % Displays empirical all-directional spatial covariance
    if covExpST(choice).dirOk  % If choice info already stored
      if get(handles.extFigureBox,'Value')   % Separate figure or not?
        axes(handles.covarianceAxes)
        image(imread('guiResources/ithinkPic.png'));
        axis image
        axis off
        figure;
      else
        axes(handles.covarianceAxes)
      end  
      set(handles.anisotropyMenu,'Value',choice);  % Direction choice coincides in menu.
      displayString = 'Plotting stored data for this choice';
      set(handles.feedbackEdit,'String',displayString);
      set(handles.maxScorrRngEdit,'String',num2str(covExpST(choice).sMaxCorrRange));
      set(handles.maxTcorrRngEdit,'String',num2str(covExpST(choice).tMaxCorrRange));
      set(handles.sLagNumberSlider,'Value',covExpST(choice).sLagsNumber);
      set(handles.tLagNumberSlider,'Value',covExpST(choice).tLagsNumber);
      set(handles.sLagNumberEdit,'String',...
      num2str(get(handles.sLagNumberSlider,'Value')));
      set(handles.tLagNumberEdit,'String',...
      num2str(get(handles.tLagNumberSlider,'Value')));
      
      dataPts = [covExpST(choice).sCovDistance(:),...
                 covExpST(choice).tCovDistance(:),...
                 covExpST(choice).experimCov(:)];
      surf(covExpST(choice).sCovDistance,...
           covExpST(choice).tCovDistance,covExpST(choice).experimCov);
      hold on
      hCov = plot3(dataPts(:,1),dataPts(:,2),dataPts(:,3),'ro');
      fewidx=covExpST(choice).dataFewidx;
      plot3(dataPts(fewidx,1),dataPts(fewidx,2),dataPts(fewidx,3),'ro','MarkerFaceColor','k');
      hold off
      view(viewAzim,viewElev)
      cmap = hot; cmap = cmap(end:-1:1,:); colormap(cmap);
      maxSdistance = max(max(covExpST(choice).sCovDistance));
      maxTdistance = max(max(covExpST(choice).tCovDistance));
      %axis image;
      axis([0 maxSdistance 0 maxTdistance min(min(covExpST(choice).experimCov))...
                                     1.05*max(max(covExpST(choice).experimCov))]);
      if thisVersion<7
        legend(hCov,[covExpST(choice).anisotropyString ' Empirical']);
      else
        legend(hCov,[covExpST(choice).anisotropyString ' Empirical'],'Location','Northeast');
      end
      xlabel('S-lag (in s-units)');
      ylabel('T-lag (in t-units)');
      zlabel('Covariance');
    else
      displayString = 'Data not available for this choice';
      set(handles.feedbackEdit,'String',displayString);
      axes(handles.covarianceAxes)
      image(imread('guiResources/ithinkPic.png'));
      axis image
      axis off
    end
  case 2     % Displays empirical E-W spatial covariance
    if covExpST(choice).dirOk  % If choice info already stored
      if get(handles.extFigureBox,'Value')   % Separate figure or not?
        axes(handles.covarianceAxes)
        image(imread('guiResources/ithinkPic.png'));
        axis image
        axis off
        figure;
      else
        axes(handles.covarianceAxes)
      end  
      set(handles.anisotropyMenu,'Value',choice);  % Direction choice coincides in menu.
      displayString = 'Plotting stored data for this choice';
      set(handles.maxScorrRngEdit,'String',num2str(covExpST(choice).sMaxCorrRange));
      set(handles.maxTcorrRngEdit,'String',num2str(covExpST(choice).tMaxCorrRange));
      set(handles.sLagNumberSlider,'Value',covExpST(choice).sLagsNumber);
      set(handles.tLagNumberSlider,'Value',covExpST(choice).tLagsNumber);
      set(handles.sLagNumberEdit,'String',...
      num2str(get(handles.sLagNumberSlider,'Value')));
      set(handles.tLagNumberEdit,'String',...
      num2str(get(handles.tLagNumberSlider,'Value')));
       
      dataPts = [covExpST(choice).sCovDistance(:),...
                 covExpST(choice).tCovDistance(:),...
                 covExpST(choice).experimCov(:)];
      surf(covExpST(choice).sCovDistance,...
           covExpST(choice).tCovDistance,covExpST(choice).experimCov);
      hold on
      hCov = plot3(dataPts(:,1),dataPts(:,2),dataPts(:,3),'m<');
      hold off
      view(viewAzim,viewElev)
      cmap = hot; cmap = cmap(end:-1:1,:); colormap(cmap);
      maxSdistance = max(max(covExpST(choice).sCovDistance));
      maxTdistance = max(max(covExpST(choice).tCovDistance));
      %axis image;
      axis([0 maxSdistance 0 maxTdistance min(min(covExpST(choice).experimCov))...
                                     1.05*max(max(covExpST(choice).experimCov))]);
      if thisVersion<7
        legend(hCov,[covExpST(choice).anisotropyString ' Empirical']);
      else
        legend(hCov,[covExpST(choice).anisotropyString ' Empirical'],'Location','Northeast');
      end
      xlabel('S-lag (in s-units)');
      ylabel('T-lag (in t-units)');
      zlabel('Covariance');
    else
      displayString = 'Data not available for this choice';
      set(handles.feedbackEdit,'String',displayString);
      axes(handles.covarianceAxes)
      image(imread('guiResources/ithinkPic.png'));
      axis image
      axis off
    end
  case 3     % Displays empirical N-S spatial covariance
    if covExpST(choice).dirOk  % If choice info already stored
      if get(handles.extFigureBox,'Value')   % Separate figure or not?
        axes(handles.covarianceAxes)
        image(imread('guiResources/ithinkPic.png'));
        axis image
        axis off
        figure;
      else
        axes(handles.covarianceAxes)
      end  
      set(handles.anisotropyMenu,'Value',choice);  % Direction choice coincides in menu.
      displayString = 'Plotting stored data for this choice';
      set(handles.maxScorrRngEdit,'String',num2str(covExpST(choice).sMaxCorrRange));
      set(handles.maxTcorrRngEdit,'String',num2str(covExpST(choice).tMaxCorrRange));
      set(handles.sLagNumberSlider,'Value',covExpST(choice).sLagsNumber);
      set(handles.tLagNumberSlider,'Value',covExpST(choice).tLagsNumber);
      set(handles.sLagNumberEdit,'String',...
      num2str(get(handles.sLagNumberSlider,'Value')));
      set(handles.tLagNumberEdit,'String',...
      num2str(get(handles.tLagNumberSlider,'Value')));
       
      dataPts = [covExpST(choice).sCovDistance(:),...
                 covExpST(choice).tCovDistance(:),...
                 covExpST(choice).experimCov(:)];
      surf(covExpST(choice).sCovDistance,...
           covExpST(choice).tCovDistance,covExpST(choice).experimCov);
      hold on
      hCov = plot3(dataPts(:,1),dataPts(:,2),dataPts(:,3),'m^');
      hold off
      view(viewAzim,viewElev)
      cmap = hot; cmap = cmap(end:-1:1,:); colormap(cmap);
      maxSdistance = max(max(covExpST(choice).sCovDistance));
      maxTdistance = max(max(covExpST(choice).tCovDistance));
      %axis image;
      axis([0 maxSdistance 0 maxTdistance min(min(covExpST(choice).experimCov))...
                                     1.05*max(max(covExpST(choice).experimCov))]);
      if thisVersion<7
        legend(hCov,[covExpST(choice).anisotropyString ' Empirical']);
      else
        legend(hCov,[covExpST(choice).anisotropyString ' Empirical'],'Location','Northeast');
      end
      xlabel('S-lag (in s-units)');
      ylabel('T-lag (in t-units)');
      zlabel('Covariance');
    else
      displayString = 'Data not available for this choice';
      set(handles.feedbackEdit,'String',displayString);
      axes(handles.covarianceAxes)
      image(imread('guiResources/ithinkPic.png'));
      axis image
      axis off
    end
  case 4     % Displays all empirical spatial covariances
    if covExpST(1).dirOk && ~covExpST(2).dirOk && ~covExpST(3).dirOk
      if get(handles.extFigureBox,'Value')   % Separate figure or not?
        axes(handles.covarianceAxes)
        image(imread('guiResources/ithinkPic.png'));
        axis image
        axis off
        figure;
      else
        axes(handles.covarianceAxes)
      end  
      choice = 1;
      set(handles.anisotropyMenu,'Value',choice);  % Direction choice coincides in menu.
      set(handles.maxScorrRngEdit,'String',num2str(covExpST(choice).sMaxCorrRange));
      set(handles.maxTcorrRngEdit,'String',num2str(covExpST(choice).tMaxCorrRange));
      set(handles.sLagNumberSlider,'Value',covExpST(choice).sLagsNumber);
      set(handles.tLagNumberSlider,'Value',covExpST(choice).tLagsNumber);
      set(handles.sLagNumberEdit,'String',...
      num2str(get(handles.sLagNumberSlider,'Value')));
      set(handles.tLagNumberEdit,'String',...
      num2str(get(handles.tLagNumberSlider,'Value')));
      dataPts = [covExpST(choice).sCovDistance(:),...
                 covExpST(choice).tCovDistance(:),...
                 covExpST(choice).experimCov(:)];
      surf(covExpST(choice).sCovDistance,...
           covExpST(choice).tCovDistance,covExpST(choice).experimCov);
      hold on
      hCov = plot3(dataPts(:,1),dataPts(:,2),dataPts(:,3),'ro');
      hold off
      view(viewAzim,viewElev)
      cmap = hot; cmap = cmap(end:-1:1,:); colormap(cmap);
      maxSdistance = max(max(covExpST(choice).sCovDistance));
      maxTdistance = max(max(covExpST(choice).tCovDistance));
      %axis image;
      axis([0 maxSdistance 0 maxTdistance min(min(covExpST(choice).experimCov))...
                                     1.05*max(max(covExpST(choice).experimCov))]);
      if thisVersion<7
        legend(hCov,[covExpST(choice).anisotropyString ' Empirical']);
      else
        legend(hCov,[covExpST(choice).anisotropyString ' Empirical'],'Location','Northeast');
      end
      xlabel('S-lag (in s-units)');
      ylabel('T-lag (in t-units)');
      zlabel('Covariance');
      displayString = 'Displaying plots for available data';
      set(handles.feedbackEdit,'String',displayString);
    elseif ~covExpST(1).dirOk && covExpST(2).dirOk && ~covExpST(3).dirOk
      if get(handles.extFigureBox,'Value')   % Separate figure or not?
        axes(handles.covarianceAxes)
        image(imread('guiResources/ithinkPic.png'));
        axis image
        axis off
        figure;
      else
        axes(handles.covarianceAxes)
      end  
      choice = 2;
      set(handles.anisotropyMenu,'Value',choice);  % Direction choice coincides in menu.
      set(handles.maxScorrRngEdit,'String',num2str(covExpST(choice).sMaxCorrRange));
      set(handles.maxTcorrRngEdit,'String',num2str(covExpST(choice).tMaxCorrRange));
      set(handles.sLagNumberSlider,'Value',covExpST(choice).sLagsNumber);
      set(handles.tLagNumberSlider,'Value',covExpST(choice).tLagsNumber);
      set(handles.sLagNumberEdit,'String',...
      num2str(get(handles.sLagNumberSlider,'Value')));
      set(handles.tLagNumberEdit,'String',...
      num2str(get(handles.tLagNumberSlider,'Value')));
      dataPts = [covExpST(choice).sCovDistance(:),...
                 covExpST(choice).tCovDistance(:),...
                 covExpST(choice).experimCov(:)];
      surf(covExpST(choice).sCovDistance,...
           covExpST(choice).tCovDistance,covExpST(choice).experimCov);
      hold on
      hCov = plot3(dataPts(:,1),dataPts(:,2),dataPts(:,3),'m<');
      hold off
      view(viewAzim,viewElev)
      cmap = hot; cmap = cmap(end:-1:1,:); colormap(cmap);
      maxSdistance = max(max(covExpST(choice).sCovDistance));
      maxTdistance = max(max(covExpST(choice).tCovDistance));
      %axis image;
      axis([0 maxSdistance 0 maxTdistance min(min(covExpST(choice).experimCov))...
                                     1.05*max(max(covExpST(choice).experimCov))]);
      if thisVersion<7
        legend(hCov,[covExpST(choice).anisotropyString ' Empirical']);
      else
        legend(hCov,[covExpST(choice).anisotropyString ' Empirical'],'Location','Northeast');
      end
      xlabel('S-lag (in s-units)');
      ylabel('T-lag (in t-units)');
      zlabel('Covariance');
      displayString = 'Displaying plots for available data';
      set(handles.feedbackEdit,'String',displayString);
    elseif ~covExpST(1).dirOk && ~covExpST(2).dirOk && covExpST(3).dirOk
      if get(handles.extFigureBox,'Value')   % Separate figure or not?
        axes(handles.covarianceAxes)
        image(imread('guiResources/ithinkPic.png'));
        axis image
        axis off
        figure;
      else
        axes(handles.covarianceAxes)
      end  
      choice = 3;
      set(handles.anisotropyMenu,'Value',choice);  % Direction choice coincides in menu.
      set(handles.maxScorrRngEdit,'String',num2str(covExpST(choice).sMaxCorrRange));
      set(handles.maxTcorrRngEdit,'String',num2str(covExpST(choice).tMaxCorrRange));
      set(handles.sLagNumberSlider,'Value',covExpST(choice).sLagsNumber);
      set(handles.tLagNumberSlider,'Value',covExpST(choice).tLagsNumber);
      set(handles.sLagNumberEdit,'String',...
      num2str(get(handles.sLagNumberSlider,'Value')));
      set(handles.tLagNumberEdit,'String',...
      num2str(get(handles.tLagNumberSlider,'Value')));
      dataPts = [covExpST(choice).sCovDistance(:),...
                 covExpST(choice).tCovDistance(:),...
                 covExpST(choice).experimCov(:)];
      surf(covExpST(choice).sCovDistance,...
           covExpST(choice).tCovDistance,covExpST(choice).experimCov);
      hold on
      hCov = plot3(dataPts(:,1),dataPts(:,2),dataPts(:,3),'m^');
      hold off
      view(viewAzim,viewElev)
      cmap = hot; cmap = cmap(end:-1:1,:); colormap(cmap);
      maxSdistance = max(max(covExpST(choice).sCovDistance));
      maxTdistance = max(max(covExpST(choice).tCovDistance));
      %axis image;
      axis([0 maxSdistance 0 maxTdistance min(min(covExpST(choice).experimCov))...
                                     1.05*max(max(covExpST(choice).experimCov))]);
      if thisVersion<7
        legend(hCov,[covExpST(choice).anisotropyString ' Empirical']);
      else
        legend(hCov,[covExpST(choice).anisotropyString ' Empirical'],'Location','Northeast');
      end
      xlabel('S-lag (in s-units)');
      ylabel('T-lag (in t-units)');
      zlabel('Covariance');
      displayString = 'Displaying plots for available data';
      set(handles.feedbackEdit,'String',displayString);
    elseif covExpST(1).dirOk && covExpST(2).dirOk && ~covExpST(3).dirOk
      maxSdistance1 = max(max(covExpST(1).sCovDistance));
      maxSdistance2 = max(max(covExpST(2).sCovDistance));
      maxSdistance = max(maxSdistance1,maxSdistance2);
      maxTdistance1 = max(max(covExpST(1).tCovDistance));
      maxTdistance2 = max(max(covExpST(2).tCovDistance));
      maxTdistance = max(maxTdistance1,maxTdistance2);
      minCov1 = min(min(covExpST(1).experimCov));
      minCov2 = min(min(covExpST(2).experimCov));
      minCov  = min(minCov1,minCov2);
      maxCov1 = max(max(covExpST(1).experimCov));
      maxCov2 = max(max(covExpST(2).experimCov));
      maxCov  = max(maxCov1,maxCov2);
      if get(handles.extFigureBox,'Value')   % Separate figure or not?
        axes(handles.covarianceAxes)
        image(imread('guiResources/ithinkPic.png'));
        axis image
        axis off
        figure;
      else
        axes(handles.covarianceAxes)
      end  
      choice = 1;
      set(handles.anisotropyMenu,'Value',choice);  % Direction choice coincides in menu.
      set(handles.maxScorrRngEdit,'String',num2str(covExpST(choice).sMaxCorrRange));
      set(handles.maxTcorrRngEdit,'String',num2str(covExpST(choice).tMaxCorrRange));
      set(handles.sLagNumberSlider,'Value',covExpST(choice).sLagsNumber);
      set(handles.tLagNumberSlider,'Value',covExpST(choice).tLagsNumber);
      set(handles.sLagNumberEdit,'String',...
      num2str(get(handles.sLagNumberSlider,'Value')));
      set(handles.tLagNumberEdit,'String',...
      num2str(get(handles.tLagNumberSlider,'Value')));

      dataPts = [covExpST(1).sCovDistance(:),...
                 covExpST(1).tCovDistance(:),...
                 covExpST(1).experimCov(:)];
      hCov1 = plot3(dataPts(:,1),dataPts(:,2),dataPts(:,3),'ro');
      hold on
      dataPts = [covExpST(2).sCovDistance(:),...
                 covExpST(2).tCovDistance(:),...
                 covExpST(2).experimCov(:)];
      hCov2 = plot3(dataPts(:,1),dataPts(:,2),dataPts(:,3),'m<');
      hold off
      view(viewAzim,viewElev)
      %axis image;
      axis([0 maxSdistance 0 maxTdistance minCov 1.05*maxCov]);
      if thisVersion<7
        legend([hCov1,hCov2],[covExpST(1).anisotropyString ' Empirical'],...
                           [covExpST(2).anisotropyString ' Empirical']);
      else
        legend([hCov1,hCov2],[covExpST(1).anisotropyString ' Empirical'],...
                           [covExpST(2).anisotropyString ' Empirical'],...
                           'Location','Northeast');
      end
      xlabel('S-lag (in s-units)');
      ylabel('T-lag (in t-units)');
      zlabel('Covariance');
      displayString = 'Displaying plots for available data';
      set(handles.feedbackEdit,'String',displayString);
    elseif covExpST(1).dirOk && ~covExpST(2).dirOk && covExpST(3).dirOk
      maxSdistance1 = max(max(covExpST(1).sCovDistance));
      maxSdistance3 = max(max(covExpST(3).sCovDistance));
      maxSdistance = max(maxSdistance1,maxSdistance3);
      maxTdistance1 = max(max(covExpST(1).tCovDistance));
      maxTdistance3 = max(max(covExpST(3).tCovDistance));
      maxTdistance = max(maxTdistance1,maxTdistance3);
      minCov1 = min(min(covExpST(1).experimCov));
      minCov3 = min(min(covExpST(3).experimCov));
      minCov  = min(minCov1,minCov3);
      maxCov1 = max(max(covExpST(1).experimCov));
      maxCov3 = max(max(covExpST(3).experimCov));
      maxCov  = max(maxCov1,maxCov3);
      if get(handles.extFigureBox,'Value')   % Separate figure or not?
        axes(handles.covarianceAxes)
        image(imread('guiResources/ithinkPic.png'));
        axis image
        axis off
        figure;
      else
        axes(handles.covarianceAxes)
      end  
      choice = 1;
      set(handles.anisotropyMenu,'Value',choice);  % Direction choice coincides in menu.
      set(handles.maxScorrRngEdit,'String',num2str(covExpST(choice).sMaxCorrRange));
      set(handles.maxTcorrRngEdit,'String',num2str(covExpST(choice).tMaxCorrRange));
      set(handles.sLagNumberSlider,'Value',covExpST(choice).sLagsNumber);
      set(handles.tLagNumberSlider,'Value',covExpST(choice).tLagsNumber);
      set(handles.sLagNumberEdit,'String',...
      num2str(get(handles.sLagNumberSlider,'Value')));
      set(handles.tLagNumberEdit,'String',...
      num2str(get(handles.tLagNumberSlider,'Value')));

      dataPts = [covExpST(1).sCovDistance(:),...
                 covExpST(1).tCovDistance(:),...
                 covExpST(1).experimCov(:)];
      hCov1 = plot3(dataPts(:,1),dataPts(:,2),dataPts(:,3),'ro');
      hold on
      dataPts = [covExpST(3).sCovDistance(:),...
                 covExpST(3).tCovDistance(:),...
                 covExpST(3).experimCov(:)];
      hCov3 = plot3(dataPts(:,1),dataPts(:,2),dataPts(:,3),'m^');
      hold off
      view(viewAzim,viewElev)
      %axis image;
      axis([0 maxSdistance 0 maxTdistance minCov 1.05*maxCov]);
      if thisVersion<7
        legend([hCov1,hCov2],[covExpST(1).anisotropyString ' Empirical'],...
                             [covExpST(3).anisotropyString ' Empirical']);
      else
        legend([hCov1,hCov2],[covExpST(1).anisotropyString ' Empirical'],...
                             [covExpST(3).anisotropyString ' Empirical'],...
                             'Location','Northeast');
      end
      xlabel('S-lag (in s-units)');
      ylabel('T-lag (in t-units)');
      zlabel('Covariance');
      displayString = 'Displaying plots for available data';
      set(handles.feedbackEdit,'String',displayString);
    elseif ~covExpST(1).dirOk && covExpST(2).dirOk && covExpST(3).dirOk
      maxSdistance2 = max(max(covExpST(2).sCovDistance));
      maxSdistance3 = max(max(covExpST(3).sCovDistance));
      maxSdistance = max(maxSdistance2,maxSdistance3);
      maxTdistance2 = max(max(covExpST(2).tCovDistance));
      maxTdistance3 = max(max(covExpST(3).tCovDistance));
      maxTdistance = max(maxTdistance2,maxTdistance3);
      minCov2 = min(min(covExpST(2).experimCov));
      minCov3 = min(min(covExpST(3).experimCov));
      minCov  = min(minCov2,minCov3);
      maxCov2 = max(max(covExpST(2).experimCov));
      maxCov3 = max(max(covExpST(3).experimCov));
      maxCov  = max(maxCov2,maxCov3);
      if get(handles.extFigureBox,'Value')   % Separate figure or not?
        axes(handles.covarianceAxes)
        image(imread('guiResources/ithinkPic.png'));
        axis image
        axis off
        figure;
      else
        axes(handles.covarianceAxes)
      end  
      choice = 2;
      set(handles.anisotropyMenu,'Value',choice);  % Direction choice coincides in menu.
      set(handles.maxScorrRngEdit,'String',num2str(covExpST(choice).sMaxCorrRange));
      set(handles.maxTcorrRngEdit,'String',num2str(covExpST(choice).tMaxCorrRange));
      set(handles.sLagNumberSlider,'Value',covExpST(choice).sLagsNumber);
      set(handles.tLagNumberSlider,'Value',covExpST(choice).tLagsNumber);
      set(handles.sLagNumberEdit,'String',...
      num2str(get(handles.sLagNumberSlider,'Value')));
      set(handles.tLagNumberEdit,'String',...
      num2str(get(handles.tLagNumberSlider,'Value')));

      dataPts = [covExpST(2).sCovDistance(:),...
                 covExpST(2).tCovDistance(:),...
                 covExpST(2).experimCov(:)];
      hCov2 = plot3(dataPts(:,1),dataPts(:,2),dataPts(:,3),'m<');
      hold on
      dataPts = [covExpST(3).sCovDistance(:),...
                 covExpST(3).tCovDistance(:),...
                 covExpST(3).experimCov(:)];
      hCov3 = plot3(dataPts(:,1),dataPts(:,2),dataPts(:,3),'m^');
      hold off
      view(viewAzim,viewElev)
      %axis image;
      axis([0 maxSdistance 0 maxTdistance minCov 1.05*maxCov]);
      if thisVersion<7
        legend([hCov1,hCov2],[covExpST(2).anisotropyString ' Empirical'],...
                             [covExpST(3).anisotropyString ' Empirical']);
      else
        legend([hCov1,hCov2],[covExpST(2).anisotropyString ' Empirical'],...
                             [covExpST(3).anisotropyString ' Empirical'],...
                             'Location','Northeast');
      end
      xlabel('S-lag (in s-units)');
      ylabel('T-lag (in t-units)');
      zlabel('Covariance');
      displayString = 'Displaying plots for available data';
      set(handles.feedbackEdit,'String',displayString);
    elseif covExpST(1).dirOk && covExpST(2).dirOk && covExpST(3).dirOk
      maxSdistance1 = max(max(covExpST(1).sCovDistance));
      maxSdistance2 = max(max(covExpST(2).sCovDistance));
      maxSdistance3 = max(max(covExpST(3).sCovDistance));
      maxSdistance = max([maxSdistance1 maxSdistance2 maxSdistance3]);
      maxTdistance1 = max(max(covExpST(1).tCovDistance));
      maxTdistance2 = max(max(covExpST(2).tCovDistance));
      maxTdistance3 = max(max(covExpST(3).tCovDistance));
      maxTdistance = max([maxTdistance1 maxTdistance2 maxTdistance3]);
      minCov1 = min(min(covExpST(1).experimCov));
      minCov2 = min(min(covExpST(2).experimCov));
      minCov3 = min(min(covExpST(3).experimCov));
      minCov  = min([minCov1 minCov2 minCov3]);
      maxCov1 = max(max(covExpST(1).experimCov));
      maxCov2 = max(max(covExpST(2).experimCov));
      maxCov3 = max(max(covExpST(3).experimCov));
      maxCov  = max([maxCov1 maxCov2 maxCov3]);
      if get(handles.extFigureBox,'Value')   % Separate figure or not?
        axes(handles.covarianceAxes)
        image(imread('guiResources/ithinkPic.png'));
        axis image
        axis off
        figure;
      else
        axes(handles.covarianceAxes)
      end  
      choice = 1;
      set(handles.anisotropyMenu,'Value',choice);  % Direction choice coincides in menu.
      set(handles.maxScorrRngEdit,'String',num2str(covExpST(choice).sMaxCorrRange));
      set(handles.maxTcorrRngEdit,'String',num2str(covExpST(choice).tMaxCorrRange));
      set(handles.sLagNumberSlider,'Value',covExpST(choice).sLagsNumber);
      set(handles.tLagNumberSlider,'Value',covExpST(choice).tLagsNumber);
      set(handles.sLagNumberEdit,'String',...
      num2str(get(handles.sLagNumberSlider,'Value')));
      set(handles.tLagNumberEdit,'String',...
      num2str(get(handles.tLagNumberSlider,'Value')));

      dataPts = [covExpST(1).sCovDistance(:),...
                 covExpST(1).tCovDistance(:),...
                 covExpST(1).experimCov(:)];
      hCov1 = plot3(dataPts(:,1),dataPts(:,2),dataPts(:,3),'ro');
      hold on
      dataPts = [covExpST(2).sCovDistance(:),...
                 covExpST(2).tCovDistance(:),...
                 covExpST(2).experimCov(:)];
      hCov2 = plot3(dataPts(:,1),dataPts(:,2),dataPts(:,3),'m<');
      hold on
      dataPts = [covExpST(3).sCovDistance(:),...
                 covExpST(3).tCovDistance(:),...
                 covExpST(3).experimCov(:)];
      hCov3 = plot3(dataPts(:,1),dataPts(:,2),dataPts(:,3),'m^');
      hold off
      view(viewAzim,viewElev)
      %axis image;
      axis([0 maxSdistance 0 maxTdistance minCov 1.05*maxCov]);
      if thisVersion<7
        legend([hCov1,hCov2,hCov3],[covExpST(1).anisotropyString ' Empirical'],...
                                   [covExpST(2).anisotropyString ' Empirical'],...
                                   [covExpST(3).anisotropyString ' Empirical']);
      else
        legend([hCov1,hCov2,hCov3],[covExpST(1).anisotropyString ' Empirical'],...
                                   [covExpST(2).anisotropyString ' Empirical'],...
                                   [covExpST(3).anisotropyString ' Empirical'],...
                                   'Location','Northeast');
      end
      xlabel('S-lag (in s-units)');
      ylabel('T-lag (in t-units)');
      zlabel('Covariance');
      displayString = 'Displaying plots for available data';
      set(handles.feedbackEdit,'String',displayString);
    else
      displayString = 'No data available for any plot';
      set(handles.feedbackEdit,'String',displayString);
      axes(handles.covarianceAxes)
      image(imread('guiResources/ithinkPic.png'));
      axis image
      axis off
    end
  case 5     % Displays empirical covariances in all-dir at s=0.
    choice = 1;
    if covExpST(choice).dirOk  % If choice info already stored
      if get(handles.extFigureBox,'Value')   % Separate figure or not?
        axes(handles.covarianceAxes)
        image(imread('guiResources/ithinkPic.png'));
        axis image
        axis off
        figure;
      else
        axes(handles.covarianceAxes)
      end  
      set(handles.anisotropyMenu,'Value',choice);  % Direction choice coincides in menu.
      displayString = 'Plotting stored data for this choice';
      set(handles.maxScorrRngEdit,'String',num2str(covExpST(choice).sMaxCorrRange));
      set(handles.maxTcorrRngEdit,'String',num2str(covExpST(choice).tMaxCorrRange));
      set(handles.sLagNumberSlider,'Value',covExpST(choice).sLagsNumber);
      set(handles.tLagNumberSlider,'Value',covExpST(choice).tLagsNumber);
      set(handles.sLagNumberEdit,'String',...
      num2str(get(handles.sLagNumberSlider,'Value')));
      set(handles.tLagNumberEdit,'String',...
      num2str(get(handles.tLagNumberSlider,'Value')));
    
      
       
      hCov = plot(covExpST(choice).tCovDistance(1,:),...
                  covExpST(choice).experimCov(1,:),'ro');
                
      hold on;
      
      fewidx=find(covExpST(choice).pairsNumber(1,:)<30);
      if ~isempty(fewidx)
        plot(covExpST(choice).tCovDistance(1,fewidx),...
             covExpST(choice).experimCov(1,fewidx),'ro','MarkerFaceColor','k'); 
      end;      
        
      hold off
      if thisVersion<7
        legend(hCov,[covExpST(choice).anisotropyString ' at lag s=0']);
      else
        legend(hCov,[covExpST(choice).anisotropyString ' at lag s=0'],'Location','Northeast');
      end
      xlabel('T-lag (in t-units)');
      ylabel('Covariance');
    else
      displayString = 'Data not available for this choice';
      set(handles.feedbackEdit,'String',displayString);
      axes(handles.covarianceAxes)
      image(imread('guiResources/ithinkPic.png'));
      axis image
      axis off
    end
  case 6     % Displays empirical covariances in E-W at s=0.
    choice = 2;
    if covExpST(choice).dirOk  % If choice info already stored
      if get(handles.extFigureBox,'Value')   % Separate figure or not?
        axes(handles.covarianceAxes)
        image(imread('guiResources/ithinkPic.png'));
        axis image
        axis off
        figure;
      else
        axes(handles.covarianceAxes)
      end  
      set(handles.anisotropyMenu,'Value',choice);  % Direction choice coincides in menu.
      displayString = 'Plotting stored data for this choice';
      set(handles.maxScorrRngEdit,'String',num2str(covExpST(choice).sMaxCorrRange));
      set(handles.maxTcorrRngEdit,'String',num2str(covExpST(choice).tMaxCorrRange));
      set(handles.sLagNumberSlider,'Value',covExpST(choice).sLagsNumber);
      set(handles.tLagNumberSlider,'Value',covExpST(choice).tLagsNumber);
      set(handles.sLagNumberEdit,'String',...
      num2str(get(handles.sLagNumberSlider,'Value')));
      set(handles.tLagNumberEdit,'String',...
      num2str(get(handles.tLagNumberSlider,'Value')));
    
       
      hCov = plot(covExpST(choice).tCovDistance(1,:),...
                  covExpST(choice).experimCov(1,:),'m<');
                
      hold on;
                
      fewidx=find(covExpST(choice).pairsNumber(1,:)<30);
      if ~isempty(fewidx)
        plot(covExpST(choice).tCovDistance(1,fewidx),...
             covExpST(choice).experimCov(1,fewidx),'m<','MarkerFaceColor','k'); 
      end;      
                
      hold off
      if thisVersion<7
        legend(hCov,[covExpST(choice).anisotropyString ' at lag s=0']);
      else
        legend(hCov,[covExpST(choice).anisotropyString ' at lag s=0'],'Location','Northeast');
      end
      xlabel('T-lag (in t-units)');
      ylabel('Covariance');
    else
      displayString = 'Data not available for this choice';
      set(handles.feedbackEdit,'String',displayString);
      axes(handles.covarianceAxes)
      image(imread('guiResources/ithinkPic.png'));
      axis image
      axis off
    end
  case 7     % Displays empirical covariances in N-S at s=0.
    choice = 3;
    if covExpST(choice).dirOk  % If choice info already stored
      if get(handles.extFigureBox,'Value')   % Separate figure or not?
        axes(handles.covarianceAxes)
        image(imread('guiResources/ithinkPic.png'));
        axis image
        axis off
        figure;
      else
        axes(handles.covarianceAxes)
      end  
      set(handles.anisotropyMenu,'Value',choice);  % Direction choice coincides in menu.
      displayString = 'Plotting stored data for this choice';
      set(handles.maxScorrRngEdit,'String',num2str(covExpST(choice).sMaxCorrRange));
      set(handles.maxTcorrRngEdit,'String',num2str(covExpST(choice).tMaxCorrRange));
      set(handles.sLagNumberSlider,'Value',covExpST(choice).sLagsNumber);
      set(handles.tLagNumberSlider,'Value',covExpST(choice).tLagsNumber);
      set(handles.sLagNumberEdit,'String',...
      num2str(get(handles.sLagNumberSlider,'Value')));
      set(handles.tLagNumberEdit,'String',...
      num2str(get(handles.tLagNumberSlider,'Value')));
       
      hCov = plot(covExpST(choice).tCovDistance(1,:),...
                  covExpST(choice).experimCov(1,:),'m^');
                
      hold on;          
                
      fewidx=find(covExpST(choice).pairsNumber(1,:)<30);
      if ~isempty(fewidx)
        plot(covExpST(choice).tCovDistance(1,fewidx),...
             covExpST(choice).experimCov(1,fewidx),'m^','MarkerFaceColor','k'); 
      end;      
      
      hold off
      if thisVersion<7
        legend(hCov,[covExpST(choice).anisotropyString ' at lag s=0']);
      else
        legend(hCov,[covExpST(choice).anisotropyString ' at lag s=0'],'Location','Northeast');
      end
      xlabel('T-lag (in t-units)');
      ylabel('Covariance');
    else
      displayString = 'Data not available for this choice';
      set(handles.feedbackEdit,'String',displayString);
      axes(handles.covarianceAxes)
      image(imread('guiResources/ithinkPic.png'));
      axis image
      axis off
    end
  case 8     % Displays empirical covariances in all-dir at t=0.
    choice = 1;
    if covExpST(choice).dirOk  % If choice info already stored
      if get(handles.extFigureBox,'Value')   % Separate figure or not?
        axes(handles.covarianceAxes)
        image(imread('guiResources/ithinkPic.png'));
        axis image
        axis off
        figure;
      else
        axes(handles.covarianceAxes)
      end  
      set(handles.anisotropyMenu,'Value',choice);  % Direction choice coincides in menu.
      displayString = 'Plotting stored data for this choice';
      set(handles.maxScorrRngEdit,'String',num2str(covExpST(choice).sMaxCorrRange));
      set(handles.maxTcorrRngEdit,'String',num2str(covExpST(choice).tMaxCorrRange));
      set(handles.sLagNumberSlider,'Value',covExpST(choice).sLagsNumber);
      set(handles.tLagNumberSlider,'Value',covExpST(choice).tLagsNumber);
      set(handles.sLagNumberEdit,'String',...
      num2str(get(handles.sLagNumberSlider,'Value')));
      set(handles.tLagNumberEdit,'String',...
      num2str(get(handles.tLagNumberSlider,'Value')));
       
      hCov = plot(covExpST(choice).sCovDistance(:,1),...
                  covExpST(choice).experimCov(:,1),'ro');
      
      hold on;          
                
      fewidx=find(covExpST(choice).pairsNumber(:,1)<30);
      if ~isempty(fewidx)
        plot(covExpST(choice).sCovDistance(fewidx,1),...
             covExpST(choice).experimCov(fewidx,1),'ro','MarkerFaceColor','k'); 
      end;                
                
      hold off
      if thisVersion<7
        legend(hCov,[covExpST(choice).anisotropyString ' at lag t=0']);
      else
        legend(hCov,[covExpST(choice).anisotropyString ' at lag t=0'],'Location','Northeast');
      end
      xlabel('S-lag (in s-units)');
      ylabel('Covariance');
    else
      displayString = 'Data not available for this choice';
      set(handles.feedbackEdit,'String',displayString);
      axes(handles.covarianceAxes)
      image(imread('guiResources/ithinkPic.png'));
      axis image
      axis off
    end
  case 9     % Displays empirical covariances in E-W at t=0.
    choice = 2;
    if covExpST(choice).dirOk  % If choice info already stored
      if get(handles.extFigureBox,'Value')   % Separate figure or not?
        axes(handles.covarianceAxes)
        image(imread('guiResources/ithinkPic.png'));
        axis image
        axis off
        figure;
      else
        axes(handles.covarianceAxes)
      end  
      set(handles.anisotropyMenu,'Value',choice);  % Direction choice coincides in menu.
      displayString = 'Plotting stored data for this choice';
      set(handles.maxScorrRngEdit,'String',num2str(covExpST(choice).sMaxCorrRange));
      set(handles.maxTcorrRngEdit,'String',num2str(covExpST(choice).tMaxCorrRange));
      set(handles.sLagNumberSlider,'Value',covExpST(choice).sLagsNumber);
      set(handles.tLagNumberSlider,'Value',covExpST(choice).tLagsNumber);
      set(handles.sLagNumberEdit,'String',...
      num2str(get(handles.sLagNumberSlider,'Value')));
      set(handles.tLagNumberEdit,'String',...
      num2str(get(handles.tLagNumberSlider,'Value')));
       
      hCov = plot(covExpST(choice).sCovDistance(:,1),...
                  covExpST(choice).experimCov(:,1),'m<');
      hold on;          
                
      fewidx=find(covExpST(choice).pairsNumber(:,1)<30);
      if ~isempty(fewidx)
        plot(covExpST(choice).sCovDistance(fewidx,1),...
             covExpST(choice).experimCov(fewidx,1),'m<','MarkerFaceColor','k'); 
      end;                        
                
      hold off
      if thisVersion<7
        legend(hCov,[covExpST(choice).anisotropyString ' at lag t=0']);
      else
        legend(hCov,[covExpST(choice).anisotropyString ' at lag t=0'],'Location','Northeast');
      end
      xlabel('S-lag (in s-units)');
      ylabel('Covariance');
    else
      displayString = 'Data not available for this choice';
      set(handles.feedbackEdit,'String',displayString);
      axes(handles.covarianceAxes)
      image(imread('guiResources/ithinkPic.png'));
      axis image
      axis off
    end
  case 10    % Displays empirical covariances in N-S at t=0.
    choice = 3;
    if covExpST(choice).dirOk  % If choice info already stored
      if get(handles.extFigureBox,'Value')   % Separate figure or not?
        axes(handles.covarianceAxes)
        image(imread('guiResources/ithinkPic.png'));
        axis image
        axis off
        figure;
      else
        axes(handles.covarianceAxes)
      end  
      set(handles.anisotropyMenu,'Value',choice);  % Direction choice coincides in menu.
      displayString = 'Plotting stored data for this choice';
      set(handles.maxScorrRngEdit,'String',num2str(covExpST(choice).sMaxCorrRange));
      set(handles.maxTcorrRngEdit,'String',num2str(covExpST(choice).tMaxCorrRange));
      set(handles.sLagNumberSlider,'Value',covExpST(choice).sLagsNumber);
      set(handles.tLagNumberSlider,'Value',covExpST(choice).tLagsNumber);
      set(handles.sLagNumberEdit,'String',...
      num2str(get(handles.sLagNumberSlider,'Value')));
      set(handles.tLagNumberEdit,'String',...
      num2str(get(handles.tLagNumberSlider,'Value')));
       
      hCov = plot(covExpST(choice).sCovDistance(:,1),...
                  covExpST(choice).experimCov(:,1),'m^');
      hold on;                
                
      fewidx=find(covExpST(choice).pairsNumber(:,1)<30);
      if ~isempty(fewidx)
        plot(covExpST(choice).sCovDistance(fewidx,1),...
             covExpST(choice).experimCov(fewidx,1),'m^','MarkerFaceColor','k'); 
      end;                        
                
                
      hold off
      if thisVersion<7
        legend(hCov,[covExpST(choice).anisotropyString ' at lag t=0']);
      else
        legend(hCov,[covExpST(choice).anisotropyString ' at lag t=0'],'Location','Northeast');
      end
      xlabel('S-lag (in s-units)');
      ylabel('Covariance');
    else
      displayString = 'Data not available for this choice';
      set(handles.feedbackEdit,'String',displayString);
      axes(handles.covarianceAxes)
      image(imread('guiResources/ithinkPic.png'));
      axis image
      axis off
    end
end

else   %%% Plot options for spatial-only study

  switch choice

    case 1     % Displays empirical all-directional spatial covariance
      if covExpST(choice).dirOk  % If choice info already stored
        if get(handles.extFigureBox,'Value')   % Separate figure or not?
          axes(handles.covarianceAxes)
          image(imread('guiResources/ithinkPic.png'));
          axis image
          axis off
          figure;
        else
          axes(handles.covarianceAxes)
        end 
        set(handles.anisotropyMenu,'Value',choice);  % Direction choice coincides in menu.
        displayString = 'Plotting stored data for this choice';
        set(handles.feedbackEdit,'String',displayString);
        set(handles.maxScorrRngEdit,'String',num2str(covExpST(choice).sMaxCorrRange));
        set(handles.sLagNumberSlider,'Value',covExpST(choice).sLagsNumber);
        set(handles.sLagNumberEdit,'String',...
            num2str(get(handles.sLagNumberSlider,'Value')));       
        hCov = plot([covExpST(choice).sCovDistance'],...
                    [covExpST(choice).experimCov'],'ro');
        hold off
        if thisVersion<7
          legend(hCov,[covExpST(choice).anisotropyString ' Empirical']);
        else
          legend(hCov,[covExpST(choice).anisotropyString ' Empirical'],'Location','Northeast');
        end
        xlabel('Lag (in s-units)');
        ylabel('Covariance');
      else
        displayString = 'Data not available for this choice';
        set(handles.feedbackEdit,'String',displayString);
        axes(handles.covarianceAxes)
        image(imread('guiResources/ithinkPic.png'));
        axis image
        axis off
      end

    case 2     % Displays empirical E-W spatial covariance
      if covExpST(choice).dirOk  % If choice info already stored
        if get(handles.extFigureBox,'Value')   % Separate figure or not?
          axes(handles.covarianceAxes)
          image(imread('guiResources/ithinkPic.png'));
          axis image
          axis off
          figure;
        else
          axes(handles.covarianceAxes)
        end 
        set(handles.anisotropyMenu,'Value',choice);  % Direction choice coincides in menu.
        displayString = 'Plotting stored data for this choice';
        set(handles.feedbackEdit,'String',displayString);
        set(handles.maxScorrRngEdit,'String',num2str(covExpST(choice).sMaxCorrRange));
        set(handles.sLagNumberSlider,'Value',covExpST(choice).sLagsNumber);
        set(handles.sLagNumberEdit,'String',...
            num2str(get(handles.sLagNumberSlider,'Value')));       
        hCov = plot([covExpST(choice).sCovDistance'],...
                    [covExpST(choice).experimCov'],'m<');
        if thisVersion<7
          legend(hCov,[covExpST(choice).anisotropyString ' Empirical']);
        else
          legend(hCov,[covExpST(choice).anisotropyString ' Empirical'],'Location','Northeast');
        end
        xlabel('Lag (in s-units)');
        ylabel('Covariance');
      else
        displayString = 'Data not available for this choice';
        set(handles.feedbackEdit,'String',displayString);
        axes(handles.covarianceAxes)
        image(imread('guiResources/ithinkPic.png'));
        axis image
        axis off
      end
      
    case 3     % Displays empirical N-S spatial covariance
      if covExpST(choice).dirOk  % If choice info already stored
        if get(handles.extFigureBox,'Value')   % Separate figure or not?
          axes(handles.covarianceAxes)
          image(imread('guiResources/ithinkPic.png'));
          axis image
          axis off
          figure;
        else
          axes(handles.covarianceAxes)
        end 
        set(handles.anisotropyMenu,'Value',choice);  % Direction choice coincides in menu.
        displayString = 'Plotting stored data for this choice';
        set(handles.feedbackEdit,'String',displayString);
        set(handles.maxScorrRngEdit,'String',num2str(covExpST(choice).sMaxCorrRange));
        set(handles.sLagNumberSlider,'Value',covExpST(choice).sLagsNumber);
        set(handles.sLagNumberEdit,'String',...
            num2str(get(handles.sLagNumberSlider,'Value')));       
        hCov = plot([covExpST(choice).sCovDistance'],...
                    [covExpST(choice).experimCov'],'m^');
        if thisVersion<7
          legend(hCov,[covExpST(choice).anisotropyString ' Empirical']);
        else
          legend(hCov,[covExpST(choice).anisotropyString ' Empirical'],'Location','Northeast');
        end
        xlabel('Lag (in s-units)');
        ylabel('Covariance');
      else
        displayString = 'Data not available for this choice';
        set(handles.feedbackEdit,'String',displayString);
        axes(handles.covarianceAxes)
        image(imread('guiResources/ithinkPic.png'));
        axis image
        axis off
      end

    case 4     % Displays all empirical spatial covariances
      if covExpST(1).dirOk && ~covExpST(2).dirOk && ~covExpST(3).dirOk
        if get(handles.extFigureBox,'Value')   % Separate figure or not?
          axes(handles.covarianceAxes)
          image(imread('guiResources/ithinkPic.png'));
          axis image
          axis off
          figure;
        else
          axes(handles.covarianceAxes)
        end 
        choice = 1;
        set(handles.anisotropyMenu,'Value',choice);  % Direction choice coincides in menu.
        set(handles.maxScorrRngEdit,'String',num2str(covExpST(choice).sMaxCorrRange));
        set(handles.sLagNumberSlider,'Value',covExpST(choice).sLagsNumber);
        set(handles.sLagNumberEdit,'String',...
          num2str(get(handles.sLagNumberSlider,'Value')));
        hCov1 = plot([covExpST(1).sCovDistance'],...
                     [covExpST(1).experimCov'],'ro');
        if thisVersion<7
          legend(hCov1,[covExpST(1).anisotropyString ' Empirical']);
        else
          legend(hCov1,[covExpST(1).anisotropyString ' Empirical'],'Location','Northeast');
        end
        xlabel('Lag (in s-units)');
        ylabel('Covariance');
        displayString = 'Displaying plots for available data';
        set(handles.feedbackEdit,'String',displayString);
      elseif ~covExpST(1).dirOk && covExpST(2).dirOk && ~covExpST(3).dirOk
        if get(handles.extFigureBox,'Value')   % Separate figure or not?
          axes(handles.covarianceAxes)
          image(imread('guiResources/ithinkPic.png'));
          axis image
          axis off
          figure;
        else
          axes(handles.covarianceAxes)
        end 
        choice = 2;
        set(handles.anisotropyMenu,'Value',choice);  % Direction choice coincides in menu.
        set(handles.maxScorrRngEdit,'String',num2str(covExpST(choice).sMaxCorrRange));
        set(handles.sLagNumberSlider,'Value',covExpST(choice).sLagsNumber);
        set(handles.sLagNumberEdit,'String',...
          num2str(get(handles.sLagNumberSlider,'Value')));
        hCov2 = plot([covExpST(2).sCovDistance'],...
                     [covExpST(2).experimCov'],'m<');
        if thisVersion<7
          legend(hCov2,[covExpST(2).anisotropyString ' Empirical']);
        else
          legend(hCov2,[covExpST(2).anisotropyString ' Empirical'],'Location','Northeast');
        end
        xlabel('Lag (in s-units)');
        ylabel('Covariance');
        displayString = 'Displaying plots for available data';
        set(handles.feedbackEdit,'String',displayString);
      elseif ~covExpST(1).dirOk && ~covExpST(2).dirOk && covExpST(3).dirOk
        if get(handles.extFigureBox,'Value')   % Separate figure or not?
          axes(handles.covarianceAxes)
          image(imread('guiResources/ithinkPic.png'));
          axis image
          axis off
          figure;
        else
          axes(handles.covarianceAxes)
        end 
        choice = 3;
        set(handles.anisotropyMenu,'Value',choice);  % Direction choice coincides in menu.
        set(handles.maxScorrRngEdit,'String',num2str(covExpST(choice).sMaxCorrRange));
        set(handles.sLagNumberSlider,'Value',covExpST(choice).sLagsNumber);
        set(handles.sLagNumberEdit,'String',...
          num2str(get(handles.sLagNumberSlider,'Value')));
        hCov3 = plot([covExpST(3).sCovDistance'],...
                     [covExpST(3).experimCov'],'m^');
        if thisVersion<7
          legend(hCov3,[covExpST(3).anisotropyString ' Empirical']);
        else
          legend(hCov3,[covExpST(3).anisotropyString ' Empirical'],'Location','Northeast');
        end
        xlabel('Lag (in s-units)');
        ylabel('Covariance');
        displayString = 'Displaying plots for available data';
        set(handles.feedbackEdit,'String',displayString);
      elseif covExpST(1).dirOk && covExpST(2).dirOk && ~covExpST(3).dirOk
        if get(handles.extFigureBox,'Value')   % Separate figure or not?
          axes(handles.covarianceAxes)
          image(imread('guiResources/ithinkPic.png'));
          axis image
          axis off
          figure;
        else
          axes(handles.covarianceAxes)
        end 
        choice = 1;
        set(handles.anisotropyMenu,'Value',choice);  % Direction choice coincides in menu.
        set(handles.maxScorrRngEdit,'String',num2str(covExpST(choice).sMaxCorrRange));
        set(handles.sLagNumberSlider,'Value',covExpST(choice).sLagsNumber);
        set(handles.sLagNumberEdit,'String',...
          num2str(get(handles.sLagNumberSlider,'Value')));
        hCov1 = plot([covExpST(1).sCovDistance'],...
                     [covExpST(1).experimCov'],'ro');
        hold on;
        hCov2 = plot([covExpST(2).sCovDistance'],...
                     [covExpST(2).experimCov'],'m<');
        hold off;
        if thisVersion<7
          legend([hCov1,hCov2],[covExpST(1).anisotropyString ' Empirical'],...
                               [covExpST(2).anisotropyString ' Empirical']);
        else
          legend([hCov1,hCov2],[covExpST(1).anisotropyString ' Empirical'],...
                               [covExpST(2).anisotropyString ' Empirical'],...
                             'Location','Northeast');
        end
        xlabel('Lag (in s-units)');
        ylabel('Covariance');
        displayString = 'Displaying plots for available data';
        set(handles.feedbackEdit,'String',displayString);
      elseif covExpST(1).dirOk && ~covExpST(2).dirOk && covExpST(3).dirOk
        if get(handles.extFigureBox,'Value')   % Separate figure or not?
          axes(handles.covarianceAxes)
          image(imread('guiResources/ithinkPic.png'));
          axis image
          axis off
          figure;
        else
          axes(handles.covarianceAxes)
        end 
        choice = 1;
        set(handles.anisotropyMenu,'Value',choice);  % Direction choice coincides in menu.
        set(handles.maxScorrRngEdit,'String',num2str(covExpST(choice).sMaxCorrRange));
        set(handles.sLagNumberSlider,'Value',covExpST(choice).sLagsNumber);
        set(handles.sLagNumberEdit,'String',...
          num2str(get(handles.sLagNumberSlider,'Value')));
        hCov1 = plot([covExpST(1).sCovDistance'],...
                     [covExpST(1).experimCov'],'ro');
        hold on;
        hCov3 = plot([covExpST(3).sCovDistance'],...
                     [covExpST(3).experimCov'],'m^');
        hold off;
        if thisVersion<7
          legend([hCov1,hCov3],[covExpST(1).anisotropyString ' Empirical'],...
                               [covExpST(3).anisotropyString ' Empirical']);
        else
          legend([hCov1,hCov3],[covExpST(1).anisotropyString ' Empirical'],...
                               [covExpST(3).anisotropyString ' Empirical'],...
                               'Location','Northeast');
        end
        xlabel('Lag (in s-units)');
        ylabel('Covariance');
        displayString = 'Displaying plots for available data';
        set(handles.feedbackEdit,'String',displayString);
      elseif ~covExpST(1).dirOk && covExpST(2).dirOk && covExpST(3).dirOk
        if get(handles.extFigureBox,'Value')   % Separate figure or not?
          axes(handles.covarianceAxes)
          image(imread('guiResources/ithinkPic.png'));
          axis image
          axis off
          figure;
        else
          axes(handles.covarianceAxes)
        end 
        choice = 2;
        set(handles.anisotropyMenu,'Value',choice);  % Direction choice coincides in menu.
        set(handles.maxScorrRngEdit,'String',num2str(covExpST(choice).sMaxCorrRange));
        set(handles.sLagNumberSlider,'Value',covExpST(choice).sLagsNumber);
        set(handles.sLagNumberEdit,'String',...
          num2str(get(handles.sLagNumberSlider,'Value')));
        hCov2 = plot([covExpST(2).sCovDistance'],...
                     [covExpST(2).experimCov'],'m<');
        hold on;
        hCov3 = plot([covExpST(3).sCovDistance'],...
                     [covExpST(3).experimCov'],'m^');
        hold off;
        if thisVersion<7
          legend([hCov2,hCov3],[covExpST(2).anisotropyString ' Empirical'],...
                               [covExpST(3).anisotropyString ' Empirical']);
        else
          legend([hCov2,hCov3],[covExpST(2).anisotropyString ' Empirical'],...
                               [covExpST(3).anisotropyString ' Empirical'],...
                               'Location','Northeast');
        end
        xlabel('Lag (in s-units)');
        ylabel('Covariance');
        displayString = 'Displaying plots for available data';
        set(handles.feedbackEdit,'String',displayString);
      elseif covExpST(1).dirOk && covExpST(2).dirOk && covExpST(3).dirOk
        if get(handles.extFigureBox,'Value')   % Separate figure or not?
          axes(handles.covarianceAxes)
          image(imread('guiResources/ithinkPic.png'));
          axis image
          axis off
          figure;
        else
          axes(handles.covarianceAxes)
        end 
        choice = 1;
        set(handles.anisotropyMenu,'Value',choice);  % Direction choice coincides in menu.
        set(handles.maxScorrRngEdit,'String',num2str(covExpST(choice).sMaxCorrRange));
        set(handles.sLagNumberSlider,'Value',covExpST(choice).sLagsNumber);
        set(handles.sLagNumberEdit,'String',...
          num2str(get(handles.sLagNumberSlider,'Value')));
        hCov1 = plot([covExpST(1).sCovDistance'],...
                     [covExpST(1).experimCov'],'ro');
        hold on;
        hCov2 = plot([covExpST(2).sCovDistance'],...
                     [covExpST(2).experimCov'],'m<');
        hold on;
        hCov3 = plot([covExpST(3).sCovDistance'],...
                     [covExpST(3).experimCov'],'m^');
        hold off;
        if thisVersion<7
          legend([hCov1,hCov2,hCov3],[covExpST(1).anisotropyString ' Empirical'],...
                                     [covExpST(2).anisotropyString ' Empirical'],...
                                     [covExpST(3).anisotropyString ' Empirical']);
        else
          legend([hCov1,hCov2,hCov3],[covExpST(1).anisotropyString ' Empirical'],...
                                     [covExpST(2).anisotropyString ' Empirical'],...
                                     [covExpST(3).anisotropyString ' Empirical'],...
                                     'Location','Northeast');
        end
        xlabel('Lag (in s-units)');
        ylabel('Covariance');
        displayString = 'Displaying plots for available data';
        set(handles.feedbackEdit,'String',displayString);
      else
        displayString = 'No data available for any plot';
        set(handles.feedbackEdit,'String',displayString);
        axes(handles.covarianceAxes)
        image(imread('guiResources/ithinkPic.png'));
        axis image
        axis off
      end

    case 5     % Displays empirical covariances in all-dir at s=0.
      displayString = 'This plot request applies only in the space-time case';
      set(handles.feedbackEdit,'String',displayString);
    case 6     % Displays empirical covariances in E-W at s=0.
      displayString = 'This plot request applies only in the space-time case';
      set(handles.feedbackEdit,'String',displayString);
    case 7     % Displays empirical covariances in N-S at s=0.
      displayString = 'This plot request applies only in the space-time case';
      set(handles.feedbackEdit,'String',displayString);
    case 8     % Displays empirical covariances in all-dir at t=0.
      displayString = 'This plot request applies only in the space-time case';
      set(handles.feedbackEdit,'String',displayString);
    case 9     % Displays empirical covariances in E-W at t=0.     
      displayString = 'This plot request applies only in the space-time case';
      set(handles.feedbackEdit,'String',displayString);
    case 10    % Displays empirical covariances in N-S at t=0.
      displayString = 'This plot request applies only in the space-time case';
      set(handles.feedbackEdit,'String',displayString);
  end

end   %%% END IF timePresent





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
  displayString = 'Plots to follow will display in separate windows';
  set(handles.feedbackEdit,'String',displayString);
        
else

  set(handles.extFigureBox,'Value',0);
  prevExtFigState = 0;
  displayString = 'Plots to follow will display in this window';
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
ip304p3TexplorAnal('Title','Exploratory Analysis');  % ...and procede to the previous unit.




% --- Executes on button press in nextButton.
function nextButton_Callback(hObject, eventdata, handles)
% hObject    handle to nextButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global covModelS covParamS
global maxCorrRangeS lagsNumberS lagsLimitsS
global covExpST
global displayString

if (covExpST(1).dirOk || covExpST(2).dirOk || covExpST(3).dirOk)
  delete(handles.figure1);                              % Close current window...
    ip305p2TcovarAnal('Title','Covariance Analysis');    % ...and procede to following screen.
else
  errordlg({'No empirical covariance information present.';...
           'This information will be necessary in the following step';...
           'in order to construct appropriate covariance models';...
           'for the estimation stage. Please load that information';...
           'or use the "Get Empirical" button above.'},...
           'Can not proceed further');
end
