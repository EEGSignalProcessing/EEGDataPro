% Author: Ben Schwartzmann, 2017

% create_eeg_main() - GUI to create a routine with the preprocessing
% options available

% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.


function [] = eegdatapro_create_main()

% Main object GUI Parent figure
main_fig = findobj('type','figure','name','EEGDataPro - Choose processing routine');
set(main_fig,'HandleVisibility','off');
close all
set(main_fig,'HandleVisibility','on');


global S_Create
S_Create      = []; 
S_Create.hfig = figure('menubar','none',...
              'Toolbar','none',...
              'Units','normalized',...
              'name','EEGDataPro - Create processing routine',...
              'numbertitle','off',...
              'resize','on',...
              'Color',[0.7 0.8 1],...
              'Position',[0.35 0.4 0.5 0.3],...
              'DockControls','off');
          

%Positions (x,y) and sizes (heigh,width) for the different buttons
ycol5 = 0;
ycol4 = 0.2;
ycol3 = 0.35;
ycol2 = 0.575;
ycol1 = 0.925;

xcol1 = 0;
xcol2 = 0.37;
xcol3 = 0.64;

hcola = 0.2;
hcolb = 0.725;
hcolc = 0.075;

wcola = 0.36;
wcolb = 1;
wcolc = 0.26;

S_Create.routine = [];
S_Create.routine.step_num=[];
S_Create.routine.option_name=[];
S_Create.routine.option_num=[];

S_Create.list_ref={'INITIAL PROCESSING';...
          'REMOVE TMS ARTIFACT';...
          'REMOVE BAD TRLs AND CHNs';...
          'FILTERING';...
          'RUN ICA';...
          'REMOVE TMS DECAY ARTIFACT';...
          'REMOVE ICA COMPONENTS';...
          'FINAL PROCESSING'};

S_Create.allowed = zeros(8,1);
S_Create.allowed(1) = 1;     
S_Create.allowed(4) = 1;
      

for k = 1:8

    if S_Create.allowed(k) == 1
        S_Create.list_of_options{k} = S_Create.list_ref{k};
    else
        S_Create.list_of_options{k} = str2html (S_Create.list_ref{k},'italic',true,'colour','#7F7F7F');
    end

end
               
S_Create.button1 = uicontrol('Parent', S_Create.hfig,'Style','text',...
                   'Units','normalized',...
                   'Position',[xcol1 ycol1 wcola hcolc],...
                   'String','List of available preprocessing options',...
                   'Callback',{@button_callback1});
S_Create.button2 = uicontrol('Parent', S_Create.hfig,'Style','listbox',...
                   'Units','normalized',...
                   'Position',[xcol1 ycol4 wcola hcolb],...
                   'BackgroundColor',[1 0.7 0.7],...
                   'String',S_Create.list_of_options,...
                   'Callback',{@button_callback2});
S_Create.button3 = uicontrol('Parent', S_Create.hfig,'Style','pushbutton',...
                   'Units','normalized',...
                   'Position',[xcol2 ycol2 wcolc hcola],...
                   'String','Add option to routine',...
                   'Callback',{@button_callback3});
S_Create.button4 = uicontrol('Parent', S_Create.hfig,'Style','pushbutton',...
                   'Units','normalized',...
                   'Position',[xcol2 ycol3 wcolc hcola],...
                   'String','Remove option to routine',...
                   'Callback',{@button_callback4});
S_Create.button5 = uicontrol('Parent', S_Create.hfig,'Style','text',...
                   'Units','normalized',...
                   'Position',[xcol3 ycol1 wcola hcolc],...
                   'String','Processing routine',...
                   'Callback',{@button_callback5});
S_Create.button6 = uicontrol('Parent', S_Create.hfig,'Style','listbox',...
                   'Units','normalized',...
                   'Position',[xcol3 ycol4 wcola hcolb],...
                   'BackgroundColor',[1 0.7 0.7],...
                   'String','');
