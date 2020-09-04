% written by hao1ei (ver_20.03.31)
% hao1ei@foxmail.com
% qinlab.BNU
clear
clc

%% Basic information set up
group  = 'CBDA';  % Group of the data
subgrp = 'CBDPA'; % Subgroup of the data
task   = 'ANT1';  % Which run of this task
condSD = 3;       % Exclude data outside N standard deviations in each condition

edata_file  = '.\behav_sample_data.txt';      % Path of the edata file
subj_file   = '.\behav_sample_data_list.txt'; % Path of the participants list
res_savedir = '.\';                           % The results will be saved in this path

%% Read E-Prime data index that used to calculate results
index = {
    'Subject';
    'PracSlideTarget.OnsetTime';
    'PracSlideFixationStart.OnsetTime';
    'PracSlideTarget.ACC';
    'PracSlideTarget.RT';
    'FlankerType';
    'WarningType';
    'PracSlideTarget.OnsetToOnsetTime';
    'PracSlideTarget.RESP'};

%% Read participants list
fid = fopen(subj_file); sublist = {}; cnt_sub = 1;
while ~feof(fid)
    linedata = textscan(fgetl(fid), '%s', 'Delimiter', '\t');
    sublist(cnt_sub,:) = linedata{1}; cnt_sub = cnt_sub+1; %#ok<*SAGROW>
end
fclose(fid);

%% Import all index of the E-prime data
fid = fopen(edata_file); edata_all = {}; cnt_data = 1;
while ~feof(fid)
    linedata = textscan(fgetl(fid), '%s', 'Delimiter', '\t');
    edata_all(cnt_data,:) = linedata{1}; cnt_data = cnt_data+1;
end
fclose(fid);

%% Filter out useless index of the E-prime data
all_index = edata_all(1,:);
for icol = 1:length(index)
    for irow = 2:length(edata_all)
        edata(irow-1,icol) = edata_all(irow,strcmp(all_index,index{icol,1}));
    end
end

%% This script will calculate the following results
allres={
    'Subj_ID','Scan_ID','Group','SubGrp',...                                              % ID of behavior data, ID of imaging data, Group, Subgroup
    'A_NoDoub_mean_abs','O_CenSpat_mean_abs','C_InconCon_mean_abs', ...                   % Delta score of alerting, orienting and executive that calculated by mean
    'A_NoDoub_mean_rate','O_CenSpat_mean_rate','C_InconCon_mean_rate',...                 % Ratio score of alerting, orienting and executive that calculated by mean
    'RT_Con_No_mean','RT_Con_Cent_mean','RT_Con_Doub_mean','RT_Con_Spat_mean',...         % RTs of congruent conditions with different cue that calculated by mean
    'RT_Incon_No_mean','RT_Incon_Cent_mean','RT_Incon_Doub_mean','RT_Incon_Spat_mean',... % RTs of incongruent conditions with different cue that calculated by mean
    'ACC_Con_No','ACC_Con_Cent','ACC_Con_Doub','ACC_Con_Spat',...                         % Accuracy of congruent conditions with different cue
    'ACC_Incon_No','ACC_Incon_Cent','ACC_Incon_Doub','ACC_Incon_Spat', ...                % Accuracy of incongruent conditions with different cue
    'ACC_mean', 'NoRespFreq', 'CleanFreq', ...                                            % Mean accuracy, Frequency of not responded, Frequency of excluded trials
    'RT_NoCue_mean', 'RT_CentCue_mean', 'RT_DoubCue_mean', 'RT_SpatCue_mean', ...         % RTs of each cue conditions
    'RT_Cong_mean', 'RT_Incong_mean'};                                                    % RTs of each target conditions

