function Aquatic_Sensitivity
    global BIGEYEROOT
    %% INITIALIZE VARIABLES
    run Parameters.m
    load('Parameters.mat')
    conditions={'Daylight'};
    pupilValues=linspace(minpupil,maxpupil,30); 
    depth=8; tol=5e-4;

    sensitivityParams.XAquatic=0.08;
    sensitivityParams.qAquatic=0.5;
    sensitivityParams.DtAquatic1=0.0116;
    sensitivityParams.DtAquatic2=1.6;
    sensitivityParams.d=10e-6;
    sensitivityParams.M=3;
    aquaticequiv={'XAquatic','qAquatic','DtAquatic','DtAquatic','d','M'};
    parameters={'XAquatic','qAquatic','DtAquatic1', 'DtAquatic2','d','M'};

    %% SOLVE FOR RANGE
    visualRange_River=zeros(length(pupilValues),2,length(parameters),length(conditions));
    actRange_River=visualRange_River;
    for s=1:length(parameters)
     %for s=3:4
        eval(sprintf('%s=%d',aquaticequiv{s},sensitivityParams.(parameters{s})));
        for i=1:length(conditions);
            if strcmp('Daylight',conditions{i})
                r_down=5;r_hor=3;
            end
            %FOR EACH DAYLIGHT, MOONLIGHT AND STARLIGHT
            %from HYDROLIGHT simulations get a,b,Kd,Ld,Lh
            a=aAquatic.(conditions{i}); b=bAquatic.(conditions{i});
            Kd=KdAquatic.(conditions{i}); Kh=KhAquatic.(conditions{i});
            Ld=LdAquatic.(conditions{i}); Lh=LhAquatic.(conditions{i});
            C0=C0Aquatic.(conditions{i});
            pAbsorb=pAbsorbAquatic.(conditions{i});

            for j=1:length(pupilValues)
                A=pupilValues(j);
                delta_down=10^(floor(log10(r_down))-4);
                delta_hor=10^(floor(log10(r_hor))-4);

                possibleSolnDownwelling=10;
                while abs(possibleSolnDownwelling-1)>tol
                    possibleSolnDownwelling=firingThresh(depth,lambda,...
                        pAbsorb,a,b,Kd,Ld,...
                        r_down,A,XAquatic,DtAquatic,qAquatic,d,k,len,T,M,R,C0);
                    if possibleSolnDownwelling>1
                        r_down=r_down-delta_down;
                    else
                        r_down=r_down+delta_down;
                    end
                    clc;
                    fprintf('pupil iteration: %d %d\n',j,i);
                    fprintf('solution downwelling: %f\n',possibleSolnDownwelling);
                    fprintf('r: %f\n',r_down);
                    fprintf('error downwellling: %f\n', abs(possibleSolnDownwelling-1));
                end

                possibleSolnHorizontal=10;
                while abs(possibleSolnHorizontal-1)>tol
                    possibleSolnHorizontal=firingThresh(depth,lambda,...
                        pAbsorb,a,b,Kh,Lh,...
                        r_hor,A,XAquatic,DtAquatic,qAquatic,d,k,len,T,M,R,C0);
                    if possibleSolnHorizontal>1
                        r_hor=r_hor-delta_hor;
                    else
                        r_hor=r_hor+delta_hor;
                    end
                    clc;
                    fprintf('pupil iteration: %d %d\n',j,i);
                    fprintf('solution horizontal: %f\n',possibleSolnHorizontal);
                    fprintf('r: %f\n',r_hor);
                    fprintf('error horizontal: %f\n', abs(possibleSolnHorizontal-1));
                end

                visualRange_River(j,1,s,i)=r_down;
                visualRange_River(j,2,s,i)=r_hor;
            end
        end
        load('Parameters')
    end

    save([BIGEYEROOT 'fig03_visualrange/aquatic_model/parameter_sensitivity/meteoAquaticSensitivityParameters_All.mat'],'visualRange_River','pupilValues');

