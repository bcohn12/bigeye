function pupilSizevsRangeConstantDepth_River
    run ../figXX_compviz/Parameters.m

    %% CONSTANT DEPTH VALUE RANGE OF VISION VS PUPIL SIZE

    PROMPT = 0;

    if PROMPT
    coastalWaterDepth=input('Input depth value in vector form between 1-15:\n');
    else 
        coastalWaterDepth=[8];
    end

    coastalWaterDepth=sort(coastalWaterDepth,'descend');
   
    pupilValues=linspace(minpupil,maxpupil,30); %rangeValues=linspace(minvisualrange,maxvisualrange,2500);
    minvisualrange=1; maxvisualrange=10;
    rangeValues=linspace(minvisualrange,maxvisualrange,5000);
   
    r_down=5; r_hor=3.3; tol=5e-4;
   
    visualRange_River=zeros(length(pupilValues),length(coastalWaterDepth),2);
    
    for i=1:length(coastalWaterDepth);
        depth=coastalWaterDepth(i);
        for j=1:length(pupilValues)
            A=pupilValues(j);
            delta_down=10^(floor(log10(r_down))-4);
            delta_hor=10^(floor(log10(r_hor))-4);
            
            possibleSolnDownwelling=10;
            while abs(possibleSolnDownwelling-1)>tol
                possibleSolnDownwelling=firingThresh(depth,lambda,...
                     photoreceptorAbsorption_River,a_River,b_River,Kd_River,Ld_River,...
                     r_down,A,X,Dt,q,d,k,len,T,M,R);
                 
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
                     photoreceptorAbsorption_River,a_River,b_River,Kh_River,Lh_River,...
                     r_hor,A,X,Dt,q,d,k,len,T,M,R);
                 
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
            
            visualRange_River(j,i,1)=r_down;
            visualRange_River(j,i,2)=r_hor;
%             possibleSolnDownwelling=zeros(length(rangeValues),1);
%             possibleSolnHorizontal=zeros(length(rangeValues),1);
%             for k=1:length(rangeValues)
%                 r=rangeValues(k);
%                 possibleSolnDownwelling(k)=firingThresh(depth,lambda,...
%                     photoreceptorAbsorption_River,a_River,b_River,Kd_River,Ld_River,...
%                     r,A,X,Dt,q,d,k,len,T,M,R);
%                 possibleSolnHorizontal(k)=firingThresh(depth,lambda,...
%                     photoreceptorAbsorption_River,a_River,b_River,Kh_River,Lh_River,...
%                     r,A,X,Dt,q,d,k,len,T,M,R);
%             end
%             IDXUp = knnsearch(possibleSolnDownwelling,1,'distance','seuclidean');
%             IDXHor=knnsearch(possibleSolnHorizontal,1,'distance','seuclidean');
%             visualRange_River(j,i,1) = rangeValues(IDXUp);
%             visualRange_River(j,i,2)=rangeValues(IDXHor);
%             fprintf('iteration pupil: %d\n',j);
         end
%         fprintf('iteration: %d\n',i);
    end
                
    save('pupilSizevsRangeConstantDepth_River','visualRange_River','pupilValues');

    drdA_River=visualRange_River;
    dVdA_River=visualRange_River;
    visualVolume_River=visualRange_River;

    for i=1:size(visualRange_River,3);
        for j=1:size(visualRange_River,2);
            for k=1:size(visualRange_River,1);
                visualVolume_River(k,j,i)=integral3(f,0,visualRange_River(k,j,i),...
                elevationMin,elevationMax,...
                azimuthMin,azimuthMax);
            end
        end
    end
    
    for i=1:size(visualRange_River,3);
        for j=1:size(visualRange_River,2);
            drdA_River(:,j,i)=derivative(pupilValues*10^3,visualRange_River(:,j,i));
            dVdA_River(:,j,i)=derivative(pupilValues*10^3,visualVolume_River(:,j,i));
        end
    end

    save('pupilSizevsRangeConstantDepth_River','visualRange_River','pupilValues','drdA_River','dVdA_River','visualVolume_River');


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