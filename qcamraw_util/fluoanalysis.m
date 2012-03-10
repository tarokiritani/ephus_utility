function varargout = fluoanalysis(varargin)
% FLUOANALYSIS M-file for fluoanalysis.fig
%      FLUOANALYSIS, by itself, creates a new FLUOANALYSIS or raises the existing
%      singleton*.
%
%      H = FLUOANALYSIS returns the handle to a new FLUOANALYSIS or the handle to
%      the existing singleton*.
%
%      FLUOANALYSIS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FLUOANALYSIS.M with the given input arguments.
%
%      FLUOANALYSIS('Property','Value',...) creates a new FLUOANALYSIS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before fluoanalysis_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to fluoanalysis_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
%      qcammex.c sometimes crashes probably because of memory depletion. In 
%      order to avoid this, use 'clear qcammex' in the command line frequently. 
% 
%      fluoanalysis.m is written for basic analysis of fluorescence imaging.
%      * Click Browse and choose file(s) for analysis. If you choose multiple 
%      files here, you can take the average of those files.
%      * Number of frames and inter frame time are typically the same as the 
%      number of pulses and ISI for the camera trigger. 
%      * There are two ways to look at the movie. One is raw intensity data and
%      the other is normalized movie (delta F/F). Default is absolute mode.
%      * Start baseline and stop baseline indicate the time window for the baseline.
%      * Hit load movie. Hit this button every time you choose new file(s).
%      * The color scale for normalized frame can be changed.
%      * The slide bar under the fluorescence image (left axes) indicates 
%      the time of the frame in the movie.
%      * Load bright field image can be used to compare fluorescence image 
%      and bright field image.
%      * In ROI analysis, you can see the change in the fluorescence over time.
%      First, input numbers or choose the region in fluorescent image using mouse.
%      Then, hit ROI analysis. If mouse does not work to specify the region,
%      edit the region with the keyboard.
%      * Vertical profile is used to look at the activity along a vertical 
%      line. The images can be rotated using “rotate image”. The profile of 
%      activity along y axis is returned by update line.
%      Written by Taro Kiritani July 2009
%      tarokiritani2008@u.northwestern.edu
%      modified by Taro on 8/19/09
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help fluoanalysis

% Last Modified by GUIDE v2.5 08-Sep-2009 11:39:10

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @fluoanalysis_OpeningFcn, ...
                   'gui_OutputFcn',  @fluoanalysis_OutputFcn, ...
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


% --- Executes just before fluoanalysis is made visible.
function fluoanalysis_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to fluoanalysis (see VARARGIN)

% Choose default command line output for fluoanalysis
handles.output = hObject;
handles.moviemode = 'absolute';
% Update handles structure
guidata(hObject, handles);


% UIWAIT makes fluoanalysis wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = fluoanalysis_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function filepath_Callback(hObject, eventdata, handles)
% hObject    handle to filepath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of filepath as text
%        str2double(get(hObject,'String')) returns contents of filepath as a double

