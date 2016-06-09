function smallestTargetSize

    run ../figXX_compviz/Parameters.m
    %load('actualDaylight');
    %load('actualMoonlight');
    %load('actualStarlight');
    %load('pupilSizevsRangeConstantDepth_Coastal');
    %load('pupilSizevsRangeConstantDepth_River');
    
    WlambdaylambdaInterp= @(lambda) interp1(Wlambdaylambda(:,1),Wlambdaylambda(:,2),lambda,'pchip'); %value checked with mathematica

    %following Middleton:
    lambda1=0.4; lambda2=0.7;
    sigma=@(lambda) ((1.1e-3*lambda.^(-4))+(0.008*lambda.^(-2.09)))/(1e3); %value checked with mathmematica
    
    BhD=LDaylight*integral(WlambdaylambdaInterp,lambda1,lambda2); %value checked with mathematica
    IspaceD=((1.31e3)/0.89)*BhD*(1e6)^2; %value checked with mathematica
    
    BhM=LMoonlight*integral(WlambdaylambdaInterp,lambda1,lambda2);
    IspaceM=((1.31e3)/0.89)*BhM*(1e6)^2;
    
    BhS=LStarlight*integral(WlambdaylambdaInterp,lambda1,lambda2);
    IspaceS=((1.31e3)/0.89)*BhS*(1e6)^2;
    
    IspaceAll=[IspaceD,IspaceM,IspaceS];
    
    rmin=1e-1;
    rmax=100;
    pupilValues=linspace(minpupil,maxpupil,30);
    rangeValues=linspace(rmin,rmax,30);
    
    tol=1e-4;
    
   targetSizeSolns=zeros(length(rangeValues),length(pupilValues),length(LVals));  
    for l=1:length(LVals)
        L=LVals(l);
        Dt=DtVals(l);
        F=FVals(l);
        X=XVals(l);
        q=qVals(l);
        Ispace=IspaceAll(l);
        C0=C0All(l);
        
        T=1e-6;
        targetSizeSolnsTemp=zeros(length(rangeValues),length(pupilValues));
        for i=1:length(pupilValues)
            A=pupilValues(i);
            delta=10^(floor(log10(T))-3);
            deltaInit=delta;
            for j=1:length(rangeValues)
                mr=rangeValues(j); 
          
                if mr>3
                    delta=deltaInit*1e3;
                end 
                possibleSolution=10;             
                while abs(possibleSolution-A)>tol
                    possibleSolution=firingThresh(WlambdaylambdaInterp,A,mr,...
                        C0,L,T,F,Ispace,Dt,q,k,len,X,d,R);
                    if possibleSolution<A
                        T=T-delta;
                    else
                        T=T+delta;
                    end
                    clc;
                    fprintf('Target size: %f\n',T);
                    fprintf('solution: %f\n', possibleSolution);
                    fprintf('error: %f\n',abs(possibleSolution-A));
                end
                
                CrFunc=@(lambda) exp(-sigma(lambda).*mr);
                Cr= C0*integral(CrFunc,lambda1,lambda2);

                angularSize=(T/mr)*10^3;
                Kt=liminalContrast(A,L,angularSize);

                if 10^(Kt) <= abs(Cr)   
                     targetSizeSolnsTemp(j,i)=T;
                else
                    while 10^(Kt)>abs(Cr)
                        T=T+delta;
                        
                        angularSize=(T/mr)*10^3;
                        Kt=liminalContrast(A,L,angularSize);
                        
                        clc;
                        fprintf('Target size: %f\n',T);
                        fprintf('error: %f\n',abs(10^Kt-abs(Cr)))
                    end
                end
            end
            T=min(targetSizeSolnsTemp(:,i));
        end
    end

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
    
function  solution=firingThresh(WHandle,A,r,C0,L,T,F,Ispace,Dt,q,k,len,X,d,R)
    lambda1=0.4; lambda2=0.7;
    sigma=@(lambda) ((1.1e-3*lambda.^(-4))+(0.008*lambda.^(-2.09)))/(1e3); %value checked with mathmematica
    
    Nspace=(pi/4)^2*(T/r)^2*A^2*Ispace*Dt*q*((k*len)/(2.3+(k*len)));
    Xch=((T*F*A)/(2*r*d))^2*X*Dt;

    %APPARENT RADIANCE OF THE GREY OBJECT
    Bgfunc=@(lambda) WHandle(lambda).*(1+(C0.*exp(-sigma(lambda).*r)));
    Bg= L*integral(Bgfunc,lambda1,lambda2);
    Iobject=((1.31e3)/0.89)*Bg*(1e6)^2;

    Itarget=Iobject;

    Ntarget=(pi/4)^2*(T/r)^2*A^2*Itarget*Dt*q*((k*len)/(2.3+(k*len)));

    solution=(R*sqrt(Ntarget+Nspace+2*Xch))/(abs(Ntarget-Nspace));
    