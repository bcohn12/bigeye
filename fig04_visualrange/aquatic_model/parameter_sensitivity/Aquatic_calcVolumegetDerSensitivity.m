function [visualRange_River, visualVolume_River, drdA_River, dVdA_River,pupilValues] = Aquatic_calcVolumegetDerSensitivity(CONTRASTTHRESH)
    run Parameters.m
    load('Parameters.mat')
    if CONTRASTTHRESH
        load('visibilityAquaticSensitivityParameters_All.mat')
        temp=visualRange_River;
        load('visibilityAquaticSensitivityContrast.mat');
        visualRange_River=reshape(visualRange_River,[30,2,1]);
    else
        load('meteoAquaticSensitivityParameters_All.mat')
    end
    temp(:,:,size(temp,3)+1)=visualRange_River; visualRange_River=temp;               
    drdA_River=visualRange_River;
    dVdA_River=visualRange_River;
    visualVolume_River=visualRange_River;

    for i=1:size(visualRange_River,3);
        for j=1:size(visualRange_River,2);
            for k=1:size(visualRange_River,1);
                visualVolume_River(k,j,i)=integral3(f,0,visualRange_River(k,j,i),...
                elevationMin,elevationMax,...
                azimuthMin,azimuthMax);
            end
        end
    end
    
    for i=1:size(visualRange_River,3);
        for j=1:size(visualRange_River,2);
            drdA_River(:,j,i)=derivative(pupilValues*10^3,visualRange_River(:,j,i));
            dVdA_River(:,j,i)=derivative(pupilValues*10^3,visualVolume_River(:,j,i));
        end
    end
    
function [ dydx ] = derivative( x,y )
    dydx(1)=(y(2)-y(1))/(x(2)-x(1));
    for n=2:length(y)-1
        dydx(n)=(y(n+1)-y(n-1))/(x(n+1)-x(n-1));
    end
    dydx(length(y))=(y(end)-y(end-1))/(x(end)-x(end-1));