clear all;

run ../figXX_compviz/Parameters.m
load ../figXX_compviz/RadianceRRG.mat

%% SET SSH (ABSORBANCE BAND OF PHOTORECEPTORS)
a0alpha=380;
a1alpha=6.09;
a0beta=247;
a1beta=3.59;
Aalpha=1;
Abeta=0.29;

lmaxalpha=500;
lmaxbeta=350;

xalpha=@(l) log(l./lmaxalpha);
xbeta=@(l) log(l./lmaxbeta);

alpha=@(l) Aalpha.*exp(-a0alpha.*xalpha(l).^2.*...
    (1+a1alpha.*xalpha(l)+(3/8).*a1alpha.^2.*xalpha(l).^2));
beta=@(l) Abeta.*exp(-a0beta.*xbeta(l).^2.*...
    (1+a1beta.*xbeta(l)+(3/8).*a1beta.^2.*xbeta(l).^2));
SSH=@(l) alpha(l)+beta(l);

%% SET EXTINCTION COEFFICIENT 
%Recheck values from Middleton vision book
sigma=@(l) (1.1e-3*l.^(-4)+8e-2*l.^(-1)); %Moller Optics of Lower Atmosphere

%% CALCULATE THE SPECTRAL RADIANCE OF SPACE
lambda1=400;
lambda2=700;
k=0.035;
len=57;
const=1e-9/(6.63e-34*2.998e8);

IspaceFunc=@(l) ((IlambdaStarlight(l*1e-3).*(l*1e-3)).*l.*const)...
    .*(1-exp(-k.*SSH(l).*len));
Ispace_starlight=integral(IspaceFunc,lambda1,lambda2);

%% RELATE PUPIL SIZE TO RANGE
minpupil=0.001; maxpupil=0.04;
minvisualrange=1; maxvisualrange=200;

pupilValuesAir=linspace(minpupil,maxpupil,25);
rangeValuesAir=linspace(minvisualrange,maxvisualrange,5000);

parfor loop1=1:length(pupilValuesAir)
    A=pupilValuesAir(loop1);
    possibleSolS=zeros(length(rangeValuesAir),1);
    for loop2=1:length(rangeValuesAir)
        r=rangeValuesAir(loop2);
        
        Nspace=(pi/4)^2*A^2*(T/r)^2*Ispace_starlight*eta*Dt;
        Xch=((T*f_night*A)/(r*d))^2*X_land*Dt;
        
         % CALCULATE SPECTRAL RADIANCE OF TARGET        
        IblackFunc=@(l)((IlambdaStarlight(l*1e-3).*(l*1e-3)).*l.*const)...
           .*(1-exp(-k.*SSH(l).*len)).*(1-(exp(-sigma(l*1e-3).*r))); 
        %units: photons/m^2srs

        IrefFunc=@(l)((RRGBlackFunc(l).*IlambdaStarlight(l*1e-3).*(l*1e-3)).*l.*const)...
            .*(1-exp(-k.*SSH(l).*len)).*(exp(-sigma(l*1e-3).*r));
        %units: photons/m^2srs

        ItargetFunc=@(l) IblackFunc(l)+IrefFunc(l);      
        Itarget=integral(ItargetFunc,lambda1,lambda2); 
        
        Ntarget=(pi/4)^2*A^2*(T/r)^2*Itarget*eta*Dt+2*Xch;
        
        eq=(R*sqrt(Ntarget+Nspace))/(abs(Ntarget-Nspace));
        
        possibleSolS(loop2)=eq;
    end
    IDXDaylight=knnsearch(possibleSolS,1,'NSMethod','exhaustive','distance','euclidean');
    visualRangeStarlight(:,loop1)=rangeValuesAir(IDXDaylight);
    
    s=sprintf('iteration: %d', loop1);
    disp(s)
end

save('starlight','pupilValuesAir','Ispace_starlight','visualRangeStarlight');
