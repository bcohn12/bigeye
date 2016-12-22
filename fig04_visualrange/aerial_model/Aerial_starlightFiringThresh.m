function [visualRangeStarlight,pupilValuesAir]=Aerial_starlightFiringThresh
global BIGEYEROOT
%EVERYTHING IN THIS FUNCTION SHOULD BE BASED ON FIELD .Starlight
    run Parameters.m
    load('Parameters.mat');
    Wlambdaylambda=csvread('Wlambda.csv');%Table from Middleton
    WlambdaylambdaInterp= @(lambda) interp1(Wlambdaylambda(:,1),Wlambdaylambda(:,2),lambda,'pchip'); %value checked with mathematica
     
    sigma=@(lambda) ((1.1e-3*lambda.^(-4))+(0.008*lambda.^(-2.09)))/(1e3); %value checked with mathmematica
    %Referred to in text as sigma(lambda) never given explicit defintion
    %extinction coeff from Middleton 
    %(originally in 1/km coverted to 1/m), value checked with mathmematica
   
    %following Middleton:
    lambda1=0.4; lambda2=0.7;
    Bh=BAerial.Starlight*integral(WlambdaylambdaInterp,lambda1,lambda2); %value checked with mathematica
    Rh=((1.31e3)/0.89)*Bh*(1e6)^2; %value checked with mathematica
    %Intensitiy Parameter coefficient, supplement pg 5 line 550
    %Full equation to get Rh is on line 549 Rh=beta*B_h,o(lambda)
    %horizon space-light photons/m^2 s sr, value checked with mathematica

    %% RELATE PUPIL SIZE TO RANGE
    if T<0.05
        minvisualrange=1; maxvisualrange=200;
    else
        minvisualrange=1; maxvisualrange=750;
    end

    pupilValuesAir=linspace(minpupil,maxpupil,25);
    rangeValuesAir=linspace(minvisualrange,maxvisualrange,7500);
    for loop1=1:length(pupilValuesAir)
        A=pupilValuesAir(loop1);
        possibleSolS=zeros(length(rangeValuesAir),1);
        for loop2=1:length(rangeValuesAir)
            r=rangeValuesAir(loop2);
            Nh=(pi/4)^2*(T/r)^2*A^2*Rh*DtAerial.Starlight*qAerial.Starlight*(1-exp(-k*len));
            %S=(pi/4)^2*A^2*(T/r)^2*Dt*(1-exp(-kl))*q, for scotopic, Eq5
            %Nh=Rh*S, pg 5 line 545
            Nfalse=((T*FAerial.Starlight*A)/(r*d))^2*XAerial*DtAerial.Starlight;
            %pg 5 line 609
            
            %APPARENT RADIANCE OF THE GREY OBJECT
            Bofunc=@(lambda) WlambdaylambdaInterp(lambda).*(1+(C0Aerial.Starlight.*exp(-sigma(lambda).*r)));
            Bg= BAerial.Starlight*integral(Bofunc,lambda1,lambda2);
            Ro=((1.31e3)/0.89)*Bg*(1e6)^2;
            %pg 4 Eq 3, equation in supplement left as a function
            %integration not included
            
            No=(pi/4)^2*(T/r)^2*A^2*Ro*DtAerial.Starlight*qAerial.Starlight*(1-exp(-k*len));
            %S=(pi/4)^2*A^2*(T/r)^2*Dt*(kl/(2.3_kl))*q, for photopic, Eq5
            %No=Ro*S, pg 5 line 546
            
            eq=(R*sqrt(No+Nh+2*Nfalse))/(abs(No-Nh));
            %pg 5 Eq 6, sensitivity multiplication integrated in the
            %previous lines, all provided in therms of photon count rather
            %than radiance times sensitivity
            possibleSolS(loop2)=eq;
        end
        IDXDaylight=knnsearch(possibleSolS,1,'distance','euclidean');
        visualRangeStarlight(:,loop1)=rangeValuesAir(IDXDaylight);

       fprintf('iteration: %d\n', loop1);
    end

    save([BIGEYEROOT 'fig03_visualrange/aerial_model/meteoAerial_Starlight.mat'],'visualRangeStarlight','pupilValuesAir')        
