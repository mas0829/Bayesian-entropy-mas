function varargout = ip002chooseTask(varargin)
% IP002CHOOSETASK M-file for ip002chooseTask.fig
%      IP002CHOOSETASK, by itself, creates a new IP002CHOOSETASK or raises the existing
%      singleton*.
%
%      H = IP002CHOOSETASK returns the handle to a new IP002CHOOSETASK or the handle to
%      the existing singleton*.
%
%      IP002CHOOSETASK('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in IP002CHOOSETASK.M with the given input arguments.
%
%      IP002CHOOSETASK('Property','Value',...) creates a new IP002CHOOSETASK or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ip002chooseTask_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ip002chooseTask_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Copyright 2002-2003 The MathWorks, Inc.

% Edit the above text to modify the response to help ip002chooseTask

% Last Modified by GUIDE v2.5 22-Jul-2005 10:21:33

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ip002chooseTask_OpeningFcn, ...
                   'gui_OutputFcn',  @ip002chooseTask_OutputFcn, ...
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


% --- Executes just before ip002chooseTask is made visible.
function ip002chooseTask_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ip002chooseTask (see VARARGIN)

% Choose default command line output for ip002chooseTask
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

% UIWAIT makes ip002chooseTask wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = ip002chooseTask_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;




% PRELIMINARY SETTINGS
%
% Create Thinker picture
axes(handles.iThinkPic_axes)
image(imread('guiResources/ithinkPic.png'));
axis off
%
% Reset figures counter
global figId
figId = 0;




% --- Executes during object creation, after setting all properties.
function tasksListbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tasksListbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on selection change in tasksListbox.
function tasksListbox_Callback(hObject, eventdata, handles)
% hObject    handle to tasksListbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns tasksListbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from tasksListbox




function [taskIndex,taskName] = getTask(handles)
% Returns the names of the two variables to plot
list_entries = get(handles.tasksListbox,'String');
index_selected = get(handles.tasksListbox,'Value');
if length(index_selected) ~= 1
    errordlg('You must select only one task','Incorrect Selection','modal')
else
    taskIndex = index_selected(1);
    taskName = list_entries{index_selected(1)};
end 




% --- Executes on button press in acceptButton.
function acceptButton_Callback(hObject, eventdata, handles)
% hObject    handle to acceptButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global cameFromMainMenu
global bmeMod bmeMom bmePdf bmeCin
global KSprocessType

bmeMod = cell(5,1);     % Initialize cell array of BME Mode output.
bmeMod{1,1} = [0];      % Indicator that estimation has not taken place.
bmeMom = cell(7,1);     % Initialize cell array of BME Moments output.
bmeMom{1,1} = [0];      % Indicator that estimation has not taken place.
bmePdf = cell(9,1);     % Initialize cell array of BME PDF output.
bmePdf{1,1} = [0];      % Indicator that estimation has not taken place.
bmeCin = cell(12,1);    % Initialize cell array of BME CI output.
bmeCin{1,1} = [0];      % Indicator that estimation has not taken place.

% The value of the following indicator is to be changed only when the user asks
% to go straight to the visualization screen. This is for the GUI to know that
% there are no data available from visits to prior screens.
cameFromMainMenu = 0;   % Initialize.
 
[taskIndex,taskName] = getTask(handles);
switch taskIndex
  case 1 % Perform full BME analysis
    KSprocessType = 1;        % Signifies BMElib processing
    delete(handles.figure1);
    ip301p1hardDataWiz('Title','Hard Data Wizard');
  case 2
    KSprocessType = 0;        % No processing
    cameFromMainMenu = 1;
    delete(handles.figure1);
    ip307v1Tvisuals('Title','Visualization Wizard');    
  case 3
    ip201helpMain('Title','BMElib Help')
  case 4
    warndlg({'You asked for a task that has not been yet implemented in SeksGUI.';,...
             'To run this task, please use the Matlab command line,';...
             'and check again in a coming version of the GUI implementation.';...
             'Thank you for using the SEKS Graphic User Interface!'},...
             'Feature unavailable yet')
  otherwise
    errordlg({'ip002chooseTask.m:acceptButton_Callback Function:';...
              'The switch commands detected more options';...
              'than currently available (7) in the Listbox.'},...
              'GUI software Error')
end
    



% --- Executes on button press in aboutButton.
function aboutButton_Callback(hObject, eventdata, handles)
% hObject    handle to aboutButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

user_response = ip000about('Title','About SEKS-GUI');
switch lower(user_response)
case 'yes'
	delete(handles.figure1)
end
   


% --- Executes on button press in exitButton.
function exitButton_Callback(hObject, eventdata, handles)
% hObject    handle to exitButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

user_response = ip101exitDialog('Title','Confirm Exit');
switch lower(user_response)
case 'no'
	% take no action
case 'yes'
	delete(handles.figure1)
end
