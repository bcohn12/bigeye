function xls2TexTable()
%% xls2TexTable()
% Convert xls table fields to LaTeX table format
% 
% Chen Chen
% 2.16.2016

%% Read or Load XLS Data
% [~,txt,~] = xlsread('bigEye_data.xlsx',1,'A20:A90');

[~,XlsData.Genus,~] = xlsread('bigEye_data.xlsx',1,'A21:A90');
[~,~,XlsData.AP] = xlsread('bigEye_data.xlsx',1,'G21:I90');
[~,~,XlsData.RefKey] = xlsread('bigEye_data.xlsx',1,'J21:J90');

% load('bigEyeData-AP-All.mat');

% Specify Needed Species Here
Ind = {};

Ind = [Ind; {'Tetrapodomorph Fish',...
    find(strcmp('Tetrapodomorph Fish',XlsData.Genus))}];

Ind = [Ind; {'Palatinichthys',...
    find(strcmp('Palatinichthys',XlsData.Genus))}];

Ind = [Ind; {'Edenopteron',...
    find(strcmp('Edenopteron',XlsData.Genus))}];

%% Get Average AP Data
AveAP = [Ind(:,1),... % Genus
    XlsData.AP(cell2mat(Ind(:,2)),3),... % Average AP (mm)
    XlsData.RefKey(cell2mat(Ind(:,2)))]; % AP-src BibTeX Reference Key

%% Convert to LaTeX Table Format
columnLabels = {'Genus'; 'Avg AP (mm)'; 'Reference'};

matrix2latex(AveAP, 'out.tex', ...
    'columnLabels', columnLabels, ...
    'alignment', 'c', ...
    'format', '%-6.2f');

disp('Done!!');