S_Create.button7 = uicontrol('Parent', S_Create.hfig,'Style','pushbutton',...
                   'Units','normalized',...
                   'Position',[xcol1 ycol5 wcolb hcola],...
                   'String','Create processing routine',...
                   'Callback',{@button_callback7});
                            
end

function button_callback3(varargin) %add option to list of routine

global S_Create
%get elements
ind_option_to_add = get(S_Create.button2,'Value');

if ~S_Create.allowed(ind_option_to_add)
    msgbox('You cannot add any option after the step final processing');
    return
end

list_options = get(S_Create.button2,'String');
name_option_to_add = list_options{ind_option_to_add};
list_for_routine = get(S_Create.button6,'String');
nb_options_existing = size(list_for_routine,1);

if S_Create.allowed(ind_option_to_add) == 0
    errordlg ( 'Not allowed' );
    set(S_Create.button2,'Value',find ( allowed, 1, 'first' ));
end  

%add option
S_Create.routine.option_name{nb_options_existing+1,1} = name_option_to_add;
S_Create.routine.step_num = (1:nb_options_existing+1)';
S_Create.routine.option_num(nb_options_existing+1,1) = sum(strcmp(S_Create.routine.option_name,name_option_to_add));

%update list of routine ans list of available options
set(S_Create.button6,'String',strcat(num2str(S_Create.routine.step_num),'.',S_Create.routine.option_name,optionnum2str(S_Create.routine.option_num)));
updatelist(ind_option_to_add);

end


function button_callback4(varargin) %remove option from list of routine

global S_Create
%if empty routine, msgbox error and return
if isempty(get(S_Create.button6,'String'))
    msgbox('The processing routine is empty');
    return
end    
    
%get elements
ind_option_to_remove = get(S_Create.button6,'Value');
name_option_to_remove = S_Create.routine.option_name{ind_option_to_remove,1};
list_for_routine = get(S_Create.button6,'String');
nb_options_existing = size(list_for_routine,1);

%remove option
temp_name(1:ind_option_to_remove-1,1) = S_Create.routine.option_name(1:ind_option_to_remove-1,1);
temp_num(1:ind_option_to_remove-1,1) = S_Create.routine.option_num(1:ind_option_to_remove-1,1);
S_Create.routine.option_num(strcmp(S_Create.routine.option_name,name_option_to_remove)) = S_Create.routine.option_num(strcmp(S_Create.routine.option_name,name_option_to_remove))-1;

% routine.option_num
if ind_option_to_remove ~= nb_options_existing
    temp_name(ind_option_to_remove:nb_options_existing-1,1) = S_Create.routine.option_name(ind_option_to_remove+1:end,1);
    temp_num(ind_option_to_remove:nb_options_existing-1,1)=  S_Create.routine.option_num(ind_option_to_remove+1:end,1);
end

S_Create.routine.option_name = temp_name;
S_Create.routine.step_num = (1:nb_options_existing-1)';
S_Create.routine.option_num = temp_num;

%case when option to remove is the fist element of the list
if ind_option_to_remove == 1 
    set(S_Create.button6,'Value',1)
else
    set(S_Create.button6,'Value',ind_option_to_remove-1);
end

%update list of routine
set(S_Create.button6,'String',strcat(num2str(S_Create.routine.step_num),'.',S_Create.routine.option_name,optionnum2str(S_Create.routine.option_num)));
updatelist2(name_option_to_remove,ind_option_to_remove);

end


function button_callback7(varargin) %create routine

global S_Create
%if empty routine, msgbox error and return
if isempty(S_Create.routine.option_name) 
    msgbox('Please select at least 1 preprocessing option');
    return;
end

%check that last step is Final Processing
list_for_routine = get(S_Create.button6,'String');
nb_options_existing = size(list_for_routine,1);
if ~strcmp(S_Create.routine.option_name(nb_options_existing),'FINAL PROCESSING')
    msgbox('Last step must be Final Processing');
    return;
end

