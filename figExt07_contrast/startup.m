global EROOT

[startupPath,x,x]=fileparts(which('startup'));
EROOT=strrep(startupPath,'\','/');

addpath([EROOT '/aerial_model']);
addpath([EROOT '/aquatic_model']);
addpath([EROOT '/figures']);
addpath([EROOT, '/image_contrast']);

parentDir=fileparts(pwd);
parentDir=strrep(parentDir,'\','/');
addpath([parentDir '/data/vision']);