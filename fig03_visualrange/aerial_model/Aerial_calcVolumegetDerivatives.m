function [visualRangeDaylight, visualRangeMoonlight, visualRangeStarlight,...
    visualVolumeDaylight, visualVolumeMoonlight, visualVolumeStarlight,...
    drdADaylight,drdAMoonlight,drdAStarlight,...
    dVdADaylight, dVdAMoonlight, dVdAStarlight,pupilValuesAir]=Aerial_calcVolumegetDerivatives(CONTRASTTHRESH)
    run ../../figXX_compviz/Parameters.m

    if CONTRASTTHRESH
        fileNames={'visibilityAerial_Daylight.mat','visibilityAerial_Moonlight.mat','visibilityAerial_Starlight.mat'};
         if exist(fileNames{1},'file')==2 && exist(fileNames{2},'file')==2 && exist(fileNames{3},'file')
             load(fileNames{1}); load(fileNames{2}); load(fileNames{3});
         else
             [visualRangeDaylight,pupilValuesAir]=Aerial_daylightContrastLimiting;
             [visualRangeMoonlight,pupilValuesAir]=Aerial_daylightContrastLimiting;
             [visualRangeStarlight,pupilValuesAir]=Aerial_daylightContrastLimiting;
         end             
    else
        fileNames={'meteoAerial_Daylight.mat','meteoAerial_Moonlight.mat','meteoAerial_Starlight.mat'};
         if exist(fileNames{1},'file')==2 && exist(fileNames{2},'file')==2 && exist(fileNames{3},'file')
             load(fileNames{1}); load(fileNames{2}); load(fileNames{3});
         else
             [visualRangeDaylight,pupilValuesAir]=Aerial_daylightFiringThresh;
             [visualRangeMoonlight,pupilValuesAir]=Aerial_daylightFiringThresh;
             [visualRangeStarlight,pupilValuesAir]=Aerial_daylightFiringThresh;
         end          
    end

    %% CALCULATE VOLUME
    for loop1=1:length(visualRangeDaylight)
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

function [ dydx ] = derivative( x,y )
    dydx(1)=(y(2)-y(1))/(x(2)-x(1));
    for n=2:length(y)-1
        dydx(n)=(y(n+1)-y(n-1))/(x(n+1)-x(n-1));
    end
    dydx(length(y))=(y(end)-y(end-1))/(x(end)-x(end-1));
