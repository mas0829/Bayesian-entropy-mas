function varargout = ip302p3HsoftDataWiz(varargin)
%IP302P3HSOFTDATAWIZ M-file for ip302p3HsoftDataWiz.fig
%      IP302P3HSOFTDATAWIZ, by itself, creates a new IP302P3HSOFTDATAWIZ or raises the existing
%      singleton*.
%
%      H = IP302P3HSOFTDATAWIZ returns the handle to a new IP302P3HSOFTDATAWIZ or the handle to
%      the existing singleton*.
%
%      IP302P3HSOFTDATAWIZ('Property','Value',...) creates a new IP302P3HSOFTDATAWIZ using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to ip302p3HsoftDataWiz_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      IP302P3HSOFTDATAWIZ('CALLBACK') and IP302P3HSOFTDATAWIZ('CALLBACK',hObject,...) call the
%      local function named CALLBACK in IP302P3HSOFTDATAWIZ.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ip302p3HsoftDataWiz

% Last Modified by GUIDE v2.5 29-Nov-2005 09:05:31

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ip302p3HsoftDataWiz_OpeningFcn, ...
                   'gui_OutputFcn',  @ip302p3HsoftDataWiz_OutputFcn, ...
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


% --- Executes just before ip302p3HsoftDataWiz is made visible.
function ip302p3HsoftDataWiz_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

% Choose default command line output for ip302p3HsoftDataWiz
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

% UIWAIT makes ip302p3HsoftDataWiz wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% Create soft data types pictures
axes(handles.sdAsoftHaxes)
image(imread('guiResources/soft7ex1.png'));
axis off
axes(handles.sdBsoftHaxes)
image(imread('guiResources/soft7ex2.png'));
axis off



% --- Outputs from this function are returned to the command line.
function varargout = ip302p3HsoftDataWiz_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;





% PRELIMINARY SETTINGS
%
global sdFilename

% Are we returning to the soft data wizard?  Check if a soft data file 
% has been chosen and display the name or the proper message in the box.
%
if ~ischar(sdFilename)
    set(handles.fileChoiceEdit,'String','No Soft Data file present');
else
    set(handles.fileChoiceEdit,'String',sdFilename);
end





% --- Executes on button press in unifMomentsButton.
function unifMomentsButton_Callback(hObject, eventdata, handles)
% hObject    handle to unifMomentsButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of unifMomentsButton
global uniformDistDataType

set(handles.unifMomentsButton, 'Value', 1); 
set(handles.unifLimitsButton, 'Value', 0); 
uniformDistDataType = 1;





% --- Executes on button press in unifLimitsButton.
function unifLimitsButton_Callback(hObject, eventdata, handles)
% hObject    handle to unifLimitsButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of unifLimitsButton
global uniformDistDataType

set(handles.unifMomentsButton, 'Value', 0); 
set(handles.unifLimitsButton, 'Value', 1); 
uniformDistDataType = 2;





function fileChoiceEdit_Callback(hObject, eventdata, handles)
% hObject    handle to fileChoiceEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fileChoiceEdit as text
%        str2double(get(hObject,'String')) returns contents of fileChoiceEdit as a double
global sdFilename

if ~ischar(sdFilename)
    set(handles.fileChoiceEdit,'String','No Soft Data file present');
    return
else
    set(handles.fileChoiceEdit,'String',sdFilename);
end





% --- Executes during object creation, after setting all properties.
function fileChoiceEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fileChoiceEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





% --- Executes on button press in getDataPushbutton.
function getDataPushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to getDataPushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

getSoftData(handles);

% global sdFilename sdPathname;
% 
% [sdFilename,sdPathname] = uigetfile({'*.txt';'*.xls'},'Select Soft Data file');
% %
% % If user presses 'Cancel' then 0 is returned.
% % Should anything go wrong, we use the following criterion
% %
% if ~ischar(sdFilename)
%     set(handles.fileChoiceEdit,'String','No Soft Data file present');
%     return
% else
%     set(handles.fileChoiceEdit,'String',sdFilename);
% end





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

delete(handles.figure1);                       % Close the current window
ip302p1softDataWiz('Title','Soft Data Wizard'); % ...and procede to the following screen.





