function [visualRange,pupilValues]=Aquatic_contrastLimitedSensitivity
    global BIGEYEROOT
    run ParametersSensitivity.m
    load('ParametersSensitivity.mat');
    if exist('Aquatic_meteoRangeSensitivity.mat','file')==2
        load('Aquatic_meteoRangeSensitivity.mat');
    else
        [visualRangeSensitivity,pupilValues]=Aquatic_firingThreshSensitivity;
    end
    
    conditions={'HighTurbidity','Clear','AbsDom','ScatDom'};
    viewing={'up','hor'};
    waterDepth=15;
    pupilValues=linspace(minpupil,maxpupil,30);   
    actRangeSensitivity=visualRangeSensitivity;
    lambda1=lambda(1); lambda2=lambda(end);
    for k=1:length(viewing)
        for j=1:length(conditions)              
            aValue=a.(conditions{j}); bValue=b.(conditions{j});
            KValue.up=Kd.(conditions{j})(:,waterDepth); KValue.hor=Kh.(conditions{j})(:,waterDepth);
            BValue.up=Bd.(conditions{j})(waterDepth); BValue.hor=Bh.(conditions{j})(waterDepth);           
            LValue.up=Ld.(conditions{j})(:,waterDepth); LValue.hor=Lh.(conditions{j})(:,waterDepth);
            [~,index.up]=max(LValue.up); [~,index.hor]=max(LValue.hor); 
            lmax.up=lambda(index.up); lmax.hor=lambda(index.hor);

            aValue=@(l) interp1(lambda,aValue,l,'pchip'); bValue=@(l) interp1(lambda,bValue,l,'pchip');
            KValue.up=@(l) interp1(lambda,KValue.up,l,'pchip'); KValue.hor=@(l) interp1(lambda,KValue.hor,l,'pchip');
            for i=1:length(pupilValues)
               A=pupilValues(i);
               mr=visualRangeSensitivity(i,j,k);
               tol=5e-2;
                if strcmp(conditions{j},'AbsDom')
                    tol=5e-5;
                end
                
                Cr.(viewing{k})=C0*exp((KValue.(viewing{k})(lmax.(viewing{k}))-aValue(lmax.(viewing{k}))-bValue(lmax.(viewing{k}))).*mr);
                angularSize.(viewing{k})=atan(T/(2*mr))*2*10^3;
                Kt.(viewing{k})=liminalContrast(A,BValue.(viewing{k}),angularSize.(viewing{k}));
                if (10^(Kt.(viewing{k}))<abs(Cr.(viewing{k})))
                    actRangeSensitivity(i,j,1)=mr;
                else
                    tempVisualRange=linspace(mr,mr/10,mr*100);
                    ind=1;
                    while 10^(Kt.(viewing{k}))-abs(Cr.(viewing{k}))>tol
                        mr=tempVisualRange(ind);
                        angularSize.(viewing{k})=atan(T/(2*mr))*2*10^3;
                        Cr.(viewing{k})=C0*exp((KValue.(viewing{k})(lmax.(viewing{k}))-aValue(lmax.(viewing{k}))-bValue(lmax.(viewing{k}))).*mr);
                        Kt.(viewing{k})=liminalContrast(A,BValue.(viewing{k}),angularSize.(viewing{k}));
                 
                        ind=ind+1;
                        clc
                        fprintf('iteration: %d %d %d\n',i,j,k);
                        fprintf('it: %d\n',ind);
                        fprintf('error: %f\n',10^(Kt.(viewing{k})) -abs(Cr.(viewing{k})));
                    end
                    actRangeSensitivity(i,j,k)=mr;
                end
            end
        end
    end
    
    visualRangeSensitivity=actRangeSensitivity;   
    save([BIGEYEROOT, 'figExt06_sensitivity/aquatic_model/Aquatic_visRangeSensitivity.mat'],'visualRangeSensitivity','pupilValues');
                
                
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
