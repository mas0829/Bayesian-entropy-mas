function varargout = ip304p1explorAnal(varargin)
%IP304P1EXPLORANAL M-file for ip304p1explorAnal.fig
%      IP304P1EXPLORANAL, by itself, creates a new IP304P1EXPLORANAL or raises the existing
%      singleton*.
%
%      H = IP304P1EXPLORANAL returns the handle to a new IP304P1EXPLORANAL or the handle to
%      the existing singleton*.
%
%      IP304P1EXPLORANAL('Property','Value',...) creates a new IP304P1EXPLORANAL using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to ip304p1explorAnal_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      IP304P1EXPLORANAL('CALLBACK') and IP304P1EXPLORANAL('CALLBACK',hObject,...) call the
%      local function named CALLBACK in IP304P1EXPLORANAL.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ip304p1explorAnal

% Last Modified by GUIDE v2.5 01-Jun-2011 21:32:06

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ip304p1explorAnal_OpeningFcn, ...
                   'gui_OutputFcn',  @ip304p1explorAnal_OutputFcn, ...
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


% --- Executes just before ip304p1explorAnal is made visible.
function ip304p1explorAnal_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

% Choose default command line output for ip304p1explorAnal
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

% UIWAIT makes ip304p1explorAnal wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ip304p1explorAnal_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% PRELIMINARY SETTINGS
%
% Set any known information in the appropriate edit boxes.
% Check and correct any issues with duplicate coordinates in the data provided.
% The updated datasets are passed as global variables from the following
% function. Fill out the remaining boxes with the outcome.
%
global hardDataPresent softDataPresent
global timePresent
global dataTimeSpan minTdata maxTdata
global ch zh cs nl limi probdens totalCoordinatesUsed totalSpCoordinatesUsed
global chOrig csOrig zhOrig
global chInitDim csInitDim
global hdOccurences sdOccurences hsOccurences duplicatesCheckDone
global xMin dx xMax yMin dy yMax zMin dz zMax
global allData outGrid minTout maxTout
global softpdftype

%addpath guiResources;           % Add the path to duplicate HD processing files
% maxGridSpan will be used by the duplicate search program to decide on whether 
% the provided data are potentially co-located. This check is necessary to
% ensure the data covariance matrix will not be singular at a later stage.
% We only check the spatial components to set the measure. In case of S/T case,
% co-located data will occur on the same t-instance, which will satisfy the 
% duplicate search program criteria.
allData = [ch;cs];
switch totalSpCoordinatesUsed % ...then use the span of the given information
  case 1
    gridSpan = max(allData(:,1))-min(allData(:,1));
    if isempty(outGrid)
      xMin=min(allData(:,1)); xMax=max(allData(:,1));
      if timePresent
        yMin=min(allData(:,2)); yMax=max(allData(:,2));
        minTout=yMin; maxTout=yMax;
      end;
    end;
  case 2
    if ~isempty(outGrid)
      gridSpan(1) = abs(xMax-xMin);
      gridSpan(2) = abs(yMax-yMin);
    else
      gridSpan(1) = max(allData(:,1))-min(allData(:,1));
      gridSpan(2) = max(allData(:,2))-min(allData(:,2));  
      xMin=min(allData(:,1)); xMax=max(allData(:,1));
      yMin=min(allData(:,2)); yMax=max(allData(:,2));
      if timePresent
        zMin=min(allData(:,3)); zMax=max(allData(:,3));
        minTout=zMin; maxTout=zMax;
      end;
    end;
  case 3
    if ~isempty(outGrid)
      gridSpan(1) = abs(xMax-xMin);
      gridSpan(2) = abs(yMax-yMin);
      gridSpan(3) = abs(zMax-zMin);
    else
      gridSpan(1) = max(allData(:,1))-min(allData(:,1));
      gridSpan(2) = max(allData(:,2))-min(allData(:,2));
      gridSpan(3) = max(allData(:,3))-min(allData(:,3)); 
      xMin=min(allData(:,1)); xMax=max(allData(:,1));
      yMin=min(allData(:,2)); yMax=max(allData(:,2));
      zMin=min(allData(:,3)); zMax=max(allData(:,3));
    end
end

  
  

