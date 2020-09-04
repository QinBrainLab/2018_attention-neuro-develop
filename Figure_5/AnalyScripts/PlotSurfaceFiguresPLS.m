% load(which('bs_pls_workspace.mat'));
% cmap=canlabCmap;
r=10; % which roi
roi_masked_dat=apply_mask(masked_dat,remove_empty(fmri_data(which([rois{r} '.nii']))));

for i=1:10
    close all;
    figure;
    tv=roi_masked_dat;
    tv.dat=b_pls_tZ{i,1};
    tv=replace_empty(tv);
    a=nan(size(tv.volInfo.image_indx));
    a(tv.volInfo.image_indx)=tv.dat;
    a=reshape(a,(tv.volInfo.dim));
    
    b=interp2(squeeze(a(43,1:109,1:91)));
    b(b==0)=nan;
    s=surf(b);
    s.EdgeColor = 'none';
    
    colormap(cmap)
    
    view(126,66);
    set(gca,'Visible','off');
    
    saveas(gcf, ['dACC',num2str(i)], 'png')
end

i=2; %cognitive control
close all;
figure;

tv=roi_masked_dat;
tv.dat=b_pls_tZ{i,r};
tv=replace_empty(tv);
a=nan(size(tv.volInfo.image_indx));
a(tv.volInfo.image_indx)=tv.dat;
a=reshape(a,(tv.volInfo.dim));
b=interp2(squeeze(a(41,50:80,25:50)));
b(b==0)=nan;
surf(b)
colormap(cmap)
view(-90,60);set(gca,'Visible','off');
saveas(gcf, [basedir 'Results' filesep 'Fig3bmiddle'], 'png')

i=3; %negative emotion
close all;
figure;

tv=roi_masked_dat;
tv.dat=b_pls_tZ{i,r};
tv=replace_empty(tv);
a=nan(size(tv.volInfo.image_indx));
a(tv.volInfo.image_indx)=tv.dat;
a=reshape(a,(tv.volInfo.dim));
b=interp2(squeeze(a(41,50:80,25:50)));
b(b==0)=nan;
surf(b)
colormap(cmap)
view(-90,60);set(gca,'Visible','off');
saveas(gcf, [basedir 'Results' filesep 'Fig3bbottom'], 'png')
