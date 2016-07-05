function aquaticSmallestTarget_River
    run ../figXX_compviz/Parameters.m
    
    PROMPT = 0;

    if PROMPT
        rangeValues=input('Input range value in vector form between 1-15:\n');
    else 
        rangeValues=[2 3 4 7];
    end
    
    pupilValues=linspace(minpupil,maxpupil,25);
    T_down=[1e-1 1e-1 1 5000]; delta_down=[1e-3 1e-2 1e-2 1];
    T_hor=[1 10 100 1000000]; delta_hor=[1e-2 1e-2 1e-1 1000];
    depth=7;
    targetSizeSolns_River=zeros(length(rangeValues),length(pupilValues),2);
    tol=4e-4;
    for i=1:length(pupilValues)
        A=pupilValues(i);
        for j=1:length(rangeValues)
            r=rangeValues(j);
            possibleSolutionDownwelling=10;
                while abs(possibleSolutionDownwelling-A)>tol
                    possibleSolutionDownwelling=firingThresh(depth,lambda,...
                    photoreceptorAbsorption_River,a_River,b_River,Kd_River,Ld_River,...
                    r,A,X,Dt,q,d,k,len,T_down(j),M,R);
                    
                    if possibleSolutionDownwelling>A
                        T_down(j)=T_down(j)+delta_down(j);
                    else
                        T_down(j)=T_down(j)-delta_down(j);
                    end
                    clc;
                    fprintf('pupil iteration: %d %d\n',j,i);
                    fprintf('solution downwelling: %f\n',possibleSolutionDownwelling);
                    fprintf('target size: %f\n',T_down);
                    fprintf('error downwellling: %f\n', abs(possibleSolutionDownwelling-A));
                    
                end
                
                possibleSolutionHorizontal=10;
                while abs(possibleSolutionHorizontal-A)>tol
                    possibleSolutionHorizontal=firingThresh(depth,lambda,...
                    photoreceptorAbsorption_River,a_River,b_River,Kh_River,Lh_River,...
                    r,A,X,Dt,q,d,k,len,T_hor(j),M,R);
                    
                    if possibleSolutionHorizontal>A
                        T_hor(j)=T_hor(j)+delta_hor(j);
                    else
                        T_hor(j)=T_hor(j)-delta_hor(j);
                    end
                    clc;
                    fprintf('pupil iteration: %d %d\n',j,i);
                    fprintf('solution horizontal: %f\n',possibleSolutionHorizontal);
                    fprintf('target size: %f\n',T_hor);
                    fprintf('error horizontal: %f\n', abs(possibleSolutionHorizontal-A));
                    
                end
                
                targetSizeSolns_River(j,i,1)=T_down(j);
                targetSizeSolns_River(j,i,2)=T_hor(j);
        end
        %T_down=min(targetSizeSolns_Coastal(:,i,1));
        %T_hor=min(targetSizeSolns_Coastal(:,i,2));
        delta_down=10.^(floor(log10(T_down)-3));
        delta_hor=10.^(floor(log10(T_hor)-3));
    end
    
    save('aqaticSmallestTarget_River','targetSizeSolns_River','pupilValues','depth','rangeValues');
    
    function  solution=firingThresh(depth,lambda,photoreceptorAbsorption,aAll,bAll,KAll,LAll,r,A,X,Dt,q,d,k,len,T,M,R)
    lambda1=lambda(1); lambda2=lambda(end);
    a=aAll(:,depth);
    K=KAll(:,depth);
    L=LAll(:,depth);
    b=bAll(:,depth);
    
    alphaInterp=@(l) interp1(lambda,photoreceptorAbsorption,l,'pchip');
    aInterp=@(l) interp1(lambda,a,l,'pchip');
    bInterp=@(l) interp1(lambda,b,l,'pchip');
    LInterp=@(l) interp1(lambda,L,l,'pchip');
    KInterp=@(l) interp1(lambda,K,l,'pchip');
    
    Xch=((T*M*A)/(2*r*d))^2*X*Dt;
    IspaceFunc=@(l) LInterp(l).*l.*(1-exp(-k*alphaInterp(l)*len));
    IblackFunc=@(l) LInterp(l).*l.*(1-exp(-k*alphaInterp(l)*len)).*(1-exp((KInterp(l)-aInterp(l)-bInterp(l))*r));
    
    Ispace=integral(IspaceFunc,lambda1,lambda2);
    %IspaceInterp=@(l) interp1(lambda,Ispace,l,'pchip');
    %IblackFunc=@(l) Ispace.*(1-exp((KInterp(l)-aInterp(l)-bInterp(l))*r));
    Iblack=integral(IblackFunc,lambda1,lambda2);
    
    Nspace=((pi/4)^2)*(A^2)*((T/r)^2)*q*Dt*Ispace;
    Nblack=((pi/4)^2)*(A^2)*((T/r)^2)*q*Dt*Iblack;

    solution=(R*sqrt(Nblack+Nspace+2*Xch))/(abs(Nblack-Nspace));    