% --- Executes on button press in nextButton.
function nextButton_Callback(hObject, eventdata, handles)
% hObject    handle to nextButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global cs sdFilename csInitDim

if ~ischar(sdFilename)  % If the user has not provided a soft data file
    errordlg({'Please provide a Soft Data file to continue!';...
              'If you do not wish to include soft data in your study,';...
              'then please use the ''Back'' button and in the previous screen';...
              'proceed without choosing any type of Soft Data.'},...
              'No Soft Data information given!')  
else % There is a filename provided for soft data input. Continue appropriately
    softDataPresent = 1;
    allOk = ip302p3HsoftDataFunction(handles);            
    if allOk
        csInitDim = size(cs,1);     % Store the original soft data set size
        delete(handles.figure1);    % Close the current window
        ip303outputGridWiz('Title','Output Configuration');
    end
end





function [allOk] = ip302p3HsoftDataFunction(handles)
% At this point the user has provided a file containing the Soft Data.
% The format has been hopefully followed as instructed in the wizard,
% and some basic checks are made while reading the file for conformity. 
% This function prepares the material necessary for BMElib to run.
%
global sdFilename sdPathname totalCoordinatesUsed
global softpdftype cs nl limi probdens

% Uniform distribution data will end up being treated as interval SD, therefore:
softpdftype = 2;                % BMELIB parameter based on current (1) SD type

initialDir = pwd;               % Save the current directory path
cd (sdPathname);                % Go where the SD file resides

nCoords = totalCoordinatesUsed; % Use a handy name
idxcoord = 1:nCoords;           % Indices of the coordinates values in a line
linenumber = 0;
is = 0;
tempval = [];
gausSDmean = NaN;
gausSDvari = NaN;
problemFlag = 0;

