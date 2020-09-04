% written by hao1ei (ver_20.03.31)
% hao1ei@foxmail.com
% qinlab.BNU
restoredefaultpath
clear

%% Basic information set up
roi_form  = 'nii';                 % The format of region of interest (ROI), 'nii' or 'mat'
img_type  = 'con';                 % What imaging type used for calculation, 'con' or 'spmT'
task_name = 'ANT';                 % Task name
con_name  = {'c1A'; 'c2O'; 'c3E'}; % Name of each condition
con_num   = {'1'; '2'; '3'};       % The number of contrast for each condition

spm_dir   = '\dir\spm12';    % Path of spm12, need to install rex and marsbar toolbox under '/spm12/toolbox'
roi_dir   = '\dir\ROIs';     % Path of ROIs, all ROIs under this path will be calculated
firlv_dir = '\dir\FirstLv';  % Path of the first level analysis results
subj_list = '\dir\list.txt'; % Path of the participants list

%% Add directory of spm to search path
addpath(genpath(spm_dir));

%% Read participants list
fid  = fopen(subj_list); subj = {}; cnt  = 1;
while ~feof(fid)
    linedata = textscan(fgetl(fid), '%s', 'Delimiter', '\t');
    subj(cnt,:) = linedata{1}; cnt = cnt+1; %#ok<*SAGROW>
end
fclose(fid);

%% Acquire ROIs list
roi_list = dir(fullfile(roi_dir, ['*.', roi_form]));
roi_list = struct2cell(roi_list);
roi_list = roi_list(1, :)';

%% Extract mean value
% Extract mean value for each condition
for con_i = 1:length(con_name)
    mean = {'Scan_ID','Conds'};
    % Extract mean value for each ROI
    for roi_i = 1:length(roi_list)
        mean{1,roi_i+2} = roi_list{roi_i,1}(1:end-4);   % Write index of column for each ROI to results file
        roifile = fullfile(roi_dir, roi_list{roi_i,1}); % Path of each ROI
        
        % Extract mean value for each participant
        for sub_i = 1:length(subj)
            % Path imaging file of each condition for each participant
            YearID = ['20', subj{sub_i,1}(1:2)];
            subjfile = fullfile (firlv_dir, YearID, subj{sub_i,1}, ...
                'fMRI', 'Stats_spm12', task_name, 'Stats_spm12_swcra', ...
                [img_type,'_000',con_num{con_i,1},'.nii']);
            
            mean{sub_i+1,1} = subj{sub_i,1};   % Write index of row for each participant to results file
            mean{sub_i+1,2} = con_name{con_i}; % Write index of row for each condition to results file
            
            if strcmp(roi_form, 'nii')                          % If the format of ROI is nii, use rex toobox
                mean{sub_i+1,roi_i+2} = rex(subjfile,roifile);  % Write mean value to results file
            end
            if strcmp(roi_form, 'mat')                          % If the format of ROI is mat, use marsbar toobox
                roi_obj = maroi(roifile);
                roi_data = get_marsy(roi_obj, subjfile, 'mean');
                mean{sub_i+1,roi_i+2} = summary_data(roi_data); % Write mean value to results file
            end
        end
    end
    
    % Name of the result file
    save_name = ['res_extrmean_', con_name{con_i}, '_', img_type,'.csv'];
    % Save the result file to disk
    fid = fopen(save_name, 'w');
    [nrows,ncols] = size(mean);
    col_num = '%s';
    for col_i = 1:(ncols-1); col_num = [col_num,',','%s']; end %#ok<*AGROW>
    col_num = [col_num, '\n'];
    for row_i = 1:nrows; fprintf(fid, col_num, mean{row_i,:}); end;
    fclose(fid);
end

%% Done
disp('=== Done ===');
