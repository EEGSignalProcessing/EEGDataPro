% Author: Matthew Frehlich, Ye Mei, Luis Garcia Dominguez, Faranak Farzan
%         2016
%         Ben Schwartzmann 
%         2017

% eegdatapro_show() - Displays EEG data in a butterfly plot after the processing 
% step given by afterstep

% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.

function [] = eegdatapro_show_v2(afterstep)

%Check if previous step was done
if tmseeg_previous_step(afterstep+1) 
    return 
end

global backcolor VARS 
% global chans_sel

% [~, EEG] = eegdatapro_load_step(afterstep + 1);
% 
% 
% choice=questdlg('Do you want to view all channels or select some channels?',...
%           '',...
%           'All channels','Select channels','default');
%       
% switch choice 
%     case 'Select channels'
%         t = figure;
%         topoplot([],EEG.chanlocs,'style','blank','electrodes','labelpoint');
%         channel_list = uicontrol('style','list','max',10,...
%              'Units','normalized',...
%              'min',1,'Position',[0.85 0.1 0.1 0.8],...
%              'Parent',t,...
%              'string',{EEG.chanlocs.labels});
%         done_button = uicontrol('style','pushbutton',...
%              'Units','normalized',...
%              'string','Done',...
%              'Position',[0.75 0.1 0.1 0.05],...
%              'Parent',t,...
%              'Callback',{@retrieve_value,channel_list,t,afterstep,EEG});
%          waitfor(t);
%     case 'All channels'
%         chans_sel=1:size({EEG.chanlocs.labels},2);
% end


hfig = figure('Units','normalized',...
              'name',['EEG After Step ' num2str(afterstep)],...
              'numbertitle','off',...
              'resize','on',...
              'color',backcolor,...
              'Position',[0 0 0.7 0.7],...
              'DockControls','off');
axes('Position',[0.2 0.1 0.75 0.9]);   

data_button = uicontrol('style','pushbutton',...
     'Units','normalized',...
     'Position',[0.02 0.90 0.1 0.05],...
     'Parent',hfig,...
     'string','View Data',...
     'Callback',{@view_data,afterstep}); %#ok
spectrum_button = uicontrol('style','pushbutton',...
     'Units','normalized',...
     'Position',[0.02 0.85 0.1 0.05],...
     'Parent',hfig,...
     'string','View Spectrum',...
     'Callback',{@view_spectrum,afterstep}); %#ok
zoom_button = uicontrol('style','pushbutton',...
     'Units','normalized',...
     'Position',[0.02 0.75 0.1 0.05],...
     'Parent',hfig,...
     'string','Zoom on Data',...
     'Callback',{@view_zoom,afterstep}); %#ok
          

xshowmin = VARS.XSHOWMIN;
xshowmax = VARS.XSHOWMAX;
yshowlimit = VARS.YSHOWLIMIT;


%Adjust display limits based on epoching
if VARS.XSHOWMIN < VARS.EPCH_STRT
    xshowmin = VARS.EPCH_STRT;
end

if VARS.XSHOWMAX > VARS.EPCH_END
    xshowmax = VARS.EPCH_END;
end


%Load proper dataset
[~, EEG] = eegdatapro_load_step(afterstep + 1);



% if afterstep == 1 || afterstep == 10
%     pre_pulse_deletion = 1;
% end
% EEGtimes  = EEG.times;             
data_temp = squeeze(nanmean(EEG.data,3));

%Create topo plot with EEGLAB timtopo() command  
% if(pre_pulse_deletion)
%     data_temp = squeeze(nanmean(EEG.data,3));
% else
%     data_temp = squeeze(nanmean(EEG.data,3));
% 
%     if(isfield(EEG,{'TMS_period2remove_b'}))
%         ix = min(EEG.TMS_period2remove_b);
%         rm_pulse_fill = NaN(size(data_temp,1),length(EEG.TMS_period2remove_b));
%         data_temp = cat(2,data_temp(:,1:ix-1),rm_pulse_fill,data_temp(:,ix:end));
%     end
% 
%     %Insert NaN values to fill space where TMS pulse was removed
%     ix       = min(EEG.TMS_period2remove_1);
%     rm_pulse_fill = NaN(size(data_temp,1),length(EEG.TMS_period2remove_1));
%     data_temp = cat(2,data_temp(:,1:ix-1),rm_pulse_fill,data_temp(:,ix:end));
% 
% end

