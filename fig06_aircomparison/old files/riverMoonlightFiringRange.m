function riverMoonlightFiringRange
    run ../figXX_compviz/ParametersSensitivity.m

    %% CONSTANT DEPTH VALUE RANGE OF VISION VS PUPIL SIZE

    PROMPT = 0;

    if PROMPT
        coastalWaterDepth=input('Input depth value in vector form between 1-15:\n');
    else 
        coastalWaterDepth=[8];
    end

    coastalWaterDepth=sort(coastalWaterDepth,'descend');
   
    pupilValues=linspace(minpupil,maxpupil,30); %rangeValues=linspace(minvisualrange,maxvisualrange,2500);
    minvisualrange=1; maxvisualrange=5;
    rangeValues=linspace(minvisualrange,maxvisualrange,5000);
    r_down=2; r_hor=1;   tol=5e-4;
   
    visualRange_Moonlight=zeros(length(pupilValues),length(coastalWaterDepth),2);
    
    for i=1:length(coastalWaterDepth);
        depth=coastalWaterDepth(i);        
        for j=1:length(pupilValues)
            A=pupilValues(j);
            delta_down=10^(floor(log10(r_down))-4);
            delta_hor=10^(floor(log10(r_hor))-4);
            
            possibleSolnDownwelling=10;
            while abs(possibleSolnDownwelling-1)>tol
                possibleSolnDownwelling=firingThresh(depth,lambda,...
                     pAbsorb_Moonlight,a_Moonlight,b_Moonlight,Kd_Moonlight,Ld_Moonlight,...
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
                     pAbsorb_Moonlight,a_Moonlight,b_Moonlight,Kh_Moonlight,Lh_Moonlight,...
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
            
            visualRange_Moonlight(j,i,1)=r_down;
            visualRange_Moonlight(j,i,2)=r_hor;
            
                
%             possibleSolnDownwelling=zeros(length(rangeValues),1);
%             possibleSolnHorizontal=zeros(length(rangeValues),1);
%             for k=1:length(rangeValues)
%                 r=rangeValues(k);
%                 possibleSolnDownwelling(k)=firingThresh(depth,lambda,...
%                     pAbsorb_Moonlight,a_Moonlight,b_Moonlight,Kd_Moonlight,Ld_Moonlight,...
%                     r,A,X,Dt,q,d,k,len,T,M,R);
%                 possibleSolnHorizontal(k)=firingThresh(depth,lambda,...
%                     pAbsorb_Moonlight,a_Moonlight,b_Moonlight,Kh_Moonlight,Lh_Moonlight,...
%                     r,A,X,Dt,q,d,k,len,T,M,R);
%             end
%             IDXUp = knnsearch(possibleSolnDownwelling,1);
%             IDXHor=knnsearch(possibleSolnHorizontal,1);
%             visualRange_Moonlight(j,i,1) = rangeValues(IDXUp);
%             visualRange_Moonlight(j,i,2)=rangeValues(IDXHor);
%             fprintf('iteration pupil: %d\n',j);
        end
        fprintf('iteration: %d\n',i);
    end
                
    save('riverMoonlightFiringRange','visualRange_Moonlight','pupilValues');

    drdA_Moonlight=visualRange_Moonlight;
    dVdA_Moonlight=visualRange_Moonlight;
    visualVolume_Moonlight=visualRange_Moonlight;

    for i=1:size(visualRange_Moonlight,3);
        for j=1:size(visualRange_Moonlight,2);
            for k=1:size(visualRange_Moonlight,1);
                visualVolume_Moonlight(k,j,i)=integral3(f,0,visualRange_Moonlight(k,j,i),...
                elevationMin,elevationMax,...
                azimuthMin,azimuthMax);
            end
        end
    end
    
    for i=1:size(visualRange_Moonlight,3);
        for j=1:size(visualRange_Moonlight,2);
            drdA_Moonlight(:,j,i)=derivative(pupilValues*10^3,visualRange_Moonlight(:,j,i));
            dVdA_Moonlight(:,j,i)=derivative(pupilValues*10^3,visualVolume_Moonlight(:,j,i));
        end
    end

    save('riverMoonlightFiringRange','visualRange_Moonlight','pupilValues','drdA_Moonlight','dVdA_Moonlight','visualVolume_Moonlight');


function  solution=firingThresh(depth,lambda,photoreceptorAbsorption,aAll,bAll,KAll,LAll,r,A,X,Dt,q,d,k,len,T,M,R)
    lambda1=lambda(1); lambda2=lambda(end);
    a=aAll;
    K=KAll(:,depth);
    L=LAll(:,depth);
    b=bAll;
    
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