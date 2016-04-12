clear all;

run ../figXX_compviz/Parameters.m
load daylight.mat
load moonlight.mat
load starlight.mat

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
        
        NspaceDaylight=0.617*A^2*(T/r)^2*q*Dt_daylight*Ispace_daylight;
        NspaceMoonlight=0.617*A^2*(T/r)^2*q*Dt*Ispace_moonlight;
        NspaceStarlight=0.617*A^2*(T/r)^2*q*Dt*Ispace_starlight;
        
        NrefDaylight=0.617*A^2*(T/r)^2*q*Dt_daylight*Iref_daylight*exp(-a_air*r);
        NrefMoonlight=0.617*A^2*(T/r)^2*q*Dt*Iref_moonlight*exp(-a_air*r);
        NrefStarlight=0.617*A^2*(T/r)^2*q*Dt*Iref_starlight*exp(-a_air*r);
        
        NblackDaylight=0.617*A^2*(T/r)^2*q*Dt_daylight*Ispace_daylight*(1-exp(-a_air*r));
        NblackMoonlight=0.617*A^2*(T/r)^2*q*Dt*Ispace_moonlight*(1-exp(-a_air*r));
        NblackStarlight=0.617*A^2*(T/r)^2*q*Dt*Ispace_starlight*(1-exp(-a_air*r));
        
        Xch_diurnal=((T*f_daylight*A)/(r*d))^2*X_land*Dt_daylight;
        Xch_nocturnal=((T*f_night*A)/(r*d))^2+X_land*Dt;
        
        eq_daylight=(R*sqrt(NspaceDaylight+NblackDaylight+NrefDaylight+2*Xch_diurnal))...
            /(abs(NblackDaylight+NrefDaylight-NspaceDaylight));
        
        eq_moonlight= (R*sqrt(NspaceMoonlight+NblackMoonlight+NrefMoonlight+2*Xch_nocturnal))...
            /(abs(NblackMoonlight+NrefMoonlight-NspaceMoonlight));
        
        eq_starlight=(R*sqrt(NspaceStarlight+NblackStarlight+NrefStarlight+2*Xch_nocturnal))...
            /(abs(NblackStarlight+NrefStarlight-NspaceStarlight));

        
         possibleSolD(loop2)=eq_daylight;
         possibleSolM(loop2)=eq_moonlight;
         possibleSolS(loop2)=eq_starlight;
         
    end
    IDXDaylight=knnsearch(possibleSolD,1.,'NSMethod','exhaustive','distance','euclidean');
    IDXMoonlight=knnsearch(possibleSolM,1.,'NSMethod','exhaustive','distance','euclidean');
    IDXStarlight=knnsearch(possibleSolS,1.,'NSMethod','exhaustive','distance','euclidean');
    
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

           