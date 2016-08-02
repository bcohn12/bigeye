function [visualRangeStarlight,pupilValuesAir]=Aerial_starlightFiringThresh
global BIGEYEROOT
    run Parameters.m
    load('Parameters.mat');
    Wlambdaylambda=csvread('Wlambda.csv');

    sigma=@(lambda) ((1.1e-3*lambda.^(-4))+(0.008*lambda.^(-2.09)))/(1e3); %value checked with mathmematica
    WlambdaylambdaInterp= @(lambda) interp1(Wlambdaylambda(:,1),Wlambdaylambda(:,2),lambda,'pchip'); %value checked with mathematica
    %following Middleton:
    lambda1=0.4; lambda2=0.7;
    Bh=BAerial.Starlight*integral(WlambdaylambdaInterp,lambda1,lambda2); %value checked with mathematica
    Rh=((1.31e3)/0.89)*Bh*(1e6)^2; %value checked with mathematica


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
            Nfalse=((T*FAerial.Starlight*A)/(2*r*d))^2*XAerial*DtAerial.Starlight;

            %APPARENT RADIANCE OF THE GREY OBJECT
            Bofunc=@(lambda) WlambdaylambdaInterp(lambda).*(1+(C0Aerial.Starlight.*exp(-sigma(lambda).*r)));
            Bg= BAerial.Starlight*integral(Bofunc,lambda1,lambda2);
            Ro=((1.31e3)/0.89)*Bg*(1e6)^2;

            No=(pi/4)^2*(T/r)^2*A^2*Ro*DtAerial.Starlight*qAerial.Starlight*(1-exp(-k*len));

            eq=(R*sqrt(No+Nh+2*Nfalse))/(abs(No-Nh));
            possibleSolS(loop2)=eq;
        end
        IDXDaylight=knnsearch(possibleSolS,1,'distance','euclidean');
        visualRangeStarlight(:,loop1)=rangeValuesAir(IDXDaylight);

       fprintf('iteration: %d\n', loop1);
    end

    save([BIGEYEROOT 'fig03_visualrange/aerial_model/meteoAerial_Starlight.mat'],'visualRangeStarlight','pupilValuesAir')        
