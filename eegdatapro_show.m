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

function [] = eegdatapro_show(afterstep, laststep)

%Check if previous step was done
if eegdatapro_previous_step(afterstep+1) 
    return 
end

global backcolor VARS lineposition

hfig = figure('Units','normalized',...
              'name',['EEG After Step ' num2str(afterstep)],...
              'numbertitle','off',...
              'resize','on',...
              'color',backcolor,...
              'Position',[0 0 0.7 0.7],...
              'DockControls','off');
% set(hfig,'WindowButtonDown',{@sendout});
      
data_button = uicontrol('style','pushbutton',...
     'Units','normalized',...
     'Position',[0.02 0.90 0.1 0.05],...
     'Parent',hfig,...
     'string','View Data',...
     'Callback',{@view_data,afterstep,laststep}); %#ok
spectrum_button = uicontrol('style','pushbutton',...
     'Units','normalized',...
     'Position',[0.02 0.85 0.1 0.05],...
     'Parent',hfig,...
     'string','View Spectrum',...
     'Callback',{@view_spectrum,afterstep}); %#ok

  
lineposition=[]; 
 
pre_pulse_deletion = 0;
 
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

if afterstep == laststep 
    pre_pulse_deletion = 1;
end


%Create topo plot with EEGLAB timtopo() command  
if(pre_pulse_deletion)
    data_temp = squeeze(nanmean(EEG.data,3));
    EEGtimes =  EEG.times;
else
    data_temp = squeeze(nanmean(EEG.data,3));
    EEGtimes =  min(EEG.times):1000/EEG.srate:max(EEG.times);

    if(isfield(EEG,{'TMS_period2remove_b'}))
        ix = min(EEG.TMS_period2remove_b);
        rm_pulse_fill = NaN(size(data_temp,1),length(EEG.TMS_period2remove_b));
        data_temp = cat(2,data_temp(:,1:ix-1),rm_pulse_fill,data_temp(:,ix:end));
    end

    if(isfield(EEG,{'TMS_period2remove_1'}))
        %Insert NaN values to fill space where TMS pulse was removed
        ix       = min(EEG.TMS_period2remove_1);
        rm_pulse_fill = NaN(size(data_temp,1),length(EEG.TMS_period2remove_1));
        data_temp = cat(2,data_temp(:,1:ix-1),rm_pulse_fill,data_temp(:,ix:end));
    end

end

% EEGtimes =  min(EEG.times):1000/EEG.srate:max(EEG.times);
data = data_temp(:,EEGtimes>=xshowmin & EEGtimes<=xshowmax);

% timtopo(data, EEG.chanlocs,'limits',[xshowmin xshowmax -yshowlimit yshowlimit]);
x = EEGtimes(EEGtimes>=xshowmin & EEGtimes<=xshowmax);
y = data;

a2=axes('Position',[0.2 0.1 0.75 0.55]);
plot(a2,x,y)
% zoomHandle = zoom;
% set(zoomHandle,'ActionPostCallback',@test);
xlim([xshowmin xshowmax]);
yla=get(a2,'ylim');
line([0 0],[yla(1) yla(2)],'Linestyle',':','Color',[0.5 0.5 0.5]);
set(gca,'ButtonDownFcn', {@AxesCallback2,afterstep,laststep});
xlabel('Latency (ms)','Fontsize', 15);
ylabel('Potential (\muV)','Fontsize',15);
axes('Position',[0.45 0.70 0.25 0.25]);
topoplot(zeros(1,EEG.nbchan),EEG.chanlocs);
title('Click on the plot to obtain the scalp map at a certain latency');
colormap('gray');
cb = colorbar;
% set(cb,'position',[.94 .66 .015 .08])
% set(cb,'YAxisLocation','left','Fontsize',20);
a=get(cb,'Limits');
delete(cb);
cb2 = colorbar('Ticks',a,'TickLabels',{'-','+'});
set(cb2,'position',[.94 .66 .015 .08])
set(cb2,'YAxisLocation','left','Fontsize',15);

end

% function sendout(varargin)
%   C = get (gca, 'CurrentPoint')
%   p = get (gcf,'Children');
%   p(1).Position
%   g=get(gco)
% end

function view_spectrum(varargin)

h = findall(gcf,'Type','axes');
delete(h);
delete(findall(gcf,'type','annotation'));

global VARS fpsd psd lineposition

lineposition=[];

afterstep=varargin{3};

[~, EEG] = eegdatapro_load_step(afterstep + 1);          

