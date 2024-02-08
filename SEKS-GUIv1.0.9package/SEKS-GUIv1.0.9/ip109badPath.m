function varargout = ip109badPath(varargin)
% IP109BADPATH MATLAB code for ip109badPath.fig
%      IP109BADPATH, by itself, creates a new IP109BADPATH or raises the existing
%      singleton*.
%
%      H = IP109BADPATH returns the handle to a new IP109BADPATH or the handle to
%      the existing singleton*.
%
%      IP109BADPATH('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in IP109BADPATH.M with the given input arguments.
%
%      IP109BADPATH('Property','Value',...) creates a new IP109BADPATH or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ip109badPath_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ip109badPath_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ip109badPath

% Last Modified by GUIDE v2.5 23-Jun-2011 00:51:47

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ip109badPath_OpeningFcn, ...
                   'gui_OutputFcn',  @ip109badPath_OutputFcn, ...
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


% --- Executes just before ip109badPath is made visible.
function ip109badPath_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ip109badPath (see VARARGIN)

% Choose default command line output for ip109badPath
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ip109badPath wait for user response (see UIRESUME)
% uiwait(handles.figure1);
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


% --- Outputs from this function are returned to the command line.
function varargout = ip109badPath_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in okButton.
function okButton_Callback(hObject, eventdata, handles)
% hObject    handle to okButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
delete(handles.figure1)
