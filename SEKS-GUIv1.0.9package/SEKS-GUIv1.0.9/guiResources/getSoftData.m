function [sdFilename,sdPathname]=getSoftData(handles)
% This function is designed to obtain the soft data from the user-specified
% location

global sdFilename sdPathname;
global currentDir;

[sdFilename,sdPathname] = uigetfile({'*.txt';'*.xls'},'Select Soft Data file');
%
% If user presses 'Cancel' then 0 is returned.
% Should anything go wrong, we use the following criterion
%
if ~ischar(sdFilename)
    set(handles.fileChoiceEdit,'String','No Soft Data file present');
    return
else
    set(handles.fileChoiceEdit,'String',sdFilename);
    currentDir=sdPathname;
end