function [visualRangeSolns,C0Range,pupilValues] = Aerial_contrastRangeRelation
global BIGEYEROOT
%% INITIALIZATION
    run Parameters.m
    load('Parameters.mat')
    load OM_TF_ST.mat
    load FinnedDigitedOrbitLength.mat
    
    pupil_TF = [mean(noElpistoOrb)-std(noElpistoOrb) mean(noElpistoOrb)+std(noElpistoOrb)].*0.449;
    pupil_ST = [mean(noSecAqOrb)-std(noSecAqOrb) mean(noSecAqOrb)+std(noSecAqOrb)].*0.449;
    fishpupil=mean(noElpistoOrb)*.449;
    tetrapodpupil=mean(noSecAqOrb)*.449;
    pupilValues=sort([fishpupil,tetrapodpupil]*1e-3);
    C0Range=linspace(-1,4,20);
    
    tol=5e-5; r=1.4e4;
    WlambdaylambdaInterp= @(lambda) interp1(Wlambdaylambda(:,1),Wlambdaylambda(:,2),lambda,'pchip'); %value checked with mathematica
    lambda1=0.4; lambda2=0.7;
    sigma=@(lambda) ((1.1e-3*lambda.^(-4))+(0.008*lambda.^(-2.09)))/(1e3); %value checked with mathmematica
    
    Rh=BAerial.Daylight*integral(WlambdaylambdaInterp,lambda1,lambda2); %value checked with mathematica
    Nh=((1.31e3)/0.89)*Rh*(1e6)^2; %value checked with mathematica
    
%% CALCULATE RANGE FROM FIRING THRESHOLD
    Bh=BAerial.Daylight; Dt=DtAerial.Daylight; F=FAerial.Daylight;
    X=XAerial; q=qAerial.Daylight;

    visualRangeSolns=zeros(length(C0Range),length(pupilValues));        
    for i=1:length(pupilValues)
        A=pupilValues(i);
        for c=1:length(C0Range)
            delta=10^(floor(log10(r))-5);
            C0=C0Range(c);                       
            possibleSolution=10;
            while abs(possibleSolution-1)>=tol
                possibleSolution=firingThreshRange(...
                     WlambdaylambdaInterp,A,r,C0,Bh,...
                     T,F,Nh,Dt,q,k,len,X,d,R);
                if possibleSolution>1
                    r=r-delta;
                else
                    r=r+delta;
                end
                clc
                fprintf('iteration: %d, %d \n', c,i);
                fprintf('possibleSolution: %f \n', possibleSolution);
                fprintf('range: %f \n', r);
                fprintf('error: %f \n', abs(possibleSolution-1));
            end
            visualRangeSolns(c,i)=r;
            mr=visualRangeSolns(c,i);

%% LIMIT RANGE WITH CONTRAST THRESHOLD
            CrFunc=@(lambda) exp(-sigma(lambda).*mr);
            Cr= C0*integral(CrFunc,lambda1,lambda2);

            angularSize=atan(T/(2*mr))*2*10^3;
            Kt=liminalContrast(A,Bh,angularSize);

            if 10^(Kt) <= abs(Cr)
                 visualRangeSolns(c,i)=mr;
            else
                delta=delta*1e1;
                while(10^(Kt)>abs(Cr))
                    mr=mr-delta;
                    angularSize=atan(T/(2*mr))*2*10^3;
                    Cr=C0*integral(CrFunc,lambda1,lambda2);
                    Kt=liminalContrast(A,Bh,angularSize);
                    clc
                    fprintf('iteration: %d, %d \n', c,i);
                    fprintf('range: %f \n',mr);
                    fprintf('error: %f \n', 10^(Kt)-abs(Cr));
                end
                visualRangeSolns(c,i)=mr;
            end

        end
    end
    save([BIGEYEROOT,'figExt07_contrast/aerial_model/Aerial_daylightContrastRange.mat'],'visualRangeSolns','C0Range','pupilValues');                

    
function  solution=firingThreshRange(WHandle,A,r,C0,L,T,F,Ispace,Dt,q,k,len,X,d,R)
    lambda1=0.4; lambda2=0.7;
    sigma=@(lambda) ((1.1e-3*lambda.^(-4))+(0.008*lambda.^(-2.09)))/(1e3); %value checked with mathmematica
    
    Nh=(pi/4)^2*(T/r)^2*A^2*Ispace*Dt*q*((k*len)/(2.3+(k*len)));
    Nfalse=((T*F*A)/(r*d))^2*X*Dt;

    %APPARENT RADIANCE OF THE GREY OBJECT
    Bofunc=@(lambda) WHandle(lambda).*(1+(C0.*exp(-sigma(lambda).*r)));
    Bo= L*integral(Bofunc,lambda1,lambda2);
    Ro=((1.31e3)/0.89)*Bo*(1e6)^2;
    No=(pi/4)^2*(T/r)^2*A^2*Ro*Dt*q*((k*len)/(2.3+(k*len)));

    solution=(R*sqrt(No+Nh+2*Nfalse))/(abs(No-Nh));

function Kt = liminalContrast(A,L,angularSize)
    %% FUNCTION DEFINTIONS
    logLa=@(L) log10(L);
    iif = @(varargin) varargin{2 * find([varargin{1:2:end}], 1, 'first')}();

    deltat=@(L) iif( -2<logLa(L) && logLa(L)<=4, @() (1.22*((555e-9)/A)*10^3),...
        logLa(L)<=-2, @() (1.22*((507e-9)/A))*10^3);  
    Psi=@(L) (logLa(L)+3.5)/2.75;
    logdeltarStar= @(L) iif(logLa(L)>1.535, @() 0.928,...
        -0.75<=logLa(L) && logLa(L)<=1.535, @() 1-(0.5*(Psi(L)^(-3.2))),...
        -2.089<=logLa(L) && logLa(L)<-0.75, @()-0.28+0.1*Psi(L)^(3.2),...
        logLa(L)<-2.089, @() 0.14*logLa(L)+0.442);
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
        if Xparam>0 && Xparam<=0.20
            Yval=1.45*Xparam;
            Kt =-2*logStardeltar-Yval;
        elseif Xparam>0.20
            Yval=Y(deltarparam,L);
            Kt=-2*logStardeltar-Yval;
        end
    end         