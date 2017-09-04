function varargout = initObj(varargin)
% INITOBJ MATLAB code for initObj.fig
%      INITOBJ, by itself, creates a new INITOBJ or raises the existing
%      singleton*.
%
%      H = INITOBJ returns the handle to a new INITOBJ or the handle to
%      the existing singleton*.
%
%      INITOBJ('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in INITOBJ.M with the given input arguments.
%
%      INITOBJ('Property','Value',...) creates a new INITOBJ or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before initObj_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to initObj_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help initObj

% Last Modified by GUIDE v2.5 17-Nov-2015 11:46:59

import QMLi.*

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @initObj_OpeningFcn, ...
    'gui_OutputFcn',  @initObj_OutputFcn, ...
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


% --- Executes just before initObj is made visible.
function initObj_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to initObj (see VARARGIN)

p = inputParser;
p.addParameter('header', @ischar);
p.addParameter('data', @ischar);
p.parse(varargin{:});

header = p.Results.header;
data = p.Results.data;

% call the identify yourself function of the record
QMLi.record('idY', true);
load([tempdir 'tmp.mat']);
params = params(~strcmp(params,'idY'))'; %#ok<NODEF>

% set values from db to table
%params{strcmp(params,'datum'),2}=str2num(char(datetime( ...
    %data(strcmp(header,'timestamp')),'Format','ddMMyyyy h:mm:ss a'))); %#ok<ST2NM>
%quick fix
datetimecol = datetime( data(strcmp(header,'timestamp')),'Format','dd.MM.yyyy HH:mm:ss');
formatOut = 'yyyymmdd';
onlydate = datestr(datetimecol,formatOut);
params{strcmp(params,'datum'),2} = str2num(onlydate);

params{strcmp(params,'foldername'),2} = char(data(strcmp(header,'name')));
params{strcmp(params,'Camera'),2} = strrep(char(data(strcmp(header,'camera'))), '_', '');
params{strcmp(params,'trim'),2} = false;
params{strcmp(params,'trapCompensation'),2} = false;
params{strcmp(params,'padding'),2} = '[1, 1, 2, 1]';
params{strcmp(params,'hasNoAtoms'),2} = true;
params{strcmp(params,'cropOnLoad'),2} = true;
params{strcmp(params,'numFilter'),2} = 0.2;
params{strcmp(params,'IrisOpening'),2} = 'large';
params{strcmp(params,'cycle_id'),2} = 1;
params{strcmp(params,'formatspec'),2} = '%g';
params{strcmp(params,'hack'),2} = true;
params{strcmp(params,'inner_boundary'),2} = '[0, 0, 0, 0]';
params{strcmp(params,'outer_boundary'),2} = '[0, 0, 0, 0]';
params{strcmp(params,'cycle_id'),2} = 1;
params{strcmp(params,'tofs'),2} = 1;
params{strcmp(params,'id'),2} = data{strcmp(header,'id')};
params{strcmp(params,'loopvars'),2} = 1;
params{strcmp(params,'isQMC'),2} = false;
params{strcmp(params,'cleanUp'),2} = true;
params{strcmp(params,'trimRange'),2} = 1;

% try to gess the filename
prefix = char(data(strcmp(header,'loop_variables')));
if strcmp(prefix,'')
    filename = '#';
else
    filename = ['#' regexprep(prefix,'i_\d+','i_\*')];
    % find TOF string and replace time by $ if exist
    if regexp(filename, '(TOF_)(\d+)') > 0
        filename = regexprep(filename, ...
            '(TOF_)\d+(\.\d+([eE](-)?\d+)?)?', '$1$');
        params{strcmp(params,'tofs'),2} = 'tofs';
    end
    % find all other numbers prefixed by a valid variable name and
    % replace by ?
    if regexp(filename, '\_(\d+)') > 0
        % set the loopvariable name to the prefixed variable
        loopvars = regexprep(filename, '.+([\d\*])_(\w+)_\d+(\.\d+([eE](-)?\d+)?)?', '$2');
        filename = regexprep(filename, ...
            '(\w+)_\d+(\.\d+([eE](-)?\d+)?)?', '$1_?');
        params{strcmp(params,'loopvars'),2} = loopvars;
    end
end
params{strcmp(params,'filename'),2} = filename;
set(handles.uitableData, 'Data', params);

datetimecol = datetime( data(strcmp(header,'timestamp')),'Format','dd.MM.yyyy HH:mm:ss');
formatOut = 'yyyymmdd';
onlydate = datestr(datetimecol,formatOut);
formatOut = 'yyyy';
onlyyear = datestr(datetimecol,formatOut);

% set default value for script path
defaultPath = ['\\ixion\las_m\' ...
    'Archiv\2D\Experiment\' onlyyear '\'...
    onlydate ' Auswertung\'];% FIXME: make this path more generic!
set(handles.editScriptPath, 'String', defaultPath);
% set default value for script name
set(handles.editScriptName, 'String', ['call_' char(data(strcmp(header,'name'))),'.m']);
% set default value for object name
set(handles.editObjectName, 'String', char(data(strcmp(header,'name'))));

% Choose default command line output for initObj
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes initObj wait for user response (see UIRESUME)
% uiwait(handles.initObj);


% --- Outputs from this function are returned to the command line.
function varargout = initObj_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in pushbuttonGenerate.
function pushbuttonGenerate_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonGenerate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%% generate file
% build file path
fullPath = fullfile(get(handles.editScriptPath, 'String'), ...
    get(handles.editScriptName, 'String'));

% check if file already exists and ask if to append to that file
if exist(fullPath, 'file')
    choice = questdlg('Would you like to append the data to the existing file?', ...
        'File already exists!', ...
        'Yes','No','Yes');
    exists = 1;
else
    choice = 'Yes';
    exists = 0;
end

if strcmp(choice, 'Yes')
    % get data from table
    data = get(handles.uitableData, 'Data');
    
    % build code
    if ~exists
        code = {'% import QMLi package', 'import QMLi.*'};
    else
        code = {''};
    end
    code{end+1} = '';
    code{end+1} = ['%% initialize record object ' get(handles.editObjectName, 'String')];
    code{end+1} = '% IMPORTANT! You have to correct the datatype of the properties';
    code{end+1} = '% in order for this code to work properly.'; % FIXME: see printed comment
    code{end+1} = [get(handles.editObjectName, 'String') ' = QMLi.record( ...'];
    
    for i = 1:size(data,1)
        if i == size(data,1)
            suffix = ');';
        else
            suffix = ', ...';
        end
        cls = class(data{i,2});
        switch cls
            case 'char'
                %Quick fix
                operand = regexp(data{i,2},'\[.+\]');
                if size(operand) == 0
                    operand = 0;
                end
                if operand || strcmp(data{i,2},'loopvars') 
                    value = num2str(data{i,2});
                else
                    value = ['''' data{i,2} ''''];
                end
            case 'logical'
                if data{i,2}
                    value = 'true';
                else
                    value = 'false';
                end
            case 'double'
                value = num2str(data{i,2});
            case 'int32'
                value = num2str(data{i,2});
            otherwise
                value = ['''' data{i,2} ''''];
        end
        l = numel(data{i,1});
        code{end+1} = [blanks(4) '''' data{i,1} ''',' blanks(20-l) value suffix];
    end
    
    code{end+1} = '';
    code{end+1} = '% notify the database about this script';
    code{end+1} = ['% ' get(handles.editObjectName, 'String') '.dbSet(' ...
        '''scripts'', ''' fullPath ''');'];
    code{end+1} = '';
    code{end+1} = '% load data';
    code{end+1} = [get(handles.editObjectName, 'String') '.loadImages(''doReinaudi'', true);'];
    
    % open file for write access and append code
    fId = fopen(fullPath,'a');
    for row = 1:numel(code)
        fprintf(fId,'%s\n', code{row});
    end
    fclose(fId);
    
    % ask if another datset should be added and close calling figure if not
    choice = questdlg('Would you like to add another dataset?', ...
        'More data to work on?', ...
        'Yes','No','Yes');
    
    if strcmp(choice, 'No')
        close(gcbf);
    end
    close(gcf);
    h = matlab.desktop.editor.openDocument(fullPath);
    h.smartIndentContents;
    h.save;
end



function editScriptName_Callback(hObject, eventdata, handles)
% hObject    handle to editScriptName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editScriptName as text
%        str2double(get(hObject,'String')) returns contents of editScriptName as a double


% --- Executes during object creation, after setting all properties.
function editScriptName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editScriptName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editObjectName_Callback(hObject, eventdata, handles)
% hObject    handle to editObjectName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editObjectName as text
%        str2double(get(hObject,'String')) returns contents of editObjectName as a double


% --- Executes during object creation, after setting all properties.
function editObjectName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editObjectName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editScriptPath_Callback(hObject, eventdata, handles)
% hObject    handle to editScriptPath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editScriptPath as text
%        str2double(get(hObject,'String')) returns contents of editScriptPath as a double


% --- Executes during object creation, after setting all properties.
function editScriptPath_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editScriptPath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when user attempts to close initObj.
function initObj_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to initObj (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isequal(get(hObject, 'waitstatus'), 'waiting')
    % The GUI is still in UIWAIT, us UIRESUME
    uiresume(hObject);
else
    % The GUI is no longer waiting, just close it
    delete(hObject);
end


% --- Executes on button press in pushbuttonSelectFolder.
function pushbuttonSelectFolder_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonSelectFolder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fullPath = get(handles.editScriptPath,'String');

newPath = uigetdir(fullPath, 'Where to save script?');

if newPath
    set(handles.editScriptPath,'String',newPath)
end
