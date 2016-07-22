%fix pupil size mid pupil 
% calculate firing thereshold range
% calculate contrast threshold range by limiting process

function visualRangeSolns = contrastRangeRelation

%% INITIALIZATION

    run ../figXX_compviz/Parameters.m
    load ../fig02_orbitsize/OM_TF_ST.mat
    pupil_TF = [mean(OM_TF)-std(OM_TF) mean(OM_TF)+std(OM_TF)].*0.449;
    pupil_ST = [mean(OM_ST)-std(OM_ST) mean(OM_ST)+std(OM_ST)].*0.449;

    fishpupil=mean(OM_TF)*.449;
    tetrapodpupil=mean(OM_ST)*.449;
    
    pupilValues=sort([fishpupil,tetrapodpupil,pupil_TF,pupil_ST]*1e-3);
    
    tol=5e-5;
    
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
    C0Range=linspace(-1,4,20);

%% CALCULATE RANGE FROM FIRING THRESHOLD
    visualRangeSolns=zeros(length(C0Range),length(pupilValues),length(LVals));
    for l=1:3
        L=LVals(l);
        Dt=DtVals(l);
        F=FVals(l);
        X=XVals(l);
        q=qVals(l);
        Ispace=IspaceAll(l);
        visualRangeSolnsTemp=zeros(length(C0Range),length(pupilValues));        
        
        if l==1
            r=1.4e4;
        elseif l==2
            r=230;
        else
            r=10;
        end
        
        for i=1:length(pupilValues)
            A=pupilValues(i);
            for c=1:length(C0Range)
                delta=10^(floor(log10(r))-5);
                C0=C0Range(c);                       
                possibleSolution=10;
                while abs(possibleSolution-1)>=tol
                    possibleSolution=firingThreshRange(...
                         WlambdaylambdaInterp,A,r,C0,L,...
                         T,F,Ispace,Dt,q,k,len,X,d,R);
                    if possibleSolution>1
                        r=r-delta;
                    else
                        r=r+delta;
                    end
                    clc
                    fprintf('iteration: %d, %d, %d \n', c,i,l);
                    fprintf('possibleSolution: %f \n', possibleSolution);
                    fprintf('range: %f \n', r);
                    fprintf('error: %f \n', abs(possibleSolution-1));
                end
                visualRangeSolnsTemp(c,i)=r;
                mr=visualRangeSolnsTemp(c,i);
                
%% LIMIT RANGE WITH CONTRAST THRESHOLD
                CrFunc=@(lambda) exp(-sigma(lambda).*mr);
                Cr= C0*integral(CrFunc,lambda1,lambda2);

                angularSize=atan(T/(2*mr))*2*10^3;
                Kt=liminalContrast(A,L,angularSize);

                if 10^(Kt) <= abs(Cr)
                     visualRangeSolnsTemp(c,i)=mr;
                else
                    delta=delta*1e1;
                    %tempRange=linspace(mr,mr/1e3,ceil(mr)*1e2);
                    %count=1;
                    while(10^(Kt)>abs(Cr))
                        mr=mr-delta;
                        %mr=tempRange(count);
                        angularSize=atan(T/(2*mr))*2*10^3;
                        Cr=C0*integral(CrFunc,lambda1,lambda2);
                        Kt=liminalContrast(A,L,angularSize);
                        clc
                        fprintf('iteration: %d, %d, %d \n', c,i,l);
                        fprintf('range: %f \n',mr);
                        fprintf('error: %f \n', 10^(Kt)-abs(Cr));
                        %count=count+1;
                    end
                    visualRangeSolnsTemp(c,i)=mr;
                end

            end
        end
        visualRangeSolns(:,:,l)=visualRangeSolnsTemp;
    end
    save('contrastRangeAll','visualRangeSolns');                

    
function  solution=firingThreshRange(WHandle,A,r,C0,L,T,F,Ispace,Dt,q,k,len,X,d,R)
    lambda1=0.4; lambda2=0.7;
    sigma=@(lambda) ((1.1e-3*lambda.^(-4))+(0.008*lambda.^(-2.09)))/(1e3); %value checked with mathmematica
    
    Nspace=(pi/4)^2*(T/r)^2*A^2*Ispace*Dt*q*((k*len)/(2.3+(k*len)));
    Xch=((T*F*A)/(r*d))^2*X*Dt;

    %APPARENT RADIANCE OF THE GREY OBJECT
    Bgfunc=@(lambda) WHandle(lambda).*(1+(C0.*exp(-sigma(lambda).*r)));
    Bg= L*integral(Bgfunc,lambda1,lambda2);
    Iobject=((1.31e3)/0.89)*Bg*(1e6)^2;

    Itarget=Iobject;

    Ntarget=(pi/4)^2*(T/r)^2*A^2*Itarget*Dt*q*((k*len)/(2.3+(k*len)));

    solution=(R*sqrt(Ntarget+Nspace+2*Xch))/(abs(Ntarget-Nspace));

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
        if Xparam>0 && Xparam<=0.20
            Yval=1.45*Xparam;
            Kt =-2*logStardeltar-Yval;
        elseif Xparam>0.20
            Yval=Y(deltarparam,L);
            Kt=-2*logStardeltar-Yval;
        end
    end         