function [visualRangeMoonlight,pupilValuesAir]=Aerial_moonlightFiringThresh
global BIGEYEROOT
    run Parameters.m
    load('Parameters.mat')
    Wlambdaylambda=csvread('Wlambda.csv');

    sigma=@(lambda) ((1.1e-3*lambda.^(-4))+(0.008*lambda.^(-2.09)))/(1e3); %value checked with mathmematica
    WlambdaylambdaInterp= @(lambda) interp1(Wlambdaylambda(:,1),Wlambdaylambda(:,2),lambda,'pchip'); %value checked with mathematica

    %following Middleton:
    lambda1=0.4; lambda2=0.7;
    Bh=BAerial_Moonlight*integral(WlambdaylambdaInterp,lambda1,lambda2); %value checked with mathematica
    Rh=((1.31e3)/0.89)*Bh*(1e6)^2; %value checked with mathematica

    %% RELATE PUPIL SIZE TO RANGE
    if T<0.05
        minvisualrange=1; maxvisualrange=500;
    else
        minvisualrange=50; maxvisualrange=3300;
    end

    pupilValuesAir=linspace(minpupil,maxpupil,25);
    rangeValuesAir=linspace(minvisualrange,maxvisualrange,1000);
    for j=1:length(pupilValuesAir)
        A=pupilValuesAir(j);
        possibleSolM=zeros(length(rangeValuesAir),1);
        for i=1:length(rangeValuesAir)
            r=rangeValuesAir(i);

            Nh=(pi/4)^2*(T/r)^2*A^2*Rh*DtAerial_Moonlight*qAerial_Moonlight*...
                (1-exp(-k*len));
            Nfalse=((T*FAerial_Moonlight*A)/(2*r*d))^2*XAerial*Dt;

            %APPARENT RADIANCE OF THE GREY OBJECT
            Bofunc=@(lambda) WlambdaylambdaInterp(lambda).*(1+(C0Aerial_Moonlight.*exp(-sigma(lambda).*r)));
            Bo= BAerial_Moonlight*integral(Bofunc,lambda1,lambda2);
            Ro=((1.31e3)/0.89)*Bo*(1e6)^2;

            No=(pi/4)^2*(T/r)^2*A^2*Ro*DtAerial_Moonlight*qAerial_Moonlight*...
                (1-exp(-k*len));

            eq=(R*sqrt(No+Nh+2*Nfalse))/(abs(No-Nh));

            possibleSolM(i)=eq;
        end
        IDXDaylight=knnsearch(possibleSolM,1,'distance','euclidean');
        visualRangeMoonlight(:,j)=rangeValuesAir(IDXDaylight);

        fprintf('iteration %d\n',j);
    end

    save([BIGEYEROOT 'fig03_visualrange/aerial_model/meteoAerial_Moonlight.mat'],'visualRangeMoonlight','pupilValuesAir')