if gridSpan==0          % If the user has asked for output at only 1 point
%  allData = [ch;cs];
  switch totalSpCoordinatesUsed           % ...then use the span of the given information
    case 1
      gridSpan = max(allData(:,1))-min(allData(:,1));
    case 2
      gridSpan(1) = max(allData(:,1))-min(allData(:,1));
      gridSpan(2) = max(allData(:,2))-min(allData(:,2));
    case 3
      gridSpan(1) = max(allData(:,1))-min(allData(:,1));
      gridSpan(2) = max(allData(:,2))-min(allData(:,2));
      gridSpan(3) = max(allData(:,3))-min(allData(:,3));
  end
end

maxnl=max(nl);
proximityLimit = 0.0005;           % How close is too close?
duplicatesCheckDone = [];

if isempty(duplicatesCheckDone)   % If the datasets have not been checked before

  hdOccurences = [];              % Initialize.
  sdOccurences = [];              % Initialize.
  hsOccurences = [];              % Initialize.
  
  if hardDataPresent              % Check hard data, if they exist
    set(handles.hdIniNoEdit,'String',num2str(chInitDim));
    useHard = 1;
    hdDim = chInitDim;
  else
    set(handles.hdIniNoEdit,'String','No Hard Data');
    useHard = 0;
    hdDim = 0;
  end
  if softDataPresent              % Check soft data, if they exist
    set(handles.sdIniNoEdit,'String',num2str(csInitDim));
    useSoft = 1;
    sdDim = csInitDim;
  else
    set(handles.sdIniNoEdit,'String','No Soft Data');
    useSoft = 0;
    sdDim = 0;
  end
  set(handles.allDataIniNoEdit,'String',...
      num2str(useHard*hdDim + useSoft*sdDim));
 
  pause(0.1);                     % Trick to allow display info on screen
  
  if useHard
    %[chTmp zhTmp I] = avedupli(ch,zh);                   % Run throught the hard data
    % Use a modified version of "avedupli" stored in the guiResources folder.
    % This version also accounts for hard data located too closely. Closeness
    % is determined by the proximityLimit parameter. This parameter is compared
    % to the ratio of (spatial distance of data pair)/(size of grid used).
    % If no grid is used, then the grid size is replaced by the data spatial span.

    if timePresent
      % In the S/T case we want to eliminate co-located or spatially close data
      % items on the same t-instance. The function aveneardupli works in a way
      % that may not eliminate eligible items, unless all data of the same
      % instance are grouped together. This is what we do in the following.
      chTmp = [];                             % Initialize.
      zhTmp = [];                             % Initialize.
      for ith=1:dataTimeSpan
        chAtInst{ith} = chOrig(find(chOrig(:,end)==(minTdata+ith-1)),:); % Instance
        zhAtInst{ith} = zhOrig(find(chOrig(:,end)==(minTdata+ith-1)),:); % Instance
        [chTmpAtInst zhTmpAtInst IAtInst] = ...
             aveneardupli(chAtInst{ith}(:,1:totalSpCoordinatesUsed),...
                          zhAtInst{ith},gridSpan,proximityLimit);
