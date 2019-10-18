% eegdatapro_init() - function to read in a set of tmseeg variables as a
% structure
%
% Author: Matthew Frehlich, 2016 
%         Ben Schwartzmann, 2017

% Copyright (C) 2016 Matthew Frehlich, UToronto,
% matthew.frehlich@mail.utoronto.ca
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

function[INIT_VARS] = eegdatapro_init(S)

INIT_VARS = struct;

R = S.routine;          
nb_function=size(R.option_name,1);

[~, EEG] = eegdatapro_load_step(1);

for i=1:nb_function

    num=R.option_num(i);  
    switch R.option_name{i}
        
        case 'INITIAL PROCESSING'
            %Step  - Initial Processing
            INIT_VARS.RESAMPLE_FREQ = 1000;
            INIT_VARS.CHANLOC_FILE  = 'standard-10-5-cap385.elp';
            INIT_VARS.BASELINE_RNG  = [-650 -250];

        case 'REMOVE TMS ARTIFACT'
            %Step - TMS Pulse Removal
            INIT_VARS.ISI = 100;
            INIT_VARS.TMS_DSP_XMIN   = -150;
            INIT_VARS.TMS_DSP_XMAX   = 50;
            INIT_VARS.SLIDER_MIN     = -5;
            INIT_VARS.SLIDER_MAX     = 10;
            INIT_VARS.PULSE_DURATION = 0;

        case 'FILTERING'
            INIT_VARS.(sprintf('FIR_FILTER_ORDER_%d',num)) = 80;
            INIT_VARS.(sprintf('IIR_FILTER_ORDER_%d',num)) = 2;

        case 'REMOVE BAD TRLs AND CHNs'
            %Step  - Remove Trials and Channels
            INIT_VARS.(sprintf('NUM_BAD_CHANS_%d',num))  = 5;
            INIT_VARS.(sprintf('NUM_BAD_TRIALS_%d',num))  = 10;
            INIT_VARS.(sprintf('PCT_BAD_CHANS_%d',num))  = 10;
            INIT_VARS.(sprintf('PCT_BAD_TRIALS_%d',num))  = 1;
            INIT_VARS.(sprintf('HEAD_PLOT_%d',num))  = 1;
            INIT_VARS.(sprintf('PLT_CHN_YMIN_%d',num))  = -400;
            INIT_VARS.(sprintf('PLT_CHN_YMAX_%d',num))  = 400;
            %Step - ATTRIBUTE extraction
            INIT_VARS.(sprintf('PULSE_ST_%d',num))  = 0;
            INIT_VARS.(sprintf('PULSE_END_%d',num))  = 50;
            if ~isempty(EEG.epoch)
                INIT_VARS.(sprintf('TIME_ST_%d',num))  = EEG.times(1);
                INIT_VARS.(sprintf('TIME_END_%d',num))  = EEG.times(end);
            else
                INIT_VARS.(sprintf('TIME_ST_%d',num))  = 0;
                INIT_VARS.(sprintf('TIME_END_%d',num))  = 1000;
            end
            INIT_VARS.(sprintf('FREQ_MIN_%d',num))  = 1;
            INIT_VARS.(sprintf('FREQ_MAX_%d',num))  = 80;

        case 'RUN ICA'
            %Step - ICA
            INIT_VARS.(sprintf('ICA_COMP_PCT_%d',num))    = 100;
            INIT_VARS.(sprintf('ICA_COMP_CHANS_%d',num))    = 0;

        case 'REMOVE ICA COMPONENTS'
            INIT_VARS.(sprintf('UPD_WDW_STRT_%d',num))=-100;
            INIT_VARS.(sprintf('UPD_WDW_END_%d',num))=500;
            INIT_VARS.(sprintf('UPD_WDW_YMIN_%d',num))=-50;
            INIT_VARS.(sprintf('UPD_WDW_YMAX_%d',num))=50;
            INIT_VARS.(sprintf('UPD_KURTOSIS_THRESH_%d',num))=15;

    end
    
    %Vew Data
    INIT_VARS.YSHOWLIMIT = 100;
    INIT_VARS.XSHOWMIN = EEG.xmin*1000;
    INIT_VARS.XSHOWMAX = EEG.xmax*1000;
    INIT_VARS.SPECTRUM_RNG = [0 EEG.srate/2];

    if ~isempty(EEG.epoch)
        INIT_VARS.EPCH_STRT = EEG.times(1);
        INIT_VARS.EPCH_END = EEG.times(end);
    else
        INIT_VARS.EPCH_STRT = -1000;
        INIT_VARS.EPCH_END = 1000;
    end
    
end

end



