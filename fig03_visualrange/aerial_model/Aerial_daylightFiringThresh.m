function [visualRangeDaylight,pupilValuesAir]=Aerial_daylightFiringThresh
global BIGEYEROOT
%EVERYTHING IN THIS FUNCTION SHOULD USE THE FIELD .Daylight
%% INITIALIZE VARIABLES    
    run Parameters.m 
    load('Parameters.mat')
    Wlambdaylambda=csvread('Wlambda.csv'); %Table from Middleton
    WlambdaylambdaInterp= @(lambda) interp1(Wlambdaylambda(:,1),Wlambdaylambda(:,2),lambda,'pchip'); %value checked with mathematica
    
    sigma=@(lambda) ((1.1e-3*lambda.^(-4))+(0.008*lambda.^(-2.09)))/(1e3);
    %Referred to in text as sigma(lambda) never given explicit defintion
    %extinction coeff from Middleton 
    %(originally in 1/km coverted to 1/m), value checked with mathmematica
    
    %following Middleton:
    lambda1=0.4; lambda2=0.7; %visible range wavelength
    Bh=BAerial.Daylight*integral(WlambdaylambdaInterp,lambda1,lambda2); %horizon luminance, value checked with mathematica
    Rh=((1.31e3)/0.89)*Bh*(1e6)^2; 
    %Intensitiy Parameter coefficient, supplement pg 5 line 550
    %Full equation to get Rh is on line 549 Rh=beta*B_h,o(lambda)
    %horizon space-light photons/m^2 s sr, value checked with mathematica

    %% RELATE PUPIL SIZE TO RANGE
    if T<0.05; %Arrange gridding based on target diameter
        minvisualrange=10; maxvisualrange=2000;
    else
        minvisualrange=100; maxvisualrange=50000;
    end
    %Initialize gridding for pupil diameter and range
    pupilValuesAir=linspace(minpupil,maxpupil,25);
    rangeValuesAir=linspace(minvisualrange,maxvisualrange,1000);
    
    visualRangeDaylight=zeros(length(pupilValuesAir),1);
    for j=1:length(pupilValuesAir)
        A=pupilValuesAir(j);
        possibleSolD=zeros(length(rangeValuesAir),1);
        for i=1:length(rangeValuesAir)
            r=rangeValuesAir(i);

            Nh=(pi/4)^2*(T/r)^2*A^2*Rh*DtAerial.Daylight*qAerial.Daylight*...
                ((k*len)/(2.3+(k*len)));
            %S=(pi/4)^2*A^2*(T/r)^2*Dt*(kl/(2.3_kl))*q, for photopic, Eq5
            %Nh=Rh*S, pg 5 line 545
            Nfalse=((T*FAerial.Daylight*A)/(r*d))^2*...
                XAerial*DtAerial.Daylight;
            %pg 5 line 609

            %APPARENT RADIANCE OF THE GREY OBJECT
            Bofunc=@(lambda) WlambdaylambdaInterp(lambda).*...
                (1+(C0Aerial.Daylight.*exp(-sigma(lambda).*r)));
            Bo= BAerial.Daylight*integral(Bofunc,lambda1,lambda2);
            %pg 4 Eq 3, equation in supplement left as a function
            %integration not included
            Ro=((1.31e3)/0.89)*Bo*(1e6)^2;
            
            No=(pi/4)^2*(T/r)^2*A^2*Ro*DtAerial.Daylight*qAerial.Daylight*...
                ((k*len)/(2.3+(k*len)));
            %S=(pi/4)^2*A^2*(T/r)^2*Dt*(kl/(2.3_kl))*q, for photopic, Eq5
            %No=Ro*S, pg 5 line 546

            eq=(R*sqrt(No+Nh+2*Nfalse))/(abs(No-Nh));
            %pg 5 Eq 6, sensitivity multiplication integrated in the
            %previous lines, all provided in therms of photon count rather
            %than radiance times sensitivity
            possibleSolD(i)=eq;
        end
        IDXDaylight=knnsearch(possibleSolD,1,'distance','euclidean'); %find closest range value to soln 1
        visualRangeDaylight(j)=rangeValuesAir(IDXDaylight); %store range value

        fprintf('iteration: %d\n', j);
    end

    save([BIGEYEROOT 'fig03_visualrange/aerial_model/meteoAerial_Daylight.mat'],'visualRangeDaylight','pupilValuesAir')        
