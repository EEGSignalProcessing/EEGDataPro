% Author: Matthew Frehlich, Ye Mei, Luis Garcia Dominguez,Faranak Farzan
%         2016
%         Ben Schwartzmann 
%         2017

% eegdatapro_main: Main GUI for the EEG app, a GUI-based signal
% processing software for EEG Data. This program creates the parent
% structure/figure. Steps in the processing workflow are denoted by
% buttons, which call specific functions encapsulating the processing
% workflow for each step.
% 
% Input Data: EEG dataset using EEGLABs .set file format 
% 
% Output Data: .set format datasets at each 

% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.

function [] = eegdatapro_main(routine)

global backcolor basefile S
backcolor   = [0.7 0.8 1];
basefile    = 'None Selected';

%Define size of GUI depending on number of options
nb_function=size(routine.option_name,1);
sizeh=0.4*(round(nb_function/2))/5;
v=1/(round(nb_function/2)+3);

% Main object, GUI Parent figure
S      = []; 
S.hfig = figure('Menubar','none',...
              'Toolbar','none',...
              'Units','normalized',...
              'Name','EEGDataPro',...
              'Numbertitle','off',...
              'Resize','on',...
              'Color',backcolor,...
              'Position',[0.1 0.1 0.6 sizeh],...
              'DockControls','off');
          
S.routine=routine; 
S.list_ref={'INITIAL PROCESSING';...
          'REMOVE TMS ARTIFACT';...
          'REMOVE BAD TRLs AND CHNs';...
          'FILTERING';...
          'RUN ICA';...
          'REMOVE TMS DECAY ARTIFACT';...
          'REMOVE ICA COMPONENTS';...
          'FINAL PROCESSING'};
S.num_steps = nb_function;

% Main GUI Buttons         
global existcolor notexistcolor
existcolor    = [0.7 1 0.7];
notexistcolor = [1 0.7 0.7];

% GUI Button Positioning
col_1 = 0;
col_2 = 0.4;
col_3 = 0.5;
col_4 = 0.9;
st = 1-v*3;
stepb_w = 0.4;
sw = 0.1;

% ----------------------------- Headers -----------------------------------
S.htext1 = uicontrol('Style','text',...
                    'unit','normalized',...
                    'HorizontalAlignment','left',...
                    'position',[0.2 1-v-1/3*v 0.8 v],...
                    'fontsize',14,...
                    'BackgroundColor',[0.7 0.8 1],...
                    'Tag','main_text',...
                    'string','  Please select data path,first!');
S.htext2 = uicontrol('Style','text',...
                    'unit','normalized',...
                    'position',[0.2 1-2*v-1/3*v 0.8 v],...
                    'HorizontalAlignment','left',...
                    'fontsize',14,...
                    'BackgroundColor',[0.7 0.8 1],...
                    'Tag','file_text',...
                    'string',['  ' basefile]);
%%
S.hbutton1  = uicontrol('Style','pushbutton',...
                    'unit','normalized',...
                    'HorizontalAlignment','left',...
                    'position',[0.0 1-v 0.2 v],...
                    'fontsize',14,...
                    'Tag','main_text_b',...
                    'string','Working Folder:',...
                    'Callback',{@wkdirbutton_callback,S});
S.hbutton2  = uicontrol('Style','pushbutton',...
                    'unit','normalized',...
                    'HorizontalAlignment','left',...
                    'position',[0.0 1-2*v 0.2 v],...
                    'fontsize',14,...
                    'Tag','file_text_b',...
                    'string','Dataset:',...
                    'Callback',{@datasetbutton_callback,S});
%%
S.button11 = uicontrol('Parent', S.hfig,'Style','pushbutton',...
                   'Units','normalized',...
                   'Position',[col_1 st-round(nb_function/2)*v 0.5 v],...
                   'String','EEGLAB',...
                   'Callback',{@button_callback11,S}); 
S.button12 = uicontrol('Parent', S.hfig,'Style','pushbutton',...
                   'Units','normalized',...
                   'Position',[col_3 st-round(nb_function/2)*v 0.5 v],...
                   'String','Settings',...
                   'Callback',{@button_callback12,S});

% ------------------Main Buttons for processing steps----------------------

