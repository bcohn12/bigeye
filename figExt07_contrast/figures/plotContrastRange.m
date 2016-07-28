function plotContrastRange
    close all;
    run Parameters.m
    
    [e,em]=fileExists;
    while ~all(e)
        
    
    if exist('Aerial_daylightContrastRange.mat','file')==2
        load('Aerial_daylightContrastRange.mat')
    else
        [visualRangeSolns,C0Range,pupilValues] = Aerial_contrastRangeRelation;
    end
    if exist('Aquatic_daylightContrastRange.mat','file')==2
        load('Aquatic_daylightContrastRange.mat')
    else
        [visualRange_River,C0Range,pupilValues]=Aquatic_dayligthContrastRange;
    end
    if exist('imageContrastValues.mat','file')==2
        load('imageContrastValues.mat')
    else
        [bugContrast,fishContrast,baseFileNames]=getBugContrast;
    end
    
    load ../../fig02_orbitsize/OM_TF_ST1.mat
   
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
    plot(C0RangeNew,contrastRange_River(:,3,1),'linewidth',linewidthDef)
    hold on;
    plot(C0RangeNew,contrastRange_River(:,3,2),':',...
        'color',[0 0.4470 0.7410],'linewidth',linewidthDef)
    plot(C0RangeNew,contrastRange_River(:,5,1),...
        'color',[0.8500    0.3250    0.0980],'linewidth',linewidthDef)
    plot(C0RangeNew,contrastRange_River(:,5,2),':',...
        'color',[0.8500    0.3250    0.0980],'linewidth',linewidthDef)
    xlabel('contrast'); ylabel('visual range (m)');
    title('Aquatic Daylight Contrast vs Range')
    ylim1=get(gca,'Ylim'); xlim1=get(gca,'Xlim');
    line([-0.3 -0.3],[ylim1(1) ylim1(2)],'linestyle',':','color','b');
    line([0.3 0.3],[ylim1(1) ylim1(2)],'linestyle',':','color','b');
    line([-0.1 -0.1],[ylim1(1) ylim1(2)],'linestyle',':','color','b');
    line([0.1 0.1],[ylim1(1) ylim1(2)],'linestyle',':','color','b');

    figure();
    plot(C0RangeNew,contrastRange(:,3),'linewidth',linewidthDef)
    hold on;
    plot(C0RangeNew,contrastRange(:,5),'linewidth',linewidthDef)
    xlabel('contrast'); ylabel('visual range (m)');
    title('Aerial Daylight Contrast vs Range')
        ylim1=get(gca,'Ylim'); xlim1=get(gca,'Xlim');
    line([-0.3 -0.3],[ylim1(1) ylim1(2)],'linestyle',':','color','r');
    line([0.3 0.3],[ylim1(1) ylim1(2)],'linestyle',':','color','r');
    line([-0.1 -0.1],[ylim1(1) ylim1(2)],'linestyle',':','color','r');
    line([0.1 0.1],[ylim1(1) ylim1(2)],'linestyle',':','color','r');
   
function [e,em]=fileExists
    e1={exist('Aerial_daylightContrastRange.mat','file')==2,'Aerial_daylightContrastRange.m'};
    e2={exist('Aquatic_daylightContrastRange.mat','file')==2, 'Aquatic_daylightContrastRange.m'};
    e3={exist('imageContrastValues.mat','file')==2,'getBugContrast.m'};
    e=[e1{1} e2{1} e3{1}];
    em=[e1{2} e2{2} e3{2}];
    
