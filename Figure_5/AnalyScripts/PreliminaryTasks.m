%% Set some parameters, configure MATLAB path, and load data
% Configure analyses:
ConfigureAnalysisOptions

% Load data
ReadSharedData
A     = load('\dir\FullDataSet_75.mat');     % Read adult data
Clow  = load('\dir\FullDataSet_low84.mat');  % Read low age group children data
Chigh = load('\dir\FullDataSet_high84.mat'); % Read high age group children data

% Mask data
MaskLONI

% Clear command line
% clc