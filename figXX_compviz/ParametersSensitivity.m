clear all; close all;

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
%MOONLIGHT
a_Moonlight=xlsread('hydrolight/moonlight/Mmoonlight.xls','a');
a_Moonlight=a_Moonlight(4:end,2);
%BASELINE
a_Baseline=xlsread('hydrolight/baseline/Mbaseline.xls','a');
a_Baseline=a_Baseline(4:end,2);
%CLEAR
a_Clear=xlsread('hydrolight/clear/MClear.xls','a');
a_Clear=a_Clear(4:end,2);
%HIGH ABSORPTION
a_Highabs=xlsread('hydrolight/highabs/Mhighabs.xls','a');
a_Highabs=a_Highabs(4:end,2);
%HIGH SCATTERING
a_Highscat=xlsread('hydrolight/highscat/Mhighscat.xls','a');
a_Highscat=a_Highscat(4:end,2);
%% SCATTERING COEFFICIENT
%MOONLIGHT
b_Moonlight=xlsread('hydrolight/moonlight/Mmoonlight.xls','b');
b_Moonlight=b_Moonlight(4:end,2);
%BASELINE
b_Baseline=xlsread('hydrolight/baseline/Mbaseline.xls','b');
b_Baseline=b_Baseline(4:end,2);
%CLEAR
b_Clear=xlsread('hydrolight/clear/MClear.xls','b');
b_Clear=b_Clear(4:end,2);
%HIGH ABSORPTION
b_Highabs=xlsread('hydrolight/highabs/Mhighabs.xls','b');
b_Highabs=b_Highabs(4:end,2);
%HIGH SCATTERING
b_Highscat=xlsread('hydrolight/highscat/Mhighscat.xls','b');
b_Highscat=b_Highscat(4:end,2);
%% K-FUNCTION
%MOONLIGHT
Kd_Moonlight=xlsread('hydrolight/moonlight/Mmoonlight.xls','Kd');
Kd_Moonlight=Kd_Moonlight(4:43,3:17);

Ku_Moonlight=xlsread('hydrolight/moonlight/Mmoonlight.xls','Ku');
Ku_Moonlight=Ku_Moonlight(4:43,3:17);

Kh_Moonlight=zeros(size(Kd_Moonlight,1),size(Kd_Moonlight,2));
%BASELINE
Kd_Baseline=xlsread('hydrolight/baseline/MBaseline.xls','Kd');
Kd_Baseline=Kd_Baseline(4:43,3:17);

Ku_Baseline=xlsread('hydrolight/baseline/MBaseline.xls','Ku');
Ku_Baseline=Ku_Baseline(4:43,3:17);

Kh_Baseline=zeros(size(Kd_Baseline,1),size(Kd_Baseline,2));
%CLEAR
Kd_Clear=xlsread('hydrolight/clear/MClear.xls','Kd');
Kd_Clear=Kd_Clear(4:43,3:17);

Ku_Clear=xlsread('hydrolight/clear/MClear.xls','Ku');
Ku_Clear=Ku_Clear(4:43,3:17);

Kh_Clear=zeros(size(Kd_Clear,1),size(Kd_Clear,2));
%HIGH ABSORPTION
Kd_Highabs=xlsread('hydrolight/highabs/Mhighabs.xls','Kd');
Kd_Highabs=Kd_Highabs(4:43,3:17);

Ku_Highabs=xlsread('hydrolight/highabs/Mhighabs.xls','Ku');
Ku_Highabs=Ku_Highabs(4:43,3:17);

<<<<<<< .mine
Kh_Highabs=zeros(size(Kd_Highabs,1),size(Kd_Highabs,2));

=======
Kh_Highabs=zeros(size(Kd_Highabs,1),size(Kd_Highabs,2));
%HIGH SCATTERING
Kd_Highscat=xlsread('hydrolight/highscat/Mhighscat.xls','Kd');
Kd_Highscat=Kd_Highscat(4:43,3:17);

Ku_Highscat=xlsread('hydrolight/highscat/Mhighscat.xls','Ku');
Ku_Highscat=Ku_Highscat(4:43,3:17);