for i=1:nb_function
    
    if i<=round(nb_function/2)
      col_a=col_1;
      col_b=col_2;
    else
      col_a=col_3;
      col_b=col_4;
    end

    nbstep=mod(i,round(nb_function/2))-1;

    if (mod(i,round(nb_function/2))==0)
        nbstep=mod(i-1,round(nb_function/2));
    end

    if routine.option_num(i)==1
        namebutton=[num2str(routine.step_num(i)),'.',routine.option_name{i}];
    else
        namebutton=[num2str(routine.step_num(i)),'.',routine.option_name{i},' ',num2str(routine.option_num(i))];
    end

    currentbutton=sprintf('button%d',i);
    S.(currentbutton) = uicontrol('Parent', S.hfig,'Style','pushbutton',...
               'Units','normalized',...
               'Position',[col_a st-v*nbstep stepb_w v],...
               'String',namebutton,...
               'Tag',num2str(i),...
               'BackgroundColor',notexistcolor,... 
               'Callback',{@button_callback1,S});
 
    namebuttonview=['View ',num2str(i)];
    currentbuttons=sprintf('button%ds',i);
    S.(currentbuttons) = uicontrol('Parent', S.hfig,'Style','pushbutton',...
                   'Units','normalized',...
                   'Position',[col_b st-v*nbstep sw v],...
                   'BackgroundColor',notexistcolor,...
                   'String',namebuttonview,...
                   'Callback',{@button_callback1s,S});
end
  
end


function wkdirbutton_callback(varargin)
%Call user input for working folder
global basepath basefile S

if ~strcmp(basefile,'None Selected')
    choice = questdlg('Changing working folder will reset dataset and settings, do you want to continue?');
    
    switch choice
        case 'Yes'
            basepath = uigetdir(pwd,'Select Data Folder');
            h = findobj('Tag','main_text');
            set(h,'String',['  ' basepath ])

            %close all open windows
            set(S.hfig,'HandleVisibility','off')
            main_fig2 = findobj('type','figure','name','Create a processing routine');
            main_fig3 = findobj('type','figure','name','Choose a processing routine');
            set(main_fig2,'HandleVisibility','off');
            set(main_fig3,'HandleVisibility','off');
            close all;
            set(S.hfig,'HandleVisibility','on');
            set(main_fig2,'HandleVisibility','on');
            set(main_fig3,'HandleVisibility','on');

            %Re-initialize GUI, variables
            basefile    = 'None Selected';
            h = findobj('Tag','file_text');
            set(h,'String',['  ' basefile ])
            guidata(S.hfig,S);
            tmseeg_upd_stp_disp(S, '.set', S.num_steps);
    end
    
else
    basepath = uigetdir(pwd,'Select Data Folder');
    h = findobj('Tag','main_text');
    set(h,'String',['  ' basepath ])

    %close all open windows
    set(S.hfig,'HandleVisibility','off')
    main_fig2 = findobj('type','figure','name','Create a processing routine');
    main_fig3 = findobj('type','figure','name','Choose a processing routine');
    set(main_fig2,'HandleVisibility','off');
    set(main_fig3,'HandleVisibility','off');
    close all;
    set(S.hfig,'HandleVisibility','on');
    set(main_fig2,'HandleVisibility','on');
    set(main_fig3,'HandleVisibility','on');

    %Re-initialize GUI, variables
    basefile    = 'None Selected';
    h = findobj('Tag','file_text');
    set(h,'String',['  ' basefile ])
    guidata(S.hfig,S);
    tmseeg_upd_stp_disp(S, '.set', S.num_steps);
end

end


function datasetbutton_callback(varargin)
%Load selected dataset, update display
global basepath basefile S VARS

%Load Selected dataset, update display
[filename] = ...
uigetfile(fullfile(basepath,'*.set'),'Select Original File');
[~,basefile,ext]         = fileparts(filename);
VARS = eegdatapro_init(S);
tmseeg_upd_stp_disp(S, ext, S.num_steps)
%Update Parent GUI
h = findobj('Tag','file_text');
set(h,'String',['  ' basefile ])
guidata(S.hfig,S);

end


function button_callback1(varargin)
%Call to step
global S 
a=varargin{1};
r=S.routine;

%Get step number and option 
step=str2double(get(a,'Tag'));
ind_option=find(strcmp(r.option_name(step),S.list_ref)==1);

switch ind_option
    case 1
        eegdatapro_init_proc(S, step);
    case 2
        eegdatapro_rm_TMS_art(S, step);
    case 3
        eegdatapro_rm_ch_tr(S, step, r.option_num(step));
    case 4
        eegdatapro_filt(S, step, r.option_num(step));
    case 5
        eegdatapro_ica(S, step, r.option_num(step));
    case 6
        eegdatapro_rm_TMS_decay(S, step);
    case 7
        eegdatapro_ica_remove(S, step, r.option_num(step));
    case 8
        eegdatapro_interpolation(S, step);
end

end


function button_callback1s(varargin)
%Call to data display
global S
a=varargin{1};
step=str2double(a.String(6:end));
laststep=size(S.routine.option_name,1);

eegdatapro_show(step, laststep);

end
    
function button_callback11(varargin)
%Call to EEGLAB
eeglab;

end

function button_callback12(varargin)
%Call to settings window
global S

eegdatapro_settings(S);

end




               