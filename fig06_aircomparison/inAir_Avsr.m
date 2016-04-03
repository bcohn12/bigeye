clear all;

run ../figXX_compviz/Parameters.m

minpupil=0.001; maxpupil=0.03;
minvisualrange=1; maxvisualrange=20000;

pupilValuesAir=linspace(minpupil,maxpupil,50);
rangeValuesAir=linspace(minvisualrange,maxvisualrange,250000);

possibleSol=zeros(length(rangeValuesAir),1);

for loop1=1:length(pupilValuesAir)
    A=pupilValuesAir(loop1);
    for loop2=1:length(rangeValuesAir)
        r=rangeValuesAir(loop2);
        
        eq_daylight=((R*sqrt((q*Dt_daylight*0.617*(T/r)^2*...
            (2*Ispace_daylight+((Iref_daylight-Ispace_daylight)*exp(-a_air*r))))))...
            /abs(q*Dt_daylight*0.617*(T/r)^2*...
            ((Iref_daylight-Ispace_daylight)*exp(-a_air*r))));
         
         possibleSol(loop2)=eq_daylight;
    end
    IDXAir=knnsearch(possibleSol,A,'NSMethod','exhaustive','distance','seuclidean');
    visualRangeAir(loop1)=rangeValuesAir(IDXAir);
end

for loop1=1:length(visualRangeAir)
    visualVolumeAir(loop1)=integral3(f,0,(visualRangeAir(loop1)),...
            elevationMin,elevationMaxAir,...
            azimuthMin,azimuthMaxAir);
end

drdAAir=derivative(pupilValuesAir,visualRangeAir);
dVdAAir=derivative(pupilValuesAir,visualVolumeAir);

save('inAir_Avsr.mat', 'pupilValuesAir', 'rangeValuesAir',...
    'visualRangeAir','visualVolumeAir', 'drdAAir','dVdAAir');

           