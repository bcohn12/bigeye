

% Set up globals
global BIGEYEROOT


BIGEYEROOT=pwd;

figdirs=dir(BIGEYEROOT);
fprintf('\nADDING PATHS:\n')

% find valid subdirs  and add these
figdirs = dir([BIGEYEROOT '/' figdirs(i).name '/figs/*']);
for j=1:length(figdirs)
    
    if isdir([BIGEYEROOT '/' figdirs(i).name '/figs/' ...
            figdirs(j).name])
        
        if exist([BIGEYEROOT '/' paperdirs(i).name ...
                '/figs/' figdirs(j).name],'dir')
            addpath(new_path)
            disp(['Included: ' new_path])
        end
        
    end
    
end


