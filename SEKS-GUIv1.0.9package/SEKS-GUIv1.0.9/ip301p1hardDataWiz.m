function varargout = ip301p1hardDataWiz(varargin)
% IP301P1HARDDATAWIZ M-file for ip301p1hardDataWiz.fig
%      IP301P1HARDDATAWIZ, by itself, creates a new IP301P1HARDDATAWIZ or raises the existing
%      singleton*.
%
%      H = IP301P1HARDDATAWIZ returns the handle to a new IP301P1HARDDATAWIZ or the handle to
%      the existing singleton*.
%
%      IP301P1HARDDATAWIZ('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in IP301P1HARDDATAWIZ.M with the given input arguments.
%
%      IP301P1HARDDATAWIZ('Property','Value',...) creates a new IP301P1HARDDATAWIZ or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ip301p1hardDataWiz_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ip301p1hardDataWiz_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Copyright 2002-2003 The MathWorks, Inc.

% Edit the above text to modify the response to help ip301p1hardDataWiz

% Last Modified by GUIDE v2.5 12-May-2011 00:16:28

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ip301p1hardDataWiz_OpeningFcn, ...
                   'gui_OutputFcn',  @ip301p1hardDataWiz_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
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




% --- Executes just before ip301p1hardDataWiz is made visible.
function ip301p1hardDataWiz_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ip301p1hardDataWiz (see VARARGIN)

% Choose default command line output for ip301p1hardDataWiz
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

% UIWAIT makes ip301p1hardDataWiz wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% PRELIMINARY SETTINGS
%
global hardDataPresent timePresent
global hdFileType hdFilename
global minThard maxThard
global chAtInstance zhAtInstance
global initialDir

if isempty(hardDataPresent) % If we have not been in this screen before
  % Defaults: Begin with the ASCII input file selection and Time not present
  set(handles.asciiButton, 'Value', 1); 
  set(handles.geoeasButton, 'Value', 0);
  hdFileType = 1;
  set(handles.timeChoiceCheckbox, 'Value', 0);
  timePresent = 0;
  set(handles.fileChoiceEdit,'String','No Hard Data file present');
else
  if (~hardDataPresent)   % ...or if we have skipped and we are returning...
    % Defaults: Begin with the ASCII input file selection. Check if Time is present
    set(handles.asciiButton, 'Value', 1); 
    set(handles.geoeasButton, 'Value', 0); 
    if timePresent
        set(handles.timeChoiceCheckbox,'Value',0); 
    end
    set(handles.fileChoiceEdit,'String','No Hard Data file present');
  else                    % ...or if we are revisiting this screen
        
    switch hdFileType
      case 1              % Corresponds to ASCII
        set(handles.asciiButton, 'Value', 1); 
        set(handles.excelButton, 'Value', 0); 
        set(handles.geoeasButton, 'Value', 0);
      case 2              % Corresponds to Excel spreadsheet
        set(handles.asciiButton, 'Value', 0); 
        set(handles.excelButton, 'Value', 1); 
        set(handles.geoeasButton, 'Value', 0);
      case 3              % Corresponds to GeoEAS format
        set(handles.asciiButton, 'Value', 0); 
        set(handles.excelButton, 'Value', 0); 
        set(handles.geoeasButton, 'Value', 1);
      otherwise
        errordlg({'ip301p1hardDataWiz:Preliminary settings:';...
                'hdFileType variable is out of range.';...
                'SEKS-GUI software Error'})
    end
    
    if ~ischar(hdFilename)
      set(handles.fileChoiceEdit,'String','No Hard Data file present');
    else
      set(handles.fileChoiceEdit,'String',hdFilename);
    end
       
    if timePresent        % If spatial-only study, box is unchecked
      set(handles.timeChoiceCheckbox,'Value',0); 
    end
    
  end
end

minThard = [];         % Initialize earliest time we have HD. To be used later
maxThard = [];         % Initialize latest time we have HD. To be used later
chAtInstance = [];     % Initialize cell array to hold HD loci of same time instance
zhAtInstance = [];     % Initialize cell array to hold HD of same time instance

timePresent = 1;       % Initialize

initialDir = pwd;

% --- Outputs from this function are returned to the command line.
function varargout = ip301p1hardDataWiz_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;




% --- Executes on button press in asciiButton.
function asciiButton_Callback(hObject, eventdata, handles)
% hObject    handle to asciiButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of asciiButton
global hdFileType

set(handles.asciiButton, 'Value', 1); 
set(handles.excelButton, 'Value', 0); 
set(handles.geoeasButton, 'Value', 0); 
hdFileType = 1;




% --- Executes on button press in excelButton.
function excelButton_Callback(hObject, eventdata, handles)
% hObject    handle to excelButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of excelButton
global hdFileType

set(handles.asciiButton, 'Value', 0); 
set(handles.excelButton, 'Value', 1); 
set(handles.geoeasButton, 'Value', 0); 
hdFileType = 2;





% --- Executes on button press in geoeasButton.
function geoeasButton_Callback(hObject, eventdata, handles)
% hObject    handle to geoeasButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of geoeasButton
global hdFileType

set(handles.asciiButton, 'Value', 0); 
set(handles.excelButton, 'Value', 0); 
set(handles.geoeasButton, 'Value', 1); 
hdFileType = 3;





% --- Executes on button press in getDataPushbutton.
function getDataPushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to getDataPushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global hdFilename hdPathname currentDir;

if get(handles.excelButton,'Value')
  [hdFilename,hdPathname] = uigetfile({'*.xls';'*.txt'},'Select Hard Data file');
else
  [hdFilename,hdPathname] = uigetfile({'*.txt';'*.xls'},'Select Hard Data file');
end;
%
% If user presses 'Cancel' then 0 is returned.
% Should anything go wrong, we use the following criterion
%
if ~ischar(hdFilename)
    set(handles.fileChoiceEdit,'String','No Hard Data file present');
    return
else
    set(handles.fileChoiceEdit,'String',hdFilename);
    currentDir=hdPathname;
end




function fileChoiceEdit_Callback(hObject, eventdata, handles)
% hObject    handle to fileChoiceEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fileChoiceEdit as text
%        str2double(get(hObject,'String')) returns contents of fileChoiceEdit as a double
global hdFilename

if ~ischar(hdFilename)
    set(handles.fileChoiceEdit,'String','No Hard Data file present');
    return
else
    set(handles.fileChoiceEdit,'String',hdFilename);
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




% --- Executes on button press in timeChoiceCheckbox.
function timeChoiceCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to timeChoiceCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of timeChoiceCheckbox
global timePresent

if get(hObject,'Value')   % If box is checked, it's spatial-only study
    timePresent = 0;
else
    timePresent = 1;
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

delete(handles.figure1);                       % Then close the splash window...
ip002chooseTask('Title','Choose a Task');      % ...and procede to the following screen.




% --- Executes on button press in nextButton.
function nextButton_Callback(hObject, eventdata, handles)
% hObject    handle to nextButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global xHdColumn yHdColumn zHdColumn hdColumn
global xHdColumnStr yHdColumnStr zHdColumnStr hdColumnStr
global ch zh
global hdFilename hdPathname hardDataPresent totalCoordinatesUsed timePresent

if ~ischar(hdFilename)  % If the user skips the hard data part
    hardDataPresent = 0;
    totalCoordinatesUsed = 0;
    timePresent = 0;    % Disregard the user potentially playing with the button
    ch = [];
    zh = [];
    delete(handles.figure1);
    ip302p1softDataWiz('Title','Soft Data Wizard');   % Proceed to the next step.
else   % There is a filename provided for hard data input. Continue appropriately
    % disp([xHdColumn yHdColumn zHdColumn hdColumn])     % For testing purposes
    processHardData = 1;  % Provide an initial value and proceed with control tests.
    
    initialDir = pwd;                   % Save the current directory path
    cd (hdPathname);                    % Go where the HD file resides
    % Is the necessary info provided correctly? If not, prompt the user to review
    %
    if ...        %Indication: File does not start with numbers, but is declared as ASCII...
        (isnan(str2double(textread(hdFilename,'%s',1))) && get(handles.asciiButton,'Value'))
        processHardData = 0;
        warndlg({'You declared the hard data file as an ASCII file';...
                'but the contents do not seem to be ASCII text.';,...
                'Please check again your input and continue.'},...
                'Possibly wrong file format!')
    elseif ...    % Indication: ASCII file, and the user declared this as GeoEAS...
        (~isnan(str2double(textread(hdFilename,'%s',1))) && ...  % Contains numbers
        (isempty(xlsfinfo(hdFilename))) && ...                   % Is not Excel
        get(handles.geoeasButton,'Value'))
        processHardData = 0;
        warndlg({'You declared the hard data file as a GeoEAS file.';...
                'It seems that it is an ASCII text file.';,...
                'Please check again your input and continue.'},...
                'Possibly wrong file format!')
    elseif ...    % Indication: Excel file, and the user declared this as GeoEAS...
        (isnan(str2double(textread(hdFilename,'%s',1))) && ...
        (~isempty(xlsfinfo(hdFilename))) && ...
        get(handles.geoeasButton,'Value'))
        processHardData = 0;
        warndlg({'You declared the hard data file as a GeoEAS file.';...
                'It seems that it is an Excel file.';,...
                'Please check again your input and continue.'},...
                'Possibly wrong file format!')
    elseif ...    % Indication: Not an Excel file, and the user declared this as one...
        ((isempty(xlsfinfo(hdFilename))) && ...
        get(handles.excelButton,'Value'))
        processHardData = 0;
        warndlg({'You declared the hard data file as an Excel file';...
                'but the contents do not comply to the format.';,...
                'Please check again your input and continue.'},...
                'Possibly wrong file format!')
    end
    cd (initialDir);                % Return to where this function was evoked from
    
    if processHardData    
        hardDataPresent = 1;
        delete(handles.figure1);
        ip301p2hardDataWiz('Title','Hard Data Wizard');   % Proceed to the next step.
    end
    
end
