function [visualRangeDaylight,pupilValuesAir]=AerialSensitivity_Daylight
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

%% SENSITIVITY
    sensitivityParams.XAerial=0.011;
    sensitivityParams.qAerial=0.8;
    sensitivityParams.DtAerial=0.0116;
    sensitivityParams.d=10e-6;
    sensitivityParams.FAerial=3;
    
    aerialEquiv={'XAerial','qAerial.Daylight','DtAerial.Daylight','d','FAerial.Daylight'};
    parameters={'XAerial','qAerial','DtAerial','d','FAerial'};
    
    %% RELATE PUPIL SIZE TO RANGE
    pupilValuesAir=linspace(minpupil,maxpupil,25);
    tol=1e-4;
    
    visualRangeDaylight=zeros(length(pupilValuesAir),length(parameters));        
    for s=5:length(parameters)
        eval(sprintf('%s=%d',aerialEquiv{s},sensitivityParams.(parameters{s})));
        r=8000;
        for i=1:length(pupilValuesAir)
            A=pupilValuesAir(i);
            delta=10^(floor(log10(r))-4);
            possibleSoln=0;
            while(abs(possibleSoln-1)>tol)                           
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

                possibleSoln=(R*sqrt(No+Nh+2*Nfalse))/(abs(No-Nh));
                %pg 5 Eq 6, sensitivity multiplication integrated in the
                %previous lines, all provided in therms of photon count rather
                %than radiance times sensitivity
                if possibleSoln>1
                    r=r-delta;
                else
                    r=r+delta;
                end
                clc;
                fprintf('pupil iteration: %d %d\n',i,s);
                fprintf('solution: %f\n',possibleSoln);
                fprintf('r: %f\n',r);
                fprintf('error: %f\n', abs(possibleSoln-1));
            end
            visualRangeDaylight(i,s)=r;
        end
        load('Parameters.mat')
    end
    save([BIGEYEROOT 'fig03_visualrange/aerial_model/parameter_sensitivity/meteoAerialParameterSensitivity_Daylight.mat'],'visualRangeDaylight','pupilValuesAir')
    
