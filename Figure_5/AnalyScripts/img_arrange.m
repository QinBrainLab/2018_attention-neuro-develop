% written by hao1ei (ver_20.03.31)
% hao1ei@foxmail.com
% qinlab.BNU
clear
clc

%% Set up
connum   = [1 2 3]; % Which contrast imaging files need to be arrange
taskname = 'ANT';   % The task name

subj_list      = '\dir\list.txt';    % Path of the participants list
script_dir     = '\dir\Figure_5';    % Path of the present script
firstlv_dir    = '\dir\FirstLv';     % Path of the first level analysis results
firstlv_arrdir = '\dir\FirstLvData'; % Path of the data after arrangement

%% Read participants list
fid = fopen(subj_list); sublist = {}; cnt = 1;
while ~feof (fid)
    linedata = textscan(fgetl(fid), '%s', 'Delimiter', '\t');
    sublist(cnt,:) = linedata{1}; cnt = cnt + 1; %#ok<*SAGROW>
end
fclose(fid);

%% Start arrangement
for icon = connum
    % Create and change to the arrangement path
    arrdir = fullfile(firstlv_arrdir,['Con',num2str(icon),num2str(icon)]);
    mkdir(arrdir); cd(arrdir)
    
    for isub = 1:length(sublist) % Number of participants
        % Locate to the target imaging file
        yearID = ['20',sublist{isub,1}(1:2)];
        subfile = fullfile(firstlv_dir,yearID,sublist{isub,1}, ...
            'fMRI','Stats_spm12',taskname ,'Stats_spm12_swcra', ...
            ['con_000',num2str(icon),'.nii']);
        % Copy file and rename
        copyfile(subfile,fullfile(arrdir,[sublist{isub,1},'.nii']));
    end
end

%% Done
cd(script_dir)
clear all %#ok<*CLALL>
disp('All Done');