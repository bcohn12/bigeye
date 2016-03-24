clear all;

warning('If parameters are changed, rerun parameters');
load('parameters')

minpupil=0.002; maxpupil=0.03;
minvisualrange=1; maxvisualrange=5000;

pupilValuesAir=linspace(minpupil,maxpupil,50);
rangeValuesAir=linspace(minvisualrange,maxvisualrange,5000);

possibleSol=zeros(length(rangeValuesAir),1);

for loop1=1:length(pupilValuesAir)
    A=pupilValuesAir(loop1);
    for loop2=1:length(rangeValuesAir)
        r=rangeValuesAir(loop2);
        
        eq2=(R*sqrt(q*Dt*(0.617*(T/r)^2*(Ispace_air*(2-exp((K_air-a_air)*r))))+...
             2*((T*M)/(2*r*d))^2*X*Dt))/...
             (abs(q*Dt*(-0.617*(T/r)^2*(Ispace_air*(exp((K_air-a_air)*r))))));
         
         possibleSol(loop2)=eq2;
    end
    IDXAir=knnsearch(possibleSol,A,'distance','seuclidean');
    visualRangeAir(loop1)=rangeValuesAir(IDXAir);
end

drdAAir(1)=(visualRangeAir(2)-visualRangeAir(1))/(pupilValuesAir(2)-pupilValuesAir(1));
for n=2:length(visualRangeAir)-1
    drdAAir(n)=(visualRangeAir(n+1)-visualRangeAir(n-1))...
        /(pupilValuesAir(n+1)-pupilValuesAir(n-1));
end
drdAAir(length(visualRangeAir))=(visualRangeAir(end)-visualRangeAir(end-1))...
    /(pupilValuesAir(end)-pupilValuesAir(end-1));

for loop1=1:length(visualRangeAir)
    visualVolumeAir(loop1)=integral3(f,0,visualRangeAir(loop1),...
            elevationMin,elevationMaxAir,...
            azimuthMin,azimuthMaxAir);
end

dVdAAir(1)=(visualVolumeAir(2)-visualVolumeAir(1))/(pupilValuesAir(2)-pupilValuesAir(1));
for n=2:length(visualVolumeAir)-1
    dVdAAir(n)=(visualVolumeAir(n+1)-visualVolumeAir(n-1))...
        /(pupilValuesAir(n+1)-pupilValuesAir(n-1));
end
dVdAAir(length(visualVolumeAir))=(visualVolumeAir(end)-visualVolumeAir(end-1))...
    /(pupilValuesAir(end)-pupilValuesAir(end-1));


save('inAir_Avsr.mat', 'pupilValuesAir', 'rangeValuesAir',...
    'visualRangeAir','visualVolumeAir', 'drdAAir','dVdAAir');

           