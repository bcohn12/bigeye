clear all 
close all
global EROOT % location of bigeye/figs on your machine
EROOT='~/animallab/trunk/papers/bigeye/figs/';


function [EROOT] = bigeye_startup(varargin)


% Set up globals
global EROOT 

% When automatically adding /papers and papers/figs/ directories,
% ignore any directories with names matching this list
dirIgnore={'.svn','.','..','tool'};

s = matlabpath;
p = 1;
pathacc = {};
while true
    t = strtok(s(p:end), pathsep);
    pathacc = [pathacc; t];
    p = p + length(t) + 1;
    if isempty(strfind(s(p:end),':')) break, end;
end
if length(varargin) >= 1
    PAPER = varargin{1};
end

if length(varargin) == 2
    if ~varargin{2}
        disp('Debug DISABLED')
    else
        disp('Debug Enabled')
        dbstop if error
    end
else
    disp('Debug Enabled')
    dbstop if error
end
    



disp('ROOT DIRECTORIES:')
EROOT = strrep(pwd,'\','/');
fprintf('AnimalLab Root Set: %s\n',EROOT)
TEMPROOT = getenv('TMPDIR');

% Check also if we're deployed since OS X actually always defines TMPDIR
if isempty(TEMPROOT) || ~isdeployed
    fprintf('Temp Root Set: %s\n\n',EROOT)
    TEMPROOT = EROOT;
end
if ~isdeployed
    disp('GENERAL PATHS:')
    % models and data
    my_addpath([EROOT '/body'])
    my_addpath([EROOT '/sensor'])
    my_addpath([EROOT '/motion'])
    my_addpath([EROOT '/stimulus'])
    my_addpath([EROOT '/afferent'])

    % vrml blackGhost main program
    my_addpath([EROOT '/motion/vrml/blackghost'])
    
    % inviscid optimal control
    my_addpath([EROOT '/motion/kirchhoff']) 
    my_addpath([EROOT '/motion/kirchhoff/snopt'])
	my_addpath([EROOT '/motion/kirchhoff/tiffany'])
    my_addpath([EROOT '/motion/kirchhoff/tiffany/initializations'])
    my_addpath([EROOT '/motion/kirchhoff/tiffany/constraints'])
    my_addpath([EROOT '/motion/kirchhoff/tiffany/snopt'])
    my_addpath([EROOT '/motion/kirchhoff/tiffany/snopt/results'])
    my_addpath([EROOT '/motion/kirchhoff/jangir/randomcode'])
    my_addpath([EROOT '/motion/kirchhoff/jangir/randomcode/bending'])
    my_addpath([EROOT '/motion/kirchhoff/jangir/randomcode/bowtie'])
    my_addpath([EROOT '/motion/kirchhoff/jangir/randomcode/new_initguess'])
    my_addpath([EROOT '/motion/kirchhoff/jangir/randomcode/error'])
    my_addpath([EROOT '/motion/kirchhoff/VaryDetPt Figures/code'])
    
    % tools, simulations & logic
    my_addpath([EROOT '/etc'])
    my_addpath([EROOT '/etc/trial_browser'])
    my_addpath([EROOT '/etc/snopt'])
    my_addpath([EROOT '/logic'])
    my_addpath([EROOT '/detection'])
    my_addpath([EROOT '/tasks'])
    my_addpath([EROOT '/build'])
    
    try
        if PAPER == 'maze1'
            my_addpath([EROOT '/papers/' PAPER '/processing'])
        end
    catch
    end

    % if alabstartup was called with a paper name,
    % add all subdirs below the figs directory for that
    % paper to the path; otherwise, add ALL paper subdirs
    % to path

    paper_path = [EROOT ];
    paperdirs=dir(paper_path);
    fprintf('\nFIGS PATHS:\n')
    for i = 1:length(paperdirs)
        % filter out parent, current, and .svn directories
        if ~ismember(paperdirs(i).name, dirIgnore)

            % only add the paper directory passed as an argument; or
            % all paper directories if no paper directories were passed
            if isempty(varargin) || strcmp(paperdirs(i).name, varargin{1})
                % add the papers/figs directory for this paper
                if isdir([EROOT '/' paperdirs(i).name '/figs'])
                    my_addpath([EROOT '/' paperdirs(i).name '/figs'])
                end

                % find valid subdirs of the /figs directory and add these
                figdirs = dir([EROOT '/' paperdirs(i).name '/figs/*']);
                for j=1:length(figdirs)
                    if ~ismember(figdirs(j).name, dirIgnore)
                        if isdir([EROOT '/' paperdirs(i).name '/figs/' ...
                                figdirs(j).name])
                            my_addpath([EROOT '/' paperdirs(i).name ...
								'/figs/' figdirs(j).name])
                        end
                    end
                end
            end
        end
    end
end
fprintf('\n');

function my_addpath(new_path)
if exist(new_path,'dir')
    addpath(new_path)
    disp(['Included: ' new_path])
end
% Modelines
% vim:set filetype=matlab ts=4 sw=4 tw=80:  %
