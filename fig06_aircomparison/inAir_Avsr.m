clear all;

warning('If parameters are changed, rerun parameters');
load('parameters')

minpupil=0.001; maxpupil=0.03;
minvisualrange=1; maxvisualrange=5000;

pupilValuesAir=linspace(minpupil,maxpupil,30);
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

for loop1=1:length(visualRangeAir)
    visualVolumeAir(loop1)=integral3(f,0,visualRangeAir(loop1),...
            elevationMin,elevationMaxAir,...
            azimuthMin,azimuthMaxAir);
end

drdAAir=derivative(pupilValuesAir,visualRangeAir);
dVdAAir=derivative(pupilValuesAir,visualVolumeAir);

save('inAir_Avsr.mat', 'pupilValuesAir', 'rangeValuesAir',...
    'visualRangeAir','visualVolumeAir', 'drdAAir','dVdAAir');

           