[nsub,~] = size(sublist); % Get the number of participants
for isub = 1:nsub
    %% Acquire this participant's data
    [sub_trial,~] = find(str2double(edata(:,strcmp(index,'Subject')))==str2double(sublist{isub,1}));
    sub_edata     = edata(sub_trial,:);
    
    %% Calculate total trials number of each condition
    % Initialization
    Sum_NoCue   = 0; Sum_DoubCue = 0; Sum_CentCue = 0;
    Sum_SpatCue = 0; Sum_Cong    = 0; Sum_Incong  = 0;
    
    for itrl = 1:length(sub_trial) % Number of trials
        % Calculate the tirals number of no cue condition
        if strcmp(sub_edata(itrl,strcmp(index,'WarningType')),'no')
            Sum_NoCue = Sum_NoCue + 1;
        end
        % Calculate the tirals number of double cue condition
        if strcmp(sub_edata(itrl,strcmp(index,'WarningType')),'double')
            Sum_DoubCue = Sum_DoubCue + 1;
        end
        % Calculate the tirals number of center cue condition
        if strcmp(sub_edata(itrl,strcmp(index,'WarningType')),'center')
            Sum_CentCue = Sum_CentCue + 1;
        end
        % Calculate the tirals number of spatial cue condition
        if strcmp(sub_edata(itrl,strcmp(index,'WarningType')),'up') || ...
                strcmp(sub_edata(itrl,strcmp(index,'WarningType')),'down')
            Sum_SpatCue = Sum_SpatCue + 1;
        end
        % Calculate the tirals number of congruent target condition
        if strcmp(sub_edata(itrl,strcmp(index,'FlankerType')),'congruent')
            Sum_Cong = Sum_Cong + 1;
        end
        % Calculate the tirals number of incongruent target condition
        if strcmp(sub_edata(itrl,strcmp(index,'FlankerType')),'incongruent')
            Sum_Incong = Sum_Incong + 1;
        end
    end
    
    % Initialization
    Sum_Con_NoCue     = 0; Sum_Con_DoubCue   = 0; Sum_Con_CentCue   = 0;
    Sum_Con_SpatCue   = 0; Sum_Incon_NoCue   = 0; Sum_Incon_DoubCue = 0;
    Sum_Incon_CentCue = 0; Sum_Incon_SpatCue = 0; Sum_NoRespond     = 0;
    
    for itrl = 1:length(sub_trial) % Number of trials
        % Calculate the trials number of not responded
        if str2double(sub_edata{itrl, 8}) >= 999 && isempty(sub_edata{itrl, 9})
            Sum_NoRespond = Sum_NoRespond + 1;
        end
        % Calculate the trials number of congruent target and no cue condition
        if strcmp(sub_edata(itrl,strcmp(index,'FlankerType')),'congruent') && strcmp(sub_edata(itrl,strcmp(index,'WarningType')),'no')
            Sum_Con_NoCue = Sum_Con_NoCue + 1;
        end
        % Calculate the trials number of congruent target and double cue condition
        if strcmp(sub_edata(itrl,strcmp(index,'FlankerType')),'congruent') && strcmp(sub_edata(itrl,strcmp(index,'WarningType')),'double')
            Sum_Con_DoubCue = Sum_Con_DoubCue + 1;
        end
        % Calculate the trials number of congruent target and center cue condition
        if strcmp(sub_edata(itrl,strcmp(index,'FlankerType')),'congruent') && strcmp(sub_edata(itrl,strcmp(index,'WarningType')),'center')
            Sum_Con_CentCue = Sum_Con_CentCue + 1;
        end
        % Calculate the trials number of congruent target and spatial cue condition
        if (strcmp(sub_edata(itrl,strcmp(index,'FlankerType')),'congruent') && strcmp(sub_edata(itrl,strcmp(index,'WarningType')),'up') || ...
                strcmp(sub_edata(itrl,strcmp(index,'FlankerType')),'congruent') && strcmp(sub_edata(itrl,strcmp(index,'WarningType')),'down'))
            Sum_Con_SpatCue = Sum_Con_SpatCue + 1;
        end
        % Calculate the trials number of incongruent target and no cue condition
        if strcmp(sub_edata(itrl,strcmp(index,'FlankerType')),'incongruent') && strcmp(sub_edata(itrl,strcmp(index,'WarningType')),'no')
            Sum_Incon_NoCue = Sum_Incon_NoCue + 1;
        end
        % Calculate the trials number of incongruent target and double cue condition
        if strcmp(sub_edata(itrl,strcmp(index,'FlankerType')),'incongruent') && strcmp(sub_edata(itrl,strcmp(index,'WarningType')),'double')
            Sum_Incon_DoubCue = Sum_Incon_DoubCue + 1;
        end
        % Calculate the trials number of incongruent target and center cue condition
        if strcmp(sub_edata(itrl,strcmp(index,'FlankerType')),'incongruent') && strcmp(sub_edata(itrl,strcmp(index,'WarningType')),'center')
            Sum_Incon_CentCue = Sum_Incon_CentCue + 1;
        end
        % Calculate the trials number of incongruent target and spatial cue condition
        if (strcmp(sub_edata(itrl,strcmp(index,'FlankerType')),'incongruent') && strcmp(sub_edata(itrl,strcmp(index,'WarningType')),'up') || ...
                strcmp(sub_edata(itrl,strcmp(index,'FlankerType')),'incongruent') && strcmp(sub_edata(itrl,strcmp(index,'WarningType')),'down'))
            Sum_Incon_SpatCue = Sum_Incon_SpatCue + 1;
        end
    end
    
    %% Acquire RTs and accuracy data of effective trials of each condition
    % Initialization
    RT_NoCueMat   = []; RT_DoubCueMat = []; RT_CentCueMat = [];
    RT_SpatCueMat = []; RT_CongMat    = []; RT_IncongMat  = [];
    
    % Initialization
    ACC_NoCueMat   = []; ACC_DoubCueMat = []; ACC_CentCueMat = [];
    ACC_SpatCueMat = []; ACC_CongMat    = []; ACC_IncongMat  = [];
    
    % Initialization
    RT_Con_NoCue_Mat     = []; RT_Con_DoubCue_Mat   = [];
    RT_Con_CentCue_Mat   = []; RT_Con_SpatCue_Mat   = [];
    RT_Incon_NoCue_Mat   = []; RT_Incon_DoubCue_Mat = [];
    RT_Incon_CentCue_Mat = []; RT_Incon_SpatCue_Mat = [];
    
    % Initialization
    ACC_Con_NoCue_Mat     = []; ACC_Con_DoubCue_Mat   = [];
    ACC_Con_CentCue_Mat   = []; ACC_Con_SpatCue_Mat   = [];
    ACC_Incon_NoCue_Mat   = []; ACC_Incon_DoubCue_Mat = [];
    ACC_Incon_CentCue_Mat = []; ACC_Incon_SpatCue_Mat = [];
    
    for itrl = 1:length(sub_trial) % Number of trials
        % If this trial is correct and warning type is no cue
        if (str2double(edata(sub_trial(itrl,1),strcmp(index,'PracSlideTarget.ACC')))==1 && strcmp(edata(sub_trial(itrl,1),strcmp(index,'WarningType')),'no'))
            temp_val_RT  = edata(sub_trial(itrl,1),strcmp(index,'PracSlideTarget.RT'));  % Acquire the RT for this trial
            temp_val_ACC = edata(sub_trial(itrl,1),strcmp(index,'PracSlideTarget.ACC')); % Acquire the accuracy for this trial
            RT_NoCueMat  = [RT_NoCueMat;str2double(temp_val_RT{1,1})]; %#ok<*AGROW>      % Attach the RT of this trial to the set
            ACC_NoCueMat = [ACC_NoCueMat;str2double(temp_val_ACC{1,1})];                 % Attach the accuracy of this trial to the set
        end
        % If this trial is correct and warning type is double cue
        if (str2double(edata(sub_trial(itrl,1),strcmp(index,'PracSlideTarget.ACC')))==1 && strcmp(edata(sub_trial(itrl,1),strcmp(index,'WarningType')),'double'))
            temp_val_RT    = edata(sub_trial(itrl,1),strcmp(index,'PracSlideTarget.RT'));  % Acquire the RT for this trial
            temp_val_ACC   = edata(sub_trial(itrl,1),strcmp(index,'PracSlideTarget.ACC')); % Acquire the accuracy for this trial
            RT_DoubCueMat  = [RT_DoubCueMat;str2double(temp_val_RT{1,1})]; %#ok<*AGROW>    % Attach the RT of this trial to the set
            ACC_DoubCueMat = [ACC_DoubCueMat;str2double(temp_val_ACC{1,1})];               % Attach the accuracy of this trial to the set
        end
        % If this trial is correct and warning type is center cue
        if (str2double(edata(sub_trial(itrl,1),strcmp(index,'PracSlideTarget.ACC')))==1 && strcmp(edata(sub_trial(itrl,1),strcmp(index,'WarningType')),'center'))
            temp_val_RT    = edata(sub_trial(itrl,1),strcmp(index,'PracSlideTarget.RT'));  % Acquire the RT for this trial
            temp_val_ACC   = edata(sub_trial(itrl,1),strcmp(index,'PracSlideTarget.ACC')); % Acquire the accuracy for this trial
            RT_CentCueMat  = [RT_CentCueMat;str2double(temp_val_RT{1,1})]; %#ok<*AGROW>    % Attach the RT of this trial to the set
            ACC_CentCueMat = [ACC_CentCueMat;str2double(temp_val_ACC{1,1})];               % Attach the accuracy of this trial to the set
        end
        % If this trial is correct and warning type is spatial cue
        if (str2double(edata(sub_trial(itrl,1),strcmp(index,'PracSlideTarget.ACC')))==1 && (strcmp(edata(sub_trial(itrl,1),strcmp(index,'WarningType')),'up') || ...
                strcmp(edata(sub_trial(itrl,1),strcmp(index,'WarningType')),'down')))
            temp_val_RT    = edata(sub_trial(itrl,1),strcmp(index,'PracSlideTarget.RT'));  % Acquire the RT for this trial
            temp_val_ACC   = edata(sub_trial(itrl,1),strcmp(index,'PracSlideTarget.ACC')); % Acquire the accuracy for this trial
            RT_SpatCueMat  = [RT_SpatCueMat;str2double(temp_val_RT{1,1})]; %#ok<*AGROW>    % Attach the RT of this trial to the set
            ACC_SpatCueMat = [ACC_SpatCueMat;str2double(temp_val_ACC{1,1})];               % Attach the accuracy of this trial to the set
        end
        
        % If this trial is correct and flanker type is congruent target
        if (str2double(edata(sub_trial(itrl,1),strcmp(index,'PracSlideTarget.ACC')))==1 && strcmp(edata(sub_trial(itrl,1),strcmp(index,'FlankerType')),'congruent'))
            temp_val_RT  = edata(sub_trial(itrl,1),strcmp(index,'PracSlideTarget.RT'));  % Acquire the RT for this trial
            temp_val_ACC = edata(sub_trial(itrl,1),strcmp(index,'PracSlideTarget.ACC')); % Acquire the accuracy for this trial
            RT_CongMat   = [RT_CongMat;str2double(temp_val_RT{1,1})]; %#ok<*AGROW>       % Attach the RT of this trial to the set
            ACC_CongMat  = [ACC_CongMat;str2double(temp_val_ACC{1,1})];                  % Attach the accuracy of this trial to the set
        end
        % If this trial is correct and flanker type is incongruent target
        if (str2double(edata(sub_trial(itrl,1),strcmp(index,'PracSlideTarget.ACC')))==1 && strcmp(edata(sub_trial(itrl,1),strcmp(index,'FlankerType')),'incongruent'))
            temp_val_RT   = edata(sub_trial(itrl,1),strcmp(index,'PracSlideTarget.RT'));  % Acquire the RT for this trial
            temp_val_ACC  = edata(sub_trial(itrl,1),strcmp(index,'PracSlideTarget.ACC')); % Acquire the accuracy for this trial
            RT_IncongMat  = [RT_IncongMat;str2double(temp_val_RT{1,1})]; %#ok<*AGROW>     % Attach the RT of this trial to the set
            ACC_IncongMat = [ACC_IncongMat;str2double(temp_val_ACC{1,1})];                % Attach the accuracy of this trial to the set
        end
        
        % If this trial is correct, flanker type is congruent target and warning type is no cue
        if (str2double(edata(sub_trial(itrl,1),strcmp(index,'PracSlideTarget.ACC')))==1 && strcmp(edata(sub_trial(itrl,1),strcmp(index,'FlankerType')),'congruent') && ...
                strcmp(edata(sub_trial(itrl,1),strcmp(index,'WarningType')),'no'))
            temp_val = edata(sub_trial(itrl,1),strcmp(index,'PracSlideTarget.RT')); % Acquire the RT for this trial
            RT_Con_NoCue_Mat = [RT_Con_NoCue_Mat;str2double(temp_val{1,1})];        % Attach the RT of this trial to the set
        end
        % If this trial is correct, flanker type is congruent target and warning type is double cue
        if (str2double(edata(sub_trial(itrl,1),strcmp(index,'PracSlideTarget.ACC')))==1 && strcmp(edata(sub_trial(itrl,1),strcmp(index,'FlankerType')),'congruent') && ...
                strcmp(edata(sub_trial(itrl,1),strcmp(index,'WarningType')),'double'))
            temp_val = edata(sub_trial(itrl,1),strcmp(index,'PracSlideTarget.RT')); % Acquire the RT for this trial
            RT_Con_DoubCue_Mat = [RT_Con_DoubCue_Mat;str2double(temp_val{1,1})];    % Attach the RT of this trial to the set
        end
        % If this trial is correct, flanker type is congruent target and warning type is center cue
        if (str2double(edata(sub_trial(itrl,1),strcmp(index,'PracSlideTarget.ACC')))==1 && strcmp(edata(sub_trial(itrl,1),strcmp(index,'FlankerType')),'congruent') && ...
                strcmp(edata(sub_trial(itrl,1),strcmp(index,'WarningType')),'center'))
            temp_val = edata(sub_trial(itrl,1),strcmp(index,'PracSlideTarget.RT')); % Acquire the RT for this trial
            RT_Con_CentCue_Mat = [RT_Con_CentCue_Mat;str2double(temp_val{1,1})];    % Attach the RT of this trial to the set
        end
        % If this trial is correct, flanker type is congruent target and warning type is spatial cue
        if (str2double(edata(sub_trial(itrl,1),strcmp(index,'PracSlideTarget.ACC')))==1 && strcmp(edata(sub_trial(itrl,1),strcmp(index,'FlankerType')),'congruent') && ...
                (strcmp(edata(sub_trial(itrl,1),strcmp(index,'WarningType')),'up') || strcmp(edata(sub_trial(itrl,1),strcmp(index,'WarningType')),'down')))
            temp_val = edata(sub_trial(itrl,1),strcmp(index,'PracSlideTarget.RT')); % Acquire the RT for this trial
            RT_Con_SpatCue_Mat = [RT_Con_SpatCue_Mat;str2double(temp_val{1,1})];    % Attach the RT of this trial to the set
        end
        % If this trial is correct, flanker type is incongruent target and warning type is no cue
        if (str2double(edata(sub_trial(itrl,1),strcmp(index,'PracSlideTarget.ACC')))==1 && strcmp(edata(sub_trial(itrl,1),strcmp(index,'FlankerType')),'incongruent') && ...
                strcmp(edata(sub_trial(itrl,1),strcmp(index,'WarningType')),'no'))
            temp_val = edata(sub_trial(itrl,1),strcmp(index,'PracSlideTarget.RT')); % Acquire the RT for this trial
            RT_Incon_NoCue_Mat = [RT_Incon_NoCue_Mat;str2double(temp_val{1,1})];    % Attach the RT of this trial to the set
        end
        % If this trial is correct, flanker type is incongruent target and warning type is double cue
        if (str2double(edata(sub_trial(itrl,1),strcmp(index,'PracSlideTarget.ACC')))==1 && strcmp(edata(sub_trial(itrl,1),strcmp(index,'FlankerType')),'incongruent') && ...
                strcmp(edata(sub_trial(itrl,1),strcmp(index,'WarningType')),'double'))
            temp_val = edata(sub_trial(itrl,1),strcmp(index,'PracSlideTarget.RT'));  % Acquire the RT for this trial
            RT_Incon_DoubCue_Mat = [RT_Incon_DoubCue_Mat;str2double(temp_val{1,1})]; % Attach the RT of this trial to the set
        end
        % If this trial is correct, flanker type is incongruent target and warning type is center cue
        if (str2double(edata(sub_trial(itrl,1),strcmp(index,'PracSlideTarget.ACC')))==1 && strcmp(edata(sub_trial(itrl,1),strcmp(index,'FlankerType')),'incongruent') && ...
                strcmp(edata(sub_trial(itrl,1),strcmp(index,'WarningType')),'center'))
            temp_val = edata(sub_trial(itrl,1),strcmp(index,'PracSlideTarget.RT'));  % Acquire the RT for this trial
            RT_Incon_CentCue_Mat = [RT_Incon_CentCue_Mat;str2double(temp_val{1,1})]; % Attach the RT of this trial to the set
        end
        % If this trial is correct, flanker type is incongruent target and warning type is spatial cue
        if (str2double(edata(sub_trial(itrl,1),strcmp(index,'PracSlideTarget.ACC')))==1 && strcmp(edata(sub_trial(itrl,1),strcmp(index,'FlankerType')),'incongruent') && ...
                (strcmp(edata(sub_trial(itrl,1),strcmp(index,'WarningType')),'up') || strcmp(edata(sub_trial(itrl,1),strcmp(index,'WarningType')),'down')))
            temp_val = edata(sub_trial(itrl,1),strcmp(index,'PracSlideTarget.RT'));  % Acquire the RT for this trial
            RT_Incon_SpatCue_Mat = [RT_Incon_SpatCue_Mat;str2double(temp_val{1,1})]; % Attach the RT of this trial to the set
        end
        
        % If this trial is correct, flanker type is congruent target and warning type is no cue
        if (str2double(edata(sub_trial(itrl,1),strcmp(index,'PracSlideTarget.ACC')))==1 && strcmp(edata(sub_trial(itrl,1),strcmp(index,'FlankerType')),'congruent') && ...
                strcmp(edata(sub_trial(itrl,1),strcmp(index,'WarningType')),'no'))
            temp_val = edata(sub_trial(itrl,1),strcmp(index,'PracSlideTarget.ACC')); % Acquire the accuracy for this trial
            ACC_Con_NoCue_Mat = [ACC_Con_NoCue_Mat;str2double(temp_val{1,1})];       % Attach the accuracy of this trial to the set
        end
        % If this trial is correct, flanker type is congruent target and warning type is double cue
        if (str2double(edata(sub_trial(itrl,1),strcmp(index,'PracSlideTarget.ACC')))==1 && strcmp(edata(sub_trial(itrl,1),strcmp(index,'FlankerType')),'congruent') && ...
                strcmp(edata(sub_trial(itrl,1),strcmp(index,'WarningType')),'double'))
            temp_val = edata(sub_trial(itrl,1),strcmp(index,'PracSlideTarget.ACC')); % Acquire the accuracy for this trial
            ACC_Con_DoubCue_Mat = [ACC_Con_DoubCue_Mat;str2double(temp_val{1,1})];   % Attach the accuracy of this trial to the set
        end
        % If this trial is correct, flanker type is congruent target and warning type is cneter cue
        if (str2double(edata(sub_trial(itrl,1),strcmp(index,'PracSlideTarget.ACC')))==1 && strcmp(edata(sub_trial(itrl,1),strcmp(index,'FlankerType')),'congruent') && ...
                strcmp(edata(sub_trial(itrl,1),strcmp(index,'WarningType')),'center'))
            temp_val = edata(sub_trial(itrl,1),strcmp(index,'PracSlideTarget.ACC')); % Acquire the accuracy for this trial
            ACC_Con_CentCue_Mat = [ACC_Con_CentCue_Mat;str2double(temp_val{1,1})];   % Attach the accuracy of this trial to the set
        end
        % If this trial is correct, flanker type is congruent target and warning type is spatial cue
        if (str2double(edata(sub_trial(itrl,1),strcmp(index,'PracSlideTarget.ACC')))==1 && strcmp(edata(sub_trial(itrl,1),strcmp(index,'FlankerType')),'congruent') && ...
                (strcmp(edata(sub_trial(itrl,1),strcmp(index,'WarningType')),'up') || strcmp(edata(sub_trial(itrl,1),strcmp(index,'WarningType')),'down')))
            temp_val = edata(sub_trial(itrl,1),strcmp(index,'PracSlideTarget.ACC')); % Acquire the accuracy for this trial
            ACC_Con_SpatCue_Mat = [ACC_Con_SpatCue_Mat;str2double(temp_val{1,1})];   % Attach the accuracy of this trial to the set
        end
        % If this trial is correct, flanker type is incongruent target and warning type is no cue
        if (str2double(edata(sub_trial(itrl,1),strcmp(index,'PracSlideTarget.ACC')))==1 && strcmp(edata(sub_trial(itrl,1),strcmp(index,'FlankerType')),'incongruent') && ...
                strcmp(edata(sub_trial(itrl,1),strcmp(index,'WarningType')),'no'))
            temp_val = edata(sub_trial(itrl,1),strcmp(index,'PracSlideTarget.ACC')); % Acquire the accuracy for this trial
            ACC_Incon_NoCue_Mat = [ACC_Incon_NoCue_Mat;str2double(temp_val{1,1})];   % Attach the accuracy of this trial to the set
        end
        % If this trial is correct, flanker type is incongruent target and warning type is double cue
        if (str2double(edata(sub_trial(itrl,1),strcmp(index,'PracSlideTarget.ACC')))==1 && strcmp(edata(sub_trial(itrl,1),strcmp(index,'FlankerType')),'incongruent') && ...
                strcmp(edata(sub_trial(itrl,1),strcmp(index,'WarningType')),'double'))
            temp_val = edata(sub_trial(itrl,1),strcmp(index,'PracSlideTarget.ACC'));   % Acquire the accuracy for this trial
            ACC_Incon_DoubCue_Mat = [ACC_Incon_DoubCue_Mat;str2double(temp_val{1,1})]; % Attach the accuracy of this trial to the set
        end
        % If this trial is correct, flanker type is incongruent target and warning type is center cue
        if (str2double(edata(sub_trial(itrl,1),strcmp(index,'PracSlideTarget.ACC')))==1 && strcmp(edata(sub_trial(itrl,1),strcmp(index,'FlankerType')),'incongruent') && ...
                strcmp(edata(sub_trial(itrl,1),strcmp(index,'WarningType')),'center'))
            temp_val = edata(sub_trial(itrl,1),strcmp(index,'PracSlideTarget.ACC'));   % Acquire the accuracy for this trial
            ACC_Incon_CentCue_Mat = [ACC_Incon_CentCue_Mat;str2double(temp_val{1,1})]; % Attach the accuracy of this trial to the set
        end
        % If this trial is correct, flanker type is incongruent target and warning type is spatial cue
        if (str2double(edata(sub_trial(itrl,1),strcmp(index,'PracSlideTarget.ACC')))==1 && strcmp(edata(sub_trial(itrl,1),strcmp(index,'FlankerType')),'incongruent') && ...
                (strcmp(edata(sub_trial(itrl,1),strcmp(index,'WarningType')),'up') || strcmp(edata(sub_trial(itrl,1),strcmp(index,'WarningType')),'down')))
            temp_val = edata(sub_trial(itrl,1),strcmp(index,'PracSlideTarget.ACC'));   % Acquire the accuracy for this trial
            ACC_Incon_SpatCue_Mat = [ACC_Incon_SpatCue_Mat;str2double(temp_val{1,1})]; % Attach the accuracy of this trial to the set
        end
    end
    
    %% Exclude data outside N standard deviations
    RT_NoCue_std  = std(RT_NoCueMat);                                                 % Calculate the standard deviation of RT for no cue condition
    RT_NoCue_mean = mean(RT_NoCueMat);                                                % Calculate the mean of RT for no cue condition
    RT_NoCueMat   = RT_NoCueMat(RT_NoCueMat > (RT_NoCue_mean - condSD*RT_NoCue_std)); % Exclude values greater than N standard deviations
    RT_NoCueMat   = RT_NoCueMat(RT_NoCueMat < (RT_NoCue_mean + condSD*RT_NoCue_std)); % Exclude values less than N standard deviations
    RT_NoCue_mean = mean(RT_NoCueMat);                                                % Calculate the mean of RT for no cue conditions after excluding extreme values
    
    RT_DoubCue_std  = std(RT_DoubCueMat);                                                       % Calculate the standard deviation of RT for double cue condition
    RT_DoubCue_mean = mean(RT_DoubCueMat);                                                      % Calculate the mean of RT for double cue condition
    RT_DoubCueMat   = RT_DoubCueMat(RT_DoubCueMat > (RT_DoubCue_mean - condSD*RT_DoubCue_std)); % Exclude values greater than N standard deviations
    RT_DoubCueMat   = RT_DoubCueMat(RT_DoubCueMat < (RT_DoubCue_mean + condSD*RT_DoubCue_std)); % Exclude values less than N standard deviations
    RT_DoubCue_mean = mean(RT_DoubCueMat);                                                      % Calculate the mean of RT for double cue conditions after excluding extreme values
    
    RT_CentCue_std  = std(RT_CentCueMat);                                                       % Calculate the standard deviation of RT for center cue condition
    RT_CentCue_mean = mean(RT_CentCueMat);                                                      % Calculate the mean of RT for center cue condition
    RT_CentCueMat   = RT_CentCueMat(RT_CentCueMat > (RT_CentCue_mean - condSD*RT_CentCue_std)); % Exclude values greater than N standard deviations
    RT_CentCueMat   = RT_CentCueMat(RT_CentCueMat < (RT_CentCue_mean + condSD*RT_CentCue_std)); % Exclude values less than N standard deviations
    RT_CentCue_mean = mean(RT_CentCueMat);                                                      % Calculate the mean of RT for center cue conditions after excluding extreme values
    
    RT_SpatCue_std  = std(RT_SpatCueMat);                                                       % Calculate the standard deviation of RT for spatial cue condition
    RT_SpatCue_mean = mean(RT_SpatCueMat);                                                      % Calculate the mean of RT for spatial cue condition
    RT_SpatCueMat   = RT_SpatCueMat(RT_SpatCueMat > (RT_SpatCue_mean - condSD*RT_SpatCue_std)); % Exclude values greater than N standard deviations
    RT_SpatCueMat   = RT_SpatCueMat(RT_SpatCueMat < (RT_SpatCue_mean + condSD*RT_SpatCue_std)); % Exclude values less than N standard deviations
    RT_SpatCue_mean = mean(RT_SpatCueMat);                                                      % Calculate the mean of RT for spatial cue conditions after excluding extreme values
    
    RT_Cong_std  = std(RT_CongMat);                                              % Calculate the standard deviation of RT for congruent target condition
    RT_Cong_mean = mean(RT_CongMat);                                             % Calculate the mean of RT for congruent target condition
    RT_CongMat   = RT_CongMat(RT_CongMat > (RT_Cong_mean - condSD*RT_Cong_std)); % Exclude values greater than N standard deviations
    RT_CongMat   = RT_CongMat(RT_CongMat < (RT_Cong_mean + condSD*RT_Cong_std)); % Exclude values less than N standard deviations
    RT_Cong_mean = mean(RT_CongMat);                                             % Calculate the mean of RT for congruent target conditions after excluding extreme values
    
    RT_Incong_std  = std(RT_IncongMat);                                                    % Calculate the standard deviation of RT for incongruent target condition
    RT_Incong_mean = mean(RT_IncongMat);                                                   % Calculate the mean of RT for incongruent target condition
    RT_IncongMat   = RT_IncongMat(RT_IncongMat > (RT_Incong_mean - condSD*RT_Incong_std)); % Exclude values greater than N standard deviations
    RT_IncongMat   = RT_IncongMat(RT_IncongMat < (RT_Incong_mean + condSD*RT_Incong_std)); % Exclude values less than N standard deviations
    RT_Incong_mean = mean(RT_IncongMat);                                                   % Calculate the mean of RT for incongruent target conditions after excluding extreme values
    
    %% Calculate mean of RTs for trials in different cue and target condition
    RT_Con_NoCue_mean     = mean(RT_Con_NoCue_Mat);     % Calculate mean of RTs for trials in no cue and congruent target condition
    RT_Con_DoubCue_mean   = mean(RT_Con_DoubCue_Mat);   % Calculate mean of RTs for trials in double cue and congruent target condition
    RT_Con_CentCue_mean   = mean(RT_Con_CentCue_Mat);   % Calculate mean of RTs for trials in center cue and congruent target condition
    RT_Con_SpatCue_mean   = mean(RT_Con_SpatCue_Mat);   % Calculate mean of RTs for trials in spatial cue and congruent target condition
    RT_Incon_NoCue_mean   = mean(RT_Incon_NoCue_Mat);   % Calculate mean of RTs for trials in no cue and incongruent target condition
    RT_Incon_DoubCue_mean = mean(RT_Incon_DoubCue_Mat); % Calculate mean of RTs for trials in double cue and incongruent target condition
    RT_Incon_CentCue_mean = mean(RT_Incon_CentCue_Mat); % Calculate mean of RTs for trials in center cue and incongruent target condition
    RT_Incon_SpatCue_mean = mean(RT_Incon_SpatCue_Mat); % Calculate mean of RTs for trials in spatial cue and incongruent target condition
    
    %% Calculate accuracy of trials in different cue and target condition
    ACC_Con_NoCue     = sum(ACC_Con_NoCue_Mat) / Sum_Con_NoCue;         % Calculate accuracy of trials in no cue and congruent target condition
    ACC_Con_DoubCue   = sum(ACC_Con_DoubCue_Mat) / Sum_Con_DoubCue;     % Calculate accuracy of trials in double cue and congruent target condition
    ACC_Con_CentCue   = sum(ACC_Con_CentCue_Mat) / Sum_Con_CentCue;     % Calculate accuracy of trials in center cue and congruent target condition
    ACC_Con_SpatCue   = sum(ACC_Con_SpatCue_Mat) / Sum_Con_SpatCue;     % Calculate accuracy of trials in spatial cue and congruent target condition
    ACC_Incon_NoCue   = sum(ACC_Incon_NoCue_Mat) / Sum_Incon_NoCue;     % Calculate accuracy of trials in no cue and incongruent target condition
    ACC_Incon_DoubCue = sum(ACC_Incon_DoubCue_Mat) / Sum_Incon_DoubCue; % Calculate accuracy of trials in double cue and incongruent target condition
    ACC_Incon_CentCue = sum(ACC_Incon_CentCue_Mat) / Sum_Incon_CentCue; % Calculate accuracy of trials in center cue and incongruent target condition
    ACC_Incon_SpatCue = sum(ACC_Incon_SpatCue_Mat) / Sum_Incon_SpatCue; % Calculate accuracy of trials in spatial cue and incongruent target condition
    
    % Calculate mean accuracy of all trials
    ACC_mean = mean([ACC_Con_NoCue, ACC_Con_DoubCue, ACC_Con_CentCue, ACC_Con_SpatCue, ACC_Incon_NoCue, ACC_Incon_DoubCue, ACC_Incon_CentCue, ACC_Incon_SpatCue]);
    
    ACC_NoCue   = sum(ACC_NoCueMat) / Sum_NoCue;     % Calculate accuracy of trials in no cue condition
    ACC_DoubCue = sum(ACC_DoubCueMat) / Sum_DoubCue; % Calculate accuracy of trials in double cue condition
    ACC_CentCue = sum(ACC_CentCueMat) / Sum_CentCue; % Calculate accuracy of trials in center cue condition
    ACC_SpatCue = sum(ACC_SpatCueMat) / Sum_SpatCue; % Calculate accuracy of trials in spatial cue condition
    ACC_Cong    = sum(ACC_CongMat) / Sum_Cong;       % Calculate accuracy of trials in congruent target condition
    ACC_Incong  = sum(ACC_IncongMat) / Sum_Incong;   % Calculate accuracy of trials in incongruent target condition
    
    %% Calculate alerting, orienting and executive attention scores
    A_NoDoub_mean_abs   = RT_NoCue_mean - RT_DoubCue_mean;   % Calculate the delta score of alerting attention measured by mean
    O_CenSpat_mean_abs  = RT_CentCue_mean - RT_SpatCue_mean; % Calculate the delta score of orienting attention measured by mean
    C_InconCon_mean_abs = RT_Incong_mean - RT_Cong_mean;     % Calculate the delta score of executive attention measured by mean
    
    A_NoDoub_mean_rate   = RT_NoCue_mean/ACC_NoCue - RT_DoubCue_mean/ACC_DoubCue;     % Calculate ratio effect score of alerting attention measured by mean
    O_CenSpat_mean_rate  = RT_CentCue_mean/ACC_CentCue - RT_SpatCue_mean/ACC_SpatCue; % Calculate ratio effect score of orienting attention measured by mean
    C_InconCon_mean_rate = RT_Incong_mean/ACC_Incong - RT_Cong_mean/ACC_Cong;         % Calculate ratio effect score of executive attention measured by mean
    
    %% Calculate frequency of trials that not respond within the time limit
    NoRespFreq = Sum_NoRespond / size(sub_edata, 1);
    
    %% Calculate frequency that exclusions of trials according to criteria
    CleanFreq = 1 -((size(RT_NoCueMat,1) + size(RT_DoubCueMat,1) + size(RT_CentCueMat,1) + size(RT_SpatCueMat,1)) / size(sub_edata, 1));
    
    %% Write the calculation results to .mat file
    allres{isub+1,1}  = sublist{isub,1};
    allres{isub+1,2}  = sublist{isub,2};
    allres{isub+1,3}  = group;
    allres{isub+1,4}  = subgrp;
    
    allres{isub+1,5}  = A_NoDoub_mean_abs;
    allres{isub+1,6}  = O_CenSpat_mean_abs;
    allres{isub+1,7}  = C_InconCon_mean_abs;
    
    allres{isub+1,8}  = A_NoDoub_mean_rate;
    allres{isub+1,9}  = O_CenSpat_mean_rate;
    allres{isub+1,10} = C_InconCon_mean_rate;

    allres{isub+1,11} = RT_Con_NoCue_mean;
    allres{isub+1,12} = RT_Con_CentCue_mean;
    allres{isub+1,13} = RT_Con_DoubCue_mean;
    allres{isub+1,14} = RT_Con_SpatCue_mean;
    allres{isub+1,15} = RT_Incon_NoCue_mean;
    allres{isub+1,16} = RT_Incon_CentCue_mean;
    allres{isub+1,17} = RT_Incon_DoubCue_mean;
    allres{isub+1,18} = RT_Incon_SpatCue_mean;
    
    allres{isub+1,19} = ACC_Con_NoCue;
    allres{isub+1,20} = ACC_Con_CentCue;
    allres{isub+1,21} = ACC_Con_DoubCue;
    allres{isub+1,22} = ACC_Con_SpatCue;
    allres{isub+1,23} = ACC_Incon_NoCue;
    allres{isub+1,24} = ACC_Incon_CentCue;
    allres{isub+1,25} = ACC_Incon_DoubCue;
    allres{isub+1,26} = ACC_Incon_SpatCue;
    allres{isub+1,27} = ACC_mean;
    allres{isub+1,28} = NoRespFreq;
    allres{isub+1,29} = CleanFreq;
    
    allres{isub+1,30} = RT_NoCue_mean;
    allres{isub+1,31} = RT_CentCue_mean;
    allres{isub+1,32} = RT_DoubCue_mean;
    allres{isub+1,33} = RT_SpatCue_mean;
    allres{isub+1,34} = RT_Cong_mean;
    allres{isub+1,35} = RT_Incong_mean;
    
end

%% Save results
% Name of the result file
res_file = fullfile(res_savedir,['behav_', group, '_', subgrp, '_',task]);
% Save the result file to disk
eval(cat(2,'save ',res_file,' allres'));

%% All done
clear all %#ok<*CLALL>
disp('All Done');
