function aquaticRangeSensitivity

run ../figXX_compviz/ParametersSensitivity.m

conditions={'Baseline','Clear','Highabs','Highscat'};

% PROMPT = 0;
% if PROMPT
%    waterDepth=input('Input depth value in vector form between 1-15:\n');
% else 
%    waterDepth=[8];
% end
    
%waterDepth=sort(waterDepth,'descend');
waterDepth=8;
pupilValues=linspace(minpupil,maxpupil,30);   
visualRangeSensitivity=zeros(length(pupilValues),length(conditions),2);

for i=1:length(conditions)
    tol=5e-4;
    if strcmp(conditions{i},'Baseline')
        r_down=1; r_hor=1; 
    elseif strcmp(conditions{i},'Clear')
        r_down=10; r_hor=10;
    elseif strcmp(conditions{i},'Highabs')
        r_down=1e-9; r_hor=1e-12;
    elseif strcmp(conditions{i},'Highscat')
        r_down=1e-7; r_hor=1e-8;
    end

    aString=strcat('a_',conditions{i}); bString=strcat('b_',conditions{i});
    KdString=strcat('Kd_',conditions{i}); KhString=strcat('Kh_',conditions{i});
    LdString=strcat('Ld_',conditions{i}); LhString=strcat('Lh_',conditions{i});
    pAbsorbString=strcat('pAbsorb_',conditions{i});
    
    a=eval(aString); b=eval(bString); Kd=eval(KdString); Kh=eval(KhString);
    Ld=eval(LdString); Lh=eval(LhString); pAbsorb=eval(pAbsorbString);
    
    for j=1:length(pupilValues)
            A=pupilValues(j);
            delta_down=10^(floor(log10(r_down))-4);
            delta_hor=10^(floor(log10(r_hor))-4);
            
            possibleSolnDownwelling=10;
            while abs(possibleSolnDownwelling-1)>tol
                possibleSolnDownwelling=firingThresh(waterDepth,lambda,...
                     pAbsorb,a,b,Kd,Ld,...
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
                 possibleSolnHorizontal=firingThresh(waterDepth,lambda,...
                     pAbsorb,a,b,Kh,Lh,...
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
            
            visualRangeSensitivity(j,i,1)=r_down;
            visualRangeSensitivity(j,i,2)=r_hor;
    end
end

save('aquaticRangeSensitivity','conditions','visualRangeSensitivity','pupilValues','waterDepth');
    
    
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