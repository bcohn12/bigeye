function figExt07_contrast
    close all;
    run Parameters.m
    load('Parameters.mat')
    load OM_TF_ST.mat
    
    [e,em]=fileExists;
    while ~all(e)
        notFound=find(e==0);
        warning('Not all *.mat files required are found some are going to be re-run');
        for i=1:length(notFound)
            fprintf('running %s\n',em{notFound(i)});
            run(em{notFound(i)});
        end
        [e,em]=fileExists;
    end
    h=warndlg({'All of the code takes atleast 24hrs to run'},'Warning!');
    waitfor(h);
    choice=questdlg({'All the required *.mat files found!',...
        'Re-run the code?'},'code re-run','yes','no','no');
    if strcmp(choice,'yes')
        for i=1:length(em)
            fprintf('running %s\n',em{i});
            run(em{i})
        end
    end
    load('Aerial_daylightContrastRange.mat')
    load('Aquatic_daylightContrastRange.mat')
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
    
