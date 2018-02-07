function [] = eegdatapro_reset_workflow(S, fromstep, tostep)
% eegdatapro_reset_workflow() - resets the workflow by deleting future
% sequential steps starting from a specified step.  Updates the parent GUI
% to reflect the deleted files.

global basefile basepath 
checkext = '';
ext = '.set';

for i = 1:tostep
    
    checkext = strcat(checkext,['_' num2str(i)]); 
    filetodelete = [basepath '/' basefile checkext ext];
   
    if exist(filetodelete,'file') && (i >= fromstep)
        delete(filetodelete);
        delete([basepath '/*' basefile checkext '_toDelete.mat']);
       
        for j = 1:tostep
            delete([basepath '/*' basefile checkext '_ICA' num2str(j) 'comp.mat']);
        end
        
    end
    
tmseeg_upd_stp_disp(S, ext, tostep)

end

if fromstep==1
    S.step_init=0;
end

if exist([basepath '/' basefile '_eegdatapro_settings.mat'],'file')
    delete([basepath '/*' basefile '_eegdatapro_settings.mat'])
end

end

