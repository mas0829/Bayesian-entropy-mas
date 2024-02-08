function varargout = ip201helpMain(varargin)
% IP201HELPMAIN M-file for ip201helpMain.fig
%      IP201HELPMAIN, by itself, creates a new IP201HELPMAIN or raises the existing
%      singleton*.
%
%      H = IP201HELPMAIN returns the handle to a new IP201HELPMAIN or the handle to
%      the existing singleton*.
%
%      IP201HELPMAIN('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in IP201HELPMAIN.M with the given input arguments.
%
%      IP201HELPMAIN('Property','Value',...) creates a new IP201HELPMAIN or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ip201helpMain_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ip201helpMain_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Copyright 2002-2003 The MathWorks, Inc.

% Edit the above text to modify the response to help ip201helpMain

% Last Modified by GUIDE v2.5 12-May-2011 00:03:28

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ip201helpMain_OpeningFcn, ...
                   'gui_OutputFcn',  @ip201helpMain_OutputFcn, ...
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


% --- Executes just before ip201helpMain is made visible.
function ip201helpMain_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ip201helpMain (see VARARGIN)

% Choose default command line output for ip201helpMain
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

% UIWAIT makes ip201helpMain wait for user response (see UIRESUME)
% uiwait(handles.figure1);



function update_outputListbox(handles,stringToExecute)
%function update_outputListbox(handles)
% 
% Upon being called, it displays on the selected 'outputListbox' listbox
% the Command Window output of the command in string 'stringToExecute'.
%
if ischar(stringToExecute) ~= 1   % Make sure we are bringing a string here
    errordlg('ERROR: ip201helpMain: update_outputListbox: Not a string to process',...
             'Incorrect Selection','modal')
end
vars = evalin('base',stringToExecute);
%set(handles.outputListbox,'String',vars);

% Open a temporary text file to flush into it the text output of the stringToExecute
fid = fopen('trash.txt','w');
fprintf(fid,'%s',vars);
fclose(fid);
% Re-open the file to read its content and display it on the help screen
fid = fopen('trash.txt','r');
i = 1;
while 1
    tline = fgetl(fid);
    if ~ischar(tline), break, end
    strC{i} = tline;
    i = i+1;
end
fclose(fid);
if ~ispc
    !rm trash.txt
end

set(handles.outputListbox,'String',strC);



% --- Outputs from this function are returned to the command line.
function varargout = ip201helpMain_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



% --- Executes on button press in groupHelpButton.
function groupHelpButton_Callback(hObject, eventdata, handles)
% hObject    handle to groupHelpButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[groupToCheck] = get_group_name(handles);
stringToExecute = ['help(''' groupToCheck ''')'];
%update_outputListbox(handles);
update_outputListbox(handles,stringToExecute);

function [groupToCheck] = get_group_name(handles)
% Returns the names of the two variables to plot
list_entries = get(handles.bmelibTopicGroups,'String');
index_selected = get(handles.bmelibTopicGroups,'Value');
if length(index_selected) ~= 1
    errordlg('Please select only 1 group for help at a time',...
             'Incorrect Selection','modal')
else
    groupLine = list_entries{index_selected};
    allWordsInLine = strread(groupLine,'%s');
    groupToCheck = allWordsInLine{1};
end 




% --- Executes on button press in funcHelpButton.
function funcHelpButton_Callback(hObject, eventdata, handles)
% hObject    handle to funcHelpButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[funcToCheck] = get_func_name(handles);
stringToExecute = ['help(''' funcToCheck ''')'];
update_outputListbox(handles,stringToExecute);

function [funcToCheck] = get_func_name(handles)
% Returns the names of the two variables to plot
list_entries = get(handles.functionsList,'String');
index_selected = get(handles.functionsList,'Value');
if length(index_selected) ~= 1
    errordlg('Please select only 1 function for help at a time',...
             'Incorrect Selection','modal')
else
    funcToCheck = list_entries{index_selected};
end 



% --- Executes on button press in closeHelpButton.
function closeHelpButton_Callback(hObject, eventdata, handles)
% hObject    handle to closeHelpButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

delete(handles.figure1)

% --- Executes on selection change in bmelibTopicGroups.
function bmelibTopicGroups_Callback(hObject, eventdata, handles)
% hObject    handle to bmelibTopicGroups (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns bmelibTopicGroups contents as cell array
%        contents{get(hObject,'Value')} returns selected item from bmelibTopicGroups
%get(handles.bmelibTopicGroups);


% --- Executes during object creation, after setting all properties.
function bmelibTopicGroups_CreateFcn(hObject, eventdata, handles)
% hObject    handle to bmelibTopicGroups (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in functionsList.
function functionsList_Callback(hObject, eventdata, handles)
% hObject    handle to functionsList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns functionsList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from functionsList


% --- Executes during object creation, after setting all properties.
function functionsList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to functionsList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in outputListbox.
function outputListbox_Callback(hObject, eventdata, handles)
% hObject    handle to outputListbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns outputListbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from outputListbox


% --- Executes during object creation, after setting all properties.
function outputListbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to outputListbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
