global EROOT

[startupPath,x,x]=fileparts(which('startup'));
EROOT=strrep(startupPath,'\','/');

addpath([EROOT '/aerial model']);
addpath([EROOT '/aquatic model']);
addpath([EROOT '/figures']);