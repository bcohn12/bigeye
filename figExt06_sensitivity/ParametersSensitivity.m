function ParametersSensitivity
global BIGEYEROOT
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
    %% SENSORY VOLUME PARAMS

    elevationCoastal=pi/3; %60 deg 

    elevationMin=pi/2-elevationCoastal;
    elevationMax=pi/2+elevationCoastal;
    azimuthMin=0;
    azimuthCoastal=(2*120-35)*(pi/180); %viewing azimuth
    azimuthMax=azimuthCoastal;

    f = @(rho,phi,theta) rho.^2.*sin(phi); %volume equation in spherical coordinates

    %% BEAM ATTENUATION COEFFICIENT
    %HighTurbidity
    a_HighTurbidity=xlsread('hydrolight/HighTurbidity/MHighTurbidity.xls','a');
    a_HighTurbidity=a_HighTurbidity(:,1);
    %CLEAR
    a_Clear=xlsread('hydrolight/Clear/MClear.xls','a');
    a_Clear=a_Clear(:,1);
    %HIGH ABSORPTION
    a_AbsDom=xlsread('hydrolight/AbsDom/MAbsDom.xls','a');
    a_AbsDom=a_AbsDom(:,1);
    %HIGH SCATTERING
    a_ScatDom=xlsread('hydrolight/ScatDom/MScatDom.xls','a');
    a_ScatDom=a_ScatDom(:,1);
    %% SCATTERING COEFFICIENT
    %HIGH TURBIDITY
    b_HighTurbidity=xlsread('hydrolight/HighTurbidity/MHighTurbidity.xls','b');
    b_HighTurbidity=b_HighTurbidity(:,1);
    %CLEAR
    b_Clear=xlsread('hydrolight/Clear/MClear.xls','b');
    b_Clear=b_Clear(:,1);
    %HIGH ABSORPTION
    b_AbsDom=xlsread('hydrolight/AbsDom/MAbsDom.xls','b');
    b_AbsDom=b_AbsDom(:,1);
    %HIGH SCATTERING
    b_ScatDom=xlsread('hydrolight/ScatDom/MScatDom.xls','b');
    b_ScatDom=b_ScatDom(:,1);
    %% K-FUNCTION
    %HIGH TURBIDITY
    Kd_HighTurbidity=xlsread('hydrolight/HighTurbidity/MHighTurbidity.xls','Kd');
    Kd_HighTurbidity=Kd_HighTurbidity(:,:);

    Ku_HighTurbidity=xlsread('hydrolight/HighTurbidity/MHighTurbidity.xls','Ku');
    Ku_HighTurbidity=Ku_HighTurbidity(:,:);

    Kh_HighTurbidity=zeros(size(Kd_HighTurbidity,1),size(Kd_HighTurbidity,2));
    %CLEAR
    Kd_Clear=xlsread('hydrolight/Clear/MClear.xls','Kd');
    Kd_Clear=Kd_Clear(:,:);

    Ku_Clear=xlsread('hydrolight/Clear/MClear.xls','Ku');
    Ku_Clear=Ku_Clear(:,:);

    Kh_Clear=zeros(size(Kd_Clear,1),size(Kd_Clear,2));
    %HIGH ABSORPTION
    Kd_AbsDom=xlsread('hydrolight/AbsDom/MAbsDom.xls','Kd');
    Kd_AbsDom=Kd_AbsDom(:,:);

    Ku_AbsDom=xlsread('hydrolight/AbsDom/MAbsDom.xls','Ku');
    Ku_AbsDom=Ku_AbsDom(:,:);

    Kh_AbsDom=zeros(size(Kd_AbsDom,1),size(Kd_AbsDom,2));
    %HIGH SCATTERING
    Kd_ScatDom=xlsread('hydrolight/ScatDom/MScatDom.xls','Kd');
    Kd_ScatDom=Kd_ScatDom(:,:);

    Ku_ScatDom=xlsread('hydrolight/ScatDom/MScatDom.xls','Ku');
    Ku_ScatDom=Ku_ScatDom(:,:);

    Kh_ScatDom=zeros(size(Kd_ScatDom,1),size(Kd_ScatDom,2));

    %% SPECTRAL RADIANCE
    lambda=(355:10:745)';
    %High TURBIDITY
    Ld_HighTurbidity=xlsread('hydrolight/HighTurbidity/MHighTurbidity.xls','Ld');
    Ld_HighTurbidity=Ld_HighTurbidity(:,:)*5.03e15;

    Lu_HighTurbidity=xlsread('hydrolight/HighTurbidity/MHighTurbidity.xls','Lu');
    Lu_HighTurbidity=Lu_HighTurbidity(:,:)*5.03e15;

    Lh_HighTurbidity=xlsread('hydrolight/HighTurbidity/MHighTurbidity.xls','Lh_2');
    Lh_HighTurbidity=Lh_HighTurbidity(:,:)*5.03e15;
    %CLEAR
    Ld_Clear=xlsread('hydrolight/Clear/MClear.xls','Ld');
    Ld_Clear=Ld_Clear(:,:)*5.03e15;

    Lu_Clear=xlsread('hydrolight/Clear/MClear.xls','Lu');
    Lu_Clear=Lu_Clear(:,:)*5.03e15;

    Lh_Clear=xlsread('hydrolight/Clear/MClear.xls','Lh_2');
    Lh_Clear=Lh_Clear(:,:)*5.03e15;
    %HIGH ABSORPTION
    Ld_AbsDom=xlsread('hydrolight/AbsDom/MAbsDom.xls','Ld');
    Ld_AbsDom=Ld_AbsDom(:,:)*5.03e15;

    Lu_AbsDom=xlsread('hydrolight/AbsDom/MAbsDom.xls','Lu');
    Lu_AbsDom=Lu_AbsDom(:,:)*5.03e15;

    Lh_AbsDom=xlsread('hydrolight/AbsDom/MAbsDom.xls','Lh_2');
    Lh_AbsDom=Lh_AbsDom(:,:)*5.03e15;
    %HIGH SCATTERING
    Ld_ScatDom=xlsread('hydrolight/ScatDom/MScatDom.xls','Ld');
    Ld_ScatDom=Ld_ScatDom(:,:)*5.03e15;

    Lu_ScatDom=xlsread('hydrolight/ScatDom/MScatDom.xls','Lu');
    Lu_ScatDom=Lu_ScatDom(:,:)*5.03e15;

    Lh_ScatDom=xlsread('hydrolight/ScatDom/MScatDom.xls','Lh_2');
    Lh_ScatDom=Lh_ScatDom(:,:)*5.03e15;

    %% PHOTORECEPTOR ABSORPTION
    A=1; a0A=800; a1A=3.1;
    B=0.5; a0B=176; a1B=1.52;

    [~,ind_B]=max(Ld_HighTurbidity);
    lambdaMax_B=lambda(ind_B(1));
    [~,ind_C]=max(Ld_Clear);
    lambdaMax_C=lambda(ind_C(1));
    [~,ind_HA]=max(Ld_AbsDom);
    lambdaMax_HA=lambda(ind_HA(1));
    [~,ind_HS]=max(Ld_ScatDom);
    lambdaMax_HS=lambda(ind_HS(1));

    pAbsorb_HighTurbidity=A*exp(-a0A*(log10(lambda./lambdaMax_B)).^2.*...
        (1+a1A*log10(lambda./lambdaMax_B)+(3*a1A^2/8).*log10(lambda./lambdaMax_B).^2)+...
        B*exp(-a0B*(log10(lambda./368)).^2.*...
        (1+a1B*log10(lambda./368)+(3*a1B^2/8)*log10(lambda./368))));

    pAbsorb_Clear=A*exp(-a0A*(log10(lambda./lambdaMax_C)).^2.*...
        (1+a1A*log10(lambda./lambdaMax_C)+(3*a1A^2/8).*log10(lambda./lambdaMax_C).^2)+...
        B*exp(-a0B*(log10(lambda./368)).^2.*...
        (1+a1B*log10(lambda./368)+(3*a1B^2/8)*log10(lambda./368))));

    pAbsorb_AbsDom=A*exp(-a0A*(log10(lambda./lambdaMax_HA)).^2.*...
        (1+a1A*log10(lambda./lambdaMax_HA)+(3*a1A^2/8).*log10(lambda./lambdaMax_HA).^2)+...
        B*exp(-a0B*(log10(lambda./368)).^2.*...
        (1+a1B*log10(lambda./368)+(3*a1B^2/8)*log10(lambda./368))));
    pAbsorb_AbsDom(1:6)=1e-300;

    pAbsorb_ScatDom=A*exp(-a0A*(log10(lambda./lambdaMax_HS)).^2.*...
        (1+a1A*log10(lambda./lambdaMax_HS)+(3*a1A^2/8).*log10(lambda./lambdaMax_HS).^2)+...
        B*exp(-a0B*(log10(lambda./368)).^2.*...
        (1+a1B*log10(lambda./368)+(3*a1B^2/8)*log10(lambda./368))));
    
save([BIGEYEROOT 'figEXT06_sensitivity/ParametersSensitivity.mat'])