Kh_Highscat=zeros(size(Kd_Highscat,1),size(Kd_Highscat,2));
>>>>>>> .r8923
%% SPECTRAL RADIANCE
%MOONLIGHT
Ld_Moonlight=xlsread('hydrolight/moonlight/Mmoonlight.xls','Ld');
lambda=Ld_Moonlight(4:end,1);
Ld_Moonlight=Ld_Moonlight(4:end,4:end)*5.03e15;

Lu_Moonlight=xlsread('hydrolight/moonlight/Mmoonlight.xls','Lu');
Lu_Moonlight=Lu_Moonlight(4:end,4:end)*5.03e15;

Lh_Moonlight=xlsread('hydrolight/moonlight/Mmoonlight.xls','Lh_2');
Lh_Moonlight=Lh_Moonlight(4:end,4:end)*5.03e15;
%BASELINE
Ld_Baseline=xlsread('hydrolight/baseline/MBaseline.xls','Ld');
%lambda=Ld_Baseline(5:end,1);
Ld_Baseline=Ld_Baseline(4:end,4:end)*5.03e15;

Lu_Baseline=xlsread('hydrolight/baseline/MBaseline.xls','Lu');
Lu_Baseline=Lu_Baseline(4:end,4:end)*5.03e15;

Lh_Baseline=xlsread('hydrolight/baseline/MBaseline.xls','Lh_2');
Lh_Baseline=Lh_Baseline(4:end,4:end)*5.03e15;
%CLEAR
Ld_Clear=xlsread('hydrolight/clear/MClear.xls','Ld');
Ld_Clear=Ld_Clear(4:end,4:end)*5.03e15;

Lu_Clear=xlsread('hydrolight/clear/MClear.xls','Lu');
Lu_Clear=Lu_Clear(4:end,4:end)*5.03e15;

Lh_Clear=xlsread('hydrolight/clear/MClear.xls','Lh_2');
Lh_Clear=Lh_Clear(4:end,4:end)*5.03e15;
<<<<<<< .mine
%HIGH ABSORPTION
=======
%HIGH ABSORPTION
Ld_Highabs=xlsread('hydrolight/highabs/Mhighabs.xls','Ld');
Ld_Highabs=Ld_Highabs(4:end,4:end);
>>>>>>> .r8923

<<<<<<< .mine


=======
Lu_Highabs=xlsread('hydrolight/highabs/Mhighabs.xls','Lu');
Lu_Highabs=Lu_Highabs(4:end,4:end);

Lh_Highabs=xlsread('hydrolight/highabs/Mhighabs.xls','Lh_2');
Lh_Highabs=Lh_Highabs(4:end,4:end);
%HIGH SCATTERING
Ld_Highscat=xlsread('hydrolight/highscat/Mhighscat.xls','Ld');
Ld_Highscat=Ld_Highscat(4:end,4:end);

Lu_Highscat=xlsread('hydrolight/highscat/Mhighscat.xls','Lu');
Lu_Highscat=Lu_Highscat(4:end,4:end);

Lh_Highscat=xlsread('hydrolight/highscat/Mhighscat.xls','Lh_2');
Lh_Highscat=Lh_Highscat(4:end,4:end);

>>>>>>> .r8923
%% PHOTORECEPTOR ABSORPTION
A=1; a0A=800; a1A=3.1;
B=0.5; a0B=176; a1B=1.52;

[~,ind_M]=max(Ld_Moonlight);
lambdaMax_M=lambda(ind_M(1));
[~,ind_B]=max(Ld_Baseline);
lambdaMax_B=lambda(ind_B(1));
[~,ind_C]=max(Ld_Clear);
lambdaMax_C=lambda(ind_C(1));
[~,ind_HA]=max(Ld_Highabs);
lambdaMax_HA=lambda(ind_HA(1));
[~,ind_HS]=max(Ld_Highscat);
lambdaMax_HS=lambda(ind_HS(1));

pAbsorb_Moonlight=A*exp(-a0A*(log10(lambda./lambdaMax_M)).^2.*...
    (1+a1A*log10(lambda./lambdaMax_M)+(3*a1A^2/8).*log10(lambda./lambdaMax_M).^2)+...
    B*exp(-a0B*(log10(lambda./368)).^2.*...
    (1+a1B*log10(lambda./368)+(3*a1B^2/8)*log10(lambda./368))));

pAbsorb_Baseline=A*exp(-a0A*(log10(lambda./lambdaMax_B)).^2.*...
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
