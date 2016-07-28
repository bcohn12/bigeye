global EROOT

[startupPath,x,x]=fileparts(which('startup'));
EROOT=strrep(startupPath,'\','/');

addpath([EROOT '/aerial_model']);
addpath([EROOT '/aquatic_model']);
addpath([EROOT '/figures']);