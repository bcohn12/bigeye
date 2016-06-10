clear all; close all;

q=0.36; %units: n/a, detection efficien
eta=0.5; %Walzl et al 2007
Dt=1.16; %units: s, integration time, used typical value

qVals=[eta,q,q];

%All values from Middleton
LDaylight=0.97*1e3; % daylight luminosity in cd/m^2 
LMoonlight=1e-2; %Fairly brigh moonlight in cd/m^2
LStarlight=1e-4; %moonless clear night sky in cd/m^2

LVals=[LDaylight,LMoonlight,LStarlight];

Dt_daylight=(LDaylight)^-0.19; %Donner etal 1994
Dt_moonlight=(LMoonlight)^-0.19;
Dt_starlight=(LStarlight)^-0.19;

DtVals=[Dt_daylight, Dt_moonlight, Dt_starlight];

% Contrast parameters. Miller uses +/- 0.5, +/-1, and +/-2 as span 
C0_daylight=-1; %daylight contrast value
C0_moonlight=1; %night contrast value, a guess (4 is snow). 
C0_starlight=1; %starlight contrast value, a guess
C0All=[C0_daylight, C0_moonlight, C0_starlight];

k=0.035; % photoreceptor absorbtion, units 1/micrometers
len=57;  % length of photoreceptor, in micrometers

X=0.011; %units: photons/s, dark-noise rate/photoreceptor @16.5degrees Celsius
%X_daylight=0.011; %units: photons/s, dark-noise rate/photoreceptor @16.5degrees Celsius
X_land=0.08; %units:photons/s, dark-noise rate/photoreceptor @23.5 degrees Celsius

XVals=[X_land,X,X];

R=1.96; %units: n/a, reliability coefficient for 95% confidence, used typical value
d=3e-6; %units: m, photoreceptor diameter, used typical value
M=2.55; %units: n/a, ratio of focal length and pupil radius (2f/A), set to Matthiessen's ratio
f_daylight=8.8; %focal_length/A for bright light
f_night=2.1; %focal_length/A for night

FVals=[f_daylight,f_night,f_night];

%Beam Attenuation Coefficient
a_River=xlsread('hydrolight/Hydrolight_BrownWater.xlsx','a_Model');
a_River=a_River(2:end,3:end);

a_Coastal=xlsread('hydrolight/Hydrolight_CoastalWater.xlsx','a');
a_Coastal=a_Coastal(2:end,3:end);

%Scattering Coefficient
b_River=xlsread('hydrolight/Hydrolight_BrownWater.xlsx','b_Model');
b_River=b_River(2:end,3:end);

b_Coastal=xlsread('hydrolight/Hydrolight_CoastalWater.xlsx','b');
b_Coastal=b_Coastal(2:end,3:end);

%Attenuation Coefficient of Background Radiance
Ku_River=xlsread('hydrolight/Hydrolight_BrownWater.xlsx','Ku');
Ku_River=Ku_River(4:end,3:end);

Ku_Coastal=xlsread('hydrolight/Hydrolight_CoastalWater.xlsx','Ku');
Ku_Coastal=Ku_Coastal(2:end,3:end);

Kd_River=xlsread('hydrolight/Hydrolight_BrownWater.xlsx','Kd');
Kd_River=Kd_River(4:end,3:end);

Kd_Coastal=xlsread('hydrolight/Hydrolight_CoastalWater.xlsx','Kd');
Kd_Coastal=Kd_Coastal(2:end,3:end);

Kh_River=zeros(size(Kd_River,1),size(Kd_River,2));
Kh_Coastal=zeros(size(Kd_Coastal,1),size(Kd_Coastal,2));

%Ispace Values
%Upwelling, horizontal, downwelling radiance
Lu_River=xlsread('hydrolight/Hydrolight_BrownWater.xlsx','Lu');
lambda=Lu_River(4:end,1);
Lu_River=Lu_River(4:end,4:end);

Lu_Coastal=xlsread('hydrolight/Hydrolight_CoastalWater.xlsx','Lu');
Lu_Coastal=Lu_Coastal(2:end,4:end);

Lh_River=xlsread('hydrolight/Hydrolight_BrownWater.xlsx','Lh');
Lh_River=Lh_River(4:end,4:end);

Lh_Coastal=xlsread('hydrolight/Hydrolight_CoastalWater.xlsx','Lh');
Lh_Coastal=Lh_Coastal(2:end,4:end);

Ld_River=xlsread('hydrolight/Hydrolight_BrownWater.xlsx','Ld');
Ld_River=Ld_River(4:end,4:end);

Ld_Coastal=xlsread('hydrolight/Hydrolight_CoastalWater.xlsx','Ld');
Ld_Coastal=Ld_Coastal(2:end,4:end);

Lu_River=Lu_River*5.03e15;
Lh_River=Lh_River*5.03e15;
Ld_River=Ld_River*5.03e15;

