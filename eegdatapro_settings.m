% Author: Matthew Frehlich, Ye Mei, Luis Garcia Dominguez,Faranak Farzan
%         2016
%         Ben Schwartzmann
%         2017

% eegdatapro_settings() - User-adjustable variables for use in TMSEEG toolbox.
% 
% Input: S - parent GUI information (structure)

% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.


function [] = eegdatapro_settings(S)

global backcolor basefile
if strcmp(basefile,'None Selected')
    msgbox('Please select data first');
    return
end

routine = S.routine;        
nb_function=size(routine.option_name,1);

nbsetting=1;

for i=1:nb_function
    
    switch routine.option_name{i}
          case {'INITIAL PROCESSING','REMOVE TMS ARTIFACT','REMOVE BAD TRLs AND CHNs','RUN ICA','REMOVE ICA COMPONENTS','FILTERING'}
              nbsetting=nbsetting+1;
    end
    
end


sizehfig=0.3*nbsetting/6;

hfig = figure('menubar','none',...
              'Toolbar','none',...
              'Units','normalized',...
              'name','EEG settings',...
              'color',backcolor,...
              'numbertitle','off',...
              'resize','off',...
              'Position',[0.3 0.3 0.3 sizehfig],...
              'DockControls','off');        
          
step=0; 
for i=1:nb_function
    
    switch routine.option_name{i}
        case 'INITIAL PROCESSING'
                namesetting='Initial Processing';
        case 'FILTERING'
                namesetting='Filtering';
        case 'REMOVE TMS ARTIFACT'
                namesetting='TMS Pulse Removal';
        case 'REMOVE BAD TRLs AND CHNs'
                namesetting='Remove Bad Trials and Channels';
        case 'RUN ICA'
                namesetting='ICA';
        case 'REMOVE ICA COMPONENTS'
                namesetting='ICA Components Removal';
        otherwise
                namesetting=[];
    end
    
    if ~isempty(namesetting)
        
        if routine.option_num(i)==1
            namebutton=namesetting;
          else
            namebutton=[namesetting,' ',num2str(routine.option_num(i))];
        end

        step=step+1;
        uicontrol('Parent', hfig,'Style','pushbutton',...
                        'Units','normalized',...
                        'Position',[0.2 1-((1-0.02*(nbsetting+1))/nbsetting+0.02)*step 0.6 (1-0.02*(nbsetting+1))/nbsetting],...
                        'Tag',num2str(i),...
                        'String',namebutton,...
                        'Callback',{@step_callback,S});
    end
    
end
        
uicontrol('Parent', hfig,'Style','pushbutton',...
                    'Units','normalized',...
                    'Position',[0.2 0.02 0.6 (1-0.02*(nbsetting+1))/nbsetting],...
                    'Tag','show_set',...
                    'String','View Data',...
                    'Callback',{@show_callback, S});
end
                
function step_callback(varargin)
% Settings call for step 1: Initial Processing
global S VARS basepath basefile

a = varargin{1};
steptoreset=str2double(get(a,'Tag'));
routine=S.routine;

occ = routine.option_num(steptoreset);

