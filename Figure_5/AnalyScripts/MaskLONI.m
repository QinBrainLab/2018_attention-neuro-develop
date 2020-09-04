%% Mask data within GM regions
gm_mask=fmri_data(which('TPM.nii')); % Tissue probability map from SPM distribution
gm_mask.dat=gm_mask.dat(:,1)>.5;     % Threshold at prob GM > 50%

%% Adult
[masked_dat_A]=apply_mask(A.FullDataSet,gm_mask); % Apply GM mask

% Some contrasts have no ROI activity, clean up for analysis CHECK THIS
masked_dat_A.Y=masked_dat_A.Y(~masked_dat_A.removed_images);
A.FullDataSet.Y=A.FullDataSet.Y(~masked_dat_A.removed_images);
masked_dat_A=remove_empty(masked_dat_A);

%% Low age group children
[masked_dat_Clow]=apply_mask(Clow.FullDataSet,gm_mask); % Apply GM mask

% Some contrasts have no ROI activity, clean up for analysis CHECK THIS
masked_dat_Clow.Y=masked_dat_Clow.Y(~masked_dat_Clow.removed_images);
Clow.FullDataSet.Y=Clow.FullDataSet.Y(~masked_dat_Clow.removed_images);
masked_dat_Clow=remove_empty(masked_dat_Clow);

%% High age group children
[masked_dat_Chigh]=apply_mask(Chigh.FullDataSet,gm_mask); % Apply GM mask

% Some contrasts have no ROI activity, clean up for analysis CHECK THIS
masked_dat_Chigh.Y=masked_dat_Chigh.Y(~masked_dat_Chigh.removed_images);
Chigh.FullDataSet.Y=Chigh.FullDataSet.Y(~masked_dat_Chigh.removed_images);
masked_dat_Chigh=remove_empty(masked_dat_Chigh);
