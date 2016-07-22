clear all; close all;

q=0.36; %units: n/a, detection efficien
eta=0.5; %Walzl et al 2007
qVals=[eta,q,q];

%All values from Middleton
LDaylight=1e3; % daylight luminosity in cd/m^2 
LMoonlight=1e-2; %Fairly brigh moonlight in cd/m^2
LStarlight=1e-4; %moonless clear night sky in cd/m^2
LVals=[LDaylight,LMoonlight,LStarlight];

Dt=1.16;
% River_daylight=(8.44e-1)^-0.19; %units: s, integration time, used typical value
% DtRiver_moonlight=(2.57e-6)^-0.11;
% DtRiver_starlight=(4.39e-8)^-0.11;
Dt_daylight=(LDaylight)^-0.19; %Donner etal 1994
Dt_moonlight=(LMoonlight)^-0.19;
Dt_starlight=(LStarlight)^-0.19;
DtVals=[Dt_daylight, Dt_moonlight, Dt_starlight];
%DtVals_River=[DtRiver_daylight, DtRiver_moonlight,DtRiver_starlight];

% Contrast parameters. Miller uses +/- 0.5, +/-1, and +/-2 as span 
C0_daylight=-1; %daylight contrast value
C0_moonlight=-1; %night contrast value, a guess (4 is snow). 
C0_starlight=-1; %starlight contrast value, a guess
C0All=[C0_daylight, C0_moonlight, C0_starlight];

C0_Sun=-1; C0_Moonlight=-1; C0_Starlight=-1;

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
ybarLambda=[0.0000 0.0001 0.0004 0.0012 0.0040 0.0116 0.02300 .0380 0.0600 0.0910,...
    0.1390 0.2080 0.3230 0.5030 0.7100 0.8620 0.9540 0.9950 0.9950 0.9520,...
    0.8700 0.7570 0.6310 0.5030 0.3810 0.2650 0.1750 0.1070 0.0610 0.0320 0.0170 0.0082,...
    0.0041 0.0021 0.0011 0.0005 0.0003 0.0001 0.0001 0.0000];
lambdabar=380:10:770;
ybarInterp=@(l) interp1(lambdabar,ybarLambda,l,'pchip');
fL=@(x) x;



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
%Luminance
ybar_Daylight=ybarInterp(lambda);

Bu_Sun=zeros(size(Lu_Sun,2),1);
Bh_Sun=zeros(size(Lh_Sun,2),1);
Bd_Sun=zeros(size(Ld_Sun,2),1);
for i=1:size(Lu_Sun,2)
    tempU=(Lu_Sun(:,i)/5.03e15).*ybar_Daylight.*lambda;
    Bu_Sun(i)=trapz(lambda,tempU);
    %tempInterpFuncU= @(l) interp1(lambda,683*tempU,l,'pchip');
    %Bu_Sun(i)=integral(tempInterpFuncU,lambda(1),lambda(end));
    
    tempH=(Lh_Sun(:,i)/5.03e15).*ybar_Daylight.*lambda;
    Bh_Sun(i)=trapz(tempH);
    %tempInterpFuncH= @(l) interp1(lambda,683*tempH,l,'pchip');
    %Bh_Sun(i)=integral(tempInterpFuncH,lambda(1),lambda(2));
    
    tempD=(Ld_Sun(:,i)/5.03e15).*ybar_Daylight.*lambda;
    Bd_Sun(i)=trapz(tempD);
    %tempInterpFuncD= @(l) interp1(lambda,683*tempD,l,'pchip');
    %Bd_Sun(i)=integral(tempInterpFuncD,lambda(1),lambda(end));
end

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
%Luminance
ybar_Moonlight=ybarInterp(lambda);

Bu_Moonlight=zeros(size(Lu_Moonlight,2),1);
Bh_Moonlight=zeros(size(Lh_Moonlight,2),1);
Bd_Moonlight=zeros(size(Ld_Moonlight,2),1);
for i=1:size(Lu_Moonlight,2)
    tempU=(Lu_Moonlight(:,i)/5.03e15).*ybar_Moonlight.*lambda;
    Bu_Moonlight(i)=trapz(lambda,tempU);
    %tempInterpFuncU= @(l) interp1(lambda,683*tempU,l,'pchip');
    %Bu_Moonlight(i)=integral(tempInterpFuncU,lambda(1),lambda(end));
    
    tempH=(Lh_Moonlight(:,i)/5.03e15).*ybar_Moonlight.*lambda;
    Bh_Moonlight(i)=trapz(lambda,tempH);
    %tempInterpFuncH= @(l) interp1(lambda,683*tempH,l,'pchip');
    %Bh_Moonlight(i)=integral(tempInterpFuncH,lambda(1),lambda(end));
    
    tempD=(Ld_Moonlight(:,i)/5.03e15).*ybar_Moonlight.*lambda;
    Bd_Moonlight(i)=trapz(lambda,tempD);
    %tempInterpFuncD= @(l) interp1(lambda,683*tempD,l,'pchip');
    %Bd_Moonlight(i)=integral(tempInterpFuncD,lambda(1),lambda(end));
end

%% STARLIGHT
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
%Luminance
ybar_Starlight=ybarInterp(lambda);

Bu_Starlight=zeros(size(Lu_Starlight,2),1);
Bh_Starlight=zeros(size(Lh_Starlight,2),1);
Bd_Starlight=zeros(size(Ld_Starlight,2),1);
for i=1:size(Lu_Starlight,2)
    tempU=(Lu_Starlight(:,i)/5.03e15).*ybar_Starlight.*lambda;
    Bu_Starlight(i)=trapz(lambda,tempU);
    %tempInterpFuncU= @(l) interp1(lambda,683*tempU,l,'pchip');
    %Bu_Starlight(i)=integral(tempInterpFuncU,lambda(1),lambda(end));
    
    tempH=(Lh_Starlight(:,i)/5.03e15).*ybar_Starlight.*lambda;
    Bh_Starlight(i)=trapz(lambda,tempH);
    %tempInterpFuncH= @(l) interp1(lambda,683*tempH,l,'pchip');
    %Bh_Starlight(i)=integral(tempInterpFuncH,lambda(1),lambda(end));
    
    tempD=(Ld_Starlight(:,i)/5.03e15).*ybar_Starlight.*lambda;
    Bd_Starlight(i)=trapz(lambda,tempD);
    %tempInterpFuncD= @(l) interp1(lambda,683*tempD,l,'pchip');
    %Bd_Starlight(i)=integral(tempInterpFuncD,lambda(1),lambda(end));
end

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
elevationCoastal=pi/6; %30 deg 

% azimuth is here assuming 35 degree overlap typical of fish;
% definitely underestimate for terrestrial case
%azimuthCoastal=(2*120-35)*(pi/180); %viewing azimuth
azimuthCoastal=(305)*(pi/180);
azimuthAir = azimuthCoastal;

elevationMin=pi/2-elevationCoastal;
elevationMax=pi/2+elevationCoastal;
elevationMinAir=pi/2;
elevationMaxAir=pi/2+elevationCoastal;

azimuthMin=0;
azimuthMax=azimuthCoastal;
azimuthMaxAir=azimuthAir;