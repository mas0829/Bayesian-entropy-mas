function varargout = ip001splashScreen(varargin)
% IP001SPLASHSCREEN M-file for ip001splashScreen.fig
%      IP001SPLASHSCREEN, by itself, creates a new IP001SPLASHSCREEN or raises the existing
%      singleton*.
%
%      H = IP001SPLASHSCREEN returns the handle to a new IP001SPLASHSCREEN or the handle to
%      the existing singleton*.
%
%      IP001SPLASHSCREEN('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in IP001SPLASHSCREEN.M with the given input arguments.
%
%      IP001SPLASHSCREEN('Property','Value',...) creates a new IP001SPLASHSCREEN or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ip001splashScreen_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ip001splashScreen_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Copyright 2002-2003 The MathWorks, Inc.

% Edit the above text to modify the response to help ip001splashScreen

% Last Modified by GUIDE v2.5 10-May-2011 23:31:40

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ip001splashScreen_OpeningFcn, ...
                   'gui_OutputFcn',  @ip001splashScreen_OutputFcn, ...
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


% --- Executes just before ip001splashScreen is made visible.
function ip001splashScreen_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ip001splashScreen (see VARARGIN)

% Choose default command line output for ip001splashScreen
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

% UIWAIT makes ip001splashScreen wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% Create Thinker picture
axes(handles.splashScrFig_axes)
image(imread('guiResources/ithinkPic.png'));
axis off

% --- Outputs from this function are returned to the command line.
function varargout = ip001splashScreen_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

pause(4);                                      % Display the splash screen for given seconds
delete(handles.figure1);                       % Then close the splash window...
ip002chooseTask('Title','Choose a Task');      % ...and procede to the following screen.
