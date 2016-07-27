close all;

q=0.36; %units: n/a, detection efficien
eta=0.5; %Walzl et al 2007
Dt=1.16; %units: s, integration time, used typical value
k=0.035; % photoreceptor absorbtion, units 1/micrometers
len=57;  % length of photoreceptor, in micrometers
X=0.011; %units: photons/s, dark-noise rate/photoreceptor @16.5degrees Celsius
R=1.96; %units: n/a, reliability coefficient for 95% confidence, used typical value
d=3e-6; %units: m, photoreceptor diameter, used typical value
M=2.55; %units: n/a, ratio of focal length and pupil radius (2f/A), set to Matthiessen's ratio
T=.1; % units: m, prey width

minpupil=0.001; % largest diameter of pupil, meters
maxpupil=0.03; % smallest diameter of pupil, meters
%% BEAM ATTENUATION COEFFICIENT
%HighTurbidity
a_HighTurbidity=xlsread('hydrolight/HighTurbidity/MHighTurbidity.xls','a');
a_HighTurbidity=a_HighTurbidity(4:end,2);
%CLEAR
a_Clear=xlsread('hydrolight/Clear/MClear.xls','a');
a_Clear=a_Clear(4:end,2);
%HIGH ABSORPTION
a_Highabs=xlsread('hydrolight/AbsDom/MAbsDom.xls','a');
a_Highabs=a_Highabs(4:end,2);
%HIGH SCATTERING
a_Highscat=xlsread('hydrolight/ScatDom/MScatDom.xls','a');
a_Highscat=a_Highscat(4:end,2);
%% SCATTERING COEFFICIENT
%MOONLIGHT
%b_Moonlight=xlsread('hydrolight/moonlight/Mmoonlight.xls','b');
%b_Moonlight=b_Moonlight(4:end,2);
%HighTurbidity
b_HighTurbidity=xlsread('hydrolight/HighTurbidity/MHighTurbidity.xls','b');
b_HighTurbidity=b_HighTurbidity(4:end,2);
%CLEAR
b_Clear=xlsread('hydrolight/Clear/MClear.xls','b');
b_Clear=b_Clear(4:end,2);
%HIGH ABSORPTION
b_Highabs=xlsread('hydrolight/AbsDom/MAbsDom.xls','b');
b_Highabs=b_Highabs(4:end,2);
%HIGH SCATTERING
b_Highscat=xlsread('hydrolight/ScatDom/MScatDom.xls','b');
b_Highscat=b_Highscat(4:end,2);
%% K-FUNCTION
%HighTurbidity
Kd_HighTurbidity=xlsread('hydrolight/HighTurbidity/MHighTurbidity.xls','Kd');
Kd_HighTurbidity=Kd_HighTurbidity(4:43,3:17);

Ku_HighTurbidity=xlsread('hydrolight/HighTurbidity/MHighTurbidity.xls','Ku');
Ku_HighTurbidity=Ku_HighTurbidity(4:43,3:17);

Kh_HighTurbidity=zeros(size(Kd_HighTurbidity,1),size(Kd_HighTurbidity,2));
%CLEAR
Kd_Clear=xlsread('hydrolight/Clear/MClear.xls','Kd');
Kd_Clear=Kd_Clear(4:43,3:17);

Ku_Clear=xlsread('hydrolight/Clear/MClear.xls','Ku');
Ku_Clear=Ku_Clear(4:43,3:17);

Kh_Clear=zeros(size(Kd_Clear,1),size(Kd_Clear,2));
%HIGH ABSORPTION
Kd_Highabs=xlsread('hydrolight/AbsDom/MAbsDom.xls','Kd');
Kd_Highabs=Kd_Highabs(4:43,3:17);

Ku_Highabs=xlsread('hydrolight/AbsDom/MAbsDom.xls','Ku');
Ku_Highabs=Ku_Highabs(4:43,3:17);

Kh_Highabs=zeros(size(Kd_Highabs,1),size(Kd_Highabs,2));
%HIGH SCATTERING
Kd_Highscat=xlsread('hydrolight/ScatDom/MScatDom.xls','Kd');
Kd_Highscat=Kd_Highscat(4:43,3:17);

Ku_Highscat=xlsread('hydrolight/ScatDom/MScatDom.xls','Ku');
Ku_Highscat=Ku_Highscat(4:43,3:17);

Kh_Highscat=zeros(size(Kd_Highscat,1),size(Kd_Highscat,2));

%% SPECTRAL RADIANCE
%MOONLIGHT
%Ld_Moonlight=xlsread('hydrolight/moonlight/Mmoonlight.xls','Ld');
%lambda=Ld_Moonlight(4:end,1);
%Ld_Moonlight=Ld_Moonlight(4:end,4:end)*5.03e15;

%Lu_Moonlight=xlsread('hydrolight/moonlight/Mmoonlight.xls','Lu');
%Lu_Moonlight=Lu_Moonlight(4:end,4:end)*5.03e15;

%Lh_Moonlight=xlsread('hydrolight/moonlight/Mmoonlight.xls','Lh_2');
%Lh_Moonlight=Lh_Moonlight(4:end,4:end)*5.03e15;
%HighTurbidity
Ld_HighTurbidity=xlsread('hydrolight/HighTurbidity/MHighTurbidity.xls','Ld');
lambda=Ld_HighTurbidity(4:end,1);
Ld_HighTurbidity=Ld_HighTurbidity(4:end,4:end)*5.03e15;