%            avedupli(chAtInst{ith}(:,1:totalSpCoordinatesUsed),zhAtInst{ith});
        % Aggregate data again
        chTmp = [chTmp ; [chTmpAtInst (minTdata+ith-1)*ones(size(chTmpAtInst,1),1)]];
        zhTmp = [zhTmp ; zhTmpAtInst];
      end
      clear chAtInst zhAtInst chTmpAtInst zhTmpAtInst;
    else
      % In the purely spatial case use aveneardupli as is to eliminate co-located data.
      [chTmp zhTmp I] = aveneardupli(chOrig,zhOrig,gridSpan,proximityLimit); % Check hard data
    end
    
    ch = []; zh = [];
    ch = chTmp;
    zh = zhTmp;
    hdOccurences = chInitDim-size(chTmp,1);   % Count of hard duplicates
  end
  
  if useSoft
    
    % First, split the data in time instances. In case of co-location,
    % this version of SEKS-GUI is coping with the situation by means of
    % displacing the SD. For that reason we only need the data coordinates
    % at each of the instances.
    if timePresent
      for ith=1:dataTimeSpan
        if useHard
          indxh = find(ch(:,end)==(minTdata+ith-1));
          chAtInst{ith} = ch(indxh,1:end-1);  % Create cell array for instance data
        end
        indxs = find(cs(:,end)==(minTdata+ith-1));
        csAtInst{ith} = cs(indxs,1:end-1);  % Create cell array for instance data
        nlAtInst{ith} = nl(indxs,:);
        limiAtInst{ith}= NaN*ones(length(indxs),max(nl));
        if (softpdftype==1 || softpdftype==3)
          probdensAtInst{ith}= NaN*ones(length(indxs),max(nl)-1);
        else
          probdensAtInst{ith}= NaN*ones(length(indxs),max(nl));
        end
        for k=1:length(indxs)
          limiAtInst{ith}(k,1:nlAtInst{ith}(k)) = limi(indxs(k),1:nl(indxs(k)));    
          if (softpdftype==1 || softpdftype==3)
            probdensAtInst{ith}(k,1:nlAtInst{ith}(k)-1) = probdens(indxs(k),1:nl(indxs(k))-1);
          else
            probdensAtInst{ith}(k,1:nlAtInst{ith}(k)) = probdens(indxs(k),1:nl(indxs(k)));
          end
          % Modified by H-L, consider the nl for limiAtInst and
          % probdensAtInst
        end;
      end
    else
      if useHard
        chAtInst{1} = ch;  % Create cell array for instance data
        zhAtInst{1} = zh;  % Create cell array for instance data
      end
      csAtInst{1} = cs;  % Create cell array for instance data
      nlAtInst{1} = nl;
      limiAtInst{1} = limi;
      probdensAtInst{1} = probdens;
    end

    % For each separate instance, check whether soft data are co-located
    % with other soft data or other hard data. If this is a spatial case,
    % the code is still valid based on the definitions in the previous lines.
    csTemporary = [];
    nlTemporary = [];
    limiTemporary = [];             
    probdensTemporary = [];         
    hsOccurences = 0;
    sdOccurences = 0;
    for ith=1:dataTimeSpan
    
      softLoci = csAtInst{ith};
      
      if ~isempty(softLoci)

        nData = size(softLoci,1);

        rand('state',sum(100*clock));
        hsOccurencesAtInst{ith} = 0;
        sdOccurencesAtInst{ith} = 0;

        for i=1:nData  % For each one of the SD at t=ith 

          switch totalSpCoordinatesUsed
            case 1           % Co-location in spatial 1-D
              if useHard     % If using HD, check for HD, SD co-location
                for ih = 1:size(chAtInst{ith},1)
                  % If soft coincides with hard, move the soft
                  if (softLoci(i,1) == chAtInst{ith}(ih,1))
                    hsOccurencesAtInst{ith} = ...
                      hsOccurencesAtInst{ith}+1;           % Add a hard-soft duplicate in count
                    softLoci(i,1) = softLoci(i,1) + rand(1)*0.1;         % Displace
                  end
                end
              end
              if i<nData
                for iNxt = i+1:nData    % Check all the SD following the i-th
                  if softLoci(i,1)==softLoci(iNxt,1)     % If soft co-located at t=ith
                    sdOccurencesAtInst{ith} = ...
                      sdOccurencesAtInst{ith}+1;             % Add a soft duplicate in count
                    softLoci(iNxt,1) = softLoci(iNxt,1) + rand(1)*0.1; % Displace
                  end
                end
              end
            case 2           % Co-location in spatial 2-D
              if useHard     % If using HD, check for HD, SD co-location
                for ih = 1:size(chAtInst{ith},1)
                  % If soft coincides with hard, move the soft
                  if (softLoci(i,1) == chAtInst{ith}(ih,1) && ...
                      softLoci(i,2) == chAtInst{ith}(ih,2))
                    hsOccurencesAtInst{ith} = ...
                      hsOccurencesAtInst{ith}+1;           % Add a hard-soft duplicate in count
                    softLoci(i,1) = softLoci(i,1) + rand(1)*0.1; % Displace x-coord
                    softLoci(i,2) = softLoci(i,2) + rand(1)*0.1; % Displace y-coord
                  end
                end
              end
              if i<nData
                for iNxt = i+1:nData    % Check all the SD following the i-th
                  if softLoci(i,1)==softLoci(iNxt,1) && ...
                     softLoci(i,2)==softLoci(iNxt,2)   % If soft co-located at t=ith
                    sdOccurencesAtInst{ith} = ...
                      sdOccurencesAtInst{ith}+1;             % Add a soft duplicate in count
                    softLoci(iNxt,1) = softLoci(iNxt,1) + rand(1)*0.1; % Displace x
                    softLoci(iNxt,2) = softLoci(iNxt,2) + rand(1)*0.1; % Displace y
                  end
                end
              end
            case 3           % Co-location in spatial 3-D
              if useHard     % If using HD, check for HD, SD co-location
                for ih = 1:size(chAtInst{ith},1)
                  % If soft coincides with hard, move the soft
                  if (softLoci(i,1) == chAtInst{ith}(ih,1) && ...
                      softLoci(i,2) == chAtInst{ith}(ih,2) && ...
                      softLoci(i,3) == chAtInst{ith}(ih,3))
                    hsOccurencesAtInst{ith} = ...
                      hsOccurencesAtInst{ith}+1;               % Add a hard-soft duplicate in count
                    softLoci(i,1) = softLoci(i,1) + rand(1)*0.1; % Displace x-coord
                    softLoci(i,2) = softLoci(i,2) + rand(1)*0.1; % Displace y-coord
                    softLoci(i,3) = softLoci(i,3) + rand(1)*0.1; % Displace z-coord
                  end
                end
              end
              if i<nData
                for iNxt = i+1:nData    % Check all the SD following the i-th
                  if softLoci(i,1)==softLoci(iNxt,1) && ...
                     softLoci(i,2)==softLoci(iNxt,2) && ...
                     softLoci(i,3)==softLoci(iNxt,3)   % If soft co-located at t=ith
                    sdOccurencesAtInst{ith} = ...
                      sdOccurencesAtInst{ith}+1;             % Add a soft duplicate in count
                    softLoci(iNxt,1) = softLoci(iNxt,1) + rand(1)*0.1; % Displace x
                    softLoci(iNxt,2) = softLoci(iNxt,2) + rand(1)*0.1; % Displace y
                    softLoci(iNxt,3) = softLoci(iNxt,3) + rand(1)*0.1; % Displace z
                  end
                end
              end
          end         % switch

        end           % for i
        
        % Modified by H-L Dec 01/2006 to adjust the soft coordinate
        % for the only spatial cases re-define the non-colocated
        % coordinates of the SD
        if timePresent
          csAtInst{ith} = [softLoci (minTdata+ith-1)*ones(size(softLoci,1),1)]; % Re-establish SD w/o duplicates
        else
          csAtInst{ith} = [softLoci];
        end;
        csTemporary = [csTemporary ; csAtInst{ith}];                    % Keep on track with
        nlTemporary = [nlTemporary ; nlAtInst{ith}];                    % the new ordering of
        limiTemporary = [limiTemporary ; limiAtInst{ith}];              % the SD coordinates
        probdensTemporary = [probdensTemporary ; probdensAtInst{ith}];  % for the SD attributes
        hsOccurences = hsOccurences + hsOccurencesAtInst{ith};
        sdOccurences = sdOccurences + sdOccurencesAtInst{ith};
      
      end           % of: ~isempty(softLoci)
      
    end             % of: For the ith-instance
    
    cs = csTemporary;
    nl = nlTemporary;
    limi = limiTemporary;
    probdens = probdensTemporary;
    
  else              % useSoft. If no soft data are used then...
    sdOccurences = 0;
    hsOccurences = 0;
  end               % useSoft

  % Use 0 if you would like to go through the duplicates check at subsequent visits
  duplicatesCheckDone = 1;

  if hardDataPresent
    set(handles.hdDupNoEdit,'String',num2str(hdOccurences));
    set(handles.hdFinNoEdit,'String',num2str(size(ch,1)));
  else
    set(handles.hdDupNoEdit,'String','No Hard Data');
    set(handles.hdFinNoEdit,'String','No Hard Data');
  end
  if softDataPresent
    if hardDataPresent
      set(handles.sdDupHNoEdit,'String',num2str(hsOccurences));
    else
      set(handles.sdDupHNoEdit,'String','No Hard');
    end
    set(handles.sdDupSNoEdit,'String',num2str(sdOccurences));
    set(handles.sdFinNoEdit,'String',num2str(size(cs,1)));
  else
    set(handles.sdDupHNoEdit,'String','No Soft');
    set(handles.sdDupSNoEdit,'String','No Soft');
    set(handles.sdFinNoEdit,'String','No Soft Data');
  end
  
  set(handles.totDupNoEdit,'String',...
      num2str(useHard*hdOccurences + useSoft*(sdOccurences+hsOccurences)));
  set(handles.allDataFinNoEdit,'String',...
      num2str(useHard*size(ch,1) + useSoft*size(cs,1)));
  
