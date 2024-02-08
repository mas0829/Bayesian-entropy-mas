function varargout = ip100noData(varargin)
%IP100NODATA M-file for ip100noData.fig
%      IP100NODATA, by itself, creates a new IP100NODATA or raises the existing
%      singleton*.
%
%      H = IP100NODATA returns the handle to a new IP100NODATA or the handle to
%      the existing singleton*.
%
%      IP100NODATA('Property','Value',...) creates a new IP100NODATA using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to ip100noData_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      IP100NODATA('CALLBACK') and IP100NODATA('CALLBACK',hObject,...) call the
%      local function named CALLBACK in IP100NODATA.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ip100noData

% Last Modified by GUIDE v2.5 11-May-2011 01:17:45

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ip100noData_OpeningFcn, ...
                   'gui_OutputFcn',  @ip100noData_OutputFcn, ...
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


% --- Executes just before ip100noData is made visible.
function ip100noData_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

% Choose default command line output for ip100noData
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

% UIWAIT makes ip100noData wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% Create Thinker picture
axes(handles.iThinkPic_axes)
image(imread('guiResources/ithinkPic.png'));
axis off



% --- Outputs from this function are returned to the command line.
function varargout = ip100noData_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in taskMenuButton.
function taskMenuButton_Callback(hObject, eventdata, handles)
% hObject    handle to taskMenuButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

delete(handles.figure1)
ip002chooseTask('Title','Choose a Task');


% --- Executes on button press in helpButton.
function helpButton_Callback(hObject, eventdata, handles)
% hObject    handle to helpButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

ip201helpMain('Title','BMElib Help')



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
