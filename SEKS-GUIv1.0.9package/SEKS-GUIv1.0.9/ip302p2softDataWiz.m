function varargout = ip302p2softDataWiz(varargin)
%IP302P2SOFTDATAWIZ M-file for ip302p2softDataWiz.fig
%      IP302P2SOFTDATAWIZ, by itself, creates a new IP302P2SOFTDATAWIZ or raises the existing
%      singleton*.
%
%      H = IP302P2SOFTDATAWIZ returns the handle to a new IP302P2SOFTDATAWIZ or the handle to
%      the existing singleton*.
%
%      IP302P2SOFTDATAWIZ('Property','Value',...) creates a new IP302P2SOFTDATAWIZ using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to ip302p2softDataWiz_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      IP302P2SOFTDATAWIZ('CALLBACK') and IP302P2SOFTDATAWIZ('CALLBACK',hObject,...) call the
%      local function named CALLBACK in IP302P2SOFTDATAWIZ.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ip302p2softDataWiz

% Last Modified by GUIDE v2.5 13-May-2011 23:02:32

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ip302p2softDataWiz_OpeningFcn, ...
                   'gui_OutputFcn',  @ip302p2softDataWiz_OutputFcn, ...
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


% --- Executes just before ip302p2softDataWiz is made visible.
function ip302p2softDataWiz_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

% Choose default command line output for ip302p2softDataWiz
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

% UIWAIT makes ip302p2softDataWiz wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = ip302p2softDataWiz_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



% PRELIMINARY SETTINGS
%
% totalCoordinatesUsed provides the dimension in which the study takes place.
% Should be 1, 2, or 3, if user has revisited or made earlier use of hard data.
% Should be currently 0 and further defined otherwise.
%
% timePresent states whether time is among the user variables. 
% Should be 1 or 0 according to the user's choice, if the user has provided
% hard data. Otherwise, the value defaults to 1 in the wait for user's input.
%
global totalCoordinatesUsed totalSpCoordinatesUsed timePresent 

% totalCoordinatesUsed=2;  % For testing purposes
if totalCoordinatesUsed

  if (totalCoordinatesUsed==1 || totalCoordinatesUsed==2 || ...
      totalCoordinatesUsed==3)
    set(handles.totCoordEdit,'String',num2str(totalCoordinatesUsed));
  else
    errordlg({'ip302p2softDataWiz.m';...
            'Though Hard Data has been defined, totalCoordinatesUsed has invalid value'},...
            'GUI software Error')
  end

  if timePresent
    set(handles.timeChoiceCheckbox,'Value',0); 
  else
    set(handles.timeChoiceCheckbox,'Value',1);
  end

else
  timePresent = 1;
  set(handles.timeChoiceCheckbox,'Value',0);
  totalSpCoordinatesUsed = totalCoordinatesUsed - 1;
end




function totCoordEdit_Callback(hObject, eventdata, handles)
% hObject    handle to totCoordEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of totCoordEdit as text
%        str2double(get(hObject,'String')) returns contents of totCoordEdit as a double
global hardDataPresent totalCoordinatesUsed

totCoordColumnStr = get(hObject,'String');
totCoordColumn = str2double(totCoordColumnStr); % Convert the input string into a number
if ~isnan(totCoordColumn)
    if ( totCoordColumn~=1 && totCoordColumn~=2 && totCoordColumn~=3 ) % If other than 1,2,3
        errordlg('Please provide a value of 1, 2, or 3','Invalid column input!')
    else
        totalCoordinatesUsed = totCoordColumn;  % Define dimension space
    end
else               % A NaN conversion may result either from a letter or no input
    if isletter(totCoordColumn)
        errordlg('Please provide a value of 1, 2, or 3','Invalid column input!')        
    end
end
    



% --- Executes during object creation, after setting all properties.
function totCoordEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to totCoordEdit (see GCBO)
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
global totalSpCoordinatesUsed totalCoordinatesUsed

if get(handles.timeChoiceCheckbox,'Value')
    timePresent = 0;
    totalSpCoordinatesUsed = totalCoordinatesUsed;
else
    timePresent = 1;
    totalSpCoordinatesUsed = totalCoordinatesUsed - 1;
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

delete(handles.figure1);                       % Close the current window
ip302p1softDataWiz('Title','Soft Data Wizard'); % ...and procede to the following screen.




% --- Executes on button press in nextButton.
function nextButton_Callback(hObject, eventdata, handles)
% hObject    handle to nextButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global totalCoordinatesUsed totalSpCoordinatesUsed
global sdCategory

if get(handles.timeChoiceCheckbox,'Value')
    timePresent = 0;
    totalSpCoordinatesUsed = totalCoordinatesUsed;
else
    timePresent = 1;
    totalSpCoordinatesUsed = totalCoordinatesUsed - 1;
end

if totalCoordinatesUsed
  switch sdCategory
    case 1
      softDataPresent = 1;
      delete(handles.figure1);    % Close the current window
      ip302p3FsoftDataWiz('Title','Soft Data Wizard - Normal PDF');
    case 2
      softDataPresent = 1;
      delete(handles.figure1);    % Close the current window
      ip302p3GsoftDataWiz('Title','Soft Data Wizard - Uniform PDF');
    case 3
      softDataPresent = 1;
      delete(handles.figure1);    % Close the current window
      ip302p3HsoftDataWiz('Title','Soft Data Wizard - Triangular PDF');
    case 4
      softDataPresent = 1;
      delete(handles.figure1);    % Close the current window
      ip302p3AsoftDataWiz('Title','Soft Data Wizard - Interval');       
    case 5
      softDataPresent = 1;
      delete(handles.figure1);    % Close the current window
      ip302p3BsoftDataWiz('Title','Soft Data Wizard - Histogram PDF');
    case 6
      softDataPresent = 1;
      delete(handles.figure1);    % Close the current window
      ip302p3CsoftDataWiz('Title','Soft Data Wizard - Linear PDF');
    case 7
      softDataPresent = 1;
      delete(handles.figure1);    % Close the current window
      ip302p3DsoftDataWiz('Title','Soft Data Wizard - Histogram Regular Grid PDF');
    case 8
      softDataPresent = 1;
      delete(handles.figure1);    % Close the current window
      ip302p3EsoftDataWiz('Title','Soft Data Wizard - Linear Regular Grid PDF');
    otherwise
      errordlg({'ip302p2softDataWiz:nextButton_Callback:';...
        'A choice for soft data type has been provided in previous screen';...
        'but the corresponding sdCategory does not have an acceptable value';...
        ['within 1,...,5 here. sdCategory=' num2str(sdCategory)]},...
        'GUI software Error')
  end
else
    errordlg({'The number of dimensions in your study has not been defined.';...
              'Please provide the dimension space you will be working in';...
              'by inserting a number (1, 2, or 3) in the appropriate screen box.'},...
              'Can not proceed further!')
end    
