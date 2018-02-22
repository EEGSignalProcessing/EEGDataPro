% Author: Matthew Frehlich, Ye Mei, Luis Garcia Dominguez, Faranak Farzan
%         2016
%         Ben Schwartzmann
%         2017

% eegdatapro_ica_remove() - loads dataset from ICA2 step, checks for previously
% labelled components, and calls the tmseeg_multiple_topos() function for ICA2
% component analysis
% 
% Inputs:  S        - parent GUI structure
%          step_num - step number of tmseeg_ica2_remove in workflow
%          option_num - option number of eegdatapro_ica_remove step


% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.

function [] = eegdatapro_ica_remove(S, step_num, option_num)

%Check if previous steps were done
if tmseeg_previous_step(step_num) 
    return 
end

global basepath
global comptype
global chans_rm

%Load Data
[files, EEG] = eegdatapro_load_step(step_num);
[~,name,~] = fileparts(files.name);

%Check for existing ICA removal data
if exist(fullfile(basepath,[name '_' num2str(step_num) sprintf('_ICA%dcomp.mat',option_num)]),'file')
    load(fullfile(basepath,[name '_' num2str(step_num) sprintf('_ICA%dcomp.mat',option_num)])); 
    comptype = eval(sprintf('ICA%dcomp',option_num));
    EEG.comptype = comptype;
else
    comptype = zeros(1,size(EEG.icawinv,2));
end

%Check for existing ICA channels removed
if exist(fullfile(basepath,[name sprintf('_ICA%dchansUnsel.mat',option_num)]),'file')
    load(fullfile(basepath,[name sprintf('_ICA%dchansUnsel.mat',option_num)])); 
else
    chans_rm = [];
end

eegdatapro_multiples_topos(EEG,name, S, step_num, option_num);

end