%% CONTRAST LIMITING

    load('meteoAquaticSensitivityParameters_All.mat');
    actRange_River=zeros(size(visualRange_River,1),size(visualRange_River,2),size(visualRange_River,3),length(conditions));
    for j=1:length(conditions)     
        for s=1:length(parameters)
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
                mr_down=visualRange_River(i,1,s,j);
                mr_hor=visualRange_River(i,2,s,j);

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
                if (10^(Kt_down(i))<abs(Cr_down(i)))
                    actRange_River(i,1,s,j)=mr_down;
                else    
                    tempVisualRange=linspace(mr_down,mr_down/10,mr_down*1000);
                    ind=1;
                    while(10^(Kt_down(i)) - abs(Cr_down(i)))>5e-2
                        mr_down=tempVisualRange(ind); %decrease range
                        angularSize_down(i)=atan(T/(2*mr_down))*2*10^3;
                        Cr_down(i)=C0*exp((Kd(lambda_down)-a(lambda_down)-b(lambda_down)).*mr_down);
                        Kt_down(i)=liminalContrast(A,Bd,angularSize_down(i));
                        ind=ind+1;
                        fprintf('error:  %f\n',10^(Kt_down(i)) -abs(Cr_down(i)));
                    end
                    actRange_River(i,1,s,j)=mr_down;
                end
                %Horizontal viewing
                if (10^(Kt_hor(i))<abs(Cr_hor(i)))
                    actRange_River(i,2,s,j)=mr_hor;
                else    
                    tempVisualRange=linspace(mr_hor,mr_hor/100,max(visualRange_River(:,j,2))*500);
                    ind=1;
                    while(10^(Kt_hor(i))-abs(Cr_hor(i)))>5e-2
                        mr_hor=tempVisualRange(ind);
                        angularSize_hor(i)=atan(T/(2*mr_hor))*2*10^3;
                        Cr_hor(i)=C0*exp((Kh(lambda_down)-a(lambda_hor)-b(lambda_hor)).*mr_hor);
                        Kt_hor(i)=liminalContrast(A,Bh,angularSize_hor(i));                    
                        ind=ind+1;
                        fprintf('error:  %f\n',10^(Kt_hor(i)) -abs(Cr_hor(i)));
                    end
                    actRange_River(i,2,s,j)=mr_hor;
                end
                fprintf('iteration %d %d:\n',i,s);
            end
        end
    end
    visualRange_River=actRange_River;   
    save([BIGEYEROOT 'fig03_visualrange/aquatic_model/parameter_sensitivity/visibilityAquaticSensitivityParameters_All.mat'],'visualRange_River','pupilValues')

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


function  solution=firingThresh(depth,lambda,photoreceptorAbsorption,a,b,KAll,LAll,r,A,X,Dt,q,d,k,len,T,M,R,C0)
    lambda1=lambda(1); lambda2=lambda(end);
    K=KAll(:,depth);
    L=LAll(:,depth);

    alphaInterp=@(l) interp1(lambda,photoreceptorAbsorption,l,'pchip');
    aInterp=@(l) interp1(lambda,a,l,'pchip');
    bInterp=@(l) interp1(lambda,b,l,'pchip');
    LInterp=@(l) interp1(lambda,L,l,'pchip');
    KInterp=@(l) interp1(lambda,K,l,'pchip');

    Nfalse=((T*M*A)/(2*r*d))^2*X*Dt; %pg 8 combination of line 932 and 933.
    %pg 7, Eq 7 integrand and integral
    RhFunc=@(l) LInterp(l).*l.*(1-exp(-k*alphaInterp(l)*len));
    RoFunc=@(l) LInterp(l).*l.*(1-exp(-k*alphaInterp(l)*len)).*(1+(C0*exp((KInterp(l)-aInterp(l)-bInterp(l))*r)));    
    Rh=integral(RhFunc,lambda1,lambda2);
    Ro=integral(RoFunc,lambda1,lambda2);
    %pg 7, Eq 7 for h, and O
    Nh=((pi/4)^2)*(A^2)*((T/r)^2)*q*Dt*Rh;
    No=((pi/4)^2)*(A^2)*((T/r)^2)*q*Dt*Ro;
    %pg 8, Eq8
    solution=(R*sqrt(No+Nh+2*Nfalse))/(abs(No-Nh));    