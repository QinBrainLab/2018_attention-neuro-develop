%% Perform bootstrap analysis for inference within each ROI
% Create RDM-based model
n_bs         = 5000;                         % Number of bootstrap
sub_ageClow  = [21 21 21 21];                % number of children in the four low age group
sub_ageChigh = [21 21 21 21];                % number of children in the four high age group
sub_ageA     = [19 19 19 18];                % number of adults in the four age group
sub_con      = [84 84 84 84 84 84 75 75 75]; % number of participants in the each process
sub_grp      = [252 252 225];                % number of participants in the each attention domain
res_name     = 'general_calcu.mat';          % Name of the result file

%% Create variable with roi names
rois = {
    'Grp_CBD_Comm_fdr05_r00_all',...
    'Grp_CBD_Comm_fdr05_r01_fef_b',...
    'Grp_CBD_Comm_fdr05_r02_spl_b',...
    'Grp_CBD_Speci_fdr05_r01_ai_b',...
    'Grp_CBD_Speci_fdr05_r02_dacc_r',...
    'Grp_CBD_Speci_fdr05_r03_tpj_r'
    };

%% create RDMs (same for all rois)
% Construct vectors indicating the membership of children in the four low age group
sub_age_X_Clow = []; age_cnt_Clow = 0; sub_cnt_Clow = 0;
for icon = 1:3
    for isub = 1:length(sub_ageClow)
        age_cnt_Clow = age_cnt_Clow + 1;
        for iage = 1:sub_ageClow(1,isub)
            sub_cnt_Clow = sub_cnt_Clow + 1;
            sub_age_X_Clow(sub_cnt_Clow,1) = age_cnt_Clow; %#ok<*SAGROW>
        end
    end
end

% Construct vectors indicating the membership of children in the four high age group
sub_age_X_Chigh = []; age_cnt_Chigh = 12; sub_cnt_Chigh = 0;
for icon = 1:3
    for isub = 1:length(sub_ageChigh)
        age_cnt_Chigh = age_cnt_Chigh + 1;
        for iage = 1:sub_ageChigh(1,isub)
            sub_cnt_Chigh = sub_cnt_Chigh + 1;
            sub_age_X_Chigh(sub_cnt_Chigh,1) = age_cnt_Chigh; %#ok<*SAGROW>
        end
    end
end

% Construct vectors indicating the membership of adults in the four age group
sub_age_X_A = []; age_cnt_A = 24; sub_cnt_A = 0;
for icon = 1:3
    for isub = 1:length(sub_ageA)
        age_cnt_A = age_cnt_A + 1;
        for iage = 1:sub_ageA(1,isub)
            sub_cnt_A = sub_cnt_A + 1;
            sub_age_X_A(sub_cnt_A,1) = age_cnt_A; %#ok<*SAGROW>
        end
    end
end

% Merge vectors of each age group for low age children, high age children and adults
sub_age_X = cat(1,sub_age_X_Clow,sub_age_X_Chigh,sub_age_X_A);

% Construct vectors indicating the membership of each process
sub_con_X = []; con_cnt = 0; sub_cnt = 0;
for isub = 1:length(sub_con)
    con_cnt = con_cnt + 1;
    for iage = 1:sub_con(1,isub)
        sub_cnt = sub_cnt + 1;
        sub_con_X(sub_cnt,1) = con_cnt; %#ok<*SAGROW>
    end
end

% Construct vectors indicating the membership of each attention domain
sub_grp_X = []; grp_cnt = 0; sub_cnt = 0;
for isub = 1:length(sub_grp)
    grp_cnt = grp_cnt + 1;
    for iage = 1:sub_grp(1,isub)
        sub_cnt = sub_cnt + 1;
        sub_grp_X(sub_cnt,1) = grp_cnt; %#ok<*SAGROW>
    end
end

inds_age=condf2indic(ceil(sub_age_X)); % Matrix of 0/1 based on age group membership
inds_con=condf2indic(ceil(sub_con_X)); % Matrix of 0/1 based on process membership
inds_grp=condf2indic(ceil(sub_grp_X)); % Matrix of 0/1 based on domain membership

% Effects unique to each age group (36 total)
for i=1:size(inds_age,2)
    RDM_age(i,:)=pdist(inds_age(:,i),'seuclidean');
end

% RDM for each attention process separately (9 total)
for i=1:size(inds_con,2)
    RDM_con(i,:)= pdist(inds_con(:,i),'seuclidean');
end

% RDM for each attention domain separately (3 total)
for i=1:size(inds_grp,2)
    RDM_grp(i,:)= pdist(inds_grp(:,i),'seuclidean');
end

