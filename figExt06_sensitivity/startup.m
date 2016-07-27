global EROOT

[startupPath,x,x]=fileparts(which('startup'));
EROOT=strrep(startupPath,'\','/');

addpath([EROOT '/hydrolight']);
addpath([EROOT '/figures']);
addpath([EROOT '/aquatic sensitivity']);
parentDir=fileparts(pwd);
parentDir=strrep(parentDir,'\','/');
addpath([parentDir '\fig03_visualrange/aquatic model']);
