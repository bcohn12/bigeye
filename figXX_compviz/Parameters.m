clear all; close all;

q=0.36; %units: n/a, detection efficien
eta=0.5; %Walzl et al 2007
qVals=[eta,q,q];

%All values from Middleton
LDaylight=1e3; % daylight luminosity in cd/m^2 
LMoonlight=1e-2; %Fairly brigh moonlight in cd/m^2
LStarlight=1e-4; %moonless clear night sky in cd/m^2
LVals=[LDaylight,LMoonlight,LStarlight];

Dt=1.16; %units: s, integration time, used typical value
Dt_daylight=(LDaylight)^-0.19; %Donner etal 1994
Dt_moonlight=(LMoonlight)^-0.19;
Dt_starlight=(LStarlight)^-0.19;
DtVals=[Dt_daylight, Dt_moonlight, Dt_starlight];

% Contrast parameters. Miller uses +/- 0.5, +/-1, and +/-2 as span 
C0_daylight=-1; %daylight contrast value
C0_moonlight=-1; %night contrast value, a guess (4 is snow). 
C0_starlight=-1; %starlight contrast value, a guess
C0All=[C0_daylight, C0_moonlight, C0_starlight];

k=0.035; % photoreceptor absorbtion, units 1/micrometers
len=57;  % length of photoreceptor, in micrometers

X=0.011; %units: photons/s, dark-noise rate/photoreceptor @16.5degrees Celsius
X_land=0.08; %units:photons/s, dark-noise rate/photoreceptor @23.5 degrees Celsius
XVals=[X_land,X,X];

R=1.96; %units: n/a, reliability coefficient for 95% confidence, used typical value
d=3e-6; %units: m, photoreceptor diameter, used typical value
M=2.55; %units: n/a, ratio of focal length and pupil radius (2f/A), set to Matthiessen's ratio
f_daylight=8.8; %focal_length/A for bright light
f_night=2.1; %focal_length/A for night
FVals=[f_daylight,f_night,f_night];

T=.1; % units: m, prey width
f = @(rho,phi,theta) rho.^2.*sin(phi); %volume equation in spherical coordinates

minpupil=0.001; % largest diameter of pupil, meters
maxpupil=0.03; % smallest diameter of pupil, meters

Wlambdaylambda=csvread('../figXX_compviz/Wlambda.csv');

%% DAYLIGHT
%Absorption Coefficient
a_Sun=xlsread('hydrolight/base_sun/Hydrolight_BrownWater.xlsx','a_Model');
a_Sun=a_Sun(2:end,3);
%Scattering Coefficient
b_Sun=xlsread('hydrolight/base_sun/Hydrolight_BrownWater.xlsx','b_Model');
b_Sun=b_Sun(2:end,3);
%Diffuse Spectral Attenuation Coeff
Ku_Sun=xlsread('hydrolight/base_sun/Hydrolight_BrownWater.xlsx','Ku');
Ku_Sun=Ku_Sun(4:end,3:end);

Kd_Sun=xlsread('hydrolight/base_sun/Hydrolight_BrownWater.xlsx','Kd');
Kd_Sun=Kd_Sun(4:end,3:end);

Kh_Sun=zeros(size(Kd_Sun,1),size(Kd_Sun,2));
%Spectral Radiance
%Upwelling, horizontal, downwelling radiance
Lu_Sun=xlsread('hydrolight/base_sun/Hydrolight_BrownWater.xlsx','Lu');
lambda=Lu_Sun(4:end,1);
Lu_Sun=Lu_Sun(4:end,4:end)*5.03e15;

Lh_Sun=xlsread('hydrolight/base_sun/Hydrolight_BrownWater.xlsx','Lh_2');
Lh_Sun=Lh_Sun(4:end,4:end)*5.03e15;

Ld_Sun=xlsread('hydrolight/base_sun/Hydrolight_BrownWater.xlsx','Ld');
Ld_Sun=Ld_Sun(4:end,4:end)*5.03e15;

%% MOONLIGHT
%Absorption Coefficient
a_Moonlight=xlsread('hydrolight/base_moon/Mbase_moon.xls','a');
a_Moonlight=a_Moonlight(4:end,3);
%Scattering Coefficient
b_Moonlight=xlsread('hydrolight/base_moon/Mbase_moon.xls','b');
b_Moonlight=b_Moonlight(4:end,3);
%Diffuse Spectral Attenuation Coeff
Ku_Moonlight=xlsread('hydrolight/base_moon/Mbase_moon.xls','Ku');
Ku_Moonlight=Ku_Moonlight(4:end,3:end);

Kd_Moonlight=xlsread('hydrolight/base_moon/Mbase_moon.xls','Kd');
Kd_Moonlight=Kd_Moonlight(4:end,3:end);

