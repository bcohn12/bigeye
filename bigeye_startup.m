%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Statistical summary of raw socket length data based on grouping
%%
%% Title                : A massive increase in visual range preceded the origin of terrestrial vertebrates
%% Authors              : Ugurcan Mugan, Malcolm A. MacIver
%% Authors' Affiliation : Northwestern University
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set up globals
global BIGEYEROOT

BIGEYEROOT=pwd;
BIGEYEROOT=[BIGEYEROOT '/'];
BIGEYEROOT=strrep(BIGEYEROOT, '\','/');

alldirs = dir([BIGEYEROOT  'figs/']);

for j=1:length(alldirs)    
    if isdir([BIGEYEROOT  'figs/' alldirs(j).name]) && ~strcmp(alldirs(j).name,'archive')...
            && ~strcmp(alldirs(j).name,'.')&&~strcmp(alldirs(j).name,'cover_submission') &&~strcmp(alldirs(j).name,'..');
        fprintf('adding folder and all subfolders... %s\n',alldirs(j).name);
        addpath(genpath([BIGEYEROOT 'figs/' alldirs(j).name]));            
    end
end
%rmpath(genpath([BIGEYEROOT 'figs/archive']))
BIGEYEROOT=[BIGEYEROOT ,'figs/'];

clearvars -except BIGEYEROOT
