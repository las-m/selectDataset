function varargout = selectDataset(varargin)
% SELECTDATASET MATLAB code for selectDataset.fig
%      SELECTDATASET, by itself, creates a new SELECTDATASET or raises the existing
%      singleton*.
%
%      H = SELECTDATASET returns the handle to a new SELECTDATASET or the handle to
%      the existing singleton*.
%
%      SELECTDATASET('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SELECTDATASET.M with the given input arguments.
%
%      SELECTDATASET('Property','Value',...) creates a new SELECTDATASET or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before selectDataset_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to selectDataset_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help selectDataset

% Last Modified by GUIDE v2.5 07-Mar-2016 10:38:45

import QMLi.*;

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @selectDataset_OpeningFcn, ...
    'gui_OutputFcn',  @selectDataset_OutputFcn, ...
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


% --- Executes just before selectDataset is made visible.
function selectDataset_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to selectDataset (see VARARGIN)

% Choose default command line output for selectDataset
handles.output = hObject;

%Get the MatLab release the program is running on
matlabVersion = version('-release');
%I only care for the release year. I want it as double for comparison.
matlabVersion = str2double(matlabVersion(1:4));
%If it an earlier release than MatLab 2015a throw a warning
if matlabVersion < 2015
    warndlg(strcat('Your MatLab version is outdated. You might not be able to use',...
        ' this tools functionality to its full extent. Use MatLab 2015a or more up-to-date',...
        ' releases to have access to its full functionality.'));
end

% set default dates
set(handles.dateMax,'String',date); %today

%set(handles.dateMin,'String',...
%    char(datetime('today','Format','dd-MMM-yyy')-days(10))); %today - 10 days

% get afs tickets if the computer doesn't have them. Note that you must have the
%keytab file in the directory C:\Users\MyUserName\Misc\lasmlab1.keytab
% if QMLi.sharedFunctions.getAFSTicket
%     errordlg(strcat('Could not obtain AFS tickets. Your Keytab file may',...
%         'no be present in the default directory or has a name that makes it',...
%         'unrecognizeable for the program. The keytab file path must be',...
%         'C:\Users\MyUserName\Misc\lasmlab1.keytab.'));
% end

%set default table
handles.table = getTable();

% if exist load default values from default.mat
connString = loadSettings();

%Connect to the database
try
    conn = adodb_connect(connString, 60);
catch
    warndlg('Could not connect to the database.');
    return;
end
% load datasets
query = ['SELECT * FROM ', handles.table, ' WHERE timestamp > DATE_SUB(CURDATE(), INTERVAL 4 DAY);'];
try
    results = adodb_query(conn, query, handles);
    updateTable(handles, results);
catch
    warndlg('Could not load data. Try manually.')
end

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes selectDataset wait for user response (see UIRESUME)
% uiwait(handles.selectDataset);


% --- Outputs from this function are returned to the command line.
function varargout = selectDataset_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function editComment_Callback(hObject, eventdata, handles)
% hObject    handle to editComment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editComment as text
%        str2double(get(hObject,'String')) returns contents of editComment as a double


% --- Executes during object creation, after setting all properties.
function editComment_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editComment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editName_Callback(hObject, eventdata, handles)
% hObject    handle to editName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editName as text
%        str2double(get(hObject,'String')) returns contents of editName as a double


% --- Executes during object creation, after setting all properties.
function editName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonFilterResults.
function pushbuttonFilterResults_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonFilterResults (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

query = '';
% get name and comment search strings
dataName = validataSQLightQueryVariables(get(handles.editName, 'String'));
if ~strcmp(dataName, '')
    if ~strcmp(query, '')
        query = [query ' AND '];
    end
    query = [query 'name LIKE "' dataName '" '];
end

dataComment = validataSQLightQueryVariables(get(handles.editComment, 'String'));
if ~strcmp(dataComment, '')
    if ~strcmp(query, '')
        query = [query ' AND '];
    end
    query = [query 'comment LIKE "' dataComment '" '];
end

dateMax = validataSQLightQueryVariables(char(datetime(get(handles.dateMax, ...
    'String'), 'Format', 'yyyy-MM-dd;')));
if ~(strcmp(dateMax, '') || strcmp(dateMax,'NaT'))
    if ~strcmp(query, '')
        query = [query ' AND '];
    end
    query = [query 'timestamp <= date("' dateMax '") '];
end

dateMin = validataSQLightQueryVariables(char(datetime(get(handles.dateMin, ...
    'String'), 'Format', 'yyyy-MM-dd')));
if ~(strcmp(dateMin, '') || strcmp(dateMin,'NaT'))
    if ~strcmp(query, '')
        query = [query ' AND '];
    end
    query = [query 'timestamp >= date("' dateMin '") '];
end
if strcmp(query, '')
    query = ['SELECT * FROM ', handles.table, ''];
else
    query = ['SELECT * FROM ', handles.table, ' WHERE ' query];
end

query = [query ';'];
% if exist load default values from default.mat
connString = loadSettings();

%Connect to the database
conn = adodb_connect(connString, 60);
results = adodb_query(conn, query, handles);
updateTable(handles, results);

% --- Executes on button press in pushbuttonLoadSelectedDataset.
function pushbuttonLoadSelectedDataset_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonLoadSelectedDataset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% get index of selected cells
dbSelection = get(handles.uitableData, 'userData');

% get ids if the selected datasets
data = get(handles.uitableData, 'data');

% get all table headers and corresponding data of the selected line
header = get(handles.uitableData, 'ColumnName');
data = data(dbSelection(1),:);
% call object instanciation tool
initObj('header', header, 'data', data);

% --- Executes during object creation, after setting all properties.
function uitableData_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uitableData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

function table = getTable()
filename = 'config.mat';
if exist(filename, 'file') == 2
    config = load(filename);
    table = config.table;
else 
    error('The configuration file config.mat does not exist.');
end

% load the saved default values and construct connection string
function connectionString = loadSettings()
filename = 'config.mat';
if exist(filename, 'file') == 2
    config = load(filename);
    connectionString = strcat('Server=', config.server, '; ', ...
        'Database=', config.database, ';',...
        'uid=', config.user, '; ', ...
        'pwd=', config.password, '; ', ...
        'driver=', config.driver, '; ');
else
    warndlg(strcat('There is no configuration file.',...
        'Please enter your preferences in the sttings window.'))
end

% update table with sqlite results
function updateTable(handles, results)
if isstruct(results) && (length(fieldnames(results)) > 0)
    % convert sqlite result struct to table
    %TODO: Make this better
    try
        t = struct2table(results);
    catch
        t = struct2table(results,'AsArray',true);
    end
    % populate table with database results
    t = sortrows(t, -1);
    set(handles.uitableData, 'ColumnName', t.Properties.VariableNames);
    set(handles.uitableData, 'data', table2cell(t));
else
    warndlg('An error occured. There was no data output from your query.')
end

% validate SQLite query
function queryVariable = validataSQLightQueryVariables(queryVariable)
% FIXME: add more SQL validation code here!
if isempty(queryVariable)
    queryVariable = '';
end

% --- Executes when user attempts to close selectDataset.
function selectDataset_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to selectDataset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: delete(hObject) closes the figure
delete(hObject);


% --- Executes on button press in pushbuttonEditData.
function pushbuttonEditData_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonEditData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
toggleEditMode(hObject, handles);

% toogle edit mode
function toggleEditMode(hObject, handles)
tableSize = size(get(handles.uitableData, 'Data'));
setEditable = ones(1,tableSize(2));
setEditable(1) = 0;

editString = 'Edit Data';
discardString = 'Discard Changes';

if strcmp(get(handles.pushbuttonEditData, 'String'), discardString);
    setEditable(:) = 0;
    setEditable = logical(setEditable);
    set(handles.uitableData, 'ColumnEditable', setEditable);
    set(handles.pushbuttonEditData, 'String', editString);
    set(handles.pushbuttonFilterResults, 'Enable', 'on');
    set(handles.pushbuttonSaveData, 'Enable', 'off');
    clear handles.tableDataTmp;
    guidata(hObject,handles);
else
    setEditable = logical(setEditable);
    set(handles.uitableData, 'ColumnEditable', setEditable);
    set(handles.pushbuttonEditData, 'String', discardString);
    set(handles.pushbuttonFilterResults, 'Enable', 'off');
    set(handles.pushbuttonSaveData, 'Enable', 'on');
    handles.tableDataTmp = get(handles.uitableData, 'Data');
    guidata(hObject,handles);
end

% --- Executes on button press in pushbuttonSaveData.
function pushbuttonSaveData_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonSaveData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%% check for changed datasets
% get actual data from table
tableDataNew = get(handles.uitableData, 'Data');

% get content of unchanged table
tableDataOld = handles.tableDataTmp;

% find all rows with changed data
changedDataIdx = (sum(cellfun(@isequal,tableDataOld,tableDataNew),2) == size(tableDataOld,2));
% get corresponding indices
changedData = tableDataNew(~changedDataIdx,:)';
% get column headers
columnHeaders = get(handles.uitableData, 'ColumnName');

% loop over all changed ids and change data in sqlite db
for i = 1:size(changedData,2)
    % construct query
    query = ['UPDATE ', handles.table, ' SET '];
    for j = 2:numel(columnHeaders)
        if ~isnan(changedData{j,i})
            if strcmp(columnHeaders{j},'timestamp')
                query = [query columnHeaders{j} ' = STR_TO_DATE("' changedData{j,i} '","%d%m%Y %r")'];
            else
                query = [query columnHeaders{j} ' = "' changedData{j,i} '"'];
            end
            if j ~= numel(columnHeaders)
                query = [query ', '];
            end
        end
    end
    
    % if exist load default values from default.mat
    connString = loadSettings();
    
    %Connect to the database
    conn = adodb_connect(connString, 60);
    if strcmp(query(end-1:end),', ');
        query = query(1:end-2);
    end
    query = [query ' WHERE id = "' num2str(changedData{1,i}) '";'];
    query = strrep(query, '\', '\\');
    %If every column has value NaN ignore it. It isnt editable anyways
    x = findstr(query, 'SET');
    y = findstr(query, 'WHERE');
    if ~strcmp(query(x+3:y-1),'  ');
        try
            results = adodb_query(conn, query, handles);
        catch
            warndlg('An error occured while updating the table');
        end
    end
end

toggleEditMode(hObject, handles);


% --- Executes on button press in pushbuttonExecQuery.
function pushbuttonExecQuery_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonExecQuery (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
connString = loadSettings();

%Connect to the database
conn = adodb_connect(connString, 60);

query = get(handles.editQuery, 'String');
results = adodb_query(conn, query, handles);
querylog = get(handles.textSQLquery, 'String');
querylog = flipud(querylog);
querylog{end+1} = query;
querylog = flipud(querylog);
set(handles.textSQLquery, 'String', querylog);

updateTable(handles, results);


function editQuery_Callback(hObject, eventdata, handles)
% hObject    handle to editQuery (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editQuery as text
%        str2double(get(hObject,'String')) returns contents of editQuery as a double


% --- Executes during object creation, after setting all properties.
function editQuery_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editQuery (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in ConnectionEstablished.
function ConnectionEstablished_Callback(hObject, eventdata, handles)
% hObject    handle to ConnectionEstablished (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ConnectionEstablished



function dateMin_Callback(hObject, eventdata, handles)
% hObject    handle to dateMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dateMin as text
%        str2double(get(hObject,'String')) returns contents of dateMin as a double


% --- Executes during object creation, after setting all properties.
function dateMin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dateMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function dateMax_Callback(hObject, eventdata, handles)
% hObject    handle to dateMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dateMax as text
%        str2double(get(hObject,'String')) returns contents of dateMax as a double


% --- Executes during object creation, after setting all properties.
function dateMax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dateMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in dateMaxCalendar.
function dateMaxCalendar_Callback(hObject, eventdata, handles)
% hObject    handle to dateMaxCalendar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
uicalendar('DestinationUI', {handles.dateMax, 'String'}, 'WindowStyle', 'Modal')

% --- Executes on button press in dateMaxCalendar.
function dateMinCalendar_Callback(hObject, eventdata, handles)
% hObject    handle to dateMaxCalendar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
uicalendar('DestinationUI', {handles.dateMin, 'String'})

function ado_connection = adodb_connect(connection_str, timeout)

% Connects to ADO OLEDB using the Microsoft ActiveX Data Source Control
% Inputs:
%  connection_str - string containing information needed for connecting to
%   the database.
%  timeout - CommandTimeout in seconds (default=60 seconds if unspecified)
% Output:
%   ado_connection - ADO connection object

if nargin<2, timeout = 60; end
ado_connection = actxserver('ADODB.Connection'); % Create activeX control
ado_connection.CursorLocation = 'adUseClient';   % Uses a client-side cursor supplied by a local cursor library
ado_connection.CommandTimeout = timeout;         % Specify connection timeout
ado_connection.Open(connection_str);             % Open connection

function [Struct, Table] = adodb_query(ado_connection, sql, handles)

% [Struct Table] = adodb_query(cn, sql)
% adoledb_query    Executes the sql statement against the connection ado_connection
% Inputs:
% ado_connection - open connection to ADO OLEDB ActiveX Data Source Control
% sql            - SQL statement to be executed
% Output:
% Struct     - query results in struct (or array of structs) format
% Table    - query results table (or array of tables) format
% Notes:
% Convert cells to strings using char. Convert cells to numeric
% data using cell2mat() for ints or double(cell2mat()) for floats

%% Run Querry
ado_recordset = ado_connection.Execute(sql);

%% Parse Recordsat
iSet = 1;
Struct{iSet} = [];                   % initialize space for output
Table {iSet} = [];
while (~isempty(ado_recordset))      % loop through all ado_recordsets
    if (ado_recordset.State && ado_recordset.RecordCount>0)
        table = ado_recordset.GetRows';  % retrieve data from recordset
        result = [];
        Fields = ado_recordset.Fields;   % retrive all Fields with column names
        for col = 1:Fields.Count         % loop through all columns
            ColumnName = Fields.Item(col-1).Name; % get column name
            name = genvarname(lower(ColumnName)); % convert it to a valid MATLAB field name
            ColumnName = regexprep(ColumnName, 'Expr\d\d\d\d', ''); % MS Access uses Expr1000 etc. when column name can not be deduced
            if (isempty(ColumnName)),
                name = char('A'-1+col);      % if column without name than use A, B, C, ... as column names
            end
            if (size(table,1)==1)          % is table a vector ?
                Res = table{col};
                if (numel(Res)==0 || strcmpi(Res, 'N/A') || isnan(all(Res))), Res=[];
                end
            else                           % is table a matrix?
                Res = table(:,col);
            end
            result.(name) = Res;
        end
        Struct{iSet} = result;
        Table {iSet} = table;
        iSet = iSet+1;
    end
    try
        ado_recordset = ado_recordset.NextRecordset(); % go to the next recordset
    catch  %#ok<CTCH> % some DB do not support NextRecordset
        break;
    end
end

%% Return the first nonempty recordset

Struct = Struct{1};
Table  = Table{1};


% --------------------------------------------------------------------
function Untitled_1_Callback(hObject, eventdata, handles)
% hObject    handle to Options (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Settings_Callback(hObject, eventdata, handles)
% hObject    handle to Settings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Options_Callback(hObject, eventdata, handles)
% hObject    handle to Options (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function DB_Settings_Callback(hObject, eventdata, handles)
% hObject    handle to DB_Settings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fig = DBSettings;
uiwait(fig);

if isdeployed
    filename = fullfile(ctfroot, 'config.mat');
else
    filename = strcat(pwd,'\config.mat');
end

try
    config = load(filename);
catch
    warndlg('Could not update settings')
end
handles.table = config.table;
guidata(hObject, handles);
