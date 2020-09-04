%% This script takes imaging data saved in .nii files and formats as a CANLAB data object
sample    = 'Cohort1';         % Which sample the data belongs to
set_name  = 'FullDataSet.mat'; % Name of the result file
subj_list = '\dir\list.txt';   % Path of the participants list
data_dir  = '\dir\GenRep';     % Path of the data after arrangement

%% Read participants list
fid = fopen(subj_list); sublist = {}; cnt = 1;
while ~feof (fid)
    linedata = textscan(fgetl(fid), '%s', 'Delimiter', '\t');
    sublist(cnt,:) = linedata{1}; cnt = cnt + 1; %#ok<*SAGROW>
end
fclose(fid);

%% Read data
image_counter=0; % Initialize counter for storing data
for study = 1:3  % Indices of studies
    
    for subject =1:length(sublist) % Indices of subjects
        
        tv=fmri_data([data_dir filesep 'FirstLvData' filesep sample filesep ['Con' num2str(study) ...
            num2str(study)] filesep sublist{subject,1} '.nii']); % Read data from disk
        tv=replace_empty(tv);                                    % Replace voxels with 0 values (for concatenating)
        image_counter=image_counter+1;                           % Update counter for indexing
        
        if image_counter==1                           % If this is the first image in data object
            FullDataSet=tv;                           % Initialize as temporary object
            FullDataSet.Y(image_counter,1)=study;     % First study so Y = 1
        else
            FullDataSet.dat=[FullDataSet.dat tv.dat]; % Concatenate data
            FullDataSet.Y(image_counter,1)=study;     % Add study index to Y
        end
    end
end

% Remove voxels that are always 0
FullDataSet=remove_empty(FullDataSet);
% Save to disk as data object in .mat file
save([data_dir filesep 'FirstLvData' filesep sample filesep set_name],'FullDataSet');
