function [visualRange_River, visualVolume_River, drdA_River, dVdA_River,pupilValues] = Aquatic_calcVolumegetDer(CONTRASTTHRESH)
    run ../../figXX_compviz/Parameters.m
    
    e=exist('visibilityAquatic_All.mat','file')==2;
    choice=questdlg('.mat files found! Re-run the code?','code re-run','yes','no','no');
    switch 2*(strcmp(choice,'no')&e)+CONTRASTTHRESH
        case 3
            load('visibilityAquatic_All.mat');
        case 2
             load('meteoAquatic_All.mat');
        case 1
             [visualRange_River,pupilValues]=Aquatic_contrastLimiting;
        case 0
             [visualRange_River,pupilValues]=Aquatic_firingThresh;
                
    end
            
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