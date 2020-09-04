% Import BN data from spreadsheet
% Script for importing data from the following spreadsheet:
%
%    Workbook: D:\Google Drive\MFC_Generalizability\Masks\BNA_subregions.xlsx
%    Worksheet: Sheet1
%
% To extend the code for use with different selected data or a different
% spreadsheet, generate a function instead of a script.

% Auto-generated by MATLAB on 2017/10/11 08:21:42

%% Import the data
[~, ~, raw] = xlsread([basedir 'Masks' filesep 'BNA_subregions.xlsx'],'Sheet1','F2:F124');
raw(cellfun(@(x) ~isempty(x) && isnumeric(x) && isnan(x),raw)) = {''};
cellVectors = raw(:,1);

%% Allocate imported array to column variable names
ci=1;
for i=1:2:246
RegionLabel{i} = ['L, ' cellVectors{ci}];
RegionLabel{i+1} = ['R, ' cellVectors{ci}];
ci=ci+1;
end
%% Clear temporary variables
clearvars raw cellVectors;