load('meteoAerialParameterSensitivity_Daylight.mat')

    actRangeDaylight=zeros(size(visualRangeDaylight,1),size(visualRangeDaylight,2));
    Cr_daylight=actRangeDaylight; angularSize=actRangeDaylight; Kt_daylight=Cr_daylight;
    mrprev=10;
    for s=1:size(visualRangeDaylight,2)
        for i=1:size(visualRangeDaylight,1);
            A=pupilValuesAir(i);
            mr=visualRangeDaylight(i,s);
            
            CrFunc=@(lambda) exp(-sigma(lambda).*mr);
            %Apparent contrast as a function of lambda, pg 5 line 636
            Cr_daylight(i)= C0Aerial.Daylight*integral(CrFunc,lambda1,lambda2);
            %Apparent contrast value accounting for all wavelengths,
            %C0Aerial.Daylight is the contrast of the object
            
            angularSize(i)=atan(T/(2*mr))*2*10^3; %angular size of object in mrad
            Kt_daylight(i)=liminalContrast(A,BAerial.Daylight,angularSize(i)); %line 13 of Alg 1, pg 6
            
            if (10^(Kt_daylight(i))) <= abs(Cr_daylight(i))
                actRangeDaylight(i)=mr;
            else
                tempVisualRange=linspace(mr,mrprev,max(visualRangeDaylight(:,s))*2);
                j=1;
                %while apparent contrast is below liminal contrast the object
                %is invisible, decrease range until apparent contrast is
                %greater than the liminal contrast
                while((10^(Kt_daylight(i))) > abs(Cr_daylight(i)))
                    mr=tempVisualRange(j); %decrease visual range
                    %Recalculate angular size, contrast threshold and apparent
                    %contrast based on the decreased range
                    angularSize(i)=atan(T/(2*mr))*2*10^3;
                    Cr_daylight(i)=C0Aerial.Daylight*integral(CrFunc,lambda1,lambda2);
                    Kt_daylight(i)=liminalContrast(A,BAerial.Daylight,angularSize(i));
                    
                    actRangeDaylight(i,s)=mr;
                    j=j+1;
                    clc;
                    fprintf('iteration: %d %d\n',i,s)
                    fprintf('range: %f\n',mr);
                end
                mrprev=mr;
            end
        end
        mrprev=10;
    end
        
    visualRangeDaylight=actRangeDaylight;
    save([BIGEYEROOT 'fig03_visualrange/aerial_model/parameter_sensitivity/visibilityAerialParameterSensitivity_Daylight.mat'], 'visualRangeDaylight','pupilValuesAir');
    
    
    function Kt = liminalContrast(A,L,angularSize)

    %% FUNCTION DEFINTIONS (Supplement Section V)
    %delta0 is labeled deltar
    %initial definitions -------
    logLa=@(L) log10(L);
    iif = @(varargin) varargin{2 * find([varargin{1:2:end}], 1, 'first')}();
    deltat=@(L) iif( -2<logLa(L) && logLa(L)<=4, @() (1.22*((555e-9)/A)*10^3),...
    logLa(L)<=-2, @() (1.22*((507e-9)/A))*10^3); %supp pg 14 line 1730
    %----------
    %supp pg 15, Eq 9
    Psi=@(L) (logLa(L)+3.5)/2.75; 
    %supp pg 15, Eq 10, typo in the last condition of supplement
    logdeltarStar= @(L) iif(logLa(L)>1.535, @() 0.928,...
        -0.75<=logLa(L) && logLa(L)<=1.535, @() 1-(0.5*(Psi(L)^(-3.2))),...
        -2.089<=logLa(L) && logLa(L)<-0.75, @()-0.28+0.1*Psi(L)^(3.2),...
        logLa(L)<-2.089, @() 0.14*logLa(L)+0.442);
    %supp pg 15, Eq 11
    %sign of logdeltarStar wrong in supplement checked from Aksyutov_2008 on dropbox Eq 4
    X=@(deltar,L) -(-log10(deltar)+logdeltarStar(L));
    %supp  pg 15, Eq 12
    %Typo in the third condition in supplement should be 1.40-0.78*logL,
    %last condition calculated based on the correct equation
    Xm=@(L) iif(logLa(L)>1.5, @() 1.48-0.48*logLa(10^1.5),...
        logLa(L)>0.11 && logLa(L)<=1.5, @() 1.48-0.48*logLa(L),...
        logLa(L)>=-1.46 && logLa(L)<=0.11, @() 1.40-0.78*logLa(L),...
        logLa(L)<-1.46, @() 1.40-0.78*logLa(10^-1.46));
    %supp pg 15, Eq 14
    Ym=@(L) 0.75*Xm(L)-0.32;
    %supp pg 15, Eq 13
    Xr=@(deltar,L) X(deltar,L)./Xm(L);
    %supp pg 15, Eq 15, for first condition refer to comment labeled with(1)
    % Y(L) is defined in the next line of code but is combined in Eq 15
    Yr=@(deltar,L) iif(Xr(deltar,L)<=0.56, @() ((1.6+0.23*logLa(L)).*(Xr(deltar,L)-0.05)).^(0.5),...
        Xr(deltar,L)>0.56, @() (1-((0.42-0.26*logLa(L)).*(1-Xr(deltar,L))))^(0.5));
    Y=@(deltar,L) Yr(deltar,L).*Ym(L);

    %% CALCULATE LIMINAL CONTRAST
    angularResolution=deltat(L);
    deltarparam=angularSize/angularResolution;
    logStardeltar=logdeltarStar(L);
    if log10(deltarparam)<=logStardeltar %condition explained in pg 15 line 1750-1751
        Kt=-2*log10(deltarparam);
    else
        Xparam=X(deltarparam,L);
        Xmparam=Xm(L);
        if Xparam>0 && Xparam<=0.20
            Yval=1.45*Xparam; % first condition of Eq 15 (1)
            Kt =-2*logStardeltar-Yval;
        elseif Xparam>0.20
            Yval=Y(deltarparam,L);
            Kt=-2*logStardeltar-Yval; % supp pg 15, Eq 16
        end
    end        
