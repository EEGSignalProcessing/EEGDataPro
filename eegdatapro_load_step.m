function [files, EEG] = eegdatapro_load_step(step_num)
% eegdatapro_load_step() loads previous step dataset given basepath and the step
% number

global basepath basefile
checkext = '';

if step_num==1
    files   = dir(fullfile(basepath,[basefile '.set']));
    EEG     = pop_loadset('filename',[basefile '.set'],'filepath',basepath);
else
    
    for i = 1:step_num - 1
        checkext = strcat(checkext,['_' num2str(i)]);
    end

    files   = dir(fullfile(basepath,[ basefile '*' checkext '.set']));
    EEG     = pop_loadset('filename',files.name,'filepath',basepath);
end

end
