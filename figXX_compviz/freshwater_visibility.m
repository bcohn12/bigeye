
% Data from Davi08a on visibility in meters of freshwater bodies, Table 1

y_bd=[...
13.09;
4.20;
5.035;
5.445;
2.8;
3.6;
1.35;
0.96;
1.135;
0.508;
0.26;
0.085;
3.37;
0.50;
0.343;
0.20;
0.47];

% disp('mean')
% mean(y_bd)
% disp('std')
% std(y_bd)
% 
% disp('25 percentile')
% prctile(y_bd,25)
% disp('50 percentile')
% prctile(y_bd,50)
% disp('75 percentile')
% prctile(y_bd,75)

c=4.8./y_bd  % attenuation coefficient

disp('mean')
mean(y_bd)
disp('std')
std(y_bd)

disp('25 percentile')
prctile(c,25)
disp('50 percentile')
prctile(c,50)
disp('75 percentile')
prctile(c,75)