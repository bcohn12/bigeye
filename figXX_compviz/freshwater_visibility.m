
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

disp('mean')
mean(y_bd)
disp('std')
std(y_bd)

disp('25 percentile')
prctile(y_bd,25)
disp('50 percentile')
prctile(y_bd,50)
disp('75 percentile')
prctile(y_bd,75)

c=4.8./y_bd;   % attenuation coefficientc
%attlen=1./c; % attenuation length
attlen = c

disp('mean')
mean(attlen)
disp('std')
std(attlen)

disp('25 percentile')
prctile(attlen,25)
disp('50 percentile')
prctile(attlen,50)
disp('75 percentile')
prctile(attlen,75)

kd= [ ...
    0.27
0.41
0.45
0.56
0.56
0.65
0.81
1.2
1.23
2.2
2.8
5.28
0.73
0.96
1.36
2.26
3.13];

disp('mean kd')
mean(kd)
disp('std')
std(kd)

disp('25 percentile')
prctile(kd,25)
disp('50 percentile')
prctile(kd,50)
disp('75 percentile')
prctile(kd,75)