% axes('Position',[0.2 0.15 0.70 0.75]);          
% pop_spectopo( EEG,1,[EEG.xmin*1000 EEG.xmax*1000],'EEG','percent',100,'freq',[2 6 20],'freqrange',VARS.SPECTRUM_RNG,'electrodes','on');

for i=1:EEG.nbchan
    EEGdata=EEG.data(i,:);
    EEGdataspect=EEGdata(~isnan(EEGdata));
[psd(:,i),fpsd]=pwelch(EEGdataspect,EEG.srate,0,EEG.srate,EEG.srate);
end

a2=axes('Position',[0.2 0.1 0.75 0.55]);
plot(a2,fpsd(VARS.SPECTRUM_RNG(1)+1:VARS.SPECTRUM_RNG(2)+1),10*log10(psd(VARS.SPECTRUM_RNG(1)+1:VARS.SPECTRUM_RNG(2)+1,:)),'Linewidth',1.5);
xlim([VARS.SPECTRUM_RNG(1) VARS.SPECTRUM_RNG(2)]);
set(gca,'ButtonDownFcn', {@AxesCallback,afterstep});
xlabel('Frequency (Hz)','Fontsize', 15);
ylabel('Power Spectral Density (dB)','Fontsize',15);
axes('Position',[0.45 0.70 0.25 0.25]);
topoplot(zeros(1,EEG.nbchan),EEG.chanlocs);
title('Click on the plot to obtain the scalp map at a certain frequency');
colormap('gray');
cb = colorbar;
% set(cb,'position',[.94 .66 .015 .08])
% set(cb,'YAxisLocation','left','Fontsize',20);
a=get(cb,'Limits');
delete(cb);
cb2 = colorbar('Ticks',a,'TickLabels',{'-','+'});
set(cb2,'position',[.94 .66 .015 .08])
set(cb2,'YAxisLocation','left','Fontsize',15);

% axes('ButtonDownFcn', @AxesCallback);

end


function AxesCallback(varargin)


afterstep=varargin{3};

[~, EEG] = eegdatapro_load_step(afterstep + 1);          

global VARS fpsd psd lineposition
C=get(gca,'CurrentPoint');
freq=round(C(1,1));
h = findall(gcf,'Type','axes');
delete(h);
delete(findall(gcf,'type','annotation'));


a2=axes('Position',[0.2 0.1 0.75 0.55]);
plot(a2,fpsd(VARS.SPECTRUM_RNG(1)+1:VARS.SPECTRUM_RNG(2)+1),10*log10(psd(VARS.SPECTRUM_RNG(1)+1:VARS.SPECTRUM_RNG(2)+1,:)),'Linewidth',1.5);
xlim([VARS.SPECTRUM_RNG(1) VARS.SPECTRUM_RNG(2)]);
yla=get(a2,'ylim');
line([freq freq],[min(10*log10(psd(freq+1,:))) max(10*log10(psd(freq+1,:)))],'LineStyle','--','LineWidth',1.5,'Color','k'); 
lineposition=[freq freq min(10*log10(psd(freq+1,:))) max(10*log10(psd(freq+1,:)))]; 

% c1=get(l,'Color');

set(gca,'ButtonDownFcn', {@AxesCallback,afterstep});
xlabel('Frequency (Hz)','Fontsize', 15);
ylabel('Power Spectral Density (dB)','Fontsize',15);
datatoplot=10*log10(psd(freq+1,:))-mean(10*log10(psd(freq+1,:)));

axes('Position',[0.45 0.70 0.25 0.25]);
topoplot(datatoplot,EEG.chanlocs);

% for i=1:500
%     datatoplot(i,:)=10*log10(psd(i,:))-mean(10*log10(psd(i,:)));
% end

% [min(min(datatoplot)) max(max(datatoplot))]
title(strcat([num2str(freq) 'Hz']));
% cb = colorbar('Ticks',[min(min(datatoplot)) max(max(datatoplot))],'TickLabels',{'-','+'}); 
cb = colorbar;
% set(cb,'position',[.94 .66 .015 .08])
% set(cb,'YAxisLocation','left','Fontsize',20);
a=get(cb,'Limits');
delete(cb);
cb2 = colorbar('Ticks',a,'TickLabels',{'-','+'});
set(cb2,'position',[.94 .66 .015 .08])
set(cb2,'YAxisLocation','left','Fontsize',15);
% set(cb,'ylim',[min(min(datatoplot)) max(max(datatoplot))]);
% set(cb,'Limits',[min(min(datatoplot)) max(max(datatoplot))]);
annotation('line',[0.2+freq/VARS.SPECTRUM_RNG(2)*0.75 0.575],[0.1+(max(10*log10(psd(freq+1,:)))-yla(1))/(yla(2)-yla(1))*0.55 0.72],'Color','k','Linewidth',1.5);