%ask to save the routine
select_save = questdlg('Do you want to save the routine?'); 
routine=S_Create.routine;%#ok
switch select_save
    case 'Yes'
        try
            [filename, pathname] = uiputfile('*.mat','Save routine as');
            newfilename = fullfile(pathname, filename);
            save(newfilename,'routine');
            eegdatapro_main(S_Create.routine); %create the routine
        catch 
            return;
        end
    case 'No'
        eegdatapro_main(S_Create.routine); %create the routine
end
    
end


function str = optionnum2str(optionnum) %if optionnum=1 don't show it

if isempty(optionnum)
    str = '';
else
    str = cell(size(optionnum));

    for i = 1:size(optionnum,1)
        if optionnum(i)== 1
            str{i,1} = '';
        else
            str{i,1} = [' ',num2str(optionnum(i))];
        end
    end
end

end

function button_callback2(varargin) %select option to be added

global S_Create
%get elements
ind_option_to_add = get(S_Create.button2,'Value');

%set up value in list of options to the first available option if option
%selected is not available
if S_Create.allowed(ind_option_to_add) == 0
    if ~isempty(find (S_Create.allowed, 1, 'first' ))
        set(S_Create.button2,'Value',find (S_Create.allowed, 1, 'first' ));
    else
        set(S_Create.button2,'Value',1);
    end
end 

end

function updatelist(step)

global S_Create
switch step
    %change available options depending on the one which was just added
    case 1
        S_Create.allowed([2:5 8]) = 1;
        S_Create.allowed(1) = 0;
    case 2 
        S_Create.allowed(2) = 0;
    case 5
        S_Create.allowed(1:8) = 0;
        S_Create.allowed(6:7) = 1;
    case {6,7}
        S_Create.allowed(1:8) = 1;
        S_Create.allowed(6:7) = 0;
    case 8
        S_Create.allowed(1:8) = 0;
end

%change available options that can be added only once
[~,already] = intersect(S_Create.list_ref,S_Create.routine.option_name);
[already2] = intersect([1 2 6],already);
S_Create.allowed(already2) = 0;

%update the list of options available
for l = 1:8
    if S_Create.allowed(l) == 1
        S_Create.list_of_options{l} = S_Create.list_ref{l};
    else
        S_Create.list_of_options{l} = str2html (S_Create.list_ref{l},'italic',true,'colour','#7F7F7F');
    end
end
set(S_Create.button2,'String',S_Create.list_of_options);          

%set up value in list of options to the first available option
if S_Create.allowed(step) == 0
    if ~isempty(find(S_Create.allowed, 1, 'first' ))
        set(S_Create.button2,'Value',find(S_Create.allowed, 1, 'first' ));
    else
        set(S_Create.button2,'Value',1);
    end
else
    set(S_Create.button2,'Value',step);
end

end


function updatelist2(nameoption,ind)

