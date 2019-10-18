% Author: Ben Schwartzmann, 2017

% eeg_toolbox_main() - GUI with 4 different buttons to access toolboxes
% already existing or to load/create routine

% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.

function []= eegdatapro_toolbox_main()

close all;
clear all; 
backcolor   = [0.7 0.8 1];

% Main object, GUI Parent figure
S      = []; 
S.hfig = figure('menubar','none',...
              'Toolbar','none',...
              'Units','normalized',...
              'name','EEGDataPro - Choose processing routine',...
              'numbertitle','off',...
              'resize','on',...
              'Color',backcolor,...
              'Position',[0.1 0.3 0.2 0.4],...
              'DockControls','off');

%Positions (x,y) and sizes (heigh,width) for the different buttons
ycol = 0.75;
xcol = 0;
hcol=0.25;
wcol = 1;

notexistcolor = [1 0.7 0.7];

S.existbutton1 = 0;
S.existbutton2 = 0;

%Check if toolboxes are installed or not
myappinfo = matlab.apputil.getInstalledAppInfo; 

if isempty(myappinfo)
    nameapp=[];
else
    nameapp={myappinfo.name};
    for i=1:size(myappinfo,2)
        loc=myappinfo(i).location;
        addpath(genpath(loc));
    end
end

cmpbutton1=zeros(size(nameapp,2),3);

for i=1:size(nameapp,2)
    cmpbutton1(i,:)=strcmp([nameapp{i}],{'tmseeg_v3.0','tmseeg_v3.1','tmseeg_v4.0'});
end

cmpbutton2=zeros(size(nameapp,2),2);

for i=1:size(nameapp,2)
    cmpbutton2(i,:)=strcmp([nameapp{i}],{'ERPEEG_v1.0','erpeeg_v2.0'});
end

listversion1={'3.0';'3.1';'4.0'};
listversion2={'1.0';'2.0'};

if sum(sum(cmpbutton1)) ~= 0
    [~,ind] = find(cmpbutton1);
    S.version1 = max(ind);
    S.existbutton1 = 1;
end

if sum(sum(cmpbutton2)) ~= 0
    [~,ind] = find(cmpbutton2);
    S.version2 = max(ind);
    S.existbutton2 = 1;
end


%Different buttons depending on toolboxes already installed or not
if S.existbutton1
    S.button1 = uicontrol('Parent', S.hfig,'Style','pushbutton',...
                       'Units','normalized',...
                       'Position',[xcol ycol wcol hcol],...
                       'String',['Go to TMSEEG toolbox (version ' listversion1{S.version1} ')'],...
                       'Callback',{@button_callback1,S});
else
    S.button1 = uicontrol('Parent', S.hfig,'Style','pushbutton',...
                       'Units','normalized',...
                       'Position',[xcol ycol wcol hcol],...
                       'String','Go to TMSEEG toolbox (not currently installed)',...
                       'BackgroundColor',notexistcolor,...
                       'Callback',{@button_callback1,S});
end

if S.existbutton2
    S.button2 = uicontrol('Parent', S.hfig,'Style','pushbutton',...
                       'Units','normalized',...
                       'Position',[xcol ycol-hcol wcol hcol],...
                       'String',['Go to ERPEEG toolbox (version ' listversion2{S.version2} ')'],...
                       'Callback',{@button_callback2,S});
else
    S.button2 = uicontrol('Parent', S.hfig,'Style','pushbutton',...
                       'Units','normalized',...
                       'Position',[xcol ycol-hcol wcol hcol],...
                       'String','Go to ERPEEG toolbox (not currently installed)',...
                       'BackgroundColor',notexistcolor,...
                       'Callback',{@button_callback2,S});
end

S.button3 = uicontrol('Parent', S.hfig,'Style','pushbutton',...
                   'Units','normalized',...
                   'Position',[xcol ycol-2*hcol wcol hcol],...
                   'String','Load processing routine',...
                   'Callback',{@button_callback3,S});
S.button4 = uicontrol('Parent', S.hfig,'Style','pushbutton',...
                   'Units','normalized',...
                   'Position',[xcol ycol-3*hcol wcol hcol],...
                   'String','Create processing routine',...
                   'Callback',{@button_callback4,S});
end
               
function button_callback1(varargin)
%Go to TMSEEG toolbox
S = varargin{3};
existbutton = S.existbutton1;

if ~existbutton
        msgbox('Please install TSMEEG toolbox first');
        return
end

if S.version1 ~= 3
    choice = questdlg('You are using an old version of the TMSEEG toolbox, do you want to continue?','Yes','No');
    switch choice 
        case 'Yes'
            tmseeg_main();
    end   
else
    tmseeg_main();
end

end


function button_callback2(varargin)
%Go to ERPEEG toolbox
S = varargin{3};
existbutton = S.existbutton2;

if ~existbutton
    msgbox('Please install ERPEEG toolbox first');
    return
end

if S.version2 ~= 3
    choice = questdlg('You are using an old version of the ERPEEG toolbox, do you want to continue?','Yes','No');
    switch choice 
        case 'Yes'
            erpeeg_main();
    end   
else
    erpeeg_main();
end

end


function button_callback3(varargin)   
%Load a routine
try
    [filename,pathname] = uigetfile(fullfile(pwd,'*.mat'),'Select original file');
    tmp = load([pathname filename]);
    name = fieldnames(tmp);
    eegdatapro_main(tmp.(name{1}))
catch
    if filename ~= 0 
        main_fig = findobj('type','figure','name','EEG processing toolbox');
        close(main_fig);
        msgbox('Please select a valid file');
    end
end
  
end 
 
function button_callback4(varargin)
%Create a routine
eegdatapro_create_main();

end
