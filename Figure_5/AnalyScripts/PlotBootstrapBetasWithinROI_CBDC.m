% Plot bootstrap distributions of Generalization Indices in each ROI
load('/home/haolei/Data/BrainDev_ANT/GenRep/Results/bsModCompWithinROI_CBDA_OneANOVA_5000_age.mat');

%% get p-values from bootstrap distribution under some assumpations of normality
b_ste = squeeze(nanstd(b)); %bootstrap SE
b_mean = squeeze(nanmean(b)); %bootstrap mean
b_ste(b_ste == 0) = Inf; %ignore cases where SE is 0
b_Z = b_mean ./ b_ste; % compute Z
b_P = 2 * (1 - normcdf(abs(b_Z))); %get two-tailed p-value from Z

%%
% region_labels={'pMCC' 'aMCC' 'pACC' 'sgACC' 'vmPFC' 'dMFC' 'MFC'}; %titles for figures

region_labels = {
    'NeuroSynth_FanANT_dACC', ...
    'NeuroSynth_FanANT_fef_l', ...
    'NeuroSynth_FanANT_fef_r', ...
    'NeuroSynth_FanANT_spl_l', ...
    'NeuroSynth_FanANT_spl_r', ...
    'NeuroSynth_allcomb'};

% region_labels = {
%     'OneANOVA_CBDA_dACC_001_33', ...
%     'OneANOVA_CBDA_ROIcomb_AOC_inter_roi_fef_l', ...
%     'OneANOVA_CBDA_ROIcomb_AOC_inter_roi_fef_l_big', ...
%     'OneANOVA_CBDA_ROIcomb_AOC_inter_roi_fef_l_small', ...
%     'OneANOVA_CBDA_ROIcomb_AOC_inter_roi_fef_r', ...
%     'OneANOVA_CBDA_ROIcomb_AOC_inter_roi_fef_r_big', ...
%     'OneANOVA_CBDA_ROIcomb_AOC_inter_roi_fef_r_small', ...
%     'OneANOVA_CBDA_ROIcomb_AOC_inter_roi_spl_l', ...
%     'OneANOVA_CBDA_ROIcomb_AOC_inter_roi_spl_r', ...
%     'OneANOVA_allcomb'};

for r=1:length(region_labels) % for each region
    % subplot(1,14,r) %plot all on same figure
    figure;
    distributionPlot(squeeze(b(:,r,44:46)),'color',{[1 0 0] [0 1 0] [0 0 1]},'showMM',5); %plot bootstrap distributions for domain-level generalization indices
    
    %format figure
    axis tight;
    xlabel 'Alert                            Orient                            Conflict';
    title(region_labels(r));
    set(gca,'XTick',[]);
    set(gca,'Linewidth',2);
    ylabel 'Generalization Index';
    h=findobj(gca,'type','line');
    set(h,'color','k','linewidth',2);
    
    
    set(gcf,'units','inches');
    set(gcf,'position',[0 0 12 3]);
    saveas(gcf, [basedir filesep 'Results' filesep region_labels{1,r}], 'png');
end

for r=1:length(region_labels) % for each region
    subplot(6,1,1) %plot all on same figure
    distributionPlot(squeeze(b(:,r,2:7)),'showMM',5); %plot bootstrap distributions for domain-level generalization indices
    subplot(6,1,2)
    distributionPlot(squeeze(b(:,r,8:13)),'showMM',5);
    
    %format figure
    axis tight;
    xlabel 'age1   age2   age3   age4   age5   age6   age7';
    title(region_labels(r));
    set(gca,'XTick',[]);
    set(gca,'Linewidth',2);
    ylabel 'Generalization Index';
    h=findobj(gca,'type','line');
    %set(h,'color','k','linewidth',2);
    
    
    set(gcf,'units','inches');
    set(gcf,'position',[0 0 12 3]);
    saveas(gcf, [basedir filesep 'Results' filesep region_labels{1,r}], 'png');
end

%% inference using FDR correction

% across all rois
sig_FDR_roi = b_P(1:(length(region_labels)-1),:) < FDR(b_P(1:(length(region_labels)-1),:),.05); %6 region by 31 parameter matrix - last 3 are domain

% for the full MFCs
sig_FDR_roicomb = b_P(length(region_labels),:) < FDR(b_P(length(region_labels),:),.05); %1 region by 31 parameter matrix - last 3 are domain