Lu_Coastal=Lu_Coastal*5.03e15;
Lh_Coastal=Lh_Coastal*5.03e15;
Ld_Coastal=Ld_Coastal*5.03e15;

% Photoreceptor absorption
[LdMax_River, indLd_River]=max(Ld_River);
lambdaLdMax_River=lambda(indLd_River(1));

[LdMax_Coastal, indLd_Coastal]=max(Ld_Coastal);
lambdaLdMax_Coastal=lambda(indLd_Coastal(1));

A=1; a0A=800; a1A=3.1;
B=0.5; a0B=176; a1B=1.52;

photoreceptorAbsorption_River=A*exp(-a0A*(log10(lambda./lambdaLdMax_River)).^2.*...
    (1+a1A*log10(lambda./lambdaLdMax_River)+(3*a1A^2/8).*log10(lambda./lambdaLdMax_River).^2)+...
    B*exp(-a0B*(log10(lambda./368)).^2.*...
    (1+a1B*log10(lambda./368)+(3*a1B^2/8)*log10(lambda./368))));

photoreceptorAbsorption_Coastal=A*exp(-a0A*(log10(lambda./lambdaLdMax_Coastal)).^2.*...
    (1+a1A*log10(lambda./lambdaLdMax_Coastal)+(3*a1A^2/8).*log10(lambda./lambdaLdMax_Coastal).^2)+...
    B*exp(-a0B*(log10(lambda./368)).^2.*...
    (1+a1B*log10(lambda./368)+(3*a1B^2/8)*log10(lambda./368))));

% a=.3; %units: 1/m, beam attenuation coefficient, pg8 supplementary
% K_up=0.14; %units: 1/m, attenuation coefficient of background radiance for looking up, pg8 supplementary
% K_hor=0;  %units: 1/m, attenuation coefficint of background radiance for horizontal view, pg8 supplementary
% K_down=-0.14; %units: 1/m, attenuation coefficint of background radiance for looking down, pg8 supplementary

% a_air=a*10E-3;% units: 1/m, beam attenuation coefficient of background radiance for on land
% 
% Ispace_up=0.97*7.94e13; %units: photons/m^2ssr, radiance of space-light 
% %background in the direction of view at the depth of the eye for downw-welling radiance at 200m, pg7
% %supplementary
% Ispace_hor=0.97*6.46e11; %units: photons/m^2ssr, radiance of space-light 
% %background in the direction of view at the depth of the eye for horizontal radiance at 200m, pg7
% %supplementary
% Ispace_down=0.97*3.67e11; %units: photons/m^2ssr, radiance of space-light 
% %background in the direction of view at the depth of the eye for up-welling radiance at 200m, pg7
% %supplementary

% Ispace_daylight=0.97*4.17e20;%units: photons/m^2ssr, radiance of space-light background 
% Ispace_starlight=3.67e15;%units: photons/m^2ssr, radiance of space-light background 
% Ispace_moonlight=1.61e16;%units: photons/m^2ssr, radiance of space-light background
% 
% Iref_daylight= 0.97*2.5e19;%units: photons/m^2ssr, radiance of reflection
% Iref_starlight=7.78e14;%2.14e15;%units: photons/m^2ssr, radiance of reflection
% Iref_moonlight=3.52e15;%9.65e15;%units: photons/m^2ssr, radiance of reflection

% att_up=2.29; %units: dB/100m, attenuation with depth for down-welling radiance,
% %pg 8 of supplementary
% att_hor=2.34; %units: dB/100m, attenuation with depth for horizontal radiance,
% %pg 8 of supplementary
% att_down=2.33; %units: dB/100m, attenuation with depth for up-welling radiance,
% %pg 8 of supplementary

% SENSORY VOLUME PARAMS
% aerial and water half elevation angle of sensory volume
elevationCoastal=pi/3; %60 deg 

% azimuth is here assuming 35 degree overlap typical of fish;
% definitely underestimate for terrestrial case
azimuthCoastal=(2*120-35)*(pi/180); %viewing azimuth
azimuthAir = azimuthCoastal;

%For possible experimentation uncomment these lines
%HUMAN: 135 approx 70 deg overlap
%azimuthAir=135*(pi/180);  
%for binocular field

% for water case, we go from elevationMin to elevationMax; for
% aerial case we go elevationMin to elevationMaxAir
elevationMin=pi/2-elevationCoastal;
elevationMax=pi/2+elevationCoastal;
elevationMaxAir=pi/2;

azimuthMin=0;
azimuthMax=azimuthCoastal;
azimuthMaxAir=azimuthAir;

T=.1; % units: m, prey width

f = @(rho,phi,theta) rho.^2.*sin(phi); %volume equation in spherical coordinates

minpupil=0.001; % largest diameter of pupil, meters
maxpupil=0.03; % smallest diameter of pupil, meters

 Wlambdaylambda=csvread('../figXX_compviz/Wlambda.csv');

save('../fig06_aircomparison/Parameters')