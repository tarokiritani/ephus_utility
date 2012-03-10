function varargout = xsgBrowser(varargin)
% XSGBROWSER MATLAB code for xsgBrowser.fig
%      XSGBROWSER, by itself, creates a new XSGBROWSER or raises the existing
%      singleton*.
%
%      H = XSGBROWSER returns the handle to a new XSGBROWSER or the handle to
%      the existing singleton*.
%
%      XSGBROWSER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in XSGBROWSER.M with the given input arguments.
%
%      XSGBROWSER('Property','Value',...) creates a new XSGBROWSER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before xsgBrowser_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to xsgBrowser_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help xsgBrowser

% Last Modified by GUIDE v2.5 10-Mar-2012 17:53:02

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @xsgBrowser_OpeningFcn, ...
                   'gui_OutputFcn',  @xsgBrowser_OutputFcn, ...
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


% --- Executes just before xsgBrowser is made visible.
function xsgBrowser_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to xsgBrowser (see VARARGIN)

% Choose default command line output for xsgBrowser
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes xsgBrowser wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = xsgBrowser_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox1

contents = cellstr(get(hObject,'String'));
cellFolder = contents(get(hObject,'Value'));

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


% --------------------------------------------------------------------
function Untitled_1_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function openCellFolder_Callback(hObject, eventdata, handles)
% hObject    handle to openCellFolder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.xsgFolder = uigetdir('C:\Data','select Cells Folder');
expNum = struct2cell(dir(handles.xsgFolder));
handles.expNum = expNum(1,:);
guidata(hObject, handles);

set(handles.listbox1,'String',handles.expNum);


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
    plotHeight = 550/numOfChannels - 10;
    axes('Parent',gcf,'units','pixels',...
        'Position',[400 (plotHeight*(k-1) + 30) 380 plotHeight-20]);
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


% --------------------------------------------------------------------
function openMfile_Callback(hObject, eventdata, handles)
% hObject    handle to openMfile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
contents = get(handles.listbox1, 'String');
cellFolder = contents(get(handles.listbox1, 'Value'));
cellFolder = strrep(cellFolder{1, 1},'.m','');
file = fullfile(handles.xsgFolder, cellFolder, [cellFolder,'.m']);
edit(file);


% --------------------------------------------------------------------
function openAutoNote_Callback(hObject, eventdata, handles)
% hObject    handle to openAutoNote (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
edit([[handles.xsgFolder],'\',[handles.cellFolder],'\',handles.cellFolder,'.txt'])


% --------------------------------------------------------------------
function Analysis_Callback(hObject, eventdata, handles)
% hObject    handle to Analysis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function uipushtool1_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to uipushtool1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
plotedit;
