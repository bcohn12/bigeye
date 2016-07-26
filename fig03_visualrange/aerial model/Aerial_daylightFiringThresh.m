function [visualRangeDaylight,pupilValuesAir]=Aerial_daylightFiringThresh
%Input: will be read in from Parameters.m file
%% INITIALIZE VARIABLES    
    run ../../figXX_compviz/Parameters.m 
    Wlambdaylambda=csvread('../../figXX_compviz/Wlambda.csv');
    
    sigma=@(lambda) ((1.1e-3*lambda.^(-4))+(0.008*lambda.^(-2.09)))/(1e3); %extinction coeff, value checked with mathmematica
    WlambdaylambdaInterp= @(lambda) interp1(Wlambdaylambda(:,1),Wlambdaylambda(:,2),lambda,'pchip'); %value checked with mathematica

    %following Middleton:
    lambda1=0.4; lambda2=0.7; %visible range wavelength
    Bh=BAerial_Daylight*integral(WlambdaylambdaInterp,lambda1,lambda2); %horizon luminance, value checked with mathematica
    Rh=((1.31e3)/0.89)*Bh*(1e6)^2; %horizon space-light photons/m^2 s sr, value checked with mathematica

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

            Nh=(pi/4)^2*(T/r)^2*A^2*Rh*DtAerial_Daylight*qAerial_Daylight*...
                ((k*len)/(2.3+(k*len)));
            Nfalse=((T*FAerial_Daylight*A)/(r*d))^2*...
                XAerial*DtAerial_Daylight; 

            %APPARENT RADIANCE OF THE GREY OBJECT
            Bofunc=@(lambda) WlambdaylambdaInterp(lambda).*...
                (1+(C0Aerial_Daylight.*exp(-sigma(lambda).*r)));
            Bo= BAerial_Daylight*integral(Bofunc,lambda1,lambda2);
            Ro=((1.31e3)/0.89)*Bo*(1e6)^2;
            No=(pi/4)^2*(T/r)^2*A^2*Ro*DtAerial_Daylight*qAerial_Daylight*...
                ((k*len)/(2.3+(k*len)));

            eq=(R*sqrt(No+Nh+2*Nfalse))/(abs(No-Nh));
            possibleSolD(i)=eq;
        end
        IDXDaylight=knnsearch(possibleSolD,1,'distance','euclidean'); %find closest range value to soln 1
        visualRangeDaylight(j)=rangeValuesAir(IDXDaylight); %store range value

        fprintf('iteration: %d\n', j);
    end

    save('meteoAerial_Daylight','visualRangeDaylight','pupilValuesAir')        
