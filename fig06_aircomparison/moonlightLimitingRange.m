%1. calculate apparent contrast given range
%2. find liminal contrast
%3. if abs liminal contrast<= abs apparent contrast
    % keep range
   %else 
    % range/2, check the if statement, keep dividing by 2 until it's met
    % grid between two range values
    % while(liminal contrast <= apparent contrast)
        % calculate apparent contrast and liminal contrast

function [actRangeMoonlight, Cr_moonlight, angularSize, Kt_moonlight] =moonlightLimitingRange

%% INITIALIZE/LOAD DATA

run ../figXX_compviz/Parameters.m
load('moonlight');
pupilValuesTerr=linspace(minpupil,maxpupil,25);

sigma=@(lambda) ((1.1e-3*lambda.^(-4))+(0.008*lambda.^(-2.09)))/(1e3); %value checked with mathmematica

lambda1=0.4; lambda2=0.7;

%global actRangeDaylight Cr_daylight angularSize Kt_daylight

%% CALCULATE RANGE MOONLIGHT

actRangeMoonlight=zeros(length(visualRangeMoonlight),1);
Cr_moonlight=actRangeMoonlight; angularSize=actRangeMoonlight; Kt_moonlight=Cr_moonlight;

for i=1:length(pupilValuesTerr);
    A=pupilValuesTerr(i);
    mr=visualRangeMoonlight(i);
    
    CrFunc=@(lambda) exp(-sigma(lambda).*mr);
    Cr_moonlight(i)= C0_moonlight*integral(CrFunc,lambda1,lambda2);
    
    angularSize(i)=(T/mr)*10^3;
    Kt_moonlight(i)=liminalContrast(A,LMoonlight,angularSize(i));
    
    if 10^(Kt_moonlight(i)) <= abs(Cr_moonlight(i))
        actRangeMoonlight(i)=mr;
    else
        tempVisualRange=linspace(mr,0.01,max(visualRangeMoonlight)*3);
        j=1;
        while(10^(Kt_moonlight(i)) > abs(Cr_moonlight(i)))
            mr=tempVisualRange(j);
            angularSize(i)=(T/mr)*10^3;
            Cr_moonlight(i)=C0_moonlight*integral(CrFunc,lambda1,lambda2);
            Kt_moonlight(i)=liminalContrast(A,LMoonlight,angularSize(i));
            
            actRangeMoonlight(i)=mr;
            j=j+1;
        end
        
    end
    it=sprintf('iteration number: %d',i);
    disp(it)
end

visualRangeMoonlight=actRangeMoonlight;

save('actualMoonlight', 'visualRangeMoonlight');
   

function Kt = liminalContrast(A,L,angularSize)

%% FUNCTION DEFINTIONS
logLa=@(L) log10(L);
iif = @(varargin) varargin{2 * find([varargin{1:2:end}], 1, 'first')}();


deltat=@(L) iif( -2.09<logLa(L) && logLa(L)<=4, @() (1.22*((555e-9)/A)*10^3),...
    logLa(L)<=-2.09, @() (1.22*((507e-9)/A))*10^3);  

Psi=@(L) (logLa(L)+3.5)/2.75;
logdeltarStar= @(L) iif(logLa(L)>1.535, @() 0.928,...
    -0.75<=logLa(L) && logLa(L)<=1.535, @() 1-(0.5*(Psi(L)^(-3.2))),...
    -2.089<=logLa(L) && logLa(L)<-0.75, @() 0.5*Psi(L)^(1.8),...
    logLa(L)<2.089, @() 0.14*logLa(L)+0.442);

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
