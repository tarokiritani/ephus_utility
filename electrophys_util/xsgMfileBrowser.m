function varargout = xsgMfileBrowser(varargin)
% XSGMFILEBROWSER MATLAB code for xsgMfileBrowser.fig
%      XSGMFILEBROWSER, by itself, creates a new XSGMFILEBROWSER or raises the existing
%      singleton*.
%
%      H = XSGMFILEBROWSER returns the handle to a new XSGMFILEBROWSER or the handle to
%      the existing singleton*.
%
%      XSGMFILEBROWSER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in XSGMFILEBROWSER.M with the given input arguments.
%
%      XSGMFILEBROWSER('Property','Value',...) creates a new XSGMFILEBROWSER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before xsgMfileBrowser_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to xsgMfileBrowser_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help xsgMfileBrowser

% Last Modified by GUIDE v2.5 12-Sep-2011 20:22:35

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @xsgMfileBrowser_OpeningFcn, ...
                   'gui_OutputFcn',  @xsgMfileBrowser_OutputFcn, ...
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


% --- Executes just before xsgMfileBrowser is made visible.
function xsgMfileBrowser_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to xsgMfileBrowser (see VARARGIN)

% Choose default command line output for xsgMfileBrowser
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes xsgMfileBrowser wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = xsgMfileBrowser_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --------------------------------------------------------------------
function File_util_Callback(hObject, eventdata, handles)
% hObject    handle to File_util (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function openCellFolder_Callback(hObject, eventdata, handles)
% hObject    handle to openCellFolder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[f, p] = uigetfile('C:\Users\kiritani\Documents\data\*.sqlite3','select .sqlite3 file');
handles.sqlite = fullfile(p, f);
handles.dataFolder = uigetdir('C:\Users\kiritani\Documents\data','select Data Folder');
handles.xsgFolder = fullfile(handles.dataFolder, 'cells');

% append path name to cellList for MfilesMap
mksqlite('open', handles.sqlite)
expNum = mksqlite('SELECT DISTINCT experiment_number FROM Cells ORDER BY experiment_number');
expNum = struct2cell(expNum);
handles.expNum = expNum;
guidata(hObject, handles);

set(handles.listbox1,'String',expNum);


% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox1

contents = cellstr(get(hObject,'String'));
cellFolder = contents(get(hObject,'Value'));

mouse_command = ['SELECT Mice.* FROM Mice LEFT JOIN Cells ON Mice.id = Cells.mouse_id',...
' LEFT JOIN ViralInjections ON Mice.id = ViralInjections.mouse_id WHERE',...
' exp_number = ','''', cellFolder{1}, ''''];

mouseInfo = mksqlite(mouse_command);

viral_command = ['SELECT * FROM ViralInjections WHERE mouse_id = ', num2str(mouseInfo(1).id)];

virusInfo = mksqlite(viral_command);

cell_command = ['SELECT * FROM Cells WHERE exp_number =', '''',cellFolder{1}, ''''];

cellInfo = mksqlite(cell_command);

try
    pMouse = parseStruct(mouseInfo(1));
catch
    pMouse = {''};
end

pVirus = {};
if length(virusInfo) > 0
    for k = 1:length(virusInfo)
        try
            pVirus = [pVirus; parseStruct(virusInfo(k))];
        catch
            pVirus = [pVirus; {''}];
        end
    end    
end

pCell = {};
if length(cellInfo) > 0
    for m = 1:length(cellInfo)
        try
            pCell = [pCell; parseStruct(cellInfo(m))];
        catch
            pCell = [pCell; {''}];
        end
    end
end

metaData = ['MOUSE INFO:';pMouse;{''};'VIRUS INFO:';pVirus;{''};'CELL INFO:';pCell];
 
set(handles.text8,'String',metaData);

% below is the code from xsgBrowser
cellFolder = strrep(cellFolder,'.m','');
cd(fullfile(handles.xsgFolder, cellFolder{1,1}));
xsgList = dir('*.xsg');
handles.xsgList = xsgList;
handles.cellFolder = cellFolder{1,1};
if isempty(xsgList)
    recList = [];
else
    for k = 1:length(xsgList)
        recList{k} = xsgList(k).name(7:14);
    end
end
set(handles.uitable1,'RowName',recList)

% show pictures if pic mode is on.
if get(handles.checkbox2,'Value') == 1
    im1 = dir(fullfile(handles.xsgFolder,handles.cellFolder,'images','*.TIF'));
    im2 = dir(fullfile(handles.xsgFolder,handles.cellFolder,'images','*.tif'));
    im3 = dir(fullfile(handles.xsgFolder,handles.cellFolder,'images','*.fig'));
    im4 = dir(fullfile(handles.xsgFolder,handles.cellFolder,'images','*.tiff'));
    imfiles = [im1;im2;im3;im4];
    try
        close(handles.hfig)
    end
    scrsz = get(0,'ScreenSize');
    handles.hfig = figure('Position',[scrsz(3)/5 scrsz(4)/5 scrsz(3)*4/5 scrsz(4)*4/5]);
    numFig = length(imfiles);
    if (sqrt(numFig) - floor(sqrt(numFig))) > 0.001
        FigSeq = floor(sqrt(numFig)) + 1;
    else
        FigSeq = sqrt(numFig);
    end
    for fNum = 1:numFig
        subplot(FigSeq, FigSeq, fNum)
        A = expdatautil.imageCDataFromFile(fullfile(handles.xsgFolder, handles.cellFolder, 'images', imfiles(fNum).name));
        figure(handles.hfig)
        imagesc(A)
        set(gca,'XTick',[])
        set(gca,'YTick',[])
    end
    colormap('gray')
end
guidata(hObject, handles)

% --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --------------------------------------------------------------------
function openMfile_Callback(hObject, eventdata, handles)
% hObject    handle to openMfile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

contents = get(handles.listbox1, 'String');
cellFolder = contents(get(handles.listbox1, 'Value'));
cellFolder = strrep(cellFolder,'.m','');
file = fullfile(handles.xsgFolder, cellFolder, [cellFolder,'.m']);
edit(file{1});


% --- Executes when selected cell(s) is changed in uitable1.
function uitable1_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to uitable1 (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)
try    
    handles = rmfield(handles, 'multChannels');    
end

handles.multChannels = plotTraces(handles, eventdata);

guidata(hObject, handles)

function multChannels = plotTraces(handles, eventdata)
% javaclasspath('C:\Data\Taro\codeRepo\java_codes\electrophysiologyexperiment\bin');

ephysChannels = unique(eventdata.Indices(:,2));
ephysChannels = sort(ephysChannels);
numOfChannels = length(ephysChannels);
try
    traceObj = findobj(gcf,'Type','axes');
    
    for n = 1:length(traceObj)
        delete(traceObj(n))
    end
end

% make axes
% multChannels = sliceexperiments.MultChannelTrace();
multChannels = cell(1,2);
rowInd = 1;
for k = 1:numOfChannels
    plotHeight = 800/numOfChannels - 10;
    axes('Parent',gcf,'units','pixels',...
        'Position',[600 (plotHeight*(k-1) + 30) 450 plotHeight-20]);
    set(gca,'Tag','trace')

    chNum = ephysChannels(k);
    expNum = find(eventdata.Indices(:,2) == chNum);
    expNum = eventdata.Indices(expNum, 1);
%     traceSets = sliceexperiments.TraceSets();
    averageTrace = [];
    
    for p = 1:length(expNum)
        traceFile = fullfile(handles.xsgFolder, handles.cellFolder, handles.xsgList(expNum(p)).name);
        traceData = load(traceFile, '-mat');
        traceData = getfield(traceData.data.ephys,['trace_',num2str(chNum)]);
        if isempty(averageTrace)
            averageTrace = traceData;
        else
            averageTrace = averageTrace + traceData;
        end
        multChannels{rowInd,1} = traceFile;
        multChannels{rowInd,2} = chNum;
        rowInd = rowInd + 1;
    end
    averageTrace = averageTrace / p;
%     for p = 1:length(expNum)
%         traceFile = fullfile(handles.xsgFolder, handles.cellFolder, handles.xsgList(expNum(p)).name);
%         traceData = load(traceFile, '-mat');
%         traceData = getfield(traceData.data.ephys,['trace_',num2str(chNum)]);
%         traceSets.addTrace(sliceexperiments.Trace(traceData, chNum, traceFile));
%     end
%     averageTrace = traceSets.getAverage();
    traceData = load(traceFile,'-mat');
    timedata = ((0 : traceData.header.ephys.ephys.sampleRate * traceData.header.ephys.ephys.traceLength - 1) / ...
            traceData.header.ephys.ephys.sampleRate)';
        
    plot(timedata,averageTrace)
    title(chNum)

%     multChannels.addTraceSets(traceSets);
end

% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Analysis_Callback(hObject, eventdata, handles)
% hObject    handle to Analysis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Vstep_Callback(hObject, eventdata, handles)
% hObject    handle to Vstep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
    vStepData = handles.multChannels;
end
vstep = electrophysiology.VStep(vStepData{1,1}, vStepData{1,2});
[Rs, Ri, tau, Cm] = vstep.calcParams;
disp('Rs, Ri, tau, Cm');
disp([Rs, Ri, tau, Cm])
[p, f] = fileparts(vStepData{1,1});
expNum = f(1:6);
filePath = fullfile(handles.dataFolder,'Taro','ANALYSIS','intrinsics','vstep', [expNum,'vstep',num2str(vStepData{1,2}),'.mat']);
disp('is the file path right? double check. rewritten with fullfile.')
[fs, ps,filter] = uiputfile('*.mat','save series',filePath);
if filter == 0
    return
end
filePath = fullfile(ps,fs);
save(filePath,'vstep');


vstepinfo = ['vsteps',num2str(vStepData{1,2}),' = ''',filePath,'''',';'];
disp(vstepinfo)

mksqlite('open',handles.sqlite);

s = mksqlite(['SELECT id FROM Cells WHERE exp_number = ''', expNum,''' AND channel_num = ', num2str(vStepData{1,2})]);
intrinsic = mksqlite(['SELECT * FROM Intrinsics WHERE cell_id = ', num2str(s.id)]);

% there must be a better way.
if isempty(intrinsic)
    mksqlite(['INSERT INTO Intrinsics (cell_id, vstep) VALUES (', num2str(s.id), ', ''', filePath, ''')']);
else
    mksqlite(['UPDATE Intrinsics SET vstep = ''', filePath, ''' WHERE cell_id = ' num2str(s.id)]);
end

% --------------------------------------------------------------------
function Istep_Callback(hObject, eventdata, handles)
% hObject    handle to Istep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
    iStepData = handles.multChannels;
end

if sum(cell2mat(iStepData(:,2)) - cell2mat(iStepData(1,2))) ~= 0
    error('only one channel is accepted')
end
isteps = electrophysiology.ISteps(iStepData(:,1), cell2mat(iStepData(1,2)));

% Construct a questdlg with two options: at resting or -70 mV
choice = questdlg('what is the holding potential?', ...
	'options', ...
	'-70','rest','rest');
% Handle response
switch choice
    case 'rest'
        suffix = '';
    case '-70'
        suffix = '_neg70';
        i = inputdlg('injected current (pA)');
        i = str2double(i);
        isteps.setHoldingCurrent(i)
end

% save the object.
[p, f] = fileparts(iStepData{1,1});
expNum = f(1:6);
filePath = fullfile(handles.dataFolder,'Taro','ANALYSIS','intrinsics','istep', [expNum, 'istep', num2str(iStepData{1,2}), suffix,'.mat']);
disp('double check the file path. should be all right, but rewritten with fullfile')
[fs, ps,filter] = uiputfile('*.mat','save series',filePath);
if filter == 0
    return
end
filePath = fullfile(ps,fs);
save(filePath,'isteps');

% manipulate the sql file.
disp('% ************* intrinsics *************%')
istepinfo = ['isteps',num2str(iStepData{1,2}),suffix,' = ''',filePath,'''',';'];
disp(istepinfo)

mksqlite('open',handles.sqlite);

s = mksqlite(['SELECT id FROM Cells WHERE exp_number = ''', expNum,''' AND channel_num = ', num2str(iStepData{1,2})]);
intrinsic = mksqlite(['SELECT * FROM Intrinsics WHERE cell_id = ', num2str(s.id)]);

% there must be a better way.
if isempty(intrinsic)
    mksqlite(['INSERT INTO Intrinsics (cell_id, istep',suffix,') VALUES (', num2str(s.id), ', ''', filePath, ''')']);
else
    mksqlite(['UPDATE Intrinsics SET istep',suffix,' = ''', filePath, ''' WHERE cell_id = ' num2str(s.id)]);
end


% --------------------------------------------------------------------
function openAutoNote_Callback(hObject, eventdata, handles)
% hObject    handle to openAutoNote (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
edit([[handles.xsgFolder],'\',[handles.cellFolder],'\',handles.cellFolder,'.txt'])

% --------------------------------------------------------------------
function uipushtool1_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to uipushtool1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
plotedit;


% --------------------------------------------------------------------
function ChR_series_Callback(hObject, eventdata, handles)
% hObject    handle to ChR_series (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
    iStepData = handles.multChannels;
end
seriesSet = CellArrayList;
for k = unique(cell2mat(iStepData(:,2)))';
    f = iStepData(cell2mat(iStepData(:,2)) == k);
    seriesType = {'IChRSeries', 'VChRSeries', 'CellAttachedChRSeries'};
    t = listdlg('PromptString','What kind of TraceSeries?','ListString', seriesType);
    tSeries = eval(['electrophysiology.', seriesType{t},'(f, ',num2str(k),')']);
    seriesSet.add(tSeries);
end
series = electrophysiology.GroupedSeries(seriesSet);

[p, f] = fileparts(iStepData{1,1});
expNum = f(1:6);
filePath = fullfile(handles.dataFolder,'Taro','ANALYSIS','rabies_ChR','ChRGroupSeries', expNum);

[fs, ps,filter] = uiputfile('*.mat','save series',filePath);
if filter == 0
    return
end
filePath = fullfile(ps,fs);
disp('in addition to ChRGroupSeries, insert into ChRGroupSeriesCell.')
save(filePath,'series');

mksqlite('open',handles.sqlite);
mksqlite(['INSERT INTO ChRGroupSeries (group_object) VALUES (''', filePath, ''')']);
series_id = mksqlite(['SELECT id FROM ChRGroupSeries WHERE group_object = ''', filePath,'''']);
for n = unique(cell2mat(iStepData(:,2)))';
cell_id = mksqlite(['SELECT id FROM Cells WHERE exp_number = ''',expNum, ''' AND channel_num = ', num2str(n)]);

mksqlite(['INSERT INTO ChRGroupSeriesCell (chrgroupseries_id, cell_id) VALUES (',...
    num2str(series_id.id),', ',num2str(cell_id.id),')']);
end


% --------------------------------------------------------------------
function ChRfreqStep_Callback(hObject, eventdata, handles)
% hObject    handle to ChRfreqStep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
    stepData = handles.multChannels;
end

series = electrophysiology.IChRSeries(stepData(:,1), stepData(:,2));
[p, f] = fileparts(stepData{1,1});
expNum = f(1:6);
chNum = cell2mat(stepData(1,2));
filePath = fullfile(handles.dataFolder,'Taro', 'ANALYSIS', 'rabies_ChR','ChRFreqStep',[expNum,'ch', num2str(chNum),'.mat']);
disp('rewritten with fullfile, needs double-checking')

keyboard; % this is no good. rewrite with uiputfile.
[fs, ps,filter] = uiputfile('*.mat','save series',filePath);
if filter == 0
    return
end
filePath = fullfile(ps,fs);
seriesType = {'IChRSeries', 'VChRSeries', 'CellAttachedChRSeries'};
t = listdlg('PromptString','What kind of TraceSeries?','ListString', seriesType);
save(filePath,'series');

mksqlite('open',handles.sqlite);
s = mksqlite(['SELECT id FROM Cells WHERE exp_number = ''', expNum,''' AND channel_num = ', num2str(chNum)]);
intrinsic = mksqlite(['SELECT * FROM ChRFreqStep WHERE cell_id = ', num2str(s.id)]);
% there must be a better way.
if isempty(intrinsic)
    mksqlite(['INSERT INTO ChRFreqStep (cell_id, step_object, type) VALUES (', num2str(s.id), ', ''', filePath, ''' ,''', seriesType{t},''')']);
else
    mksqlite(['UPDATE ChRFreqStep SET step_object = ''', filePath, ''', type = ''', seriesType{t},''' WHERE cell_id = ' num2str(s.id)]);
end

% --------------------------------------------------------------------
function ChRdurStep_Callback(hObject, eventdata, handles)
% hObject    handle to ChRdurStep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
    stepData = handles.multChannels;
end

if sum(cell2mat(stepData(:,2)) - cell2mat(stepData(1,2))) ~= 0
    error('only one channel is accepted')
end
chNum = cell2mat(stepData(1,2));
series = electrophysiology.IChRSeries(stepData(:,1), chNum);

% save the series object.
[p, f] = fileparts(stepData{1,1});
expNum = f(1:6);
filePath = fullfile(handles.dataFolder,'Taro','ANALYSIS','rabies_ChR','ChRDurStep',[expNum,'ch', num2str(chNum),'.mat']);
[fs, ps,filter] = uiputfile('*.mat','save series',filePath);
if filter == 0
    return
end
filePath = fullfile(ps,fs);
seriesType = {'IChRSeries', 'VChRSeries', 'CellAttachedChRSeries'};
t = listdlg('PromptString','What kind of TraceSeries?','ListString', seriesType);
save(filePath,'series');


mksqlite('open',handles.sqlite);
s = mksqlite(['SELECT id FROM Cells WHERE exp_number = ''', expNum,''' AND channel_num = ', num2str(chNum)]);
intrinsic = mksqlite(['SELECT * FROM ChRDurationStep WHERE cell_id = ', num2str(s.id)]);
% there must be a better way.
if isempty(intrinsic)
    mksqlite(['INSERT INTO ChRDurationStep (cell_id, duration_object, type) VALUES (', num2str(s.id), ', ''', filePath, ''' ,''', seriesType{t},''')']);
else
    mksqlite(['UPDATE ChRDurationStep SET duration_object = ''', filePath, ''', type = ''', seriesType{t},''' WHERE cell_id = ' num2str(s.id)]);
end




% --------------------------------------------------------------------
function exportFileMap_Callback(hObject, eventdata, handles)
% hObject    handle to exportFileMap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

mfiles = cell(handles.Mfiles.keySet.toArray);
% append folder names and convert to absolute path.
mfiles = cell2mat(mfiles);
mfiles = mfiles(:,[1:6]);
mfiles = [mfiles, repmat('\',size(mfiles,1),1), mfiles, repmat('.m',size(mfiles,1),1)];
mfiles = [repmat([handles.xsgFolder, '\'],size(mfiles, 1), 1), mfiles];
mat2cell(mfiles, ones(1,size(mfiles, 1)), size(mfiles,2))

% uisave('mfiles');


% --------------------------------------------------------------------
function openExplorer_Callback(hObject, eventdata, handles)
% hObject    handle to openExplorer (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

folder = fullfile(handles.xsgFolder, handles.cellFolder);
winopen(folder)


% --------------------------------------------------------------------
function exportFilesWithCellTypes_Callback(hObject, eventdata, handles)
% hObject    handle to exportFilesWithCellTypes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% to be rewritten after implementing relational database. this fcn does not 
% have to be very readable or efficient because I will not maintain
% this function for a long time anyways.

keys = handles.Mfiles.keySet.toArray;
ctype = inputdlg('what kind of cell?');
cellList = [];

for k = 1:handles.Mfiles.keySet.size
    mfile = handles.Mfiles.get(keys(k));
    
    for m = 1:4
        c = mfile.get(['cellType',num2str(m)]);
        
        if strcmp(c, ctype{1,1})
            cellList = [cellList,'\n','''',strrep(char(mfile.getFileName),'\','\\'),'''',', ',num2str(m),';'];    
        end
    end   
end

sprintf(cellList)

% --------------------------------------------------------------------
function calcVm_Callback(hObject, eventdata, handles)
% hObject    handle to calcVm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
    data = handles.multChannels;
end

vm = electrophysiology.ITrace(data{1,1},data{1,2}).getYdata;
vm = mean(vm(1:1000))

[p, f] = fileparts(data{1,1});
fileName = f(1:6);

mksqlite('open',handles.sqlite);
s = mksqlite(['SELECT id FROM Cells WHERE exp_number = ''', fileName,''' AND channel_num = ', num2str(data{1,2})]);
intrinsic = mksqlite(['SELECT * FROM Intrinsics WHERE cell_id = ', num2str(s.id)]);

% there must be a better way.
if isempty(intrinsic)
    mksqlite(['INSERT INTO Intrinsics (cell_id, resting_potential) VALUES (', num2str(s.id), ', ', num2str(vm), ')']);
else
    mksqlite(['UPDATE Intrinsics SET resting_potential = ', num2str(vm), ' WHERE cell_id = ' num2str(s.id)]);
end

function edit9_Callback(hObject, eventdata, handles)
% hObject    handle to edit9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit9 as text
%        str2double(get(hObject,'String')) returns contents of edit9 as a double
command = get(hObject,'String');
data = mksqlite(command);

for k = 1:length(data)
    c{1,k} = data(k).exp_number;
end

if ~exist('c', 'var')
    disp('no cells matched.')
    return
else
    handles.expNum = c;
end
set(handles.listbox1, 'String', handles.expNum);
guidata(hObject, handles)

% --- Executes during object creation, after setting all properties.
function edit9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function p = parseStruct(s)

k = fieldnames(s);
space = cell(length(k), 1);
v = cell(length(k), 1);
for m = 1:length(k)
    space{m} = ':  ';
    v{m} = getfield(s, k{m});
    if isnumeric(v{m})
        v{m} = num2str(v{m});
    end
end
kspace = strcat(k, space);
p = strcat(kspace, v);


% --------------------------------------------------------------------
function ChRAnalysis_Callback(hObject, eventdata, handles)
% hObject    handle to ChRAnalysis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function ChRIntStep_Callback(hObject, eventdata, handles)
% hObject    handle to ChRIntStep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
    stepData = handles.multChannels;
end

if sum(cell2mat(stepData(:,2)) - cell2mat(stepData(1,2))) ~= 0
    error('only one channel is accepted')
end
chNum = cell2mat(stepData(1,2));
series = electrophysiology.IChRSeries(stepData(:,1), chNum);

seriesType = {'IChRSeries', 'VChRSeries', 'CellAttachedChRSeries'};
t = listdlg('PromptString','What kind of TraceSeries?','ListString', seriesType);

[p, f] = fileparts(stepData{1,1});
expNum = f(1:6);

filePath = fullfile(handles.dataFolder,'Taro','ANALYSIS','rabies_ChR','ChRIntensityStep', [expNum, 'ch', num2str(chNum), '.mat']);
[fs, ps,filter] = uiputfile('*.mat','save series',filePath);
if filter == 0
    return
end
filePath = fullfile(ps,fs);
save(filePath,'series');

mksqlite('open',handles.sqlite);

s = mksqlite(['SELECT id FROM Cells WHERE exp_number = ''', expNum,''' AND channel_num = ', num2str(chNum)]);
intStep = mksqlite(['SELECT * FROM ChRIntensityStep WHERE cell_id = ', num2str(s.id)]);

% there must be a better way.
if isempty(intStep)
    mksqlite(['INSERT INTO ChRIntensityStep (cell_id, step_object, type) VALUES (', num2str(s.id), ', ''', filePath, ''', ''',seriesType{t},''')']);
else
    mksqlite(['UPDATE ChRIntensityStep SET step_object = ''', filePath, ''' WHERE cell_id = ' num2str(s.id)]);
end


% --------------------------------------------------------------------
function ChRIntCellAttached_Callback(hObject, eventdata, handles)
% hObject    handle to ChRIntCellAttached (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
    stepData = handles.multChannels;
end

if sum(cell2mat(stepData(:,2)) - cell2mat(stepData(1,2))) ~= 0
    error('only one channel is accepted')
end
chNum = cell2mat(stepData(1,2));
series = electrophysiology.CellAttachedSeries(stepData(:,1), chNum);


[p, f] = fileparts(stepData{1,1});
expNum = f(1:6);
filePath = fullfile(handles.dataFolder,'Taro','ANALYSIS','rabies_ChR','ChRIntensityStep', [fileName, 'ch', num2str(chNum), '.mat']);
keyboard; % make sure that file path is ok.
[fs, ps,filter] = uiputfile('*.mat','save series',filePath);
if filter == 0
    return
end
filePath = fullfile(ps,fs);
save(filePath,'series');


mksqlite('open',handles.sqlite);
s = mksqlite(['SELECT id FROM Cells WHERE exp_number = ''', expNum,''' AND channel_num = ', num2str(chNum)]);
intStep = mksqlite(['SELECT * FROM ChRIntensityStepCellAttached WHERE cell_id = ', num2str(s.id)]);
% there must be a better way.
if isempty(intStep)
    mksqlite(['INSERT INTO ChRIntensityStepCellAttached (cell_id, step_object) VALUES (', num2str(s.id), ', ''', filePath, ''')']);
else
    mksqlite(['UPDATE ChRIntensityStepCellAttached SET step_object = ''', filePath, ''' WHERE cell_id = ' num2str(s.id)]);
end



% --------------------------------------------------------------------
function PairedSeries_Callback(hObject, eventdata, handles)
% hObject    handle to PairedSeries (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function ChRSeries_Callback(hObject, eventdata, handles)
% hObject    handle to ChRSeries (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
    stepData = handles.multChannels;
end

if sum(cell2mat(stepData(:,2)) - cell2mat(stepData(1,2))) ~= 0
    error('only one channel is accepted')
end

chNum = cell2mat(stepData(1,2));
files = stepData(:, 1);
seriesType = {'IChRSeries', 'VChRSeries', 'CellAttachedChRSeries'};
t = listdlg('PromptString','What kind of TraceSeries?','ListString', seriesType);
series = eval(['electrophysiology.', seriesType{t},'(files, ',num2str(chNum),')']);

[p, f] = fileparts(stepData{1,1});
fileName = f(1:6);
[fs, ps,filter] = uiputfile('*.mat','save series',fullfile(handles.dataFolder,'Taro','ANALYSIS','rabies_ChR','ChRSeries',fileName));
if filter == 0
    return
end
filePath = fullfile(ps,fs);

save(filePath,'series');

mksqlite('open',handles.sqlite);

s = mksqlite(['SELECT id FROM Cells WHERE exp_number = ''', fileName,''' AND channel_num = ', num2str(chNum)]);
disp('cell id is: ');s.id

seriesInSql = mksqlite(['SELECT * FROM ChRSimpleSeries WHERE cell_id = ', num2str(s.id)]);

% there must be a better way.
%if isempty(seriesInSql)
    mksqlite(['REPLACE INTO ChRSimpleSeries (cell_id, series_object, type) VALUES (', num2str(s.id), ', ''', filePath, ''',','''',seriesType{t},''')']);    
%else
 %   mksqlite(['UPDATE ChRSeriesSimple SET step_object = ''', filePath, ''' WHERE cell_id = ' num2str(s.id)]);
%end


% --------------------------------------------------------------------
function GroupSeriesElecStim_Callback(hObject, eventdata, handles)
% hObject    handle to GroupSeriesElecStim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
    multiCh = handles.multChannels;
end
seriesSet = CellArrayList;
for k = unique(cell2mat(multiCh(:,2)))';
    f = multiCh(cell2mat(multiCh(:,2)) == k);
    seriesType = {'IChRSeries', 'VChRSeries', 'CellAttachedChRSeries'};
    t = listdlg('PromptString','What kind of TraceSeries?','ListString', seriesType);
    tSeries = eval(['electrophysiology.', seriesType{t},'(f, ',num2str(k),')']);
    seriesSet.add(tSeries);
end
series = electrophysiology.GroupedSeries(seriesSet);

[p, f] = fileparts(multiCh{1,1});
expNum = f(1:6);
filePath = fullfile(handles.dataFolder,'Taro','ANALYSIS','multi_rec_project','ChRGroupSeries', expNum);
[fs, ps,filter] = uiputfile('*.mat','save series',filePath);
if filter == 0
    return
end
filePath = fullfile(ps,fs);
save(filePath,'series');

keyboard % below is the messages to sqlite. double check.
mksqlite('open',handles.sqlite);

cellIds = strrep(['SELECT id FROM CELLS WHERE exp_number = ''',...
    num2str(expNum), ''' AND channel_num IN (', ...
    num2str(unique(cell2mat(multiCh(:,2)))','%i,'),')'],',)',')');
cellIds = cell2mat(struct2cell(mksqlite(cellIds)));

objectIdMax = cell2mat(struct2cell(mksqlite('SELECT MAX(id) FROM GroupSeriesElecStim')));
gsId = num2str(objectIdMax + 1);

mksqlite(['INSERT INTO GroupSeriesElecStim (id, group_object) VALUES (', gsId,',''', filePath, ''')']);
for kk = 1:length(cellIds)
mksqlite(['INSERT INTO GroupSeriesElecStimCell (groupserieselecstim_id, ',...
    'cell_id) VALUES (',gsId,',',num2str(cellIds(kk)),')'])
end


% --- Executes on button press in checkbox2.
function checkbox2_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox2


% --------------------------------------------------------------------
function getYfrac_Callback(hObject, eventdata, handles)
% hObject    handle to getYfrac (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
im1 = dir(fullfile(handles.xsgFolder,handles.cellFolder,'images','*.TIF'));
im2 = dir(fullfile(handles.xsgFolder,handles.cellFolder,'images','*.tif'));
im3 = dir(fullfile(handles.xsgFolder,handles.cellFolder,'images','*.fig'));
im4 = dir(fullfile(handles.xsgFolder,handles.cellFolder,'images','*.tiff'));
imfiles = [im1;im2;im3;im4];
h1 = figure;
numFig = length(imfiles);
if (sqrt(numFig) - floor(sqrt(numFig))) > 0.001
    FigSeq = floor(sqrt(numFig)) + 1;    
else
    FigSeq = sqrt(numFig);    
end

for fNum = 1:numFig
    subplot(FigSeq, FigSeq, fNum)
    A = expdatautil.imageCDataFromFile(fullfile(handles.xsgFolder, handles.cellFolder, 'images', imfiles(fNum).name));
    imagesc(A)
    set(gca,'XTick',[]) 
    set(gca,'YTick',[])    
end
colormap('gray')
waitforbuttonpress
chosenFig = get(gco,'CData');
close(h1)
h2 = figure;
imagesc(chosenFig)
colormap('gray')
stopFlag = 1;
while stopFlag
title('click pia, cell and whitematter (double clicks)')
[x,y] = ginput(3);
yfrac = sqrt((x(1)-x(2))^2 + (y(1)-y(2))^2)/(sqrt((x(1)-x(2))^2 + (y(1)-y(2))^2) + (sqrt((x(3)-x(2))^2 + (y(3)-y(2))^2)));
flag = questdlg(['yfrac is calculated as:',num2str(yfrac),'. Is this fine?'],'flag');
if strcmp(flag, 'Yes');stopFlag = 0;end
end
close(h2)

ch = inputdlg('channel num?');

mksqlite(['UPDATE Cells SET yfrac = ',num2str(yfrac),' WHERE exp_number = ''',handles.cellFolder, ...
''' AND channel_num = ',ch{1}]);