global S_Create
switch nameoption
    case 'INITIAL PROCESSING'
        %remove all options after this step and make only 'INITIAL
        %PROCESSING' and 'FILTERING' options available again`   
        S_Create.routine.step_num(ind:end) = [];
        S_Create.routine.option_name(ind:end) = [];
        S_Create.routine.option_num(ind:end) = [];
        set(S_Create.button6,'String',strcat(num2str(S_Create.routine.step_num),'.',S_Create.routine.option_name,optionnum2str(S_Create.routine.option_num)));
        S_Create.allowed(2:8) = 0;
        S_Create.allowed(1) = 1;
        S_Create.allowed(4) = 1;
        
    case 'REMOVE TMS ARTIFACT'
        %make this option available again
        S_Create.allowed(2) = 1;
        
    case {'REMOVE TMS DECAY ARTIFACT';'REMOVE ICA COMPONENTS'}
        %remove also 'RUN ICA' option
        list_for_routine = get(S_Create.button6,'String');
        nb_options_existing = size(list_for_routine,1);
        %remove option
        temp_name(1:ind-2,1) = S_Create.routine.option_name(1:ind-2,1);
        temp_num(1:ind-2,1) = S_Create.routine.option_num(1:ind-2,1);
        S_Create.routine.option_num(strcmp(S_Create.routine.option_name,'RUN ICA')) = S_Create.routine.option_num(strcmp(S_Create.routine.option_name,'RUN ICA'))-1;
        % routine.option_num
        if ind ~= nb_options_existing-1
            temp_name(ind-1:nb_options_existing-1,1) = S_Create.routine.option_name(ind:end,1);
            temp_num(ind-1:nb_options_existing-1,1) = S_Create.routine.option_num(ind:end,1);
        end
        S_Create.routine.option_name = temp_name;
        S_Create.routine.step_num = (1:nb_options_existing-1)';
        S_Create.routine.option_num = temp_num;
        set(S_Create.button6,'String',strcat(num2str(S_Create.routine.step_num),'.',S_Create.routine.option_name,optionnum2str(S_Create.routine.option_num)));
        set(S_Create.button6,'Value',ind-2);
        
    case 'RUN ICA'
        %remove also 'REMOVE ICA COMPONENTS' or 'REMOVE TMS DECAY ARTIFACT' option if
        %it was added
        list_for_routine = get(S_Create.button6,'String');
        nb_options_existing = size(list_for_routine,1);
        if ind <= nb_options_existing
            %remove option
            temp_name(1:ind-1,1) = S_Create.routine.option_name(1:ind-1,1);
            temp_num(1:ind-1,1) = S_Create.routine.option_num(1:ind-1,1);
            %if next option was 'REMOVE ICA COMPONENTS', update also
            %option_num for it
            if strcmp(S_Create.routine.option_name(ind),'REMOVE ICA COMPONENTS')
                S_Create.routine.option_num(strcmp(S_Create.routine.option_name,'REMOVE ICA COMPONENTS')) = S_Create.routine.option_num(strcmp(S_Create.routine.option_name,'REMOVE ICA COMPONENTS'))-1;
            end
            % routine.option_num
            if ind ~= nb_options_existing
                temp_name(ind:nb_options_existing-1,1) = S_Create.routine.option_name(ind+1:end,1);
                temp_num(ind:nb_options_existing-1,1) = S_Create.routine.option_num(ind+1:end,1);
            end
            S_Create.routine.option_name = temp_name;
            S_Create.routine.step_num = (1:nb_options_existing-1)';
            S_Create.routine.option_num = temp_num;
            set(S_Create.button6,'String',strcat(num2str(S_Create.routine.step_num),'.',S_Create.routine.option_name,optionnum2str(S_Create.routine.option_num)));     
        else %RUN ICA was the last option added
            %make all options available again except options that can be add
            %only once and 'REMOVE ICA COMPONENTS' and 'REMOVE TMS DECAY ARTIFACT' options
            S_Create.allowed(1:8) = 1;
            S_Create.allowed(6:7) = 0;
            [~,already] = intersect(S_Create.list_ref,S_Create.routine.option_name);
            [already2] = intersect([1 2 6],already);
            S_Create.allowed(already2) = 0;
        end
        
     case 'FINAL PROCESSING'
        %make all options available again except options that can be add
        %only once and 'REMOVE ICA COMPONENTS' and 'REMOVE TMS DECAY ARTIFACT' options 
        S_Create.allowed(1:8) = 1;
        S_Create.allowed(6:7) = 0;
        [~,already] = intersect(S_Create.list_ref,S_Create.routine.option_name);
        [already2] = intersect([1 2 6],already);
        S_Create.allowed(already2) = 0;
end

%update the list of options available
for l = 1:8
    if S_Create.allowed(l) == 1
        S_Create.list_of_options{l} = S_Create.list_ref{l};
    else
        S_Create.list_of_options{l} = str2html (S_Create.list_ref{l},'italic',true,'colour','#7F7F7F');
    end
end    
set(S_Create.button2,'String',S_Create.list_of_options);

%set up value in list of options to the first available option
if ~isempty(find(S_Create.allowed, 1, 'first' ))
    set(S_Create.button2,'Value',find (S_Create.allowed, 1, 'first' ));
else
    set(S_Create.button2,'Value',1);
end

end


