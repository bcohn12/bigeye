clear all;

run ../figXX_compviz/Parameters.m
load spreadInfo.mat
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

%% CONSTANTS
lambda1=400;
lambda2=700;
k=0.035;
len=57;
const=1/(6.63e-34*2.998e8);

C=0.4;

%% INFORMATION CAPACITY - TERRESTRIAL

minpupil=0.001; maxpupil=0.04;
pupilValuesInfo=linspace(minpupil,maxpupil,25);

for loop1=1:length(pupilValuesInfo)
    A=pupilValuesInfo(loop1);
    
    N = @(l) eta*Dt_daylight*(pi/4)^2*A^2*(d/(f_daylight*A))^2 ...
    .*((IlambdaDaylight(l*1e6).*(l*1e6)*10).*l.*const)...
    .*(1-exp(-k.*SSH(l*1e9).*len));

    Deltapl=@(l) l/A;
    Deltapr=@(l) l/(2*A);
    Deltaphi=@(l) l/(2*A);
    
    lambda=550e-9;
    
    Ml=@(v) exp(-s(A).*v);
    Deltap2=@(l) (Deltapl(l)).^2 + 0.38.*(Deltapr(l)).^2;
    Mr=@(v,l) exp(-1.35.*v.^2.*Deltap2(l));
    
    vs=@(l) 1./(2*Deltaphi(l));
    P2=@(v) 1./(v.^(2));
    k2=@(v) v.*P2(v);
    noise=@(v,l) (C^2.*P2(v).*vs(l).^2.*N(l).*(Ml(v)).^2.*(Mr(v,l)).^2)...
        ./(integral(k2,0,Inf));
    
    inside=@(v,l) v.*log(1+noise(v,l));
    
    H=integral2(inside,0,vs(l),lambda1*1e-9,lambda2*1e-9);
end