if isempty(xlsfinfo(sdFilename))  % If it is not Excel format, expect an ASCII file

  fid = fopen(sdFilename,'r');    % Check if the file can be opened
  if fid==-1
    fclose('all');
    cd (initialDir);
    errordlg(['Problem opening file ' sdFilename],...
      'Data file error!');
  end

  while ~feof(fid)                % Start reading the file to its end
    str = fgetl(fid);             % Get one line at a time
    linenumber = linenumber+1;    % Keep track of the line number itself
    if str~=-1                    % If this is not the end of line
      tempval = sscanf(str,'%g'); % Store the line contents into individual values
      nTempval = size(tempval,1);       % Number of values in the current line
      % The number of values to be read in this line must be equal to the sum of:
      % (# of coordinates)+(3 numbers with PDF mode and limits)
      expectednTempval = nCoords + 3;
      if nTempval~=expectednTempval     % If line contains unexpected number of values
        cd (initialDir);
        errordlg({['Line ' num2str(linenumber) ' in your Soft Data file'];...
             ['has ' num2str(nTempval) ' values, whereas '...
             num2str(expectednTempval) ' are expected.'];,...
             'Please check your Soft Data input again.'},...
             'Data file error!');
        allOk = 0;
        break;
      else                              % If line contains expected number of values
        is=is+1;                        % Keep track of the SD entries
        for iCo=1:nCoords               % Pre-R.14 versions show error if not in loop
          cs(is,iCo) = tempval(iCo);    % Read datum coordinates
        end
        curr = nCoords+1;               % Index of element we are about to read
        nl(is,1) = 3;                   % BMELIB nl parameter: Number of limits
        limi(is,1) = tempval(curr);     % BMELIB limi: Lower limit of triangular PDF
        limi(is,2) = tempval(curr+1);   % BMELIB limi: Position of mode for triang PDF
        limi(is,3) = tempval(curr+2);   % BMELIB limi: Upper limit of triangular PDF
        probdens(is,1) = 0;                          % BMELIB probadens: At lower limit
        probdens(is,2) = 2/(limi(is,3) - limi(is,1));% BMELIB probadens: At mode
        probdens(is,3) = 0;                          % BMELIB probadens: At upper limit
        allOk = 1;
        if isinf(probdens(is,2))        % If the denominator is zero...
          errordlg({['In line ' num2str(linenumber) ' in your Soft Data file'];...
                 'the interval lower and upper limit values coincide.';,...
                 'Please revise your data and use only non-zero sized intervals.'},...
                 'Data file error!');
          allOk = 0;
          break;                        % Exit loop if there is discrepancy
        end
        if probdens(is,2)<0
          errordlg({['In line ' num2str(linenumber) ' in your Soft Data file'];...
                 'the interval limits seem to have been inserted in the inverse order.';,...
                 'Please revise your data and ensure the lower limits precede the upper ones.'},...
                 'Data file error!');
          allOk = 0;
          break;                        % Exit loop if there is discrepancy
        end
      end
    end
  end
  
  st = fclose(fid);
  if st==-1,
    fclose('all');
    cd (initialDir);
    errordlg(['Could close properly file ' sdFilename],...
             'Data file error!');
  end;
  
else                              % If it is an Excel file, read data accordingly
  
  [sdVal,sdValname] = xlsread(sdFilename);
  for is=1:size(cs,1)                 % For each line in the file
    % Reading an Excel file produces an array whose columns are equal to the
    % file line that has the maximum columns. Each line fills any empty spaces
    % till the max column number with NaNs. For the current line "is" the 
    % following command stores temporarily all its non-NaN contents in "tempval".
    linenumber = linenumber+1;        % Keep track of the line number itself
    tempval = sdVal(is,isfinite(sdVal(is,:)));     % Grab contents of current line
    nTempval = size(tempval,2);       % Number of values in the current line
    % The number of values to be read in this line must be equal to the sum of:
    % (# of coordinates)+(3 numbers with PDF mode and limits)
    expectednTempval = nCoords + 3;
    if nTempval~=expectednTempval % If line contains unexpected number of values
      cd (initialDir);
      errordlg({['Line ' num2str(linenumber) ' in your Soft Data file'];...
           ['has ' num2str(nTempval) ' values, whereas '...
           num2str(expectednTempval) ' are expected.'];,...
           'Please check your Soft Data input again.'},...
           'Data file error!');
      allOk = 0;
      break;
    else
      for iCo=1:nCoords               % Pre-R.14 versions show error if not in loop
        cs(is,iCo) = tempval(iCo);    % Read datum coordinates
      end
      curr = nCoords+1;               % Index of element we are about to read
      nl(is,1) = 3;                   % BMELIB nl parameter: Number of limits
      limi(is,1) = tempval(curr);     % BMELIB limi: Lower limit of triangular PDF
      limi(is,2) = tempval(curr+1);   % BMELIB limi: Position of mode for triang PDF
      limi(is,3) = tempval(curr+2);   % BMELIB limi: Upper limit of triangular PDF
      probdens(is,1) = 0;                          % BMELIB probadens: At lower limit
      probdens(is,2) = 2/(limi(is,3) - limi(is,1));% BMELIB probadens: At mode
      probdens(is,3) = 0;                          % BMELIB probadens: At upper limit
      allOk = 1;
      if isinf(probdens(is,2))        % If the denominator is zero...
        errordlg({['In line ' num2str(linenumber) ' in your Soft Data file'];...
                 'the interval lower and upper limit values coincide.';,...
                 'Please revise your data and use only non-zero sized intervals.'},...
                 'Data file error!');
        allOk = 0;
        break;                        % Exit loop if there is discrepancy
      end
      if probdens(is,2)<0
        errordlg({['In line ' num2str(linenumber) ' in your Soft Data file'];...
                 'the interval limits seem to have been inserted in the inverse order.';,...
                 'Please revise your data and ensure the lower limits precede the upper ones.'},...
                 'Data file error!');
        allOk = 0;
        break;                        % Exit loop if there is discrepancy
      end
    end
  end
  
end

if linenumber==0       % No lines read. This is an empty file  
    warndlg({'The Soft Data file you provided is empty';...
            'Please check your input file again.'},...
            'Empty Soft Data file!');
    allOk = 0;
    %cs = zeros(0,totalCoordinatesUsed);  % Settings for HD only study
    %softpdftype = 1;
    %nl = zeros(0,1);
    %limi = zeros(0,1);
    %probdens = zeros(0,1);
end;
 
cd (initialDir)             % Finally, return to where this function was evoked from

%softpdftype     % For testing purposes
%cs
%nl
%limi
%probdens
