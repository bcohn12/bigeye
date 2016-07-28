function [viusalRangeRiver, pupilValues]=Aquatic_firingThresh
global EROOT
%% INITIALIZE VARIABLES
    run Parameters.m
    load('Parameters.mat')
    conditions={'Daylight','Moonlight','Starlight'};
    pupilValues=linspace(minpupil,maxpupil,30); 
    depth=8; tol=5e-4;

%% SOLVE FOR RANGE
    visualRange_River=zeros(length(pupilValues),length(conditions),2);
    actRange_River=visualRange_River;
    for i=1:length(conditions);
        if strcmp('Daylight',conditions{i})
            r_down=5;r_hor=3;
        elseif strcmp('Moonlight',conditions{i})
            r_down=2;r_hor=1;
        elseif strcmp('Starlight',conditions{i})
            r_down=1;r_hor=.3;
        end
        
        aString=strcat('aAquatic_',conditions{i}); bString=strcat('bAquatic_',conditions{i});
        KdString=strcat('KdAquatic_',conditions{i}); KhString=strcat('KhAquatic_',conditions{i});
        LdString=strcat('LdAquatic_',conditions{i}); LhString=strcat('LhAquatic_',conditions{i});
        C0String=strcat('C0Aquatic_',conditions{i});
        
        pAbsorbString=strcat('pAbsorbAquatic_',conditions{i});
        a=eval(aString); b=eval(bString); Kd=eval(KdString); Kh=eval(KhString);
        Ld=eval(LdString); Lh=eval(LhString); pAbsorb=eval(pAbsorbString); C0=eval(C0String);      
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
            
            visualRange_River(j,i,1)=r_down;
            visualRange_River(j,i,2)=r_hor;
        end
    end
                
    save([EROOT 'fig03_visualrange/aquatic_model/meteoAquatic_All.mat'],'visualRange_River','pupilValues');

function  solution=firingThresh(depth,lambda,photoreceptorAbsorption,a,b,KAll,LAll,r,A,X,Dt,q,d,k,len,T,M,R,C0)
    lambda1=lambda(1); lambda2=lambda(end);
    K=KAll(:,depth);
    L=LAll(:,depth);
   
    alphaInterp=@(l) interp1(lambda,photoreceptorAbsorption,l,'pchip');
    aInterp=@(l) interp1(lambda,a,l,'pchip');
    bInterp=@(l) interp1(lambda,b,l,'pchip');
    LInterp=@(l) interp1(lambda,L,l,'pchip');
    KInterp=@(l) interp1(lambda,K,l,'pchip');
    
    Nfalse=((T*M*A)/(2*r*d))^2*X*Dt;
    RhFunc=@(l) LInterp(l).*l.*(1-exp(-k*alphaInterp(l)*len));
    RoFunc=@(l) LInterp(l).*l.*(1-exp(-k*alphaInterp(l)*len)).*(1+(C0*exp((KInterp(l)-aInterp(l)-bInterp(l))*r)));
    
    Rh=integral(RhFunc,lambda1,lambda2);
    Ro=integral(RoFunc,lambda1,lambda2);
    
    Nh=((pi/4)^2)*(A^2)*((T/r)^2)*q*Dt*Rh;
    No=((pi/4)^2)*(A^2)*((T/r)^2)*q*Dt*Ro;

    solution=(R*sqrt(No+Nh+2*Nfalse))/(abs(No-Nh));    