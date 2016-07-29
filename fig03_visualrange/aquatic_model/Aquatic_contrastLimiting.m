function [visualRange_River,pupilValues]=Aquatic_contrastLimiting
global BIGEYEROOT
    run Parameters.m    
    load('Parameters.mat')
    if exist('meteoAquatic_All.mat','file')==2
        load('meteoAquatic_All.mat');
    else
        [visualRange_River,pupilValues]=Aquatic_firingThresh;
    end
    
    conditions={'Daylight','Moonlight','Starlight'};
    depth=8; tol=5e-4;
    actRange_River=zeros(size(visualRange_River,1),size(visualRange_River,2),size(visualRange_River,3));

    for j=1:length(conditions)
        aString=strcat('aAquatic_',conditions{j}); bString=strcat('bAquatic_',conditions{j});
        KdString=strcat('KdAquatic_',conditions{j}); KhString=strcat('KhAquatic_',conditions{j});      
        BdString=strcat('BdAquatic_',conditions{j}); BhString=strcat('BhAquatic_',conditions{j});
        C0String=strcat('C0Aquatic_',conditions{j});
        
        a=eval(aString); b=eval(bString); Kd=eval(KdString); Kh=eval(KhString);
        Kd=Kd(:,depth); Kh=Kh(:,depth);
        a=@(l) interp1(lambda,a,l,'pchip'); b=@(l) interp1(lambda,b,l,'pchip');
        Kd=@(l) interp1(lambda,Kd,l,'pchip'); Kh=@(l) interp1(lambda,Kh,l,'pchip');
       
        Bd=eval(BdString); Bh=eval(BhString); C0=eval(C0String);
        Bd=Bd(depth); Bh=Bh(depth);
        for i=1:length(pupilValues)
            A=pupilValues(i);
            mr_down=visualRange_River(i,j,1);
            mr_hor=visualRange_River(i,j,2);

            CrFunc_down=@(lambda) exp((Kd(lambda)-a(lambda)-b(lambda)).*mr_down);
            CrFunc_hor=@(lambda) exp((Kh(lambda)-a(lambda)-b(lambda)).*mr_hor);
            Cr_down(i)= C0*integral(CrFunc_down,lambda(1),lambda(end));
            Cr_hor(i)=C0*integral(CrFunc_hor,lambda(1),lambda(end));

            angularSize_down(i)=atan(T/(2*mr_down))*2*10^3;
            angularSize_hor(i)=atan(T/(2*mr_down))*2*10^3;

            Kt_down(i)=liminalContrast(A,Bd,angularSize_down(i));
            Kt_hor(i)=liminalContrast(A,Bh,angularSize_hor(i));

            if (10^(Kt_down(i))<abs(Cr_down(i)))
                actRange_River(i,j,1)=mr_down;
            else    
                tempVisualRange=linspace(mr_down,mr_down/100,max(visualRange_River(:,j,1))*100);
                ind=1;
                while(10^(Kt_down(i)) > abs(Cr_down(i)))
                    mr_down=tempVisualRange(j);
                    angularSize_down(i)=atan(T/(2*mr_down))*2*10^3;
                    Cr_down(i)=C0*integral(CrFunc_down,lambda1,lambda2);
                    Kt_down(i)=liminalContrast(A,Bd,angularSize_down(i));

                    actRange_River(i,j,1)=mr_down;
                    ind=ind+1;
                end
            end

            if (10^(Kt_hor(i))<abs(Cr_hor(i)))
                actRange_River(i,j,2)=mr_hor;
            else    
                tempVisualRange=linspace(mr_hor,mr_hor/100,max(visualRange_River(:,j,2))*100);
                ind=1;
                while(10^(Kt_hor(i)) > abs(Cr_hor(i)))
                    mr_hor=tempVisualRange(ind);
                    angularSize_hor(i)=atan(T/(2*mr_hor))*2*10^3;
                    Cr_down(i)=C0*integral(CrFunc_hor,lambda1,lambda2);
                    Kt_hor(i)=liminalContrast(A,Bh,angularSize_hor(i));

                    actRange_River(i,j,2)=mr_hor;
                    ind=ind+1;
                end
            end
        end
    end
    visualRange_River=actRange_River;   
    save([BIGEYEROOT 'fig03_visualrange/aquatic_model/visibilityAquatic_All.mat'],'visualRange_River','pupilValues')

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