Lu_HighTurbidity=xlsread('hydrolight/HighTurbidity/MHighTurbidity.xls','Lu');
Lu_HighTurbidity=Lu_HighTurbidity(4:end,4:end)*5.03e15;

Lh_HighTurbidity=xlsread('hydrolight/HighTurbidity/MHighTurbidity.xls','Lh_2');
Lh_HighTurbidity=Lh_HighTurbidity(4:end,4:end)*5.03e15;
%CLEAR
Ld_Clear=xlsread('hydrolight/Clear/MClear.xls','Ld');
Ld_Clear=Ld_Clear(4:end,4:end)*5.03e15;

Lu_Clear=xlsread('hydrolight/Clear/MClear.xls','Lu');
Lu_Clear=Lu_Clear(4:end,4:end)*5.03e15;

Lh_Clear=xlsread('hydrolight/Clear/MClear.xls','Lh_2');
Lh_Clear=Lh_Clear(4:end,4:end)*5.03e15;
%HIGH ABSORPTION
Ld_Highabs=xlsread('hydrolight/AbsDom/MAbsDom.xls','Ld');
Ld_Highabs=Ld_Highabs(4:end,4:end)*5.03e15;

Lu_Highabs=xlsread('hydrolight/AbsDom/MAbsDom.xls','Lu');
Lu_Highabs=Lu_Highabs(4:end,4:end)*5.03e15;

Lh_Highabs=xlsread('hydrolight/AbsDom/MAbsDom.xls','Lh_2');
Lh_Highabs=Lh_Highabs(4:end,4:end)*5.03e15;
%HIGH SCATTERING
Ld_Highscat=xlsread('hydrolight/ScatDom/MScatDom.xls','Ld');
Ld_Highscat=Ld_Highscat(4:end,4:end)*5.03e15;

Lu_Highscat=xlsread('hydrolight/ScatDom/MScatDom.xls','Lu');
Lu_Highscat=Lu_Highscat(4:end,4:end)*5.03e15;

Lh_Highscat=xlsread('hydrolight/ScatDom/MScatDom.xls','Lh_2');
Lh_Highscat=Lh_Highscat(4:end,4:end)*5.03e15;

%% PHOTORECEPTOR ABSORPTION
A=1; a0A=800; a1A=3.1;
B=0.5; a0B=176; a1B=1.52;

%[~,ind_M]=max(Ld_Moonlight);
%lambdaMax_M=lambda(ind_M(1));
[~,ind_B]=max(Ld_HighTurbidity);
lambdaMax_B=lambda(ind_B(1));
[~,ind_C]=max(Ld_Clear);
lambdaMax_C=lambda(ind_C(1));
[~,ind_HA]=max(Ld_Highabs);
lambdaMax_HA=lambda(ind_HA(1));
[~,ind_HS]=max(Ld_Highscat);
lambdaMax_HS=lambda(ind_HS(1));

%pAbsorb_Moonlight=A*exp(-a0A*(log10(lambda./lambdaMax_M)).^2.*...
%    (1+a1A*log10(lambda./lambdaMax_M)+(3*a1A^2/8).*log10(lambda./lambdaMax_M).^2)+...
%    B*exp(-a0B*(log10(lambda./368)).^2.*...
%    (1+a1B*log10(lambda./368)+(3*a1B^2/8)*log10(lambda./368))));

pAbsorb_HighTurbidity=A*exp(-a0A*(log10(lambda./lambdaMax_B)).^2.*...
    (1+a1A*log10(lambda./lambdaMax_B)+(3*a1A^2/8).*log10(lambda./lambdaMax_B).^2)+...
    B*exp(-a0B*(log10(lambda./368)).^2.*...
    (1+a1B*log10(lambda./368)+(3*a1B^2/8)*log10(lambda./368))));

pAbsorb_Clear=A*exp(-a0A*(log10(lambda./lambdaMax_C)).^2.*...
    (1+a1A*log10(lambda./lambdaMax_C)+(3*a1A^2/8).*log10(lambda./lambdaMax_C).^2)+...
    B*exp(-a0B*(log10(lambda./368)).^2.*...
    (1+a1B*log10(lambda./368)+(3*a1B^2/8)*log10(lambda./368))));

pAbsorb_Highabs=A*exp(-a0A*(log10(lambda./lambdaMax_HA)).^2.*...
    (1+a1A*log10(lambda./lambdaMax_HA)+(3*a1A^2/8).*log10(lambda./lambdaMax_HA).^2)+...
    B*exp(-a0B*(log10(lambda./368)).^2.*...
    (1+a1B*log10(lambda./368)+(3*a1B^2/8)*log10(lambda./368))));
pAbsorb_Highabs(1:6)=1e-300;

pAbsorb_Highscat=A*exp(-a0A*(log10(lambda./lambdaMax_HS)).^2.*...
    (1+a1A*log10(lambda./lambdaMax_HS)+(3*a1A^2/8).*log10(lambda./lambdaMax_HS).^2)+...
    B*exp(-a0B*(log10(lambda./368)).^2.*...
    (1+a1B*log10(lambda./368)+(3*a1B^2/8)*log10(lambda./368))));


%% SENSORY VOLUME PARAMS

elevationCoastal=pi/3; %60 deg 

elevationMin=pi/2-elevationCoastal;
elevationMax=pi/2+elevationCoastal;
azimuthMin=0;
azimuthCoastal=(2*120-35)*(pi/180); %viewing azimuth
azimuthMax=azimuthCoastal;

f = @(rho,phi,theta) rho.^2.*sin(phi); %volume equation in spherical coordinates
