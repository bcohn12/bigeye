function [visualRangeDaylight...
    visualVolumeDaylight,...
    drdADaylight,...
    dVdADaylight,pupilValuesAir]=AerialSensitivity_calcVolumegetDerivatives(CONTRASTTHRESH)
    run Parameters.m
    load('Parameters.mat')

    if CONTRASTTHRESH
        fileNames={'visibilityAerialParameterSensitivity_Daylight.mat'};
        load(fileNames{1});
        visualRangeParameter=visualRangeDaylight;
        load('visibilityAerialContrastSensitivity_Daylight.mat');
                  
    else
        fileNames={'meteoAerialParameterSensitivity_Daylight.mat'};        
        load(fileNames{1});                
    end
    
    visualRangeDaylight=[visualRangeDaylight visualRangeParameter];

    %% CALCULATE VOLUME
    for j=1:size(visualRangeDaylight,2)
        for i=1:size(visualRangeDaylight,1)
            visualVolumeDaylight(i,1,j)=integral3(f,0,(visualRangeDaylight(i,j)),...
                elevationMinAir,elevationMaxAir,...
                azimuthMin,azimuthMaxAir);
        end
    end

    %% CALCULATE DERIVATIVE
    for j=1:size(visualRangeDaylight,2)
        drdADaylight(:,1,j)=derivative(pupilValuesAir*10^3,visualRangeDaylight(:,j));
        dVdADaylight(:,1,j)=derivative(pupilValuesAir*10^3,visualVolumeDaylight(:,j));
    end
    
    visualRangeDaylight=reshape(visualRangeDaylight,[size(visualRangeDaylight,1),1,size(visualRangeDaylight,2)]);

function [ dydx ] = derivative( x,y )
    dydx(1)=(y(2)-y(1))/(x(2)-x(1));
    for n=2:length(y)-1
        dydx(n)=(y(n+1)-y(n-1))/(x(n+1)-x(n-1));
    end
    dydx(length(y))=(y(end)-y(end-1))/(x(end)-x(end-1));