else                % isempty(duplicatesCheckDone). If it's not empty
    
  if hardDataPresent
    set(handles.hdIniNoEdit,'String',num2str(chInitDim));
    set(handles.hdDupNoEdit,'String',num2str(hdOccurences));
    set(handles.hdFinNoEdit,'String',num2str(size(ch,1)));
    useHard = 1;
    hdDim = chInitDim;
  else
    set(handles.hdIniNoEdit,'String','No Hard Data');
    set(handles.hdDupNoEdit,'String','No Hard Data');
    set(handles.hdFinNoEdit,'String','No Hard Data');
    useHard = 0;
    hdDim = 0;
  end
  if softDataPresent
    set(handles.sdIniNoEdit,'String',num2str(csInitDim));
    if hardDataPresent
      set(handles.sdDupHNoEdit,'String',num2str(hsOccurences));
    else
      set(handles.sdDupHNoEdit,'String','No Hard');
    end
    set(handles.sdDupSNoEdit,'String',num2str(sdOccurences));
    set(handles.sdFinNoEdit,'String',num2str(size(cs,1)));
    useSoft = 1;
    sdDim = csInitDim;
  else
    set(handles.sdIniNoEdit,'String','No Soft Data');
    set(handles.sdDupHNoEdit,'String','No Soft');
    set(handles.sdDupSNoEdit,'String','No Soft');
    set(handles.sdFinNoEdit,'String','No Soft Data');
    useSoft = 0;
    sdDim = 0;
  end
  set(handles.allDataIniNoEdit,'String',...
      num2str(useHard*hdDim + useSoft*sdDim));
  set(handles.totDupNoEdit,'String',...
      num2str(useHard*hdOccurences + useSoft*(sdOccurences+hsOccurences)));
  set(handles.allDataFinNoEdit,'String',...
      num2str(useHard*size(ch,1) + useSoft*size(cs,1)));

