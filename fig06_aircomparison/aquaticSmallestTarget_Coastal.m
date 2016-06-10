function aquaticSmallestTarget_Coastal
    run ../figXX_compviz/Parameters.m
    
    PROMPT = 1;

    if PROMPT
    rangeValues=input('Input range value in vector form between 1-15:\n');
    else 
        rangeValues=[1 2 4];
    end
    
    pupilValues=linspace(minpupil,maxpupil);
    T=1e-1;
    targetSizeSolns=zeros(length(rangeValues),length(pupilValues),2);
    tol=4e-4;
    for i=1:length(pupilValues)
        A=pupilValues(i);
        for j=1:length(rangeValues)
            r=rangeValues(j);
            possibleSolution=10*ones(1,2);
                while abs(possibleSolution(k)-A)<tol
                    possibleSolution(k)=firingThresh()
                end
        end
    end
    
    
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