% Place RDMs in design matrix
X=[RDM_age' RDM_con' RDM_grp'];

% Scale to have mean of 1000
for i=1:size(X,2)
    X(:,i)=1000*X(:,i)/sum(X(:,i));
end

%% Do bootstrap resampling separately for each neural RDM (per ROI)
if computeBootstrap
    clear b;
    for r = 1:length(rois)
        rng(6) % Start with same seed for each region of interest
        
        % Mask out data that is not within this ROI
        roi_masked_dat_Clow  = apply_mask(masked_dat_Clow, remove_empty(fmri_data(which([rois{r} '.nii']))));
        roi_masked_dat_Chigh = apply_mask(masked_dat_Chigh, remove_empty(fmri_data(which([rois{r} '.nii']))));
        roi_masked_dat_A     = apply_mask(masked_dat_A, remove_empty(fmri_data(which([rois{r} '.nii']))));
        roi_masked_dat.dat   = cat(2,roi_masked_dat_Clow.dat, roi_masked_dat_Chigh.dat, roi_masked_dat_A.dat);
        
        % Bootstrap resampling of subjects within age group
        bootstrap_num = 0;
        for it = 1:n_bs % 5000 bootstrap samples
            bootstrap_num = bootstrap_num + 1;
            disp(['bootstrap number = ', num2str(bootstrap_num)])
            
            bs_inds(1:21)=randi([1,21],1,21);       % Resample with replacement within first age group
            bs_inds(22:42)=randi([22,42],1,21);     % Resample with replacement within second age group
            bs_inds(43:63)=randi([43,63],1,21);     % Resample with replacement within third age group
            bs_inds(64:84)=randi([64,84],1,21);     % ... ...
            bs_inds(85:105)=randi([85,105],1,21);   % ... ...
            bs_inds(106:126)=randi([106,126],1,21); % ... ...
            bs_inds(127:147)=randi([127,147],1,21); % ... ...
            bs_inds(148:168)=randi([148,168],1,21); % ... ...
            bs_inds(169:189)=randi([169,189],1,21); % ... ...
            bs_inds(190:210)=randi([190,210],1,21); % ... ...
            bs_inds(211:231)=randi([211,231],1,21); % ... ...
            bs_inds(232:252)=randi([232,252],1,21); % ... ...
            
            bs_inds(253:273)=randi([253,273],1,21); % ... ...
            bs_inds(274:294)=randi([274,294],1,21); % ... ...
            bs_inds(295:315)=randi([295,315],1,21); % ... ...
            bs_inds(316:336)=randi([316,336],1,21); % ... ...
            bs_inds(337:357)=randi([337,357],1,21); % ... ...
            bs_inds(358:378)=randi([358,378],1,21); % ... ...
            bs_inds(379:399)=randi([379,399],1,21); % ... ...
            bs_inds(400:420)=randi([400,420],1,21); % ... ...
            bs_inds(421:441)=randi([421,441],1,21); % ... ...
            bs_inds(442:462)=randi([442,462],1,21); % ... ...
            bs_inds(463:483)=randi([463,483],1,21); % ... ...
            bs_inds(484:504)=randi([484,504],1,21); % ... ...
            
            bs_inds(505:523)=randi([505,523],1,19); % ... ...
            bs_inds(524:542)=randi([524,542],1,19); % ... ...
            bs_inds(543:561)=randi([543,561],1,19); % ... ...
            bs_inds(562:579)=randi([562,579],1,18); % ... ...
            bs_inds(580:598)=randi([580,598],1,19); % ... ...
            bs_inds(599:617)=randi([599,617],1,19); % ... ...
            bs_inds(618:636)=randi([618,636],1,19); % ... ...
            bs_inds(637:654)=randi([637,654],1,18); % ... ...
            bs_inds(655:673)=randi([655,673],1,19); % ... ...
            bs_inds(674:692)=randi([674,692],1,19); % ... ...
            bs_inds(693:711)=randi([693,711],1,19); % ... ...
            bs_inds(712:729)=randi([712,729],1,18); % Resample with replacement within thirty-six age group
            
            resampled_mat = roi_masked_dat.dat(:,bs_inds)'; % Grab data from bootstrap indices
            Y = pdist(resampled_mat,'correlation');         % Compute distance matrix on this data
            Y(Y<.00001) = NaN;                              % Exclude very small off diagonal elements (because subjects can be replicated, and because some subjects have low variance)
            
            [full_x] = glmfit([ones(length(Y),1) double(X)],Y','normal','constant','off'); % Estimate coefficients with OLS
            b(it,r,:) = full_x;                                                            % Store bootstrap statistic for each iteration, each roi
            
        end
        save(res_name, 'b', '-v7.3'); % Save bootstrap statistics to disk
    end
end
