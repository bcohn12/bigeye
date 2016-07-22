function plotContrastRange

    close all;
    run ../figXX_compviz/Parameters.m
    
    load('aquaticContrastRange');
    load('daylightContrastRange');
    load ../fig02_orbitsize/OM_TF_ST1.mat
   
    [contrastRange_River,C0RangeNew]=interpolateContrastRange(C0Range,visualRange_River);
    [contrastRange,C0RangeNew]=interpolateContrastRange(C0Range,visualRangeSolnsTemp);
   
    fillboxalpha=0.18; % transparency of fillbox to show +/- std of pupil size;
    
    pupil_TF = [mean(OM_TF)-std(OM_TF) mean(OM_TF)+std(OM_TF)].*0.449;
    pupil_ST = [mean(OM_ST)-std(OM_ST) mean(OM_ST)+std(OM_ST)].*0.449;

    fishpupil=mean(OM_TF)*.449;
    tetrapodpupil=mean(OM_ST)*.449;

    linewidthDef=2;
        key={'finned lower SD', 'digited lower SD','finned','finned higher SD',...
        'digited','digited higher SD'};
    
    figure();
    plot(C0RangeNew,contrastRange_River,'linewidth',linewidthDef)
    xlabel('contrast'); ylabel('visual range (m)');
    title('Aquatic Daylight Contrast vs Range')
    columnlegend(3,key,'location','north',...
        'fontsize',8)
    figure();
    plot(C0RangeNew,contrastRange,'linewidth',linewidthDef)
    xlabel('contrast'); ylabel('visual range (m)');
    title('Aerial Daylight Contrast vs Range')
    columnlegend(3,key,'location','north',...
        'fontsize',8)