end

function AxesCallback2(varargin)


afterstep=varargin{3};
laststep=varargin{4};

pre_pulse_deletion = 0;

global VARS lineposition

[~, EEG] = eegdatapro_load_step(afterstep + 1);          

C=get(gca,'CurrentPoint');
freq=round(C(1,1));

h = findall(gcf,'Type','axes');
delete(h);
delete(findall(gcf,'type','annotation'));

if afterstep == laststep || afterstep == 1
    pre_pulse_deletion = 1;
end

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


%Create topo plot with EEGLAB timtopo() command  
if(pre_pulse_deletion)
    data_temp = squeeze(nanmean(EEG.data,3));
    EEGtimes =  EEG.times;
else
    data_temp = squeeze(nanmean(EEG.data,3));
    EEGtimes =  min(EEG.times):1000/EEG.srate:max(EEG.times);

    if(isfield(EEG,{'TMS_period2remove_b'}))
        ix = min(EEG.TMS_period2remove_b);
        rm_pulse_fill = NaN(size(data_temp,1),length(EEG.TMS_period2remove_b));
        EEGtimes =  min(EEG.times):1000/EEG.srate:max(EEG.times);
        data_temp = cat(2,data_temp(:,1:ix-1),rm_pulse_fill,data_temp(:,ix:end));
    end

    if(isfield(EEG,{'TMS_period2remove_1'}))
        %Insert NaN values to fill space where TMS pulse was removed
        ix       = min(EEG.TMS_period2remove_1);
        rm_pulse_fill = NaN(size(data_temp,1),length(EEG.TMS_period2remove_1));
        EEGtimes =  min(EEG.times):1000/EEG.srate:max(EEG.times);
        data_temp = cat(2,data_temp(:,1:ix-1),rm_pulse_fill,data_temp(:,ix:end));
    end
    
    
end

% EEGtimes =  min(EEG.times):1000/EEG.srate:max(EEG.times);
data = data_temp(:,EEGtimes>=xshowmin & EEGtimes<=xshowmax);

% timtopo(data, EEG.chanlocs,'limits',[xshowmin xshowmax -yshowlimit yshowlimit]);
x = EEGtimes(EEGtimes>=xshowmin & EEGtimes<=xshowmax);
y = data;

[~,time]=find(round(x)==freq);

while isempty(time)
    freq=freq+1;
    [~,time]=find(round(x)==freq);
end

if time>length(x)
    time=length(x);
end

a2=axes('Position',[0.2 0.1 0.75 0.55]);
plot(a2,x,y);
xlim([xshowmin xshowmax]);
yla=get(a2,'ylim');
line([0 0],[yla(1) yla(2)],'Linestyle',':','Color',[0.5 0.5 0.5]);

line([freq freq],[min(y(:,time)) max(y(:,time))],'Linestyle','--','LineWidth',1.5,'Color','k'); 
lineposition=[freq freq min(y(:,time)) max(y(:,time))];
% l=line([freq freq],[ylim],'LineStyle','--','LineWidth',1.5); 

% c1=get(l,'Color');

set(gca,'ButtonDownFcn', {@AxesCallback2,afterstep,laststep});


xlabel('Latency (ms)','Fontsize', 15);
ylabel('Potential (\muV)','Fontsize',15);
if ~isnan(y(:,time))
    datatoplot=y(:,time);
    axes('Position',[0.45 0.70 0.25 0.25]);
topoplot(datatoplot,EEG.chanlocs);

% for i=1:500
%     datatoplot(i,:)=10*log10(psd(i,:))-mean(10*log10(psd(i,:)));
% end

% [min(min(datatoplot)) max(max(datatoplot))]
title(strcat([num2str(freq) 'ms']));
% cb = colorbar('Ticks',[min(min(datatoplot)) max(max(datatoplot))],'TickLabels',{'-','+'}); 
cb = colorbar;
% set(cb,'position',[.94 .66 .015 .08])
% set(cb,'YAxisLocation','left','Fontsize',20);
a=get(cb,'Limits');
delete(cb);
cb2 = colorbar('Ticks',a,'TickLabels',{'-','+'});
set(cb2,'position',[.94 .66 .015 .08])
set(cb2,'YAxisLocation','left','Fontsize',15);
% set(cb,'ylim',[min(min(datatoplot)) max(max(datatoplot))]);
% set(cb,'Limits',[min(min(datatoplot)) max(max(datatoplot))]);
annotation('line',[0.2+(freq-x(1))/(x(end)-x(1)+1)*0.75 0.575],[0.1+(max(y(:,time))-yla(1))/(yla(2)-yla(1))*0.55 0.72],'Color','k','Linewidth',1.5);
else
    datatoplot=zeros(1,EEG.nbchan);
    axes('Position',[0.45 0.70 0.25 0.25]);
