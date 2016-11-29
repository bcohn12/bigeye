function [visualRange_River,pupilValues]=Aquatic_contrastLimitingSensitivity
global BIGEYEROOT
    run Parameters.m    
    load('Parameters.mat')
    if exist('meteoAquatic_All.mat','file')==2
        load('meteoAquatic_All.mat');
    else
        [visualRange_River,pupilValues]=Aquatic_firingThresh;
    end
    
    conditions={'Daylight'};
    depth=8; tol=5e-4;
    actRange_River=zeros(size(visualRange_River,1),length(conditions),size(visualRange_River,3));

    for j=1:length(conditions)
        %FOR EACH DAYLIGHT, MOONLIGHT AND STARLIGHT
        %from HYDROLIGHT simulations get a,b,Kd,Ld,Lh, find min absorbance
        %wavelength for apparent contrast calculations 
        a=aAquatic.(conditions{j}); b=bAquatic.(conditions{j}); 
        Kd=KdAquatic.(conditions{j}); Kh=KhAquatic.(conditions{j});
        Kd=Kd(:,depth); Kh=Kh(:,depth);
        Ld=LdAquatic.(conditions{j})(:,depth); Lh=LhAquatic.(conditions{j})(:,depth);
        [~,index_down]=max(Ld); [~,index_hor]=max(Lh);
        lambda_down=lambda(index_down); lambda_hor=lambda(index_hor);
        Bd=BdAquatic.(conditions{j}); Bh=BhAquatic.(conditions{j});
        Bd=Bd(depth); Bh=Bh(depth); %calculation of luminance based on Mobley book done in Parameters
        C0=C0Aquatic.(conditions{j});

        a=@(l) interp1(lambda,a,l,'pchip'); b=@(l) interp1(lambda,b,l,'pchip');
        Kd=@(l) interp1(lambda,Kd,l,'pchip'); Kh=@(l) interp1(lambda,Kh,l,'pchip');

        for i=1:length(pupilValues)
            A=pupilValues(i);
            mr_down=visualRange_River(i,j,1);
            mr_hor=visualRange_River(i,j,2);
            
            %Apparent contrast for horizontal and upward viewing
            Cr_down(i)=C0*exp((Kd(lambda_down)-a(lambda_down)-b(lambda_down)).*mr_down);
            Cr_hor(i)=C0*exp((Kh(lambda_down)-a(lambda_hor)-b(lambda_hor)).*mr_hor);
            %angular size of object horizontal and upward in mrad
            angularSize_down(i)=atan(T/(2*mr_down))*2*10^3;
            angularSize_hor(i)=atan(T/(2*mr_down))*2*10^3;
            Kt_down(i)=liminalContrast(A,Bd,angularSize_down(i));
            Kt_hor(i)=liminalContrast(A,Bh,angularSize_hor(i));
            
            %1.check to see if apparent contrast is above threshold
            %2.if it is range is correct
            %  else
            %      decrease range until the apparent contrast is above
            %      contrast threshold (liminal contrast)
            
            %Upward viewing
            if ((10^(Kt_down(i)))*1.15<abs(Cr_down(i)))
                actRange_River(i,j,1)=mr_down;
            else    
                 tempVisualRange=linspace(mr_down,mr_down/100,max(visualRange_River(:,j,1))*500);
                ind=1;
                while((10^(Kt_down(i)))*1.15 - abs(Cr_down(i)))>5e-3
                    mr_down=tempVisualRange(ind); %decrease range
                    angularSize_down(i)=atan(T/(2*mr_down))*2*10^3;
                    Cr_down(i)=C0*exp((Kd(lambda_down)-a(lambda_down)-b(lambda_down)).*mr_down);
                    Kt_down(i)=liminalContrast(A,Bd,angularSize_down(i));
                    ind=ind+1;
                    clc;
                    fprintf('error:  %f\n',10^(Kt_down(i)) -abs(Cr_down(i)));
                end
                actRange_River(i,j,1)=mr_down;
            end
            %Horizontal viewing
            if ((10^(Kt_hor(i)))*1.15<abs(Cr_hor(i)))
                actRange_River(i,j,2)=mr_hor;
            else    
                tempVisualRange=linspace(mr_hor,mr_hor/100,max(visualRange_River(:,j,2))*500);
                ind=1;
                while((10^(Kt_hor(i)))*1.15-abs(Cr_hor(i)))>5e-4
                    mr_hor=tempVisualRange(ind);
                    angularSize_hor(i)=atan(T/(2*mr_hor))*2*10^3;
                    Cr_hor(i)=C0*exp((Kh(lambda_down)-a(lambda_hor)-b(lambda_hor)).*mr_hor);
                    Kt_hor(i)=liminalContrast(A,Bh,angularSize_hor(i));                    
                    ind=ind+1;
                    clc;
                    fprintf('error:  %f\n',10^(Kt_hor(i)) -abs(Cr_hor(i)));
                end
                actRange_River(i,j,2)=mr_hor;
            end
            fprintf('iteration %d %d:\n',i,j);
        end
    end
    visualRange_River=actRange_River;   
    save([BIGEYEROOT 'fig03_visualrange/aquatic_model/visibilityAquaticSensitivityContrast.mat'],'visualRange_River','pupilValues')

