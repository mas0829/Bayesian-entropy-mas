function varargout = ip301p2hardDataWiz(varargin)
% IP301P2HARDDATAWIZ M-file for ip301p2hardDataWiz.fig
%      IP301P2HARDDATAWIZ, by itself, creates a new IP301P2HARDDATAWIZ or raises the existing
%      singleton*.
%
%      H = IP301P2HARDDATAWIZ returns the handle to a new IP301P2HARDDATAWIZ or the handle to
%      the existing singleton*.
%
%      IP301P2HARDDATAWIZ('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in IP301P2HARDDATAWIZ.M with the given input arguments.
%
%      IP301P2HARDDATAWIZ('Property','Value',...) creates a new IP301P2HARDDATAWIZ or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ip301p2hardDataWiz_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ip301p2hardDataWiz_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Copyright 2002-2003 The MathWorks, Inc.

% Edit the above text to modify the response to help ip301p2hardDataWiz

% Last Modified by GUIDE v2.5 13-Jun-2005 11:04:55

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ip301p2hardDataWiz_OpeningFcn, ...
                   'gui_OutputFcn',  @ip301p2hardDataWiz_OutputFcn, ...
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




% --- Executes just before ip301p2hardDataWiz is made visible.
function ip301p2hardDataWiz_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ip301p2hardDataWiz (see VARARGIN)

% Choose default command line output for ip301p2hardDataWiz
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

% UIWAIT makes ip301p2hardDataWiz wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% PRELIMINARY SETTINGS
%
global hardDataPresent 
global ch zh
global xHdColumnStr yHdColumnStr zHdColumnStr hdColumnStr

if hardDataPresent   % If we are revisiting this screen
    set(handles.xcoordEdit,'String',xHdColumnStr);
    set(handles.ycoordEdit,'String',yHdColumnStr);
    set(handles.zcoordEdit,'String',zHdColumnStr);
    set(handles.dataColEdit,'String',hdColumnStr);
end

ch = [];
zh = [];

% --- Outputs from this function are returned to the command line.
function varargout = ip301p2hardDataWiz_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;




function xcoordEdit_Callback(hObject, eventdata, handles)
% hObject    handle to xcoordEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of xcoordEdit as text
%        str2double(get(hObject,'String')) returns contents of xcoordEdit as a double
if (exist('xHdColumnStr'))
    clear xHdColumnStr xHdColumn;
end

global xHdColumnStr xHdColumn

xHdColumnStr = get(hObject,'String');
xHdColumn = str2double(xHdColumnStr); % Convert the input string into a number
if ~isnan(xHdColumn)
switch 1
    case ( xHdColumn<=0 || mod(xHdColumn,floor(xHdColumn)) ) % If negative, 0, or non-integer
        errordlg('Please provide a positive integer for the x-Axis','Invalid column input!')
    case ( xHdColumn>9) % Two digits... Is this correct input?
        warndlg(['You asked for Column ' num2str(xHdColumn) '. Proceed, if correct, or review your input.'],...
                'Warning about input')
    case ( xHdColumnStr == get(handles.ycoordEdit,'String') )
        errordlg('Please provide different column numbers for the x-Axis and the y-Axis',...
                 'Input columns coincide!')        
    case ( xHdColumnStr == get(handles.zcoordEdit,'String') )
        errordlg('Please provide different column numbers for the x-Axis and the z-Axis',...
                 'Input columns coincide!')        
    case ( xHdColumnStr == get(handles.dataColEdit,'String') )
        errordlg('Please provide different column numbers for the x-Axis and the Hard Data',...
                 'Input columns coincide!')        
end
else   % A NaN conversion may result either from a letter or no input
    if isletter(xHdColumnStr)  % If letter
        errordlg('Please provide a positive integer for the x-Axis','Invalid column input!')        
    else                       % If no input
        errordlg({'You need to specify at least coordinates';...
              'in the x-Axis (and the Hard Data) boxes for your Hard Data!';...
              '';'If you do not wish to use any Hard Data';...
              'first de-select any Hard Data input file';...
              '(click on the ''Browse...'' button and cancel the action)';...
              'and then proceed by pushing the ''Next'' button.'},...
              'No x-coordinates column input info');
    end
end




% --- Executes during object creation, after setting all properties.
function xcoordEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to xcoordEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




function ycoordEdit_Callback(hObject, eventdata, handles)
% hObject    handle to ycoordEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ycoordEdit as text
%        str2double(get(hObject,'String')) returns contents of ycoordEdit as a double
if (exist('yHdColumnStr'))
    clear yHdColumnStr yHdColumn;
end

global yHdColumn yHdColumnStr

yHdColumnStr = get(hObject,'String');
yHdColumn = str2double(yHdColumnStr); % Convert the input string into a number
if ~isnan(yHdColumn)    
switch 1
    case ( yHdColumn<=0 || mod(yHdColumn,floor(yHdColumn)) ) % If negative, 0, or non-integer
        errordlg('Please provide a positive integer for the y-Axis','Invalid column input!')
    case ( yHdColumn>9) % Two digits... Is this correct input?
        warndlg(['You asked for column ' num2str(yHdColumn) '. Proceed, if correct, or review your input.'],...
                'Warning about input')
    case ( yHdColumnStr == get(handles.xcoordEdit,'String') )
        errordlg('Please provide different column numbers for the y-Axis and the x-Axis',...
                 'Input columns coincide!')        
    case ( yHdColumnStr == get(handles.zcoordEdit,'String') )
        errordlg('Please provide different column numbers for the y-Axis and the z-Axis',...
                 'Input columns coincide!')        
    case ( yHdColumnStr == get(handles.dataColEdit,'String') )
        errordlg('Please provide different column numbers for the y-Axis and the Hard Data',...
                 'Input columns coincide!')        
end
else   % A NaN conversion may result either from a letter or no input
    if isletter(yHdColumnStr)
        errordlg('Please provide a positive integer for the y-Axis','Invalid column input!')        
    end
end




% --- Executes during object creation, after setting all properties.
function ycoordEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ycoordEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




function zcoordEdit_Callback(hObject, eventdata, handles)
% hObject    handle to zcoordEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of zcoordEdit as text
%        str2double(get(hObject,'String')) returns contents of zcoordEdit as a double
if (exist('zHdColumnStr'))
    clear zHdColumnStr zHdColumn;
end

global zHdColumn zHdColumnStr

zHdColumnStr = get(hObject,'String');
zHdColumn = str2double(zHdColumnStr); % Convert the input string into a number
if ~isnan(zHdColumn)    
switch 1
    case ( zHdColumn<=0 || mod(zHdColumn,floor(zHdColumn)) ) % If negative, 0, or non-integer
        errordlg('Please provide a positive integer for the z-Axis','Invalid column input!')
    case ( zHdColumn>9) % Two digits... Is this correct input?
        warndlg(['You asked for column ' num2str(zHdColumn) '. Proceed, if correct, or review your input.'],...
                'Warning about input')
    case ( zHdColumnStr == get(handles.xcoordEdit,'String') )
        errordlg('Please provide different column numbers for the z-Axis and the x-Axis',...
                 'Input columns coincide!')        
    case ( zHdColumnStr == get(handles.ycoordEdit,'String') )
        errordlg('Please provide different column numbers for the z-Axis and the y-Axis',...
                 'Input columns coincide!')        
    case ( zHdColumnStr == get(handles.dataColEdit,'String') )
        errordlg('Please provide different column numbers for the z-Axis and the Hard Data',...
                 'Input columns coincide!')        
end
else   % A NaN conversion may result either from a letter or no input
    if isletter(zHdColumnStr)
        errordlg('Please provide a positive integer for the z-Axis','Invalid column input!')        
    end
end




% --- Executes during object creation, after setting all properties.
function zcoordEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to zcoordEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




function dataColEdit_Callback(hObject, eventdata, handles)
% hObject    handle to dataColEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dataColEdit as text
%        str2double(get(hObject,'String')) returns contents of dataColEdit as a double
if (exist('hdColumnStr'))
    clear hdColumnStr hdColumn;
end

global hdColumnStr hdColumn

hdColumnStr = get(hObject,'String');
hdColumn = str2double(hdColumnStr); % Convert the input string into a number
if ~isnan(hdColumn)    
switch 1
    case ( hdColumn<=0 || mod(hdColumn,floor(hdColumn)) ) % If negative, 0, or non-integer
        errordlg('Please provide a positive integer for your Hard Data','Invalid column input!')
    case ( hdColumn>9) % Two digits... Is this correct input?
        warndlg(['You asked for column ' num2str(hdColumn) '. Proceed, if correct, or review your input.'],...
                 'Warning about input')
    case ( hdColumnStr == get(handles.xcoordEdit,'String') )
        errordlg('Please provide different column numbers for Hard Data and the x-Axis',...
                 'Input columns coincide!')        
    case ( hdColumnStr == get(handles.ycoordEdit,'String') )
        errordlg('Please provide different column numbers for Hard Data and the y-Axis',...
                 'Input columns coincide!')        
    case ( hdColumnStr == get(handles.zcoordEdit,'String') )
        errordlg('Please provide different column numbers for Hard Data and the z-Axis',...
                 'Input columns coincide!')        
end
else
    if isletter(hdColumnStr)     % If letter
        errordlg('Please provide a positive integer for your Hard Data','Invalid column input!')        
    else                         % If no input
        errordlg({'You need to specify at least coordinates';...
              'in the Hard Data (and the x-Axis) boxes for your Hard Data!';...
              '';'If you do not wish to use any Hard Data';...
              'first de-select any Hard Data input file';...
              '(click on the ''Browse...'' button and cancel the action)';...
              'and then proceed by pushing the ''Next'' button.'},...
              'No Hard Data column input info');
    end
end

% --- Executes during object creation, after setting all properties.
function dataColEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dataColEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
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
ip301p1hardDataWiz('Title','Hard Data Wizard');      % ...and procede to the following screen.




% --- Executes on button press in nextButton.
function nextButton_Callback(hObject, eventdata, handles)
% hObject    handle to nextButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global xHdColumn yHdColumn zHdColumn hdColumn
global xHdColumnStr yHdColumnStr zHdColumnStr hdColumnStr
global ch zh

processHardData = 1;  % Provide an initial value and proceed with control tests.

% Prevent the user from assigning the same columns for different coordinates
%
if (xHdColumn == yHdColumn)
    processHardData = 0;
    errordlg(...
    {'The designated columns for the x and y coordinates must be different.';...
     'Please correct before continuing.'},...
     'Can not proceed further!')  
elseif (xHdColumn == zHdColumn)
    processHardData = 0;
    errordlg(...
    {'The designated columns for the x and z coordinates must be different.';...
     'Please correct before continuing.'},...
     'Can not proceed further!')  
elseif (xHdColumn == hdColumn)
    processHardData = 0;
    errordlg({...
     'The designated columns for the x coordinates and Hard Data must be different.';...
     'Please correct before continuing.'},...
     'Can not proceed further!')  
elseif (yHdColumn == zHdColumn)
    processHardData = 0;
    errordlg({...
     'The designated columns for the y and z coordinates must be different.';...
     'Please correct before continuing.'},...
     'Can not proceed further!')  
elseif (yHdColumn == hdColumn)
    processHardData = 0;
    errordlg({...
     'The designated columns for the y coordinates and Hard Data must be different.';...
     'Please correct before continuing.'},...
     'Can not proceed further!')  
elseif (zHdColumn == hdColumn)
    processHardData = 0;
    errordlg({...
     'The designated columns for the z coordinates and Hard Data must be different.';...
     'Please correct before continuing.'},...
     'Can not proceed further!')  
end
    
% Is the necessary info provided correctly? If not, prompt the user to review
%
if ( isempty(xHdColumnStr) || isempty(hdColumnStr) ) 
    %disp([isempty(xHdColumnStr) isempty(hdColumnStr)])   % For testing purposes
    processHardData = 0;
    errordlg({'You have chosen a Hard Data input file.';...
          'The columns where your Hard Data and coordinates reside are required.';...
          'The minimum acceptable input';...
          'are the x-Axis and the Hard Data column numbers for the 1-D case.'},...
          'Missing column input info');
end

if ( ~isempty(xHdColumnStr) && isempty(yHdColumnStr) && ~isempty(zHdColumnStr))
    processHardData = 0;
    errordlg({'You have provided information only in the x- and z-Axis boxes.';...
          'If you have a 3-D study, please provide info in the y-Axis box, too.';...
          'If you have a 2-D study, please fill the boxes sequentially';...
          'starting from x and ending in y';...
          '(regardless whether your coordinates may be x and z, or x and time t).'},...
          'Can not proceed further!');
end
  
if processHardData    
    hardDataPresent = 1;
    ip301p2hardDataFunction(handles);  
    delete(handles.figure1);
    ip302p1softDataWiz('Title','Soft Data Wizard');   % Proceed to the next step.
end




function ip301p2hardDataFunction(handles)
% At this point the user has provided a file containing the Hard Data
% as well as information regarding the columns inside the data file.
% This function prepares the material necessary for SEKS-GUI to run.
%
global xHdColumnStr hdColumnStr xHdColumn yHdColumn zHdColumn hdColumn
global ch zh chInitDim
global hdFilename hdPathname hardDataPresent
global totalCoordinatesUsed totalSpCoordinatesUsed timePresent
global hdFileType
global negativeValues
global xAxisName yAxisName zAxisName variableName

initialDir = pwd;                   % Save the current directory path
cd (hdPathname);                    % Go where the HD file resides

switch hdFileType
  case 1                            % Either the hard data are in an ASCII file
    hdVal = load(hdFilename);
  case 2                            % ...or the hard data are in an Excel file
    [hdVal,hdValname] = xlsread(hdFilename);
  case 3                            % ...or the hard data are in a GeoEAS file
    [hdVal,hdValname,hdFiletitle] = readGeoEAS(hdFilename);
  otherwise
    errordlg({'ip301p2hardDataWiz:ip301p2hardDataFunction:';...
              'hdFileType variable is out of range.';...
              'SEKS-GUI software Error'})
end

% cd (initialDir);                    % Return to where this function was evoked from

ch(:,1) = hdVal(:,xHdColumn);       % Define the hard data coordinates array
if hdFileType==1
  xAxisName = 'x-Axis';
else
  if ~isempty(hdValname)            % If headers not empty in Excel or GeoEAS file
    if size(hdValname,2)>=xHdColumn % If exists header for this column
      if isempty(hdValname{xHdColumn})
        xAxisName = 'x-Axis';       % If header for this column not set
      else
        xAxisName = hdValname{xHdColumn};
      end
    else
      xAxisName = 'x-Axis';
    end
  else
    xAxisName = 'x-Axis';
  end
end
chInitDim = size(ch,1);             % Store the original hard data set size
totalCoordinatesUsed = 1;           % So far a total of 1 coordinates set
if ~isnan(yHdColumn)
    ch(:,2) = hdVal(:,yHdColumn);
    totalCoordinatesUsed = totalCoordinatesUsed + 1;   % Increase appropriately
    if hdFileType==1
      yAxisName = 'y-Axis';
    else
      if ~isempty(hdValname)            % If headers not empty in Excel or GeoEAS file
        if size(hdValname,2)>=yHdColumn % If exists header for this column
          if isempty(hdValname{yHdColumn})
            yAxisName = 'y-Axis';       % If header for this column not set
          else
            yAxisName = hdValname{yHdColumn};
          end
        else
          yAxisName = 'y-Axis';
        end
      else
        yAxisName = 'y-Axis';
      end
    end
else
    yAxisName = [];
end
if ~isnan(zHdColumn)
    ch(:,3) = hdVal(:,zHdColumn);
    totalCoordinatesUsed = totalCoordinatesUsed + 1;   % Increase appropriately
    if hdFileType==1
      zAxisName = 'z-Axis';
    else
      if ~isempty(hdValname)            % If headers not empty in Excel or GeoEAS file
        if size(hdValname,2)>=zHdColumn % If exists header for this column
          if isempty(hdValname{zHdColumn})
            zAxisName = 'z-Axis';       % If header for this column not set
          else
            zAxisName = hdValname{zHdColumn};
          end
        else
          zAxisName = 'z-Axis';
        end
      else
        zAxisName = 'z-Axis';
      end
    end
else
    zAxisName = [];
end
zh = hdVal(:,hdColumn);             % Define the hard data values vector
if hdFileType==1
  variableName = 'Variable';
else
  if ~isempty(hdValname)            % If headers not empty in Excel or GeoEAS file
    if size(hdValname,2)>=hdColumn % If exists header for this column
      if isempty(hdValname{hdColumn})
        variableName = 'Variable';       % If header for this column not set
      else
        variableName = hdValname{hdColumn};
      end
    else
      variableName = 'Variable';
    end
  else
    variableName = 'Variable';
  end
end

% remove the NaN data from the database
idx=find(~isnan(zh));
ch=ch(idx,:);
zh=zh(idx,:);
chInitDim = size(ch,1); % Remove NaN data directly without notifying the user H-L 20080610

if timePresent                      % Keep number of spatial coordinates handy
    totalSpCoordinatesUsed = totalCoordinatesUsed - 1;
else
    totalSpCoordinatesUsed = totalCoordinatesUsed;
end
