clear all;

run ../figXX_compviz/Parameters.m

minpupil=0.001; maxpupil=0.04;
minvisualrange=1; maxvisualrange=20000;

pupilValuesAir=linspace(minpupil,maxpupil,50);
rangeValuesAir=linspace(minvisualrange,maxvisualrange,250000);

possibleSolD=zeros(length(rangeValuesAir),1);
possibleSolM=zeros(length(rangeValuesAir),1);
possibleSolS=zeros(length(rangeValuesAir),1);

for loop1=1:length(pupilValuesAir)
    A=pupilValuesAir(loop1);
    for loop2=1:length(rangeValuesAir)
        r=rangeValuesAir(loop2);
        
        eq_daylight=((R*sqrt((q*Dt_daylight*0.617*(T/r)^2*...
            (2*Ispace_daylight+((Iref_daylight-Ispace_daylight)*exp(-a_air*r))))))...
            /abs(q*Dt_daylight*0.617*(T/r)^2*...
            ((Iref_daylight-Ispace_daylight)*exp(-a_air*r))));
         
        eq_moonlight=((R*sqrt((q*Dt*0.617*(T/r)^2*...
            (2*Ispace_moonlight+((Iref_moonlight-Ispace_moonlight)*exp(-a_air*r))))+...
            2*((T*M)/(2*r*d))^2)*X_night*Dt)...
            /abs(q*Dt*0.617*(T/r)^2*...
            ((Iref_moonlight-Ispace_moonlight)*exp(-a_air*r))));
        
        eq_starlight=((R*sqrt((q*Dt*0.617*(T/r)^2*...
            (2*Ispace_starlight+((Iref_starlight-Ispace_starlight)*exp(-a_air*r))))+...
            2*((T*M)/(2*r*d))^2)*X_night*Dt)...
            /abs(q*Dt*0.617*(T/r)^2*...
            ((Iref_starlight-Ispace_starlight)*exp(-a_air*r))));
        
         possibleSolD(loop2)=eq_daylight;
         possibleSolM(loop2)=eq_moonlight;
         possibleSolS(loop2)=eq_starlight;
         
    end
    IDXDaylight=knnsearch(possibleSolD,A,'NSMethod','exhaustive','distance','seuclidean');
    IDXMoonlight=knnsearch(possibleSolM,A,'NSMethod','exhaustive','distance','seuclidean');
    IDXStarlight=knnsearch(possibleSolS,A,'NSMethod','exhaustive','distance','seuclidean');
    
    visualRangeDaylight(loop1)=rangeValuesAir(IDXDaylight);
    visualRangeMoonlight(loop1)=rangeValuesAir(IDXMoonlight);
    visualRangeStarlight(loop1)=rangeValuesAir(IDXStarlight);
end

for loop1=1:length(visualRangeDaylight)
    visualVolumeDaylight(loop1)=integral3(f,0,(visualRangeDaylight(loop1)),...
            elevationMin,elevationMaxAir,...
            azimuthMin,azimuthMaxAir);
        
    visualVolumeMoonlight(loop1)=integral3(f,0,(visualRangeMoonlight(loop1)),...
            elevationMin,elevationMaxAir,...
            azimuthMin,azimuthMaxAir);
    
    visualVolumeStarlight(loop1)=integral3(f,0,(visualRangeStarlight(loop1)),...
            elevationMin,elevationMaxAir,...
            azimuthMin,azimuthMaxAir);
end

drdADaylight=derivative(pupilValuesAir*10^3,visualRangeDaylight);
dVdADaylight=derivative(pupilValuesAir*10^3,visualVolumeDaylight);
drdAMoonlight=derivative(pupilValuesAir*10^3,visualRangeMoonlight);
dVdAMoonlight=derivative(pupilValuesAir*10^3,visualRangeMoonlight);
drdAStarlight=derivative(pupilValuesAir*10^3,visualRangeStarlight);
dVdAStarlight=derivative(pupilValuesAir*10^3,visualRangeStarlight);

save('inAir_Avsr.mat', 'pupilValuesAir', 'rangeValuesAir',...
    'visualRangeDaylight','visualVolumeDaylight', 'drdADaylight','dVdADaylight',...
    'visualRangeMoonlight','visualVolumeMoonlight','drdAMoonlight','dVdAMoonlight',...
    'visualRangeStarlight','visualVolumeStarlight','drdAStarlight','dVdAStarlight');

           