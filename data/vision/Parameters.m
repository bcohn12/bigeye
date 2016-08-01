function Parameters
    close all;
    global BIGEYEROOT
    parametersPath=[BIGEYEROOT 'data/vision'];
    %% Common Parameters:
    k=0.035; % photoreceptor absorbtion, units 1/micrometers
    len=57;  % length of photoreceptor, in micrometers
    T=.1; % units: m, prey width
    f = @(rho,phi,theta) rho.^2.*sin(phi); %volume equation in spherical coordinates
    R=1.96; %units: n/a, reliability coefficient for 95% confidence, used typical value
    d=3e-6; %units: m, photoreceptor diameter, used typical value
    minpupil=0.001; % largest diameter of pupil, meters
    maxpupil=0.03; % smallest diameter of pupil, meters

    % SENSORY VOLUME PARAMS
    % aerial and water half elevation angle of sensory volume
    elevationCoastal=pi/6; %30 deg 

    % azimuth is here assuming 35 degree overlap typical of fish;
    % definitely underestimate for terrestrial case
    azimuthCoastal=(305)*(pi/180);
    azimuthAir = azimuthCoastal;

    elevationMin=pi/2-elevationCoastal;
    elevationMax=pi/2+elevationCoastal;
    elevationMinAir=pi/2;
    elevationMaxAir=pi/2+elevationCoastal;

    azimuthMin=0;
    azimuthMax=azimuthCoastal;
    azimuthMaxAir=azimuthAir;

    %% AEIRAL MODEL
    lambda=(355:10:745)';
    %photoeceptor detection efficiency
    qAerial_Daylight=0.5; qAerial_Moonlight=0.36; qAerial_Starlight=0.36; 
    qAerialVals=[qAerial_Daylight,qAerial_Moonlight,qAerial_Starlight];

    %Luminance (All values from Middleton)
    Wlambdaylambda=csvread('Wlambda.csv');
    BAerial_Daylight=1e3; % daylight luminance in cd/m^2 
    BAerial_Moonlight=1e-2; %Fairly brigh moonlight in cd/m^2
    BAerial_Starlight=1e-4; %moonless clear night sky in cd/m^2
    BAerial=[BAerial_Daylight,BAerial_Moonlight,BAerial_Starlight];

    %Integration Time
    DtAerial_Daylight=(BAerial_Daylight)^-0.19; %Donner etal 1994
    DtAerial_Moonlight=(BAerial_Moonlight)^-0.19;
    DtAerial_Starlight=(BAerial_Starlight)^-0.19;
    DtAerial=[DtAerial_Daylight, DtAerial_Moonlight, DtAerial_Starlight];

    % Contrast parameters. Miller uses +/- 0.5, +/-1, and +/-2 as span 
    C0Aerial_Daylight=-1; %aerial daylight contrast value, target black
    C0Aerial_Moonlight=-1; %aerial moonlight contrast value, target black 
    C0Aerial_Starlight=-1; %aerial starlight contrast value, taget black
    C0Aerial=[C0Aerial_Daylight, C0Aerial_Moonlight, C0Aerial_Starlight];

    %Dark Noise
    XAerial=0.08;% units: photons/s, dark noise rate Rh/photoreceptor @23.5C

    %F-number
    FAerial_Daylight=8.8; %F-number: focal length/pupil diamter(D) for bright light
    FAerial_Moonlight=2.1; FAerial_Starlight=2.1; %F-number: focal lenght/D for light starved
    FAerial=[FAerial_Daylight,FAerial_Moonlight,FAerial_Starlight];
    
    %Intensitiy Parameter Coefficient
    BbarAerial=(1.31e15)/0.89;

    %% AQUATIC MODEL
    qAquatic=0.36; %Efficiency
    DtAquatic=1.16; %Integration time

    %Contrast parameters
    C0Aquatic_Daylight=-1; %aquatic contrast value, black target
    C0Aquatic_Moonlight=-1; C0Aquatic_Starlight=-1;

    %Dark-noise
    XAquatic=0.011; %Rh/photoreceptor dark-noise rate @16.5C

    %Mattheisien's Ratio
    M=2.55; %units: n/a, ratio of focal length and pupil radius (2f/A), set to Matthiessen's ratio


    ybarAquaticLambda=[0.0000 0.0001 0.0004 0.0012 0.0040 0.0116 0.02300 .0380 0.0600 0.0910,...
        0.1390 0.2080 0.3230 0.5030 0.7100 0.8620 0.9540 0.9950 0.9950 0.9520,...
        0.8700 0.7570 0.6310 0.5030 0.3810 0.2650 0.1750 0.1070 0.0610 0.0320 0.0170 0.0082,...
        0.0041 0.0021 0.0011 0.0005 0.0003 0.0001 0.0001 0.0000]; %photopic luminosity function, Mobley Light and Water book
    lambdabar=380:10:770; %luminosity function wavelength domain
    ybarAquaticInterp=@(l) interp1(lambdabar,ybarAquaticLambda,l,'pchip');

    % DAYLIGHT
    %Absorption Coefficient
    aAquatic_Daylight=xlsread([parametersPath,'/hydrolight/base_sun/Hydrolight_BrownWater.xlsx'],'a_Model');
    aAquatic_Daylight=aAquatic_Daylight(:,1);
    %Scattering Coefficient
    bAquatic_Daylight=xlsread([parametersPath,'/hydrolight/base_sun/Hydrolight_BrownWater.xlsx'],'b_Model');
    bAquatic_Daylight=bAquatic_Daylight(:,1);
    %Diffuse Spectral Attenuation Coeff
    KuAquatic_Daylight=xlsread([parametersPath,'/hydrolight/base_sun/Hydrolight_BrownWater.xlsx'],'Ku');
    KuAquatic_Daylight=KuAquatic_Daylight(:,:);

    KdAquatic_Daylight=xlsread([parametersPath,'/hydrolight/base_sun/Hydrolight_BrownWater.xlsx'],'Kd');
    KdAquatic_Daylight=KdAquatic_Daylight(:,:);

    KhAquatic_Daylight=zeros(size(KdAquatic_Daylight,1),size(KdAquatic_Daylight,2));
    %Spectral Radiance
    %Upwelling, horizontal, downwelling radiance
    LuAquatic_Daylight=xlsread([parametersPath,'/hydrolight/base_sun/Hydrolight_BrownWater.xlsx'],'Lu');
    LuAquatic_Daylight=LuAquatic_Daylight(:,:)*5.03e15;

    LhAquatic_Daylight=xlsread([parametersPath,'/hydrolight/base_sun/Hydrolight_BrownWater.xlsx'],'Lh_2');
    LhAquatic_Daylight=LhAquatic_Daylight(:,:)*5.03e15;

    LdAquatic_Daylight=xlsread([parametersPath,'/hydrolight/base_sun/Hydrolight_BrownWater.xlsx'],'Ld');
    LdAquatic_Daylight=LdAquatic_Daylight(:,:)*5.03e15;
    %Luminance
    ybarAquatic_Daylight=ybarAquaticInterp(lambda);

    BuAquatic_Daylight=zeros(size(LuAquatic_Daylight,2),1);
    BhAquatic_Daylight=zeros(size(LhAquatic_Daylight,2),1);
    BdAquatic_Daylight=zeros(size(LdAquatic_Daylight,2),1);
    for i=1:size(LuAquatic_Daylight,2)
        tempU=(LuAquatic_Daylight(:,i)/5.03e15).*ybarAquatic_Daylight.*lambda;
        BuAquatic_Daylight(i)=trapz(lambda,tempU); 

        tempH=(LhAquatic_Daylight(:,i)/5.03e15).*ybarAquatic_Daylight.*lambda;
        BhAquatic_Daylight(i)=trapz(tempH);

        tempD=(LdAquatic_Daylight(:,i)/5.03e15).*ybarAquatic_Daylight.*lambda;
        BdAquatic_Daylight(i)=trapz(tempD);
    end

    % MOONLIGHT
    %Absorption Coefficient
    aAquatic_Moonlight=xlsread([parametersPath,'/hydrolight/base_moon/Mbase_moon.xls'],'a');
    aAquatic_Moonlight=aAquatic_Moonlight(:,1);
    %Scattering Coefficient
    bAquatic_Moonlight=xlsread([parametersPath,'/hydrolight/base_moon/Mbase_moon.xls'],'b');
    bAquatic_Moonlight=bAquatic_Moonlight(:,1);
    %Diffuse Spectral Attenuation Coeff
    KuAquatic_Moonlight=xlsread([parametersPath,'/hydrolight/base_moon/Mbase_moon.xls'],'Ku');
    KuAquatic_Moonlight=KuAquatic_Moonlight(:,:);

    KdAquatic_Moonlight=xlsread([parametersPath,'/hydrolight/base_moon/Mbase_moon.xls'],'Kd');
    KdAquatic_Moonlight=KdAquatic_Moonlight(:,:);

    KhAquatic_Moonlight=zeros(size(KdAquatic_Moonlight,1),size(KdAquatic_Moonlight,2));
    %Spectral Radiance
    %Upwelling, horizontal,downwelling radiance
    LuAquatic_Moonlight=xlsread([parametersPath,'/hydrolight/base_moon/Mbase_moon.xlsx'],'Lu');
    LuAquatic_Moonlight=LuAquatic_Moonlight(:,:)*5.03e15;

    LdAquatic_Moonlight=xlsread([parametersPath,'/hydrolight/base_moon/Mbase_moon.xlsx'],'Ld');
    LdAquatic_Moonlight=LdAquatic_Moonlight(:,:)*5.03e15;

    LhAquatic_Moonlight=xlsread([parametersPath,'/hydrolight/base_moon/Mbase_moon.xlsx'],'Lh_2');
    LhAquatic_Moonlight=LhAquatic_Moonlight(:,:)*5.03e15;
    %Luminance
    ybarAquatic_Moonlight=ybarAquaticInterp(lambda);

    BuAquatic_Moonlight=zeros(size(LuAquatic_Moonlight,2),1);
    BhAquatic_Moonlight=zeros(size(LhAquatic_Moonlight,2),1);
    BdAquatic_Moonlight=zeros(size(LdAquatic_Moonlight,2),1);
    for i=1:size(LuAquatic_Moonlight,2)
        tempU=(LuAquatic_Moonlight(:,i)/5.03e15).*ybarAquatic_Moonlight.*lambda;
        BuAquatic_Moonlight(i)=trapz(lambda,tempU);

        tempH=(LhAquatic_Moonlight(:,i)/5.03e15).*ybarAquatic_Moonlight.*lambda;
        BhAquatic_Moonlight(i)=trapz(lambda,tempH);

        tempD=(LdAquatic_Moonlight(:,i)/5.03e15).*ybarAquatic_Moonlight.*lambda;
        BdAquatic_Moonlight(i)=trapz(lambda,tempD);

    end

    % STARLIGHT
    %Absorption Coefficient
    aAquatic_Starlight=xlsread([parametersPath,'/hydrolight/base_stars/Mbase_stars.xls'],'a');
    aAquatic_Starlight=aAquatic_Starlight(:,1);
    %Scattering Coefficient
    bAquatic_Starlight=xlsread([parametersPath,'/hydrolight/base_stars/Mbase_stars.xls'],'b');
    bAquatic_Starlight=bAquatic_Starlight(:,1);
    %Diffuse Spectral Attenuation Coeff
    KuAquatic_Starlight=xlsread([parametersPath,'/hydrolight/base_stars/Mbase_stars.xls'],'Ku');
    KuAquatic_Starlight=KuAquatic_Starlight(:,:);

    KdAquatic_Starlight=xlsread([parametersPath,'/hydrolight/base_stars/Mbase_stars.xls'],'Kd');
    KdAquatic_Starlight=KdAquatic_Starlight(:,:);

    KhAquatic_Starlight=zeros(size(KdAquatic_Starlight,1),size(KdAquatic_Starlight,2));
    %Spectral Radiance
    %Upwelling,horizontal,downwellling radiance
    LuAquatic_Starlight=xlsread([parametersPath,'/hydrolight/base_stars/Mbase_stars.xls'],'Lu');
    LuAquatic_Starlight=LuAquatic_Starlight(:,:)*5.03e15;

    LdAquatic_Starlight=xlsread([parametersPath,'/hydrolight/base_stars/Mbase_stars.xls'],'Ld');
    LdAquatic_Starlight=LdAquatic_Starlight(:,:)*5.03e15;

    LhAquatic_Starlight=xlsread([parametersPath,'/hydrolight/base_stars/Mbase_stars.xls'],'Lh_2');
    LhAquatic_Starlight=LhAquatic_Starlight(:,:)*5.03e15;
    %Luminance
    ybarAquatic_Starlight=ybarAquaticInterp(lambda);

    BuAquatic_Starlight=zeros(size(LuAquatic_Starlight,2),1);
    BhAquatic_Starlight=zeros(size(LhAquatic_Starlight,2),1);
    BdAquatic_Starlight=zeros(size(LdAquatic_Starlight,2),1);
    for i=1:size(LuAquatic_Starlight,2)
        tempU=(LuAquatic_Starlight(:,i)/5.03e15).*ybarAquatic_Starlight.*lambda;
        BuAquatic_Starlight(i)=trapz(lambda,tempU);

        tempH=(LhAquatic_Starlight(:,i)/5.03e15).*ybarAquatic_Starlight.*lambda;
        BhAquatic_Starlight(i)=trapz(lambda,tempH);

        tempD=(LdAquatic_Starlight(:,i)/5.03e15).*ybarAquatic_Starlight.*lambda;
        BdAquatic_Starlight(i)=trapz(lambda,tempD);
    end

    % PHOTORECEPTOR ABSORPTION
    A=1; a0A=800; a1A=3.1;
    B=0.5; a0B=176; a1B=1.52;

    [~, ind_Su]=max(LdAquatic_Daylight);
    lambdaMax_Su=lambda(ind_Su(1));
    [~,ind_M]=max(LdAquatic_Moonlight);
    lambdaMax_M=lambda(ind_M(1));
    [~,ind_St]=max(LdAquatic_Starlight);
    lambdaMax_St=lambda(ind_St(1));

    pAbsorbAquatic_Daylight=A*exp(-a0A*(log10(lambda./lambdaMax_Su)).^2.*...
        (1+a1A*log10(lambda./lambdaMax_Su)+(3*a1A^2/8).*log10(lambda./lambdaMax_Su).^2)+...
        B*exp(-a0B*(log10(lambda./368)).^2.*...
        (1+a1B*log10(lambda./368)+(3*a1B^2/8)*log10(lambda./368))));

    pAbsorbAquatic_Moonlight=A*exp(-a0A*(log10(lambda./lambdaMax_M)).^2.*...
        (1+a1A*log10(lambda./lambdaMax_M)+(3*a1A^2/8).*log10(lambda./lambdaMax_M).^2)+...
         B*exp(-a0B*(log10(lambda./368)).^2.*...
        (1+a1B*log10(lambda./368)+(3*a1B^2/8)*log10(lambda./368))));

    pAbsorbAquatic_Starlight=A*exp(-a0A*(log10(lambda./lambdaMax_St)).^2.*...
        (1+a1A*log10(lambda./lambdaMax_St)+(3*a1A^2/8).*log10(lambda./lambdaMax_St).^2)+...
         B*exp(-a0B*(log10(lambda./368)).^2.*...
        (1+a1B*log10(lambda./368)+(3*a1B^2/8)*log10(lambda./368))));
    save([parametersPath,'/Parameters.mat'])