EEGtimes =  min(EEG.times):1000/EEG.srate:max(EEG.times);
data = data_temp(:,EEGtimes>=xshowmin & EEGtimes<=xshowmax);

timtopo(data, EEG.chanlocs,'limits',[xshowmin xshowmax -yshowlimit yshowlimit])
% timtopo(data, EEG.chanlocs,'limits',[xshowmin xshowmax -yshowlimit yshowlimit],'plotchans',chans_sel)

end

function view_spectrum(varargin)

h = findall(gcf,'Type','axes');
delete(h);

global VARS 
% global chans_sel
afterstep=varargin{3};

[~, EEG] = eegdatapro_load_step(afterstep + 1);          

axes('Position',[0.2 0.15 0.70 0.75]);          
pop_spectopo( EEG,1,[EEG.xmin*1000 EEG.xmax*1000],'EEG','percent',100,'freq',[2 6 20],'freqrange',VARS.SPECTRUM_RNG,'electrodes','on');

% if length(chans_sel) == 1
%     pop_spectopo( EEG,1,[EEG.xmin*1000 EEG.xmax*1000],'EEG','percent',100,'freqrange',VARS.SPECTRUM_RNG,'electrodes','on','plotchans',chans_sel);
% else
%     pop_spectopo( EEG,1,[EEG.xmin*1000 EEG.xmax*1000],'EEG','percent',100,'freq',[2 6 20],'freqrange',VARS.SPECTRUM_RNG,'electrodes','on','plotchans',chans_sel);
% end
        
end


function view_data(varargin)

h = findall(gcf,'Type','axes');
delete(h);

global VARS 
%global chans_sel

afterstep=varargin{3};

xshowmin = VARS.XSHOWMIN;
xshowmax = VARS.XSHOWMAX;
yshowlimit = VARS.YSHOWLIMIT;


%Adjust display limits based on epoching
if VARS.XSHOWMIN < VARS.EPCH_STRT
    xshowmin = VARS.EPCH_STRT;
end

if VARS.XSHOWMAX > VARS.EPCH_END
    xshowmax = VARS.EPCH_END;
end

[~, EEG] = eegdatapro_load_step(afterstep + 1);
            
data_temp = squeeze(nanmean(EEG.data,3));
EEGtimes =  min(EEG.times):1000/EEG.srate:max(EEG.times);
data = data_temp(:,EEGtimes>=xshowmin & EEGtimes<=xshowmax);

axes('Position',[0.2 0.1 0.75 0.9]);          
timtopo(data, EEG.chanlocs,'limits',[xshowmin xshowmax -yshowlimit yshowlimit]);

% timtopo(data, EEG.chanlocs,'limits',[xshowmin xshowmax -yshowlimit yshowlimit],'plotchans',chans_sel);

end


% function retrieve_value(varargin)
% 
% global chans_sel
% 
% h_list = varargin{3};
% chans_sel = get(h_list,'value');
% close(varargin{4});
% 
% end


function view_zoom(varargin)
%Load EEG Data, display in custom plot allowing zoom feature

global VARS
afterstep=varargin{3};

figure('units','normalized',...
        'menubar','none',...
        'numbertitle','off',...
        'toolbar','none',...
        'name',['After Step ' num2str(afterstep)],...
        'position',[0 0 .9 .9 ]);

xshowmin = VARS.XSHOWMIN;
xshowmax = VARS.XSHOWMAX;

%Adjust display limits based on epoching
if VARS.XSHOWMIN < VARS.EPCH_STRT
    xshowmin = VARS.EPCH_STRT;
end

if VARS.XSHOWMAX > VARS.EPCH_END
    xshowmax = VARS.EPCH_END;
end

[~, EEG] = eegdatapro_load_step(afterstep + 1);
EEGtimes =  min(EEG.times):1000/EEG.srate:max(EEG.times);

data_temp = squeeze(nanmean(EEG.data,3));
data = data_temp(:,EEGtimes>=xshowmin & EEGtimes<=xshowmax);

x = EEGtimes(EEGtimes>=xshowmin & EEGtimes<=xshowmax);
y = squeeze(nanmean(data,3));
plot(x,y)

titlestr  = ['Data after processing step ' num2str(afterstep) ...
    ', use cursor to zoom in, shift + click to zoom out'];
title(titlestr)
xlabel('Time(ms)');
ylabel(['Amplitude (' char(0181) 'V)']);
zoom on

end