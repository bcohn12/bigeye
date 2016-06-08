function pupilSizevsRangeConstantDepth_Coastal
    run ../figXX_compviz/Parameters.m

    %% CONSTANT DEPTH VALUE RANGE OF VISION VS PUPIL SIZE

    PROMPT = 1;

    if PROMPT
    coastalWaterDepth=input('Input depth value in vector form between 1-15:\n');
    else 
        coastalWaterDepth=[5 10];
    end

    coastalWaterDepth=sort(coastalWaterDepth,'descend');
   
    pupilValues=linspace(minpupil,maxpupil,30); %rangeValues=linspace(minvisualrange,maxvisualrange,2500);
    minvisualrange=0.01; maxvisualrange=20;
    rangeValues=linspace(minvisualrange,maxvisualrange,5000);
    
    rDownwelling=0.01;
    rHorizontal=0.01;
    deltaD=1e-3;
    deltaH=1e-4;
    tol=4e-6;
    
    visualRange_Coastal=zeros(length(pupilValues),length(coastalWaterDepth),2);
    
    for i=1:length(coastalWaterDepth);
        depth=coastalWaterDepth(i);
        for j=1:length(pupilValues)
            A=pupilValues(j);
            possibleSolnDownwelling=zeros(length(rangeValues),1);
            possibleSolnHorizontal=zeros(length(rangeValues),1);
            for k=1:length(rangeValues)
                r=rangeValues(k);
                possibleSolnDownwelling(k)=firingThresh(depth,lambda,...
                    photoreceptorAbsorption_Coastal,a_Coastal,b_Coastal,Kd_Coastal,Ld_Coastal,...
                    r,A,X,Dt,q,d,k,len,T,M,R);
                possibleSolnHorizontal(k)=firingThresh(depth,lambda,...
                    photoreceptorAbsorption_Coastal,a_Coastal,b_Coastal,Kh_Coastal,Lh_Coastal,...
                    r,A,X,Dt,q,d,k,len,T,M,R);
            end
            IDXUp = knnsearch(possibleSolnDownwelling,A);
            IDXHor=knnsearch(possibleSolnHorizontal,A);
            visualRange_Coastal(j,i,1) = rangeValues(IDXUp);
            visualRange_Coastal(j,i,2)=rangeValues(IDXHor);
            fprintf('iteration pupil: %d\n',j);
        end
        fprintf('iteration: %d\n',i);
    end
                
%             A=pupilValues(j);
%             solnDownwelling=10;
%             while(abs(solnDownwelling-A)>=tol)
%                 solnDownwelling=firingThresh(depth,lambda,...
%                     photoreceptorAbsorption,aAll,bAll,KdAll,LdAll,rDownwelling,A,X,Dt,q,d,k,len,T,M,R);
%                 error=abs(solnDownwelling-A);
%                 
%                 clc
%                 fprintf('downwelling solution: %f \r', solnDownwelling);
%                 fprintf('range: %f \r', rDownwelling);
%                 fprintf('error: %f \r', error);
%                 
%                 rDownwelling=rDownwelling+deltaD;
%             end
%             visualRange(j,i,1)=solnDownwelling;
%             
%             solnHorizontal=10;
%             while(abs(solnHorizontal-A)>=tol)
%                 solnHorizontal=firingThresh(depth,lambda,...
%                     photoreceptorAbsorption,aAll,bAll,KhAll,LhAll,rHorizontal,A,X,Dt,q,d,k,len,T,M,R);
%                 error=abs(solnHorizontal-A);
%                 
%                 clc
%                 fprintf('horizontal solution: %f \r', solnHorizontal);
%                 fprintf('range: %f \r', rHorizontal);
%                 fprintf('error: %f \r', error);
%                 
%                 rHorizontal=rHorizontal+deltaH;
%             end
%             visualRange(j,i,2)=solnHorizontal;            
%         end
%         rDownwelling=rDownwelling-deltaD;
%         rHorizontal=rHorizontal-deltaH;
%     end

    save('pupilSizevsRangeConstantDepth_Coastal','visualRange_Coastal','pupilValues');

    drdA_Coastal=visualRange_Coastal;
    dVdA_Coastal=visualRange_Coastal;
    visualVolume_Coastal=visualRange_Coastal;

    for i=1:size(visualRange_Coastal,3);
        for j=1:size(visualRange_Coastal,2);
            for k=1:size(visualRange_Coastal,1);
                visualVolume_Coastal(k,j,i)=integral3(f,0,visualRange_Coastal(k,j,i),...
                elevationMin,elevationMax,...
                azimuthMin,azimuthMax);
            end
        end
    end
    
    for i=1:size(visualRange_Coastal,3);
        for j=1:size(visualRange_Coastal,2);
            drdA_Coastal(:,j,i)=derivative(pupilValues*10^3,visualRange_Coastal(:,j,i));
            dVdA_Coastal(:,j,i)=derivative(pupilValues*10^3,visualVolume_Coastal(:,j,i));
        end
    end

    save('pupilSizevsRangeConstantDepth_Coastal','visualRange_Coastal','pupilValues','drdA_Coastal','dVdA_Coastal','visualVolume_Coastal');


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