function varargout = VowelMaker(varargin)
% VOWELMAKER MATLAB code for VowelMaker.fig
%      VOWELMAKER, by itself, creates a new VOWELMAKER or raises the existing
%      singleton*.
%
%      H = VOWELMAKER returns the handle to a new VOWELMAKER or the handle to
%      the existing singleton*.
%
%      VOWELMAKER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in VOWELMAKER.M with the given input arguments.
%
%      VOWELMAKER('Property','Value',...) creates a new VOWELMAKER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before VowelMaker_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to VowelMaker_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help VowelMaker

% Last Modified by GUIDE v2.5 20-Aug-2015 08:19:10

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @VowelMaker_OpeningFcn, ...
                   'gui_OutputFcn',  @VowelMaker_OutputFcn, ...
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

% --- Executes just before VowelMaker is made visible.
function VowelMaker_OpeningFcn(hObject, eventdata, handles, varargin)
    handles.output = hObject;
    handles.trainingSet = 'w';
    handles.length = 1.0;
    handles.numSlices = 4;
    handles.trainingAmplitudeThreshold = 0.8;
    handles.model = [];
    guidata(hObject, handles);
    onConfigurationChanged(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = VowelMaker_OutputFcn(hObject, eventdata, handles) 
    varargout{1} = handles.output;

% Configuration change means rebuilding the model.
function onConfigurationChanged(hObject, handles)
    handles = updateHandles(hObject, handles);
    set(handles.loading, 'Visible', 'on');
    drawnow;
    model = Model.BuildModel('ks525_vowel.txt', handles.trainingSet, handles.numSlices, handles.trainingAmplitudeThreshold);
    set(handles.loading, 'Visible', 'off');
    drawnow;
    handles.model = model;
    set(handles.slider_f0, 'Value', model.F0);
    updateHandles(hObject, handles);

% Updating handles just refreshes the current state of the UI.
function handles = updateHandles(hObject, handles)
    handles.trainingSet = getTrainingSet(handles);
    handles.numSlices = str2double(getPopupValue(handles.popupmenu_numslices));
    handles.length = str2double(getPopupValue(handles.popupmenu_length));
    handles.trainingAmplitudeThreshold = str2double(getPopupValue(handles.popupmenu_trainingamplitudethreshold));
    handles.model.F0 = get(handles.slider_f0,'Value');
    f0label = strcat(num2str(round(handles.model.F0)), ' Hz');
    set(handles.text_f0, 'String', f0label);
    guidata(hObject, handles);

function trainingSet = getTrainingSet(handles)
    strValue = getPopupValue(handles.popupmenu_trainingset);
    switch strValue
        case 'Woman'
            trainingSet = 'w';
        case 'Man'
            trainingSet = 'm';
        case 'Boy'
            trainingSet = 'b';
        case 'Girl'
            trainingSet = 'g';
        case 'Combined'
            trainingSet = 'c';
    end
    

function strValue = getPopupValue(hObject)
    contents = cellstr(get(hObject,'String'));
    strValue = contents{get(hObject,'Value')};

function num = getSliderValue(hObject)
    contents = cellstr(get(hObject,'String'));
    strValue = get(hObject,'Value');
    
% Vowel button callbacks:
function pushbutton_iy_Callback(hObject, eventdata, handles)
    handles.model.PlayVowel('iy', handles.length)
function pushbutton_ih_Callback(hObject, eventdata, handles)
    handles.model.PlayVowel('ih', handles.length)
function pushbutton_ei_Callback(hObject, eventdata, handles)
    handles.model.PlayVowel('ei', handles.length)
function pushbutton_eh_Callback(hObject, eventdata, handles)
    handles.model.PlayVowel('eh', handles.length)
function pushbutton_ah_Callback(hObject, eventdata, handles)
    handles.model.PlayVowel('ah', handles.length)
function pushbutton_er_Callback(hObject, eventdata, handles)
    handles.model.PlayVowel('er', handles.length)
function pushbutton_oo_Callback(hObject, eventdata, handles)
    handles.model.PlayVowel('oo', handles.length)
function pushbutton_uw_Callback(hObject, eventdata, handles)
    handles.model.PlayVowel('uw', handles.length)
function pushbutton_uh_Callback(hObject, eventdata, handles)
    handles.model.PlayVowel('uh', handles.length)
function pushbutton_oa_Callback(hObject, eventdata, handles)
    handles.model.PlayVowel('oa', handles.length)
function pushbutton_aw_Callback(hObject, eventdata, handles)
    handles.model.PlayVowel('aw', handles.length)
function pushbutton_ae_Callback(hObject, eventdata, handles)
    handles.model.PlayVowel('ae', handles.length)


% --- Executes on selection change in popupmenu_trainingset.
function popupmenu_trainingset_Callback(hObject, eventdata, handles)
    onConfigurationChanged(hObject, handles);

% --- Executes during object creation, after setting all properties.
function popupmenu_trainingset_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

% --- Executes on selection change in popupmenu_numslices.
function popupmenu_numslices_Callback(hObject, eventdata, handles)
    onConfigurationChanged(hObject, handles);

% --- Executes during object creation, after setting all properties.
function popupmenu_numslices_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


% --- Executes on selection change in popupmenu_length.
function popupmenu_length_Callback(hObject, eventdata, handles)
    handles = updateHandles(hObject, handles);

% --- Executes during object creation, after setting all properties.
function popupmenu_length_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu_trainingamplitudethreshold.
function popupmenu_trainingamplitudethreshold_Callback(hObject, eventdata, handles)
    onConfigurationChanged(hObject, handles);

% --- Executes during object creation, after setting all properties.
function popupmenu_trainingamplitudethreshold_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on slider movement.
function slider_f0_Callback(hObject, eventdata, handles)
    handles = updateHandles(hObject, handles);

% --- Executes during object creation, after setting all properties.
function slider_f0_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in loading.
function loading_Callback(hObject, eventdata, handles)
% hObject    handle to loading (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