switch routine.option_name{steptoreset}
    case 'INITIAL PROCESSING'
        
        %Pop-up display settings
        prompt = {'Enter Resampling Frequency:',...
                    'Baseline Calculation Range'};
        dlg_title = ['Step' num2str(steptoreset) ' Settings'];
        num_lines = 1;
        defaultans = {num2str(VARS.RESAMPLE_FREQ),...
                      num2str(VARS.BASELINE_RNG)};
        answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
    
        if isempty(answer) %modification by Ben
        %if (length(answer) == 0) %Cancel Button
            disp('No changes made')
        else %OK button
            if exist([basepath '/' basefile '_1' '.set'],'file')
                choice = questdlg(['Continuing will reset workflow to step ' num2str(steptoreset) ', continue?']);
                switch choice %Change Settings
                    case 'Yes'
                        VARS.RESAMPLE_FREQ = str2double(answer{1});
                        VARS.BASELINE_RNG = str2double(answer{2});
                        eegdatapro_reset_workflow(S,steptoreset,S.num_steps)
                end
            else
                VARS.RESAMPLE_FREQ = str2double(answer{1});
                VARS.BASELINE_RNG = str2num(answer{2});
            end

        end
        
    case 'REMOVE BAD TRLs AND CHNs'
        
        %Pop-up Display
        prompt = {'% bad channels allowed in trial','% bad trials allowed in channel',...
                    'Start time for ATTRIBUTE extraction','End time for ATTRIBUTE extraction',...
                    'Pulse gap start time (ms)','Pulse gap end time (ms)',...
                    'Frequency band min (Hz)','Frequency band max (Hz)',...
                    'Channel plot ymin','Channel plot ymax'};
        dlg_title = ['Step' num2str(steptoreset) ' Settings'];
        num_lines = 1;
        defaultans = {num2str(VARS.(sprintf('PCT_BAD_CHANS_%d',occ))),... 
                    num2str(VARS.(sprintf('PCT_BAD_TRIALS_%d',occ))),... 
                    num2str(VARS.(sprintf('TIME_ST_%d',occ))),... 
                    num2str(VARS.(sprintf('TIME_END_%d',occ))),... 
                    num2str(VARS.(sprintf('PULSE_ST_%d',occ))),... 
                    num2str(VARS.(sprintf('PULSE_END_%d',occ))),... 
                    num2str(VARS.(sprintf('FREQ_MIN_%d',occ))),... 
                    num2str(VARS.(sprintf('FREQ_MAX_%d',occ))),... 
                    num2str(VARS.(sprintf('PLT_CHN_YMIN_%d',occ))),...
                    num2str(VARS.(sprintf('PLT_CHN_YMAX_%d',occ)))};
        answer = inputdlg(prompt,dlg_title,num_lines,defaultans);

        if isempty(answer) %modification by Ben
        %if (length(answer) == 0) %Cancel Button
            disp('No changes made')
        else
            if exist([basepath '/' basefile '_1' '.set'],'file')
                choice = questdlg(['Continuing will reset workflow to step ' num2str(steptoreset) ', continue?']);
                switch choice
                    case 'Yes' %Change settings
                        VARS.(sprintf('PCT_BAD_CHANS_%d',occ)) = str2double(answer{1});
                        VARS.(sprintf('PCT_BAD_TRIALS_%d',occ)) = str2double(answer{2});
                        VARS.(sprintf('TIME_ST_%d',occ)) = str2double(answer{3});
                        VARS.(sprintf('TIME_END_%d',occ)) = str2double(answer{4});
                        VARS.(sprintf('PULSE_ST_%d',occ)) = str2double(answer{5});
                        VARS.(sprintf('PULSE_END_%d',occ)) = str2double(answer{6});
                        VARS.(sprintf('FREQ_MIN_%d',occ)) = str2double(answer{7});
                        VARS.(sprintf('FREQ_MAX_%d',occ)) = str2double(answer{8});
                        VARS.(sprintf('PLT_CHN_YMIN_%d',occ)) = str2double(answer{9});
                        VARS.(sprintf('PLT_CHN_YMAX_%d',occ)) = str2double(answer{10});
                        eegdatapro_reset_workflow(S,steptoreset,S.num_steps)
                end
            else
                VARS.(sprintf('PCT_BAD_CHANS_%d',occ)) = str2double(answer{1});
                VARS.(sprintf('PCT_BAD_TRIALS_%d',occ)) = str2double(answer{2});
                VARS.(sprintf('TIME_ST_%d',occ)) = str2double(answer{3});
                VARS.(sprintf('TIME_END_%d',occ)) = str2double(answer{4});
                VARS.(sprintf('PULSE_ST_%d',occ)) = str2double(answer{5});
                VARS.(sprintf('PULSE_END_%d',occ)) = str2double(answer{6});
                VARS.(sprintf('FREQ_MIN_%d',occ)) = str2double(answer{7});
                VARS.(sprintf('FREQ_MAX_%d',occ)) = str2double(answer{8});
                VARS.(sprintf('PLT_CHN_YMIN_%d',occ)) = str2double(answer{9});
                VARS.(sprintf('PLT_CHN_YMAX_%d',occ)) = str2double(answer{10});
            end
        end
        
    case 'RUN ICA'
        
        % Pop-up display settings
        prompt = {'Percent of maximum ICA Components'};
        dlg_title = ['Step' num2str(steptoreset) ' Settings'];
        num_lines = 1;
        defaultans = {num2str(VARS.(sprintf('ICA_COMP_PCT_%d',occ)))};
        answer = inputdlg(prompt,dlg_title,num_lines,defaultans);

        if isempty(answer) %modification by Ben
        %if (length(answer) == 0) %Cancel Button
            disp('No changes made')
        else
            if exist([basepath '/' basefile '_1' '.set'],'file')
                choice = questdlg(['Continuing will reset workflow to step ' num2str(steptoreset) ', continue?']);
                switch choice
                    case 'Yes' %Update Settings
                        VARS.(sprintf('ICA_COMP_PCT_%d',occ)) = str2double(answer{1});
                        eegdatapro_reset_workflow(S,steptoreset, S.num_steps)
                end
            else
               VARS.(sprintf('ICA_COMP_PCT_%d',occ)) = str2double(answer{1});
            end
        end
        
        
    case 'REMOVE ICA COMPONENTS'
        
        % Pop-up display settings
        prompt = {'Update window start time (ms)',...
            'Update window end time (ms)',...
            'Update window ymin',...
            'Update window ymax',...
            '(Advanced) Kurtosis Threshold for electrode tagging'};
        dlg_title = ['Step' num2str(steptoreset) ' Settings'];
        num_lines = 1;
        defaultans = {num2str(VARS.(sprintf('UPD_WDW_STRT_%d',occ))),...
            num2str(VARS.(sprintf('UPD_WDW_END_%d',occ))),...
            num2str(VARS.(sprintf('UPD_WDW_YMIN_%d',occ))),...
            num2str(VARS.(sprintf('UPD_WDW_YMAX_%d',occ))),...
            num2str(VARS.(sprintf('UPD_KURTOSIS_THRESH_%d',occ)))};
        answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
        
        if isempty(answer) %modification by Ben
            %if (length(answer) == 0) %Cancel Button
            disp('No changes made')
        else
            if exist([basepath '/' basefile '_1' '.set'],'file')
                choice = questdlg(['Continuing will reset workflow to step ' num2str(steptoreset) ', continue?']);
                 switch choice
                        case 'Yes' %Change Settings
                            VARS.(sprintf('UPD_WDW_STRT_%d',occ))    = str2double(answer{1});
                            VARS.(sprintf('UPD_WDW_END_%d',occ))     = str2double(answer{2});
                            VARS.(sprintf('UPD_WDW_YMIN_%d',occ))    = str2double(answer{3});
                            VARS.(sprintf('UPD_WDW_YMAX_%d',occ))    = str2double(answer{4});
                            VARS.(sprintf('UPD_KURTOSIS_THRESH_%d',occ)) = str2double(answer{5});
                 end
            else
                VARS.(sprintf('UPD_WDW_STRT_%d',occ))    = str2double(answer{1});
                VARS.(sprintf('UPD_WDW_END_%d',occ))     = str2double(answer{2});
                VARS.(sprintf('UPD_WDW_YMIN_%d',occ))    = str2double(answer{3});
                VARS.(sprintf('UPD_WDW_YMAX_%d',occ))    = str2double(answer{4});
                VARS.(sprintf('UPD_KURTOSIS_THRESH_%d',occ)) = str2double(answer{5});
            end
        end
        
    case 'REMOVE TMS ARTIFACT'
        %Pop-up Display settings
        prompt = {'Enter ISI time interval (ms)',...
                    'TMS Pulse Duration (ms)'};
        dlg_title = ['Step' num2str(steptoreset) ' Settings'];
        num_lines = 1;
        defaultans = {num2str(VARS.ISI),...
                      num2str(VARS.PULSE_DURATION)};
        answer = inputdlg(prompt,dlg_title,num_lines,defaultans);

        if isempty(answer) %Cancel Button
            disp('No changes made')
        else
            if exist([basepath '/' basefile '_1' '.set'],'file')
                choice = questdlg(['Continuing will reset workflow to step ' num2str(steptoreset) ', continue?']);
                switch choice
                    case 'Yes' %Change settings
                        VARS.ISI            =  str2double(answer{1});
                        VARS.PULSE_DURATION =  str2double(answer{2});
                        eegdatapro_reset_workflow(S,steptoreset,S.num_steps)
                end
            else
                VARS.ISI            =  str2double(answer{1});
                VARS.PULSE_DURATION =  str2double(answer{2});
            end
        end
        
    case 'FILTERING'
        %Pop-up Display settings
        valid=1;
        prompt = {'Enter FIR Filter order (50-200):',...
                   'Enter IIR Filter order (1-20):'};
        dlg_title = ['Step' num2str(steptoreset) ' Settings'];
        num_lines = 1;
        defaultans = {num2str(VARS.(sprintf('FIR_FILTER_ORDER_%d',occ))),...
                      num2str(VARS.(sprintf('IIR_FILTER_ORDER_%d',occ)))};
        answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
        
        if isempty(answer)
            disp('No changes made')
        else
            if (str2double(answer{1}) < 50) || (str2double(answer{1}) > 200)
                valid=0;
                disp('Invalid Filter Order Entry - No changes made');
            end
        
            if (str2double(answer{2}) < 1) || (str2double(answer{2}) > 20)
                valid=0;
                disp('Invalid Filter Order Entry - No changes made');
            end
        end
        
        if valid && ~isempty(answer) 
               if exist([basepath '/' basefile '_1' '.set'],'file')
                    choice = questdlg(['Continuing will reset workflow to step ' num2str(steptoreset) ', continue?']);
                    switch choice
                        case 'Yes' %Change settings
                            VARS.(sprintf('FIR_FILTER_ORDER_%d',occ)) =  str2double(answer{1});
                            VARS.(sprintf('IIR_FILTER_ORDER_%d',occ)) =  str2double(answer{2});
                            eegdatapro_reset_workflow(S,steptoreset,S.num_steps)
                    end
                else
                    VARS.(sprintf('FIR_FILTER_ORDER_%d',occ)) =  str2double(answer{1});
                    VARS.(sprintf('IIR_FILTER_ORDER_%d',occ)) =  str2double(answer{2});
                end
        end
end
    
    
end


function show_callback(varargin)
% Settings call for View Data button
global VARS
% Set up pop-up display
prompt = {'View Data x min',...
          'View Data x max',...
          'View Data y limit',...
          'View Spectrum Frequency Range'};
dlg_title = 'View Data Settings';
num_lines = 1;
defaultans = {num2str(VARS.XSHOWMIN),...
              num2str(VARS.XSHOWMAX),...
              num2str(VARS.YSHOWLIMIT),...
              num2str(VARS.SPECTRUM_RNG)};
answer = inputdlg(prompt,dlg_title,num_lines,defaultans);

if isempty(answer)
    disp('No changes made')
else
    VARS.XSHOWMIN = str2double(answer{1});
    VARS.XSHOWMAX = str2double(answer{2});
    VARS.YSHOWLIMIT = str2double(answer{3});
    VARS.SPECTRUM_RNG = str2num(answer{4});
end



end