function Kt = liminalContrast(A,L,angularSize)
%Equations should be the same as in the aquatic case, quick annotation
    %% FUNCTION DEFINTIONS
    logLa=@(L) log10(L);
    iif = @(varargin) varargin{2 * find([varargin{1:2:end}], 1, 'first')}();
    deltat=@(L) iif( -2<logLa(L) && logLa(L)<=4, @() (1.22*((555e-9)/A)*10^3),...
        logLa(L)<=-2, @() (1.22*((507e-9)/A))*10^3); %pg 14 line 1730

    Psi=@(L) (logLa(L)+3.5)/2.75; %pg 15, Eq 9
    logdeltarStar= @(L) iif(logLa(L)>1.535, @() 0.928,...
        -0.75<=logLa(L) && logLa(L)<=1.535, @() 1-(0.5*(Psi(L)^(-3.2))),...
        -2.089<=logLa(L) && logLa(L)<-0.75, @()-0.28+0.1*Psi(L)^(3.2),...
        logLa(L)<-2.089, @() 0.14*logLa(L)+0.442); %last condition typo in text, pg 15, Eq 10
    X=@(deltar,L) -(-log10(deltar)+logdeltarStar(L)); %sign typo in text, pg 15, Eq 11
    Xm=@(L) iif(logLa(L)>1.5, @() 1.48-0.48*logLa(10^1.5),...
        logLa(L)>0.11 && logLa(L)<=1.5, @() 1.48-0.48*logLa(L),...
        logLa(L)>=-1.46 && logLa(L)<=0.11, @() 1.40-0.78*logLa(L),...
        logLa(L)<-1.46, @() 1.40-0.78*logLa(10^-1.46)); %3rd condition typo in text, pg 15, Eq 12
    Ym=@(L) 0.75*Xm(L)-0.32; %pg 15, Eq 14
    Xr=@(deltar,L) X(deltar,L)./Xm(L); %pg 15, Eq 13
    Yr=@(deltar,L) iif(Xr(deltar,L)<=0.56, @() ((1.6+0.23*logLa(L)).*(Xr(deltar,L)-0.05)).^(0.5),...
        Xr(deltar,L)>0.56, @() (1-((0.42-0.26*logLa(L)).*(1-Xr(deltar,L))))^(0.5)); 
    Y=@(deltar,L) Yr(deltar,L).*Ym(L);%pg 15, Eq 15 combined with the above equation

    %% CALCULATE LIMINAL CONTRAST
    angularResolution=deltat(L);
    deltarparam=angularSize/angularResolution;
    logStardeltar=logdeltarStar(L);
    if log10(deltarparam)<=logStardeltar
        Kt=-2*log10(deltarparam); %pg 15, line 1750
    else
        Xparam=X(deltarparam,L);
        Xmparam=Xm(L);
        if Xparam>0 && Xparam<=0.20 %first condition of pg 15, Eq 15
            Yval=1.45*Xparam;
            Kt =-2*logStardeltar-Yval; %pg 15, Eq 16
        elseif Xparam>0.20
            Yval=Y(deltarparam,L); %taken care of in the above functions
            Kt=-2*logStardeltar-Yval; %pg 15, Eq 16
        end
    end        