handles.filename = get(hObject,'String');
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function filepath_CreateFcn(hObject, eventdata, handles)
% hObject    handle to filepath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushLoad.
function pushLoad_Callback(hObject, eventdata, handles)
% hObject    handle to pushLoad (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if iscell(handles.filename)
    mvinfo = qcammex('getHeaderString',handles.filename{1});
    [start_idx, end_idx, extents, match] = regexp(mvinfo, 'ROI: \d+, \d+, \d+, \d+');
    [start_roi, end_roi, foo, match_roi] = regexp(match{1}, '\d+');
    x = match_roi{1};
    y = match_roi{2};
    width = match_roi{3};
    height = match_roi{4};
    nframes = qcammex('getNumberOfFrames', handles.filename{1});
    
    for k = 2:length(handles.filename)
        if nframes ~= qcammex('getNumberOfFrames', handles.filename{k});
            errordlg('number of frames in all files should match!')
            return
        end
        
        mvinfo_compare = qcammex('getHeaderString',handles.filename{k});
        [start_idx_cmp, end_idx_cmp, extents_cmp, match_cmp] = regexp(mvinfo, 'ROI: \d+, \d+, \d+, \d+');
        if not(strcmp(match, match_cmp))
            errordlg('pixel number should not change between files')
            return
        end
    end
else
    mvinfo = qcammex('getHeaderString',handles.filename);     
    [start_idx, end_idx, extents, match] = regexp(mvinfo, 'ROI: \d+, \d+, \d+, \d+');
    [start_roi, end_roi, foo, match_roi] = regexp(match{1}, '\d+');
    x = match_roi{1};
    y = match_roi{2};
    width = match_roi{3};
    height = match_roi{4};
    
    nframes = qcammex('getNumberOfFrames', handles.filename);
end


binning = strfind(mvinfo,'Binning');
binning = str2double(mvinfo(binning + 9));

% watch out for inconsitency in dimensions.
numofpixels(1) = str2num(height);
numofpixels(2) = str2num(width);

% E = zeros(numofpixels(1));
% e1 = 1:2 * numofpixels(1) + 2:numofpixels(1)*numofpisels(1);
% e2 = 1 + numofpisels(1):2 * numofpixels(1) + 2:numofpixels(1):numofpixels(1)*numofpisels(1);
% E(e1) = 1;
% E(e2) = 1;

%nframes = handles.numofframe;              % number of frames in the movie
Frames = moviein(nframes); % initialize the matrix 'Frames'
figure;
%axes(handles.axes1)

Aveframe = zeros(numofpixels(1),numofpixels(2));

if strcmp(handles.moviemode,'absolute')
    for i = 1:nframes;   
        if iscell(handles.filename)
            frames = qcammex('getFrames',handles.filename{1},i)';clear qcammex
            imagesc(frames,[0 4095]);colorbar
            daspect([1 1 1])
            Frames(i) = getframe;
        else
            frames = qcammex('getFrames',handles.filename,i)';clear qcammex
            h = imagesc(frames,[0 4095]);colorbar
            % movegui(h)
            daspect([1 1 1])
            Frames(i)=getframe;
        end
    end
    handles.avefig = [];
else
    if not(iscell(handles.filename))
        for i = handles.startbase:handles.endbase;
            frames = qcammex('getFrames',handles.filename,i)';clear qcammex
            frames = single(frames);
            Aveframe =  Aveframe + 1/(handles.endbase-handles.startbase + 1) * frames;
        end
    else
        for j = 1:length(handles.filename)
            for i = handles.startbase:handles.endbase;
            frames = qcammex('getFrames',handles.filename{j},i)';clear qcammex
            frames = single(frames);
            Aveframe =  Aveframe + 1/(handles.endbase-handles.startbase + 1) * frames;
            end
        end
        Aveframe = Aveframe/j;
    end
    
    for i = 1:nframes;
        
         if iscell(handles.filename) 
             frames = qcammex('getFrames',handles.filename{1},i)';clear qcammex
             frames = single(frames);
             frames = (frames ./ Aveframe) * 100;
             h = imagesc(frames,[50 150]);colorbar;
             % movegui(h)
             daspect([1 1 1])
             Frames(i)=getframe;
         else
             frames = qcammex('getFrames',handles.filename,i)';clear qcammex
             frames = single(frames);
             frames = (frames ./ Aveframe) * 100;
             h = imagesc(frames,[50 150]);colorbar;
             % movegui(h)
             daspect([1 1 1])
             Frames(i) = getframe;
         end
    end

    handles.avefig = Aveframe;
end

handles.figs = Frames;

%axes(handles.axes1);
handles.fig_size = [numofpixels(1),numofpixels(2)];
handles.numofframe = nframes;
handles.movieaxes = gcf;

guidata(hObject,handles)


% --- Executes during object creation, after setting all properties.
function axes1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes1



function ymin_Callback(hObject, eventdata, handles)
% hObject    handle to ymin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ymin as text
%        str2double(get(hObject,'String')) returns contents of ymin as a double
handles.metricdata.ymin = str2double(get(hObject,'String'));
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function ymin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ymin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function xmin_Callback(hObject, eventdata, handles)
% hObject    handle to xmin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of xmin as text
%        str2double(get(hObject,'String')) returns contents of xmin as a double
handles.metricdata.xmin = str2double(get(hObject,'String'));
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function xmin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to xmin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ymax_Callback(hObject, eventdata, handles)
% hObject    handle to ymax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ymax as text
%        str2double(get(hObject,'String')) returns contents of ymax as a double
handles.metricdata.ymax = str2double(get(hObject,'String'));
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function ymax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ymax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function xmax_Callback(hObject, eventdata, handles)
% hObject    handle to xmax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of xmax as text
%        str2double(get(hObject,'String')) returns contents of xmax as a double
handles.metricdata.xmax = str2double(get(hObject,'String'));
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function xmax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to xmax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in roiAnalysis.
                             
% hObject    handle to roiAnalysis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

for i = 1:handles.numofframe;
     intframes = qcammex('getFrames',handles.filename,i);
     intensity(i) = mean(mean(double(intframes(handles.metricdata.xmin:handles.metricdata.xmax,handles.metricdata.ymin:handles.metricdata.ymax))));
end

intensity = intensity /mean(intensity(handles.startbase:handles.endbase)) * 100;
keyboard
xmin = handles.metricdata.xmin;
xmax = handles.metricdata.xmax;
ymin = handles.metricdata.ymin;
ymax = handles.metricdata.ymax;
axes(handles.axes1);rectangle('Position', [xmin,ymin,xmax - xmin,ymax-ymin]);
axes(handles.axes3);plot(handles.interframes * (1:handles.numofframe),intensity);ylim([95 105])
handles.intensityroi = intensity;
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function axes3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes3


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
cd(handles.pathname)
catch
display('C:\Data\ does not exist')
end
[filename, pathname] = uigetfile('*.qcamraw', 'Select an qcam movie.','MultiSelect', 'on');
if iscell(filename)
    pathInText = [];
    for i = 1:length(filename)
        filepath{i} = [pathname,filename{i}];
        pathInText = [pathInText,filepath{i}];       
    end
    set(handles.filepath,'String',pathInText);
else
    filepath = [pathname,filename];
    set(handles.filepath,'String',filepath);
end
handles.pathname = pathname;
handles.filename = filepath;

guidata(hObject,handles)


% --- Executes on button press in mouseinput.
function mouseinput_Callback(hObject, eventdata, handles)
% hObject    handle to mouseinput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
axes(handles.axes1);
MouseRegion = floor(getrect);

set(handles.xmin,'String',MouseRegion(1));
set(handles.xmax,'String',MouseRegion(1) + MouseRegion(3));
set(handles.ymin,'String',MouseRegion(2));
set(handles.ymax,'String',MouseRegion(2) + MouseRegion(4));

handles.metricdata.xmin = MouseRegion(1);
handles.metricdata.xmax = MouseRegion(1) + MouseRegion(3);
handles.metricdata.ymin = MouseRegion(2);
handles.metricdata.ymax = MouseRegion(2) + MouseRegion(4);

axes(handles.axes1)
axes(handles.axes1);rectangle('Position', [MouseRegion(1),MouseRegion(2), MouseRegion(3),MouseRegion(4)]);

axes(handles.axes4);rectangle('Position', [MouseRegion(1)*8-7, MouseRegion(2)*8-7, MouseRegion(3)*8,MouseRegion(4)*8])


guidata(hObject,handles)


% --- Executes on button press in radioNormalized.
function radioNormalized_Callback(hObject, eventdata, handles)
% hObject    handle to radioNormalized (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radioNormalized

handles.moviemode = 'normalized';
guidata(hObject,handles)


% --- Executes on button press in radioAbsolute.
function radioAbsolute_Callback(hObject, eventdata, handles)
% hObject    handle to radioAbsolute (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radioAbsolute

handles.moviemode = 'absolute';
guidata(hObject,handles)


% --- Executes on button press in pushbuttonSave.
function pushbuttonSave_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonSave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

intensity = handles.intensityroi;

save(handles.filesaved,'intensity');



function savefilepath_Callback(hObject, eventdata, handles)
% hObject    handle to savefilepath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of savefilepath as text
%        str2double(get(hObject,'String')) returns contents of savefilepath as a double
handles.filesaved = get(hObject,'String');
guidata(hObject,handles)


% --- Executes during object creation, after setting all properties.
function savefilepath_CreateFcn(hObject, eventdata, handles)
% hObject    handle to savefilepath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Browsesave.
function Browsesave_Callback(hObject, eventdata, handles)
% hObject    handle to Browsesave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
cd 'C:\Data\'
catch
display('C:\Data\ does not exist')
end

[filename,pathname] = uiputfile;
filepath = [pathname,filename];
set(handles.savefilepath,'String',filepath);
handles.filesaved = filepath;
guidata(hObject,handles)


% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future versitryon of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

if not(isfield(handles,'scalemin'))

    handles.scalemin = 98;
end

if not(isfield(handles,'scalemax'))

    handles.scalemax = 102;
end

numofimage = (get(hObject,'Value'));
axes(handles.axes1);
handles.numofimage = floor(handles.numofframe * numofimage);

if iscell(handles.filename)
    F = qcammex('getFrames',handles.filename{1},handles.numofimage);
    for i = 2:length(handles.filename)
    
        F = F + qcammex('getFrames',handles.filename{i},handles.numofimage);
    end
    F = F/i;
else
    F = qcammex('getFrames',handles.filename,handles.numofimage);
end
F = F';
if strcmp(handles.moviemode,'absolute')
imagesc(F,[0 4095]);
else
imagesc(100 * (double(F)./(handles.avefig)),[handles.scalemin handles.scalemax]);colorbar
end
daspect([1 1 1])
handles.F = F;
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on key press with focus on roiAnalysis and no controls selected.
function roiAnalysis_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to roiAnalysis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function startbaseline_Callback(hObject, eventdata, handles)
% hObject    handle to startbaseline (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of startbaseline as text
%        str2double(get(hObject,'String')) returns contents of startbaseline as a double
handles.startbase = floor(str2double(get(hObject,'String'))/handles.interframes);
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function startbaseline_CreateFcn(hObject, eventdata, handles)
% hObject    handle to startbaseline (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function baselineEnd_Callback(hObject, eventdata, handles)
% hObject    handle to baselineEnd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of baselineEnd as text
%        str2double(get(hObject,'String')) returns contents of baselineEnd as a double
handles.endbase = floor(str2double(get(hObject,'String'))/handles.interframes);
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function baselineEnd_CreateFcn(hObject, eventdata, handles)
% hObject    handle to baselineEnd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushBaseline.
function pushBaseline_Callback(hObject, eventdata, handles)
% hObject    handle to pushBaseline (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

axes(handles.axes3);
MouseRegion = floor(getrect);

set(handles.startbaseline,'String',MouseRegion(1));
set(handles.baselineEnd,'String',MouseRegion(3));

handles.startbase = floor(MouseRegion(1)/handles.interframes);
handles.endbase = floor(MouseRegion(3)/handles.interframes);

guidata(hObject,handles)


% --- Executes on button press in pushbutton12.
function pushbutton12_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[filename,pathname] = uiputfile;
filepath = [pathname,filename];

frames = double(qcammex('getFrames',handles.filename,handles.numofimage)')./ handles.avefig;
save(filepath,'frames')


% --- Executes on button press in saveAve.
function saveAve_Callback(hObject, eventdata, handles)
% hObject    handle to saveAve (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[filename,pathname] = uiputfile;
filepath = [pathname,filename];
Aveframe = qcammex('getFrames',handles.filename,handles.startbase) / (handles.endbase-handles.startbase + 1);
Aveframe = double(Aveframe');

for i = handles.startbase+1:handles.endbase;
     frames = qcammex('getFrames',handles.filename,i);
     frames = frames';
     frames = double(frames);
     Aveframe =  Aveframe + 1/(handles.endbase-handles.startbase + 1) * frames;
end

save(filepath,'Aveframe')



function editNumFrame_Callback(hObject, eventdata, handles)
% hObject    handle to editNumFrame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editNumFrame as text
%        str2double(get(hObject,'String')) returns contents of editNumFrame as a double

handles.numofframe = str2double(get(hObject,'String'));
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function editNumFrame_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editNumFrame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function baselineStart_Callback(hObject, eventdata, handles)
% hObject    handle to baselineStart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of baselineStart as text
%        str2double(get(hObject,'String')) returns contents of baselineStart as a double

handles.startbase = str2double(get(hObject,'String'));
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function baselineStart_CreateFcn(hObject, eventdata, handles)
% hObject    handle to baselineStart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editSamplerate_Callback(hObject, eventdata, handles)
% hObject    handle to editSamplerate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editSamplerate as text
%        str2double(get(hObject,'String')) returns contents of editSamplerate as a double
handles.interframes = str2double(get(hObject,'String'));
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function editSamplerate_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editSamplerate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in diplay_movie.
function diplay_movie_Callback(hObject, eventdata, handles)
% hObject    handle to diplay_movie (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

figure;
if strcmp(handles.moviemode,'absolute')
    imagesc(zeros(3,4),[1 4995])
else
    imagesc(zeros(3,4),[50 150])
end

daspect([1 1 1]);colorbar

movie(handles.figs);


% --- Executes on button press in Summary.
function Summary_Callback(hObject, eventdata, handles)

try
cd 'C:\Data\Taro\CELLS'
catch
display('C:\Data\Taro\CELLS does not exist')
end
[filename_bf, pathname_bf] = uigetfile('*.*', 'Select a bright field image.');
filepath_bf = [pathname_bf,filename_bf];

try
cd 'C:\Data\Taro\CELLS'
catch
display('C:\Data\Taro\CELLS does not exist')
end
[filename_q, pathname_q] = uigetfile('*.*', 'Select a qcam image.');
filepath_q = [pathname_q,filename_q];

figure
subplot([321])
I = imread(filepath_bf);
Irgb = cat(3,I,I,I);
image(Irgb)
daspect([1 1 1])


subplot([322])
frames = mean(double(qcammex('getFrames',filepath_q,20:25)),3)'./ mean(double(qcammex('getFrames',filepath_q,2:10)),3)';
imagesc(frames,[0.95 1.05])
daspect([1 1 1])


for i = 1:handles.numofframe;
     intframes = qcammex('getFrames',handles.filename,i);
     intensity(i) = mean(mean(double(intframes(handles.metricdata.xmin:handles.metricdata.xmax,handles.metricdata.ymin:handles.metricdata.ymax))));
end

intensity = intensity /mean(intensity(handles.startbase:handles.endbase)) * 100;

subplot([323]);plot(intensity)

mkdir(pathname,'summary')
save Summary



% hObject    handle to Summary (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton17.
function pushbutton17_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
cd 'C:\Data\'
catch
display('C:\Data\ does not exist')
end
[bffile, bfpath] = uigetfile('*.*', 'Select a bright filed image.');
bffile = [bfpath,bffile];
handles.bf = imread(bffile);
axes(handles.axes4);
imagesc(cat(3,handles.bf,handles.bf,handles.bf))
guidata(hObject,handles)


function edit14_Callback(hObject, eventdata, handles)
% hObject    handle to edit14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit14 as text
%        str2double(get(hObject,'String')) returns contents of edit14 as a double

try exist('handles.scalemin','var')

catch
    handles.scalemin = 98;
end

try exist('handles.scalemax','var')
    
catch
    handles.scalemax = 102;
end

rotAngle = str2double(get(hObject,'String'));
get(handles.axes1);
fluoImg = imrotate(100 * (double(handles.F)./(handles.avefig)),rotAngle);
bfImg = imrotate(handles.bf,rotAngle);

bfImg = cat(3,bfImg,bfImg,bfImg);

axes(handles.axes1)
imagesc(fluoImg,[handles.scalemin handles.scalemax]);daspect([1 1 1])

axes(handles.axes4)
imagesc(bfImg);daspect([1 1 1])

handles.rot = rotAngle;
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function edit14_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit15_Callback(hObject, eventdata, handles)
% hObject    handle to edit15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit15 as text
%        str2double(get(hObject,'String')) returns contents of edit15 as a double

handles.scalemin = str2double(get(hObject,'String'));
guidata(hObject,handles)
% --- Executes during object creation, after setting all properties.
function edit15_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit16_Callback(hObject, eventdata, handles)
% hObject    handle to edit16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit16 as text
%        str2double(get(hObject,'String')) returns contents of edit16 as a double


handles.scalemax = str2double(get(hObject,'String'));
guidata(hObject,handles)
% --- Executes during object creation, after setting all properties.
function edit16_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit17_Callback(hObject, eventdata, handles)
% hObject    handle to edit17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit17 as text
%        str2double(get(hObject,'String')) returns contents of edit17 as a double
handles.xval = str2double(get(hObject,'String'));

guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function edit17_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit18_Callback(hObject, eventdata, handles)
% hObject    handle to edit18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit18 as text
%        str2double(get(hObject,'String')) returns contents of edit18 as a double

handles.ymin =  str2double(get(hObject,'String'));

guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function edit18_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit19_Callback(hObject, eventdata, handles)
% hObject    handle to edit19 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit19 as text
%        str2double(get(hObject,'String')) returns contents of edit19 as a double


% --- Executes during object creation, after setting all properties.
function edit19_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit19 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit20_Callback(hObject, eventdata, handles)
% hObject    handle to edit20 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit20 as text
%        str2double(get(hObject,'String')) returns contents of edit20 as a double
handles.width =  str2double(get(hObject,'String'));

guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function edit20_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit20 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton20.
function pushbutton20_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton20 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
axes(handles.axes1)
rectangle('Position',[handles.xval-handles.width handles.ymin handles.width*2 handles.ymax-handles.ymin],'EdgeColor','r')

axes(handles.axes4)
rectangle('Position',length(handles.bf)/length(handles.F)*[handles.xval-handles.width handles.ymin handles.width*2 handles.ymax-handles.ymin],'EdgeColor','r')

verProfile = imrotate(100 * (double(handles.F)./(handles.avefig)),handles.rot);
verProfile = verProfile(handles.ymin:handles.ymax,handles.xval - handles.width:handles.xval + handles.width);
verProfile = mean(verProfile,2);
figure;plot(verProfile)
assignin('base','verProfile',verProfile);


function edit22_Callback(hObject, eventdata, handles)
% hObject    handle to edit22 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit22 as text
%        str2double(get(hObject,'String')) returns contents of edit22 as a double

handles.ymax =  str2double(get(hObject,'String'));

guidata(hObject,handles)
% --- Executes during object creation, after setting all properties.
function edit22_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit22 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton21.
function pushbutton21_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton21 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
    rot = handles.rot;
catch
    rot = 0;
end
Frotate = imrotate(100 * (double(handles.F)./(handles.avefig)),rot);
Brotate = imrotate(cat(3,handles.bf,handles.bf,handles.bf),rot);
figure;imagesc(Frotate,[handles.scalemin handles.scalemax]);
figure;imagesc(Brotate);
assignin('base','Cf',100*(double(handles.F)./(handles.avefig)))
assignin('base','Cbf',handles.bf)


% --- Executes on button press in roiAnalysis.
function roiAnalysis_Callback(hObject, eventdata, handles)
% hObject    handle to roiAnalysis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on button press in roiAnalysis.
                             
% hObject    handle to roiAnalysis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if iscell(handles.filename)
    for j = 1:length(handles.filename)
        if j == 1
            for i = 1:handles.numofframe;
                intframes = qcammex('getFrames',handles.filename{j},i);clear qcammex
                intensity(i) = mean(mean(double(intframes(handles.metricdata.xmin:handles.metricdata.xmax,handles.metricdata.ymin:handles.metricdata.ymax))));
            end     
        else
            for i = 1:handles.numofframe;
                intframes = qcammex('getFrames',handles.filename{j},i);clear qcammex
                intensity(i) = intensity(i) + mean(mean(double(intframes(handles.metricdata.xmin:handles.metricdata.xmax,handles.metricdata.ymin:handles.metricdata.ymax))));
            end   
        end
    end
else
    for i = 1:handles.numofframe;
         intframes = qcammex('getFrames',handles.filename,i);clear qcammex
         intensity(i) = mean(mean(double(intframes(handles.metricdata.xmin:handles.metricdata.xmax,handles.metricdata.ymin:handles.metricdata.ymax))));
    end
end
intensity = intensity /mean(intensity(handles.startbase:handles.endbase)) * 100;

xmin = handles.metricdata.xmin;
xmax = handles.metricdata.xmax;
ymin = handles.metricdata.ymin;
ymax = handles.metricdata.ymax;
axes(handles.axes1);rectangle('Position', [xmin,ymin,xmax - xmin,ymax-ymin]);
axes(handles.axes3);plot(handles.interframes * (1:handles.numofframe),intensity);
figure;plot(handles.interframes * (1:handles.numofframe),intensity);
handles.intensityroi = intensity;
guidata(hObject,handles)


% --- Executes on button press in pushbutton22.
function pushbutton22_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton22 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename, pathname] = uiputfile('example.avi', 'Save an avi file.');
movie2avi(handles.figs, fullfile(pathname,filename),'fps',4,'compression','None')
