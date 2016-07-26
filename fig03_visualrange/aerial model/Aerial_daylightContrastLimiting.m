function [actRangeDaylight] =Aerial_daylightContrastLimiting
    %% INITIALIZE/LOAD DATA
    run ../../figXX_compviz/Parameters.m
    if exist('meteoAerial_Daylight.mat','file')==2
        load('meteoAerial_Daylight');
    else
        [visualRangeDaylight,pupilValuesAir]=Aerial_daylightFiringThresh;
        clc;
    end

    sigma=@(lambda) ((1.1e-3*lambda.^(-4))+(0.008*lambda.^(-2.09)))/(1e3); %value checked with mathmematica
    lambda1=0.4; lambda2=0.7;

    %% CALCULATE RANGE DAYLIGHT
    actRangeDaylight=zeros(length(visualRangeDaylight),1);
    Cr_daylight=actRangeDaylight; angularSize=actRangeDaylight; Kt_daylight=Cr_daylight;
    mrprev=10;
    for i=1:length(pupilValuesAir);
        A=pupilValuesAir(i);
        mr=visualRangeDaylight(i);

        CrFunc=@(lambda) exp(-sigma(lambda).*mr);
        Cr_daylight(i)= C0Aerial_Daylight*integral(CrFunc,lambda1,lambda2);

        angularSize(i)=atan(T/(2*mr))*2*10^3;
        Kt_daylight(i)=liminalContrast(A,BAerial_Daylight,angularSize(i));

        if 10^(Kt_daylight(i)) <= abs(Cr_daylight(i))
            actRangeDaylight(i)=mr;
        else
            tempVisualRange=linspace(mr,mrprev,max(visualRangeDaylight)*2);
            j=1;
            while(10^(Kt_daylight(i)) > abs(Cr_daylight(i)))
                mr=tempVisualRange(j);
                angularSize(i)=atan(T/(2*mr))*10^3;
                Cr_daylight(i)=C0Aerial_Daylight*integral(CrFunc,lambda1,lambda2);
                Kt_daylight(i)=liminalContrast(A,BAerial_Daylight,angularSize(i));

                actRangeDaylight(i)=mr;
                j=j+1;
                clc;
                fprintf('iteration: %d\n',i)
                fprintf('range: %f\n',mr);
            end
            mrprev=mr;
        end

    end

    visualRangeDaylight=actRangeDaylight;
    save('visibilityAerial_Daylight', 'visualRangeDaylight','pupilValuesAir');
   
function Kt = liminalContrast(A,L,angularSize)

    %% FUNCTION DEFINTIONS (Supplement Section V)
    logLa=@(L) log10(L);
    iif = @(varargin) varargin{2 * find([varargin{1:2:end}], 1, 'first')}();

    deltat=@(L) iif( -2<logLa(L) && logLa(L)<=4, @() (1.22*((555e-9)/A)*10^3),...
        logLa(L)<=-2, @() (1.22*((507e-9)/A))*10^3);  
    Psi=@(L) (logLa(L)+3.5)/2.75;
    logdeltarStar= @(L) iif(logLa(L)>1.535, @() 0.928,...
        -0.75<=logLa(L) && logLa(L)<=1.535, @() 1-(0.5*(Psi(L)^(-3.2))),...
        -2.089<=logLa(L) && logLa(L)<-0.75, @()-0.28+0.1*Psi(L)^(3.2),...
        logLa(L)<-2.089, @() 0.19*logLa(L)+0.442);
    X=@(deltar,L) -(-log10(deltar)+logdeltarStar(L));
    Xm=@(L) iif(logLa(L)>1.5, @() 1.48-0.48*logLa(10^1.5),...
        logLa(L)>0.11 && logLa(L)<=1.5, @() 1.48-0.48*logLa(L),...
        logLa(L)>=-1.46 && logLa(L)<=0.11, @() 1.40-0.78*logLa(L),...
        logLa(L)<-1.46, @() 1.40-0.78*logLa(10^-1.46));
    Ym=@(L) 0.75*Xm(L)-0.32;

    Xr=@(deltar,L) X(deltar,L)./Xm(L);
    Yr=@(deltar,L) iif(Xr(deltar,L)<=0.56, @() ((1.6+0.23*logLa(L)).*(Xr(deltar,L)-0.05)).^(0.5),...
        Xr(deltar,L)>0.56, @() (1-((0.42-0.26*logLa(L)).*(1-Xr(deltar,L))))^(0.5));
    Y=@(deltar,L) Yr(deltar,L).*Ym(L);

    %% CALCULATE LIMINAL CONTRAST
    angularResolution=deltat(L);
    deltarparam=angularSize/angularResolution;
    logStardeltar=logdeltarStar(L);
    if log10(deltarparam)<=logStardeltar
        Kt=-2*log10(deltarparam);
    else
        Xparam=X(deltarparam,L);
        Xmparam=Xm(L);
        if Xparam>0 && Xparam<=0.20
            Yval=1.45*Xparam;
            Kt =-2*logStardeltar-Yval;
        elseif Xparam>0.20
            Yval=Y(deltarparam,L);
            Kt=-2*logStardeltar-Yval;
        end
    end        