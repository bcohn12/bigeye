clear all;

run ../figXX_compviz/Parameters.m

% Radiance values from various papers, and RRG 
% RRG: Ratio of reflected irradiance (from vertical or horizontal wall of a specific
% material and color) to global irradiance during the day (so not appropriate for nocturnal
% conditions, but we are using the same values for now)
% To get the mat file, run loadRadianceRRG.m within
% figXX_compviz
load ../figXX_compviz/RadianceRRG.mat

VEGETATIVE=0;
if(VEGETATIVE) 
    IlambdaDaylight=@(l)interp1(lambdaV,vegetativeRadiance,l,'pchip');
else
    RRGGreenFunc=@(l) interp1(lambdaRRGGreen,RRGGreen,l,'pchip');
    IlambdaDaylight=@(l)(interp1(lambdaD,daylightRadiance,l,'pchip'));
end

RRGBlackFunc=@(l) interp1(lambdaRRGBlack,RRGBlack,l,'pchip');    

%% SET SSH (ABSORBANCE BAND OF PHOTORECEPTORS)
% This is the amount of light absorbed by photoreceptor
% on one pass through (so tapetum is ignored)

% parameters for the alpha band absorbance of the a1 rhodopsin
a0alpha=380;
a1alpha=6.09;
Aalpha=1;

% parameters for the beta band absorbance of the a1 rhodopsin
a0beta=247;
a1beta=3.59;
Abeta=0.29;

% maximum absorbtion wavelengths in nm for the alpha
% and beta bands
lmaxalpha=500e-9;
lmaxbeta=350e-9;

xalpha=@(l) log(l./lmaxalpha);
xbeta=@(l) log(l./lmaxbeta);

alpha=@(l) Aalpha.*exp(-a0alpha.*xalpha(l).^2.*...
    (1+a1alpha.*xalpha(l)+(3/8).*a1alpha.^2.*xalpha(l).^2));
beta=@(l) Abeta.*exp(-a0beta.*xbeta(l).^2.*...
    (1+a1beta.*xbeta(l)+(3/8).*a1beta.^2.*xbeta(l).^2));
SSH=@(l) alpha(l)+beta(l);

%% SET EXTINCTION COEFFICIENT 
% Recheck values from Middleton vision book
% Sum of the Rayleigh scattering and aerosol scattering for horizontal
% beam at sea level, mean environmental conditions, over 1 km (which
% is why it is divided by 1e3 to get value per meter
% wavelength lambda is in micrometers 
% Conversion to micrometers for wavelength is done here
sigma=@(lambda) ((1.1e-3*(lambda*1e6).^(-4)+8e-2*(lambda*1e6).^(-1))./(1e3)); %Moller Optics of Lower Atmosphere

%% CALCULATE THE SPECTRAL RADIANCE OF SPACE
lambda1=400e-9;  % min wavelength for integration, nm
lambda2=700e-9;  % max wavelength for integration, nm
k=0.035;          % photoreceptor absorbtion, units 1/micrometers
len=57;            % length of photoreceptor, in micrometers

% conversion factor for going from spectral radiance in W/(m^2*sr*s)   into
% photons/(m^2*sr*s) (Planck's constant * speed of light) 1e-9 to convert 
% nm
const=1/(6.63e-34*2.998e8); 

% IspaceFunc: Background spectral radiance
% IlambdaDaylight loaded from RadianceRRG
%   it is the spectral radiance of daylight, at 600 meters up from
%   sea levels, looking up at 20 degrees
%  l is in micrometers so multiplied by 1e-3
IspaceFunc=@(l) ((IlambdaDaylight(l).*(l)).*l.*const)...
    .*(1-exp(-k.*SSH(l).*len));

% Ispace_daylight the spectral radiance absorbed based on
% photoreceptor properties (background)
% assumes an infinite extent source
Ispace_daylight=integral(IspaceFunc,lambda1,lambda2);

%% RELATE PUPIL SIZE TO RANGE
minvisualrange=1; maxvisualrange=50000;

pupilValuesAir=linspace(minpupil,maxpupil,25);
rangeValuesAir=linspace(minvisualrange,maxvisualrange,10000);

parfor loop1=1:length(pupilValuesAir)
    A=pupilValuesAir(loop1);
    possibleSolD=zeros(length(rangeValuesAir),1);
    for loop2=1:length(rangeValuesAir)
        r=rangeValuesAir(loop2);
        
        Nspace=(pi/4)^2*A^2*(T/r)^2*Ispace_daylight*eta*Dt_daylight;
        Xch=((T*f_daylight*A)/(r*d))^2*X_land*Dt_daylight;
        
        % CALCULATE SPECTRAL RADIANCE OF volume around TARGET, absorbed by
        % photoreceptor, in this case around a shiny black wall, vertical
        % position
        IblackFunc=@(l)((IlambdaDaylight(l).*(l)).*l.*const)...
            .*(1-exp(-k.*SSH(l).*len)).*(1-(exp((-sigma(l)).*r))); 
        %units: photons/m^2srs
 
        % spectral radiance, reflected light, absorbed by photoreceptor
        % again from shiny black wall
        IrefFunc=@(l)((RRGBlackFunc(l).*IlambdaDaylight(l).*(l)).*l.*const)...
            .*(1-exp(-k.*SSH(l).*len)).*(exp(-sigma(l).*r));
        %units: photons/m^2srs

        % across all wavelengths, spectral radiance absorbed by a
        % photoreceptor, photons/(m^2 sr s)
        Iblack=integral(IblackFunc,lambda1,lambda2);
        Iref=integral(IrefFunc,lambda1,lambda2);
        Itarget=Iblack+Iref;
        
        % pi/4 is because square array of photoreceptors is assumed
        % T target size, r - visual range, A pupil diameter
        % eta - detection efficiency (higher in daylight 0.8, lower at night
        % or in water conditions, 0.3)
        % Dt_daylight - shutter speed, based on spectral radiance
        % Xch dark noise - photons receptor registers that were not
        % actually received (25 deg C; for nighttime and water 16.5 deg)
        % Nilsson used 4 deg. We may revisit 16.5 deg since this was
        % in tropical waters in the Late Devonian
        Ntarget=(pi/4)^2*A^2*(T/r)^2*Itarget*eta*Dt_daylight+2*Xch;
        
        % R reliability coefficcient
        eq=(R*sqrt(Ntarget+Nspace))/(abs(Ntarget-Nspace));
        
        possibleSolD(loop2)=eq;
    end
    IDXDaylight=knnsearch(possibleSolD,1,'distance','euclidean');
    visualRangeDaylight(:,loop1)=rangeValuesAir(IDXDaylight);
    
    s=sprintf('iteration: %d', loop1);
    disp(s)
end

save('daylight','Ispace_daylight','visualRangeDaylight');
