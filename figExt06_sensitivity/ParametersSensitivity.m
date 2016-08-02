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
    a.HighTurbidity=xlsread('hydrolight/HighTurbidity/MHighTurbidity.xls','a');
    a.HighTurbidity=a.HighTurbidity(:,1);
    %CLEAR
    a.Clear=xlsread('hydrolight/Clear/MClear.xls','a');
    a.Clear=a.Clear(:,1);
    %HIGH ABSORPTION
    a.AbsDom=xlsread('hydrolight/AbsDom/MAbsDom.xls','a');
    a.AbsDom=a.AbsDom(:,1);
    %HIGH SCATTERING
    a.ScatDom=xlsread('hydrolight/ScatDom/MScatDom.xls','a');
    a.ScatDom=a.ScatDom(:,1);
    %% SCATTERING COEFFICIENT
    %HIGH TURBIDITY
    b.HighTurbidity=xlsread('hydrolight/HighTurbidity/MHighTurbidity.xls','b');
    b.HighTurbidity=b.HighTurbidity(:,1);
    %CLEAR
    b.Clear=xlsread('hydrolight/Clear/MClear.xls','b');
    b.Clear=b.Clear(:,1);
    %HIGH ABSORPTION
    b.AbsDom=xlsread('hydrolight/AbsDom/MAbsDom.xls','b');
    b.AbsDom=b.AbsDom(:,1);
    %HIGH SCATTERING
    b.ScatDom=xlsread('hydrolight/ScatDom/MScatDom.xls','b');
    b.ScatDom=b.ScatDom(:,1);
    %% K-FUNCTION
    %HIGH TURBIDITY
    Kd.HighTurbidity=xlsread('hydrolight/HighTurbidity/MHighTurbidity.xls','Kd');
    Kd.HighTurbidity=Kd.HighTurbidity(:,:);

    Ku.HighTurbidity=xlsread('hydrolight/HighTurbidity/MHighTurbidity.xls','Ku');
    Ku.HighTurbidity=Ku.HighTurbidity(:,:);

    Kh.HighTurbidity=zeros(size(Kd.HighTurbidity,1),size(Kd.HighTurbidity,2));
    %CLEAR
    Kd.Clear=xlsread('hydrolight/Clear/MClear.xls','Kd');
    Kd.Clear=Kd.Clear(:,:);

    Ku.Clear=xlsread('hydrolight/Clear/MClear.xls','Ku');
    Ku.Clear=Ku.Clear(:,:);

    Kh.Clear=zeros(size(Kd.Clear,1),size(Kd.Clear,2));
    %HIGH ABSORPTION
    Kd.AbsDom=xlsread('hydrolight/AbsDom/MAbsDom.xls','Kd');
    Kd.AbsDom=Kd.AbsDom(:,:);

    Ku.AbsDom=xlsread('hydrolight/AbsDom/MAbsDom.xls','Ku');
    Ku.AbsDom=Ku.AbsDom(:,:);

    Kh.AbsDom=zeros(size(Kd.AbsDom,1),size(Kd.AbsDom,2));
    %HIGH SCATTERING
    Kd.ScatDom=xlsread('hydrolight/ScatDom/MScatDom.xls','Kd');
    Kd.ScatDom=Kd.ScatDom(:,:);

    Ku.ScatDom=xlsread('hydrolight/ScatDom/MScatDom.xls','Ku');
    Ku.ScatDom=Ku.ScatDom(:,:);

    Kh.ScatDom=zeros(size(Kd.ScatDom,1),size(Kd.ScatDom,2));

    %% SPECTRAL RADIANCE
    lambda=(355:10:745)';
    %High TURBIDITY
    Ld.HighTurbidity=xlsread('hydrolight/HighTurbidity/MHighTurbidity.xls','Ld');
    Ld.HighTurbidity=Ld.HighTurbidity(:,:)*5.03e15;

    Lu.HighTurbidity=xlsread('hydrolight/HighTurbidity/MHighTurbidity.xls','Lu');
    Lu.HighTurbidity=Lu.HighTurbidity(:,:)*5.03e15;

    Lh.HighTurbidity=xlsread('hydrolight/HighTurbidity/MHighTurbidity.xls','Lh_2');
    Lh.HighTurbidity=Lh.HighTurbidity(:,:)*5.03e15;
    %CLEAR
    Ld.Clear=xlsread('hydrolight/Clear/MClear.xls','Ld');
    Ld.Clear=Ld.Clear(:,:)*5.03e15;

    Lu.Clear=xlsread('hydrolight/Clear/MClear.xls','Lu');
    Lu.Clear=Lu.Clear(:,:)*5.03e15;

    Lh.Clear=xlsread('hydrolight/Clear/MClear.xls','Lh_2');
    Lh.Clear=Lh.Clear(:,:)*5.03e15;
    %HIGH ABSORPTION
    Ld.AbsDom=xlsread('hydrolight/AbsDom/MAbsDom.xls','Ld');
    Ld.AbsDom=Ld.AbsDom(:,:)*5.03e15;

    Lu.AbsDom=xlsread('hydrolight/AbsDom/MAbsDom.xls','Lu');
    Lu.AbsDom=Lu.AbsDom(:,:)*5.03e15;

    Lh.AbsDom=xlsread('hydrolight/AbsDom/MAbsDom.xls','Lh_2');
    Lh.AbsDom=Lh.AbsDom(:,:)*5.03e15;
    %HIGH SCATTERING
    Ld.ScatDom=xlsread('hydrolight/ScatDom/MScatDom.xls','Ld');
    Ld.ScatDom=Ld.ScatDom(:,:)*5.03e15;

    Lu.ScatDom=xlsread('hydrolight/ScatDom/MScatDom.xls','Lu');
    Lu.ScatDom=Lu.ScatDom(:,:)*5.03e15;

    Lh.ScatDom=xlsread('hydrolight/ScatDom/MScatDom.xls','Lh_2');
    Lh.ScatDom=Lh.ScatDom(:,:)*5.03e15;

    %% PHOTORECEPTOR ABSORPTION
    A=1; a0A=800; a1A=3.1;
    B=0.5; a0B=176; a1B=1.52;

    [~,ind_B]=max(Ld.HighTurbidity);
    lambdaMax_B=lambda(ind_B(1));
    [~,ind_C]=max(Ld.Clear);
    lambdaMax_C=lambda(ind_C(1));
    [~,ind_HA]=max(Ld.AbsDom);
    lambdaMax_HA=lambda(ind_HA(1));
    [~,ind_HS]=max(Ld.ScatDom);
    lambdaMax_HS=lambda(ind_HS(1));

    pAbsorb.HighTurbidity=A*exp(-a0A*(log10(lambda./lambdaMax_B)).^2.*...
        (1+a1A*log10(lambda./lambdaMax_B)+(3*a1A^2/8).*log10(lambda./lambdaMax_B).^2)+...
        B*exp(-a0B*(log10(lambda./368)).^2.*...
        (1+a1B*log10(lambda./368)+(3*a1B^2/8)*log10(lambda./368))));

    pAbsorb.Clear=A*exp(-a0A*(log10(lambda./lambdaMax_C)).^2.*...
        (1+a1A*log10(lambda./lambdaMax_C)+(3*a1A^2/8).*log10(lambda./lambdaMax_C).^2)+...
        B*exp(-a0B*(log10(lambda./368)).^2.*...
        (1+a1B*log10(lambda./368)+(3*a1B^2/8)*log10(lambda./368))));

    pAbsorb.AbsDom=A*exp(-a0A*(log10(lambda./lambdaMax_HA)).^2.*...
        (1+a1A*log10(lambda./lambdaMax_HA)+(3*a1A^2/8).*log10(lambda./lambdaMax_HA).^2)+...
        B*exp(-a0B*(log10(lambda./368)).^2.*...
        (1+a1B*log10(lambda./368)+(3*a1B^2/8)*log10(lambda./368))));
    pAbsorb.AbsDom(1:6)=1e-300;

    pAbsorb.ScatDom=A*exp(-a0A*(log10(lambda./lambdaMax_HS)).^2.*...
        (1+a1A*log10(lambda./lambdaMax_HS)+(3*a1A^2/8).*log10(lambda./lambdaMax_HS).^2)+...
        B*exp(-a0B*(log10(lambda./368)).^2.*...
        (1+a1B*log10(lambda./368)+(3*a1B^2/8)*log10(lambda./368))));
    
save([BIGEYEROOT 'figEXT06_sensitivity/ParametersSensitivity.mat'])