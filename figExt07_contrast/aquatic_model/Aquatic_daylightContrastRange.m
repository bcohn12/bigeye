function [visualRange_River,C0Range,pupilValues]=Aquatic_daylightContrastRange
global BIGEYEROOT
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
    
    tol=5e-5; depth=8; r_down=5.7; r_hor=3.7;
    C0Range=linspace(-1,4,20);
    
    a=aAquatic.Daylight; b=bAquatic.Daylight; 
    Kd=KdAquatic.Daylight(:,depth); Kh=KhAquatic.Daylight(:,depth);
    Ld=LdAquatic.Daylight(:,depth); Lh=LhAquatic.Daylight(:,depth);
    [~,index_down]=max(Ld); [~,index_hor]=max(Lh);
    lambda_down=lambda(index_down); lambda_hor=lambda(index_hor);
    Bd=BdAquatic.Daylight(depth); Bh=BhAquatic.Daylight(depth);
    pAbsorb=pAbsorbAquatic.Daylight;
    KdF=@(l) interp1(lambda,Kd,l,'pchip'); KhF=@(l) interp1(lambda,Kh,l,'pchip');
    aF=@(l) interp1(lambda,a,l,'pchip'); bF=@(l) interp1(lambda,b,l,'pchip');
      
    visualRange_River=zeros(length(C0Range),length(pupilValues),2);    
    for j=1:length(pupilValues);
        A=pupilValues(j);
        for i=1:length(C0Range);
            C0=C0Range(i);
            delta_down=10^(floor(log10(r_down))-5);
            delta_hor=10^(floor(log10(r_hor))-5);
            
            possibleSolnDown=10;
            while abs(possibleSolnDown-1)>tol
                possibleSolnDown=firingThresh(lambda,...
                     pAbsorb,a,b,Kd,Ld,...
                     r_down,A,XAquatic,DtAquatic,qAquatic,d,k,len,T,M,R,C0);
                 
                 if possibleSolnDown>1
                     r_down=r_down-delta_down;
                 else
                     r_down=r_down+delta_down;
                 end
                 clc;
                 fprintf('pupil iteration: %d %d\n',j,i);
                 fprintf('solution downwelling: %f\n',possibleSolnDown);
                 fprintf('r: %f\n',r_down);
                 fprintf('error downwellling: %f\n', abs(possibleSolnDown-1));
            end            
            mr_down=r_down;
                                
            possibleSolnHor=10;
            while abs(possibleSolnHor-1)>tol
                possibleSolnHor=firingThresh(lambda,...
                     pAbsorb,a,b,Kh,Lh,...
                     r_hor,A,XAquatic,DtAquatic,qAquatic,d,k,len,T,M,R,C0);                
                 
                 if possibleSolnHor>1
                     r_hor=r_hor-delta_hor;
                 else
                     r_hor=r_hor+delta_hor;
                 end
                 clc;
                 fprintf('pupil iteration: %d %d\n',j,i);
                 fprintf('solution horizontal: %f\n',possibleSolnHor);
                 fprintf('r: %f\n',r_hor);
                 fprintf('error horizontal: %f\n', abs(possibleSolnHor-1));
            end            
            mr_hor=r_hor;
            
            Cr_down(i)=C0*exp((KdF(lambda_down)-aF(lambda_down)-bF(lambda_down)).*mr_down);
            Cr_hor(i)=C0*exp((KhF(lambda_down)-aF(lambda_hor)-bF(lambda_hor)).*mr_hor);            
            angularSize_down(i)=atan(T/(2*mr_down))*2*10^3;
            angularSize_hor(i)=atan(T/(2*mr_hor))*2*10^3;            
            Kt_down(i)=liminalContrast(A,Bd,angularSize_down(i));
            Kt_hor(i)=liminalContrast(A,Bh,angularSize_hor(i));

            if (10^(Kt_down(i))<abs(Cr_down(i)))
                visualRange_River(i,j,1)=mr_down;
            else    
                tempVisualRange=linspace(mr_down,floor(mr_down/10),ceil(mr_down)*1000);
                ind=1;
                while(10^(Kt_down(i)) - abs(Cr_down(i)))>5e-2
                    mr_down=tempVisualRange(ind);
                    angularSize_down(i)=atan(T/(2*mr_down))*2*10^3;
                    Cr_down(i)=C0*integral(CrFunc_down,lambda1,lambda2);
                    Kt_down(i)=liminalContrast(A,Bd,angularSize_down(i));
                   
                    ind=ind+1;                    
                    fprintf('error: %f\n',(10^(Kt_hor(i))-abs(Cr_hor(i))));
                end
                visualRange_River(i,j,1)=mr_down;
            end
                
            if (10^(Kt_hor(i))<abs(Cr_hor(i)))
                visualRange_River(i,j,2)=mr_hor;
            else    
                tempVisualRange=linspace(mr_hor,floor(mr_hor/10),ceil(mr_hor)*1000);
                ind=1;
                while(10^(Kt_hor(i))-abs(Cr_hor(i)))>5e-2
                    mr_hor=tempVisualRange(ind);
                    angularSize_hor(i)=atan(T/(2*mr_hor))*2*10^3;
                    Cr_hor(i)=C0*integral(CrFunc_hor,lambda1,lambda2);
                    Kt_hor(i)=liminalContrast(A,Bh,angularSize_hor(i));
                    
                    ind=ind+1;
                    fprintf('error: %f\n',(10^(Kt_hor(i))-abs(Cr_hor(i))));
                end
                visualRange_River(i,j,2)=mr_hor;
            end
        end
    end
    
    save([BIGEYEROOT, 'figExt07_contrast/aquatic_model/Aquatic_daylightContrastRange.mat'],'C0Range','pupilValues','visualRange_River');
            
function  solution=firingThresh(lambda,photoreceptorAbsorption,a,b,K,L,r,A,X,Dt,q,d,k,len,T,M,R,C0)
    lambda1=lambda(1); lambda2=lambda(end);

    alphaInterp=@(l) interp1(lambda,photoreceptorAbsorption,l,'pchip');
    aInterp=@(l) interp1(lambda,a,l,'pchip');
    bInterp=@(l) interp1(lambda,b,l,'pchip');
    LInterp=@(l) interp1(lambda,L,l,'pchip');
    KInterp=@(l) interp1(lambda,K,l,'pchip');
    
    Nfalse=((T*M*A)/(2*r*d))^2*X*Dt;
    RhFunc=@(l) LInterp(l).*l.*(1-exp(-k*alphaInterp(l)*len));
    RoFunc=@(l) LInterp(l).*l.*(1-exp(-k*alphaInterp(l)*len)).*(1+(C0*exp((KInterp(l)-aInterp(l)-bInterp(l))*r)));
    
    Rh=integral(RhFunc,lambda1,lambda2);
    Ro=integral(RoFunc,lambda1,lambda2);
    
    Nh=((pi/4)^2)*(A^2)*((T/r)^2)*q*Dt*Rh;
    No=((pi/4)^2)*(A^2)*((T/r)^2)*q*Dt*Ro;

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
        Xmparam=Xm(L);
        if Xparam>0 && Xparam<=0.20
            Yval=1.45*Xparam;
            Kt =-2*logStardeltar-Yval;
        elseif Xparam>0.20
            Yval=Y(deltarparam,L);
            Kt=-2*logStardeltar-Yval;
        end
    end        