Kh_Moonlight=zeros(size(Kd_Moonlight,1),size(Kd_Moonlight,2));
%Spectral Radiance
%Upwelling, horizontal,downwelling radiance
Lu_Moonlight=xlsread('hydrolight/base_moon/Mbase_moon.xls','Lu');
Lu_Moonlight=Lu_Moonlight(4:end,4:end)*5.03e15;

Ld_Moonlight=xlsread('hydrolight/base_moon/Mbase_moon.xls','Ld');
Ld_Moonlight=Ld_Moonlight(4:end,4:end)*5.03e15;

Lh_Moonlight=xlsread('hydrolight/base_moon/Mbase_moon.xls','Lh_2');
Lh_Moonlight=Lh_Moonlight(4:end,4:end)*5.03e15;

%%STARLIGHT
%Absorption Coefficient
a_Starlight=xlsread('hydrolight/base_stars/Mbase_stars.xls','a');
a_Starlight=a_Starlight(4:end,3);
%Scattering Coefficient
b_Starlight=xlsread('hydrolight/base_stars/Mbase_stars.xls','b');
b_Starlight=b_Starlight(4:end,3);
%Diffuse Spectral Attenuation Coeff
Ku_Starlight=xlsread('hydrolight/base_stars/Mbase_stars.xls','Ku');
Ku_Starlight=Ku_Starlight(4:end,3:end);

Kd_Starlight=xlsread('hydrolight/base_stars/Mbase_stars.xls','Kd');
Kd_Starlight=Kd_Starlight(4:end,3:end);

Kh_Starlight=zeros(size(Kd_Starlight,1),size(Kd_Starlight,2));
%Spectral Radiance
%Upwelling,horizontal,downwellling radiance
Lu_Starlight=xlsread('hydrolight/base_stars/Mbase_stars.xls','Lu');
Lu_Starlight=Lu_Starlight(4:end,4:end)*5.03e15;

Ld_Starlight=xlsread('hydrolight/base_stars/Mbase_stars.xls','Ld');
Ld_Starlight=Ld_Starlight(4:end,4:end)*5.03e15;

Lh_Starlight=xlsread('hydrolight/base_stars/Mbase_stars.xls','Lh_2');
Lh_Starlight=Lh_Starlight(4:end,4:end)*5.03e15;

%% PHOTORECEPTOR ABSORPTION
A=1; a0A=800; a1A=3.1;
B=0.5; a0B=176; a1B=1.52;

[~, ind_Su]=max(Ld_Sun);
lambdaMax_Su=lambda(ind_Su(1));
[~,ind_M]=max(Ld_Moonlight);
lambdaMax_M=lambda(ind_M(1));
[~,ind_St]=max(Ld_Starlight);
lambdaMax_St=lambda(ind_St(1));

pAbsorb_Sun=A*exp(-a0A*(log10(lambda./lambdaMax_Su)).^2.*...
    (1+a1A*log10(lambda./lambdaMax_Su)+(3*a1A^2/8).*log10(lambda./lambdaMax_Su).^2)+...
    B*exp(-a0B*(log10(lambda./368)).^2.*...
    (1+a1B*log10(lambda./368)+(3*a1B^2/8)*log10(lambda./368))));

pAbsorb_Moonlight=A*exp(-a0A*(log10(lambda./lambdaMax_M)).^2.*...
    (1+a1A*log10(lambda./lambdaMax_M)+(3*a1A^2/8).*log10(lambda./lambdaMax_M).^2)+...
     B*exp(-a0B*(log10(lambda./368)).^2.*...
    (1+a1B*log10(lambda./368)+(3*a1B^2/8)*log10(lambda./368))));

pAbsorb_Starlight=A*exp(-a0A*(log10(lambda./lambdaMax_St)).^2.*...
    (1+a1A*log10(lambda./lambdaMax_St)+(3*a1A^2/8).*log10(lambda./lambdaMax_St).^2)+...
     B*exp(-a0B*(log10(lambda./368)).^2.*...
    (1+a1B*log10(lambda./368)+(3*a1B^2/8)*log10(lambda./368))));


%% SENSORY VOLUME PARAMS
% aerial and water half elevation angle of sensory volume
elevationCoastal=pi/3; %60 deg 

% azimuth is here assuming 35 degree overlap typical of fish;
% definitely underestimate for terrestrial case
azimuthCoastal=(2*120-35)*(pi/180); %viewing azimuth
azimuthAir = azimuthCoastal;

elevationMin=pi/2-elevationCoastal;
elevationMax=pi/2+elevationCoastal;
elevationMinAir=pi/2;
elevationMaxAir=pi/2+elevationCoastal;

azimuthMin=0;
azimuthMax=azimuthCoastal;
azimuthMaxAir=azimuthAir;