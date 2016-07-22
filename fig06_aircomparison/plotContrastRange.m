function plotContrastRange

    close all;
    run ../figXX_compviz/Parameters.m
    
    load('aquaticContrastRange');
    load('daylightContrastRange');
    load('contrastValues');
    load ../fig02_orbitsize/OM_TF_ST1.mat
   
    [contrastRange_River,C0RangeNew]=interpolateContrastRange(C0Range,visualRange_River);
    [contrastRange,C0RangeNew]=interpolateContrastRange(C0Range,visualRangeSolnsTemp);
   
    fillboxalpha=0.18; % transparency of fillbox to show +/- std of pupil size;
    
    pupil_TF = [mean(OM_TF)-std(OM_TF) mean(OM_TF)+std(OM_TF)].*0.449;
    pupil_ST = [mean(OM_ST)-std(OM_ST) mean(OM_ST)+std(OM_ST)].*0.449;

    fishpupil=mean(OM_TF)*.449;
    tetrapodpupil=mean(OM_ST)*.449;

    minFishContrast=min(fishContrast); minBugContrast=min(bugContrast);
    maxFishContrast=max(fishContrast); maxBugContrast=max(bugContrast);
    
    linewidthDef=2;
        key={'finned lower SD', 'digited lower SD','finned','finned higher SD',...
        'digited','digited higher SD'};
    
    figure();
    plot(C0RangeNew,contrastRange_River,'linewidth',linewidthDef)
    hold on;
    xlabel('contrast'); ylabel('visual range (m)');
    title('Aquatic Daylight Contrast vs Range')
    ylim1=get(gca,'Ylim'); xlim1=get(gca,'Xlim');
    fillboxTF = patch([minFishContrast minFishContrast,...
        maxFishContrast maxFishContrast], ...
    [ylim1(1) ylim1(2) ylim1(2) ylim1(1)],[1 0 0]);
    set(fillboxTF,'facealpha',fillboxalpha,'edgecolor','none');
%     fillboxST = patch([pupil_ST(1) pupil_ST(1) pupil_ST(2) pupil_ST(2)], ...
%         [ylim1(1) ylim1(2) ylim1(2) ylim1(1)],[0 0 1]);
%     set(fillboxST,'facealpha',fillboxalpha,'edgecolor','none');
    
    columnlegend(3,key,'location','north',...
        'fontsize',8)
    figure();
    plot(C0RangeNew,contrastRange,'linewidth',linewidthDef)
    hold on;
    xlabel('contrast'); ylabel('visual range (m)');
    title('Aerial Daylight Contrast vs Range')
        ylim1=get(gca,'Ylim'); xlim1=get(gca,'Xlim');
    fillboxTF = patch([minBugContrast minBugContrast,...
        maxBugContrast maxBugContrast], ...
    [ylim1(1) ylim1(2) ylim1(2) ylim1(1)],[1 0 0]);
    set(fillboxTF,'facealpha',fillboxalpha,'edgecolor','none');
    
    columnlegend(3,key,'location','north',...
        'fontsize',8)