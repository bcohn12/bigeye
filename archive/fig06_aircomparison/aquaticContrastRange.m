function aquaticContrastRange
    
    run ../figXX_compviz/Parameters.m
    load ../fig02_orbitsize/OM_TF_ST.mat
    pupil_TF = [mean(OM_TF)-std(OM_TF) mean(OM_TF)+std(OM_TF)].*0.449;
    pupil_ST = [mean(OM_ST)-std(OM_ST) mean(OM_ST)+std(OM_ST)].*0.449;

    fishpupil=mean(OM_TF)*.449;
    tetrapodpupil=mean(OM_ST)*.449;    
    pupilValues=sort([fishpupil,tetrapodpupil,pupil_TF,pupil_ST]*1e-3);
    
    tol=5e-5; depth=8; r=5.75;
    
    a=a_Sun; b=b_Sun; Kd=Kd_Sun(:,depth); L=Ld_Sun(:,depth); Bd=Bd_Sun(depth); pAbsorb=pAbsorb_Sun;
    KdF=@(l) interp1(lambda,Kd,l,'pchip'); LF=@(l) interp1(lambda,L,l,'pchip');
    aF=@(l) interp1(lambda,a,l,'pchip'); bF=@(l) interp1(lambda,b,l,'pchip');
    
    C0Range=linspace(-1,4,20);
    
    visualRange_River=zeros(length(C0Range),length(pupilValues));
    
    for j=1:length(pupilValues);
        A=pupilValues(j);
        for i=1:length(C0Range);
            C0=C0Range(i);
            delta=10^(floor(log10(r))-5);
            
            possibleSoln=10;
            while abs(possibleSoln-1)>tol
                possibleSoln=firingThresh(lambda,...
                     pAbsorb,a,b,Kd,L,...
                     r,A,X,Dt,q,d,k,len,T,M,R,C0);
                 
                 if possibleSoln>1
                     r=r-delta;
                 else
                     r=r+delta;
                 end
                 clc;
                 fprintf('pupil iteration: %d %d\n',j,i);
                fprintf('solution downwelling: %f\n',possibleSoln);
                fprintf('r: %f\n',r);
                fprintf('error downwellling: %f\n', abs(possibleSoln-1));
            end            
            mr=r;
            
            CrFunc=@(l) exp((KdF(l)-aF(l)-bF(l)).*mr);
            Cr(i)= C0*integral(CrFunc,lambda(1),lambda(end));
            angularSize(i)=atan(T/(2*mr))*2*10^3;   
            Kt(i)=liminalContrast(A,Bd,angularSize(i));

            if (10^(Kt(i))<abs(Cr(i)))
                visualRange_River(i,j)=mr;
            else    
                tempVisualRange=linspace(mr,mr/100,max(visualRange_River(:,j))*100);
                ind=1;
                while(10^(Kt(i)) > abs(Cr(i)))
                    mr=tempVisualRange(ind);
                    angularSize(i)=atan(T/(2*mr))*2*10^3;
                    Cr(i)=C0*integral(CrFunc,lambda1,lambda2);
                    Kt(i)=liminalContrast(A,Bd,angularSize(i));

                    visualRange_River(i,j)=mr;
                    ind=ind+1;
                end
            end
        end
    end
            
function  solution=firingThresh(lambda,photoreceptorAbsorption,a,b,K,L,r,A,X,Dt,q,d,k,len,T,M,R,C0)
    lambda1=lambda(1); lambda2=lambda(end);

    alphaInterp=@(l) interp1(lambda,photoreceptorAbsorption,l,'pchip');
    aInterp=@(l) interp1(lambda,a,l,'pchip');
    bInterp=@(l) interp1(lambda,b,l,'pchip');
    LInterp=@(l) interp1(lambda,L,l,'pchip');
    KInterp=@(l) interp1(lambda,K,l,'pchip');
    
    Xch=((T*M*A)/(2*r*d))^2*X*Dt;
    IspaceFunc=@(l) LInterp(l).*l.*(1-exp(-k*alphaInterp(l)*len));
    IblackFunc=@(l) LInterp(l).*l.*(1-exp(-k*alphaInterp(l)*len)).*(1+(C0*exp((KInterp(l)-aInterp(l)-bInterp(l))*r)));
    
    Ispace=integral(IspaceFunc,lambda1,lambda2);
    %IspaceInterp=@(l) interp1(lambda,Ispace,l,'pchip');
    %IblackFunc=@(l) Ispace.*(1-exp((KInterp(l)-aInterp(l)-bInterp(l))*r));
    Iblack=integral(IblackFunc,lambda1,lambda2);
    
    Nspace=((pi/4)^2)*(A^2)*((T/r)^2)*q*Dt*Ispace;
    Nblack=((pi/4)^2)*(A^2)*((T/r)^2)*q*Dt*Iblack;

    solution=(R*sqrt(Nblack+Nspace+2*Xch))/(abs(Nblack-Nspace));  
    
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
