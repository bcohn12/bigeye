function [visualRangeMoonlight,pupilValuesAir]=Aerial_moonlightFiringThresh
global BIGEYEROOT
%EVERYTHING IN THIS FUNCTION SHOULD HAVE THE FIELD .Moonlight
    run Parameters.m
    load('Parameters.mat')
    Wlambdaylambda=csvread('Wlambda.csv');
    WlambdaylambdaInterp= @(lambda) interp1(Wlambdaylambda(:,1),Wlambdaylambda(:,2),lambda,'pchip'); %value checked with mathematica
    
    %value checked with mathmematica
    sigma=@(lambda) ((1.1e-3*lambda.^(-4))+(0.008*lambda.^(-2.09)))/(1e3); 
    %Explicit defintion not provided function taken from Middleton
    %Given in (1/km) converted to (1/m)

    %following Middleton:
    lambda1=0.4; lambda2=0.7;
    Bh=BAerial.Moonlight*integral(WlambdaylambdaInterp,lambda1,lambda2); %value checked with mathematica
    %supp pg 5 line 550
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

            Nh=(pi/4)^2*(T/r)^2*A^2*Rh*DtAerial.Moonlight*qAerial.Moonlight*...
                (1-exp(-k*len));
            %Sensitivity in the mesopic and scotopic range
            %S=(pi/4)^2*D^2*(T/r)^2*Dt*(1-exp(-kl))*q, supp pg 5, Eq 5
            %Nh=Rh*S, supp pg 5, line 545
            Nfalse=((T*FAerial.Moonlight*A)/(r*d))^2*XAerial*Dt;
            %supp pg 5, line 610

            %APPARENT RADIANCE OF THE GREY OBJECT
            Bofunc=@(lambda) WlambdaylambdaInterp(lambda).*(1+(C0Aerial.Moonlight.*exp(-sigma(lambda).*r)));
            Bo= BAerial.Moonlight*integral(Bofunc,lambda1,lambda2);
            %supp pg4, Eq 3 with integral included
            Ro=((1.31e3)/0.89)*Bo*(1e6)^2;
            %supp pg 5 line 550

            No=(pi/4)^2*(T/r)^2*A^2*Ro*DtAerial.Moonlight*qAerial.Moonlight*...
                (1-exp(-k*len));
            %No=Ro*S, with S in mesopic and scotopic condition
            %supp pg 5, line 546 and Eq 5 for sensitivity

            eq=(R*sqrt(No+Nh+2*Nfalse))/(abs(No-Nh));
            %supp pg5, Eq 6 condensed form with Nh=Rh*S, No=Ro*S
            %2*Nfalse=2*X*(TFD/rd)^2*Dt

            possibleSolM(i)=eq;
        end
        IDXDaylight=knnsearch(possibleSolM,1,'distance','euclidean');
        visualRangeMoonlight(:,j)=rangeValuesAir(IDXDaylight);

        fprintf('iteration %d\n',j);
    end

    save([BIGEYEROOT 'fig03_visualrange/aerial_model/meteoAerial_Moonlight.mat'],'visualRangeMoonlight','pupilValuesAir')
