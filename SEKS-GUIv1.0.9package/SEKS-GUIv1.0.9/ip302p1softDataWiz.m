function varargout = ip302p1softDataWiz(varargin)
%IP302p1SOFTDATAWIZ M-file for ip302p1softDataWiz.fig
%      IP302p1SOFTDATAWIZ, by itself, creates a new IP302p1SOFTDATAWIZ or raises the existing
%      singleton*.
%
%      H = IP302p1SOFTDATAWIZ returns the handle to a new IP302p1SOFTDATAWIZ or the handle to
%      the existing singleton*.
%
%      IP302p1SOFTDATAWIZ('Property','Value',...) creates a new IP3021SOFTDATAWIZ using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to ip3021softDataWiz_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      IP302p1SOFTDATAWIZ('CALLBACK') and IP302p1SOFTDATAWIZ('CALLBACK',hObject,...) call the
%      local function named CALLBACK in IP302p1SOFTDATAWIZ.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ip302p1softDataWiz

% Last Modified by GUIDE v2.5 13-May-2011 22:44:14

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ip302p1softDataWiz_OpeningFcn, ...
                   'gui_OutputFcn',  @ip302p1softDataWiz_OutputFcn, ...
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


% --- Executes just before ip3021softDataWiz is made visible.
function ip302p1softDataWiz_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

% Choose default command line output for ip302p1softDataWiz
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

% UIWAIT makes ip302p1softDataWiz wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% Create soft data types pictures
axes(handles.softAaxes)
image(imread('guiResources/soft0interval.png'));
axis off
axes(handles.softBaxes)
image(imread('guiResources/soft1histIrregGrid.png'));
axis off
axes(handles.softCaxes)
image(imread('guiResources/soft2linearIrregGrid.png'));
axis off
axes(handles.softDaxes)
image(imread('guiResources/soft3histRegGrid.png'));
axis off
axes(handles.softEaxes)
image(imread('guiResources/soft4linearRegGrid.png'));
axis off




% PRELIMINARY SETTINGS
%
% Begin with the ASCII input file selection as default
global sdCategory
global minTsoft maxTsoft
global csAtInstance


sdCategory = 0;
set(handles.sdTypeSelectionMenu,'Value',1);

minTsoft = [];         % Initialize earliest time we have SD. To be used later
maxTsoft = [];         % Initialize latest time we have SD. To be used later
csAtInstance = [];     % Initialize cell array to hold SD loci of same time instance





% --- Executes on selection change in sdTypeSelectionMenu.
function sdTypeSelectionMenu_Callback(hObject, eventdata, handles)
% hObject    handle to sdTypeSelectionMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns sdTypeSelectionMenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from sdTypeSelectionMenu
global sdCategory

% This variable is also used in ip304p2explorAnal.m
switch get(handles.sdTypeSelectionMenu,'Value')
  case 1               % Do nothing; not a valid choice for SD
    sdCategory = 0;
  case 2               % SD are Normal distributions
    sdCategory = 1;   
  case 3               % SD are Uniform distributions
    sdCategory = 2;   
  case 4               % SD are Triangular distributions
    sdCategory = 3;   
  case 5               % SD are Intervals       
    sdCategory = 4;   
  case 6               % SD are Histograms      
    sdCategory = 5;   
  case 7               % SD are Linear
    sdCategory = 6;   
  case 8               % SD are Histograms on a normal grid 
    sdCategory = 7;   
  case 9               % SD are Linear on a normal grid 
    sdCategory = 8;   
end





% --- Executes during object creation, after setting all properties.
function sdTypeSelectionMenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sdTypeSelectionMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Outputs from this function are returned to the command line.
function varargout = ip302p1softDataWiz_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;




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
ip301p1hardDataWiz('Title','Hard Data Wizard'); % ...and procede to the following screen.




% --- Executes on button press in nextButton.
function nextButton_Callback(hObject, eventdata, handles)
% hObject    handle to nextButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global hardDataPresent softDataPresent sdCategory sdFilename
global softpdftype cs nl limi probdens

if sdCategory
    softDataPresent = 1;
    delete(handles.figure1);    % Close the current window
    if hardDataPresent
      switch sdCategory
        case 1
            ip302p3FsoftDataWiz('Title','Soft Data Wizard - Normal PDF');
        case 2
            ip302p3GsoftDataWiz('Title','Soft Data Wizard - Uniform PDF');
        case 3
            ip302p3HsoftDataWiz('Title','Soft Data Wizard - Triangular PDF');
        case 4
            ip302p3AsoftDataWiz('Title','Soft Data Wizard - Interval');       
        case 5
            ip302p3BsoftDataWiz('Title','Soft Data Wizard - Histogram PDF');
        case 6
            ip302p3CsoftDataWiz('Title','Soft Data Wizard - Linear PDF');
        case 7
            ip302p3DsoftDataWiz('Title','Soft Data Wizard - Histogram Regular Grid PDF');
        case 8
            ip302p3EsoftDataWiz('Title','Soft Data Wizard - Linear Regular Grid PDF');
        otherwise
            errordlg({'ip302p1softDataWiz:nextButton_Callback:';...
              'A choice for soft data type has been provided';...
              'but the corresponding sdCategory does not have an acceptable value';...
              ['within 1,...,5 here. sdCategory=' num2str(sdCategory)]},...
              'SEKS-GUI software Error')
      end
    else
        ip302p2softDataWiz('Title','Soft Data Wizard');
    end
else   % No soft data provided. If returning and choices have previously been made:
    softDataPresent = 0;
    sdCategory = 0;
    sdFilename = '';
    softpdftype = 1;         % Required by BMElib. If left as empty, error will occur.
    cs = [];
    nl = [];
    limi = [];
    probdens = [];
    % At this point, if no soft data are provided, the user:
    % 1) Either has provided hard data and wants to perform a kriging study
    % 2) Or has not even provided hard data, so prompt the user for an action
    if hardDataPresent
        delete(handles.figure1);    % Close the current window
        ip303outputGridWiz('Title','Output Configuration');
    else
        delete(handles.figure1);    % Close the current window
        ip100noData('Title','No Data Provided');
    end
end