end





function hdIniNoEdit_Callback(hObject, eventdata, handles)
% hObject    handle to hdIniNoEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of hdIniNoEdit as text
%        str2double(get(hObject,'String')) returns contents of hdIniNoEdit as a double
global chInitDim hardDataPresent

if hardDataPresent
    set(handles.hdIniNoEdit,'String',num2str(chInitDim));
else
    set(handles.hdIniNoEdit,'String','No Hard Data');
end




% --- Executes during object creation, after setting all properties.
function hdIniNoEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hdIniNoEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




function sdIniNoEdit_Callback(hObject, eventdata, handles)
% hObject    handle to sdIniNoEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of sdIniNoEdit as text
%        str2double(get(hObject,'String')) returns contents of sdIniNoEdit as a double
global csInitDim softDataPresent

if softDataPresent
    set(handles.sdIniNoEdit,'String',num2str(csInitDim));
else
    set(handles.sdIniNoEdit,'String','No Soft Data');
end




% --- Executes during object creation, after setting all properties.
function sdIniNoEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sdIniNoEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




function allDataIniNoEdit_Callback(hObject, eventdata, handles)
% hObject    handle to allDataIniNoEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of allDataIniNoEdit as text
%        str2double(get(hObject,'String')) returns contents of allDataIniNoEdit as a double
global chInitDim csInitDim hardDataPresent softDataPresent

if hardDataPresent
    useHard = 1;
    hdDim = chInitDim;
else
    useHard = 0;
    hdDim = 0;
end
if softDataPresent
    useSoft = 1;
    sdDim = csInitDim;
else
    useSoft = 0;
    sdDim = 0;
end
set(handles.allDataIniNoEdit,'String',...
      num2str(useHard*hdDim + useSoft*sdDim));




% --- Executes during object creation, after setting all properties.
function allDataIniNoEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to allDataIniNoEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




function hdDupNoEdit_Callback(hObject, eventdata, handles)
% hObject    handle to hdDupNoEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of hdDupNoEdit as text
%        str2double(get(hObject,'String')) returns contents of hdDupNoEdit as a double
global hdOccurences hardDataPresent

if hardDataPresent
    set(handles.hdDupNoEdit,'String',num2str(hdOccurences));
else
    set(handles.hdDupNoEdit,'String','No Hard Data');
end




% --- Executes during object creation, after setting all properties.
function hdDupNoEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hdDupNoEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




function sdDupHNoEdit_Callback(hObject, eventdata, handles)
% hObject    handle to sdDupHNoEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of sdDupHNoEdit as text
%        str2double(get(hObject,'String')) returns contents of sdDupHNoEdit as a double
global hsOccurences hardDataPresent softDataPresent

