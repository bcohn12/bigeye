clear all;
run ../figXX_compviz/Parameters.m

CONTRASTTHRESH=1;
if CONTRASTTHRESH
    load actualDaylight.mat
    load actualMoonlight.mat
    load actualStarlight.mat
else
    load daylight.mat
    load moonlight.mat
    load starlight.mat
end

pupilValuesAir=linspace(minpupil,maxpupil,25);

%% CALCULATE VOLUME

for loop1=1:length(visualRangeDaylight)
%       visualVolumeDaylight(loop1)=4/3*pi*visualRangeDaylight(loop1)^3;
%       visualVolumeMoonlight(loop1)=4/3*pi*visualRangeMoonlight(loop1)^3;
%       visualVolumeStarlight(loop1)=4/3*pi*visualRangeStarlight(loop1)^3;
    visualVolumeDaylight(loop1)=integral3(f,0,(visualRangeDaylight(loop1)),...
        elevationMinAir,elevationMaxAir,...
        azimuthMin,azimuthMaxAir);
        
    visualVolumeMoonlight(loop1)=integral3(f,0,(visualRangeMoonlight(loop1)),...
            elevationMinAir,elevationMaxAir,...
            azimuthMin,azimuthMaxAir);
    
    visualVolumeStarlight(loop1)=integral3(f,0,(visualRangeStarlight(loop1)),...
            elevationMinAir,elevationMaxAir,...
            azimuthMin,azimuthMaxAir);
end

%% CALCULATE DERIVATIVE

drdADaylight=derivative(pupilValuesAir*10^3,visualRangeDaylight);
dVdADaylight=derivative(pupilValuesAir*10^3,visualVolumeDaylight);
drdAMoonlight=derivative(pupilValuesAir*10^3,visualRangeMoonlight);
dVdAMoonlight=derivative(pupilValuesAir*10^3,visualVolumeMoonlight);
drdAStarlight=derivative(pupilValuesAir*10^3,visualRangeStarlight);
dVdAStarlight=derivative(pupilValuesAir*10^3,visualVolumeStarlight);

save('terrestrial_Avsr','pupilValuesAir',...
    'visualRangeDaylight','visualVolumeDaylight', 'drdADaylight','dVdADaylight',...
    'visualRangeMoonlight','visualVolumeMoonlight','drdAMoonlight','dVdAMoonlight',...
    'visualRangeStarlight','visualVolumeStarlight','drdAStarlight','dVdAStarlight');