topoplot(datatoplot,EEG.chanlocs);
colormap('gray');
title(strcat([num2str(freq) 'ms']));
cb = colorbar;
% set(cb,'position',[.94 .66 .015 .08])
% set(cb,'YAxisLocation','left','Fontsize',20);
a=get(cb,'Limits');
delete(cb);
cb2 = colorbar('Ticks',a,'TickLabels',{'-','+'});
set(cb2,'position',[.94 .66 .015 .08])
set(cb2,'YAxisLocation','left','Fontsize',15);
end

end

% function test(varargin)
% 
% global lineposition
% delete(findall(gcf,'type','annotation'));
% if ~isempty(lineposition)
%     xl=xlim;
%     yla=ylim;
%     if lineposition(1) >= xl(1) &&  lineposition(1) <= xl(2)
%         annotation('line',[0.2+(lineposition(1)-xl(1))/(xl(2)-xl(1))*0.75 0.575],[0.1+(lineposition(4)-yla(1))/(yla(2)-yla(1))*0.55 0.72],'Color','k','Linewidth',1.5);
%     end
% end
% 
% end

function view_data(varargin)

h = findall(gcf,'Type','axes');
delete(h);
delete(findall(gcf,'type','annotation'));

global VARS 

afterstep=varargin{3};
laststep=varargin{4};

pre_pulse_deletion = 0;
 
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

if afterstep == laststep
    pre_pulse_deletion = 1;
end


%Create topo plot with EEGLAB timtopo() command  
if(pre_pulse_deletion)
    data_temp = squeeze(nanmean(EEG.data,3));
    EEGtimes =  EEG.times;
else
    data_temp = squeeze(nanmean(EEG.data,3));
    EEGtimes =  min(EEG.times):1000/EEG.srate:max(EEG.times);

    if(isfield(EEG,{'TMS_period2remove_b'}))
        ix = min(EEG.TMS_period2remove_b);
        rm_pulse_fill = NaN(size(data_temp,1),length(EEG.TMS_period2remove_b));
        EEGtimes =  min(EEG.times):1000/EEG.srate:max(EEG.times);
        data_temp = cat(2,data_temp(:,1:ix-1),rm_pulse_fill,data_temp(:,ix:end));
    end

    if(isfield(EEG,{'TMS_period2remove_1'}))
        %Insert NaN values to fill space where TMS pulse was removed
        ix       = min(EEG.TMS_period2remove_1);
        rm_pulse_fill = NaN(size(data_temp,1),length(EEG.TMS_period2remove_1));
        EEGtimes =  min(EEG.times):1000/EEG.srate:max(EEG.times);
        data_temp = cat(2,data_temp(:,1:ix-1),rm_pulse_fill,data_temp(:,ix:end));
    end

end

% EEGtimes =  min(EEG.times):1000/EEG.srate:max(EEG.times);
data = data_temp(:,EEGtimes>=xshowmin & EEGtimes<=xshowmax);

% timtopo(data, EEG.chanlocs,'limits',[xshowmin xshowmax -yshowlimit yshowlimit]);
x = EEGtimes(EEGtimes>=xshowmin & EEGtimes<=xshowmax);
y = data;

a2=axes('Position',[0.2 0.1 0.75 0.55]);
plot(a2,x,y)
xlim([xshowmin xshowmax]);
yla=get(a2,'ylim');
line([0 0],[yla(1) yla(2)],'Linestyle',':','Color',[0.5 0.5 0.5]);
set(gca,'ButtonDownFcn', {@AxesCallback2,afterstep,laststep});
xlabel('Latency (ms)','Fontsize', 15);
ylabel('Potential (\muV)','Fontsize',15);
axes('Position',[0.45 0.70 0.25 0.25]);
topoplot(zeros(1,EEG.nbchan),EEG.chanlocs);
title('Click on the plot to obtain the scalp map at a certain latency');
colormap('gray');
cb = colorbar;
% set(cb,'position',[.94 .66 .015 .08])
% set(cb,'YAxisLocation','left','Fontsize',20);
a=get(cb,'Limits');
delete(cb);
cb2 = colorbar('Ticks',a,'TickLabels',{'-','+'});
set(cb2,'position',[.94 .66 .015 .08])
set(cb2,'YAxisLocation','left','Fontsize',15);     

end