if softDataPresent && hardDataPresent
    set(handles.sdDupHNoEdit,'String',num2str(hsOccurences));
elseif softDataPresent && ~hardDataPresent
    set(handles.sdDupHNoEdit,'String','No Hard');
elseif ~softDataPresent && hardDataPresent
    set(handles.sdDupHNoEdit,'String','No Soft');
end




% --- Executes during object creation, after setting all properties.
function sdDupHNoEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sdDupHNoEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




function sdDupSNoEdit_Callback(hObject, eventdata, handles)
% hObject    handle to sdDupSNoEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of sdDupSNoEdit as text
%        str2double(get(hObject,'String')) returns contents of sdDupSNoEdit as a double
global sdOccurences hardDataPresent softDataPresent

if softDataPresent
    set(handles.sdDupSNoEdit,'String',num2str(sdOccurences));
else
    set(handles.sdDupSNoEdit,'String','No Soft');
end




% --- Executes during object creation, after setting all properties.
function sdDupSNoEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sdDupSNoEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




function totDupNoEdit_Callback(hObject, eventdata, handles)
% hObject    handle to totDupNoEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of totDupNoEdit as text
%        str2double(get(hObject,'String')) returns contents of totDupNoEdit as a double
global hdOccurences sdOccurences hsOccurences hardDataPresent softDataPresent

if hardDataPresent
    useHard = 1;
else
    useHard = 0;
end
if softDataPresent
    useSoft = 1;
else
    useSoft = 0;
end
set(handles.totDupNoEdit,'String',...
    num2str(useHard*hdOccurences + useSoft*(sdOccurences+hsOccurences)));




% --- Executes during object creation, after setting all properties.
function totDupNoEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to totDupNoEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




function hdFinNoEdit_Callback(hObject, eventdata, handles)
% hObject    handle to hdFinNoEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of hdFinNoEdit as text
%        str2double(get(hObject,'String')) returns contents of hdFinNoEdit as a double
global ch hardDataPresent

if hardDataPresent
    set(handles.hdFinNoEdit,'String',num2str(size(ch,1)));
else
    set(handles.hdFinNoEdit,'String','No Hard Data');
end




% --- Executes during object creation, after setting all properties.
function hdFinNoEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hdFinNoEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




function sdFinNoEdit_Callback(hObject, eventdata, handles)
% hObject    handle to sdFinNoEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of sdFinNoEdit as text
%        str2double(get(hObject,'String')) returns contents of sdFinNoEdit as a double
global cs softDataPresent

if softDataPresent
    set(handles.sdFinNoEdit,'String',num2str(size(cs,1)));
else
    set(handles.sdFinNoEdit,'String','No Soft Data');
end




% --- Executes during object creation, after setting all properties.
function sdFinNoEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sdFinNoEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




function allDataFinNoEdit_Callback(hObject, eventdata, handles)
% hObject    handle to allDataFinNoEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of allDataFinNoEdit as text
%        str2double(get(hObject,'String')) returns contents of allDataFinNoEdit as a double
global ch cs hardDataPresent softDataPresent

if hardDataPresent
    useHard = 1;
else
    useHard = 0;
end
if softDataPresent
    useSoft = 1;
else
    useSoft = 0;
end
set(handles.allDataFinNoEdit,'String',...
    num2str(useHard*size(ch,1) + useSoft*size(cs,1)));




% --- Executes during object creation, after setting all properties.
function allDataFinNoEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to allDataFinNoEdit (see GCBO)
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

delete(handles.figure1);                             % Close the current window...
ip303outputGridWiz('Title','Output Configuration');  % ...and proceed to the previous unit.




% --- Executes on button press in nextButton.
function nextButton_Callback(hObject, eventdata, handles)
% hObject    handle to nextButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global timePresent
global KSprocessType

delete(handles.figure1);           % Close the current window...
switch KSprocessType
  case 1     % If using BME processing
    if timePresent                     % ...and proceed to appropriate screen.
      ip304p2TexplorAnal('Title','Exploratory Analysis');
    else
      ip304p2explorAnal('Title','Exploratory Analysis');
    end
  otherwise
      errordlg({'ip304p1explorAnal.m:nextButton_Callback Function:';...
              'The switch commands detected more options';...
              'than currently available (1) for KSprocessType.'},...
              'GUI software Error');
end
