function plotComparisonRange
    close all;
    run ../figXX_compviz/Parameters.m
    
    CONTRASTTHRESH=1;

    if CONTRASTTHRESH
        load actualDaylight.mat;
        load actualMoonlight.mat;
        load actualStarlight.mat;
    else
        load daylight.mat
        load moonlight.mat
        load starlight.mat
    end
    load terrestrial_Avsr.mat
    load('pupilSizevsRangeConstantDepth_Coastal.mat');
    load('pupilSizevsRangeConstantDepth_River.mat');
    
    pupilValuesAir=linspace(minpupil,maxpupil,25);
    
    fillboxalpha=0.07; % transparency of fillbox to show +/- std of pupil size;
    load ../fig02_orbitsize/OM_TF_ST.mat
    pupil_TF = [mean(OM_TF)-std(OM_TF) mean(OM_TF)+std(OM_TF)].*0.53;
    pupil_ST = [mean(OM_ST)-std(OM_ST) mean(OM_ST)+std(OM_ST)].*0.53;

    fishpupil=mean(OM_TF)*.53;
    tetrapodpupil=mean(OM_ST)*.53;

    linewidthDef=2;
    
    visualRange=[visualRangeDaylight, visualRangeMoonlight, visualRangeStarlight];
    drdA=[smooth(drdADaylight)';smooth(drdAMoonlight)';smooth(drdAStarlight)'];
    visualVolume=[visualVolumeDaylight;visualVolumeMoonlight;visualVolumeStarlight];
    dVdA=[smooth(dVdADaylight,7)';smooth(dVdAMoonlight,7)';smooth(dVdAStarlight,7)'];
    
    %visualRange_Coastal=[visualRange_Coastal(:,1:2,1) visualRange_Coastal(:,1:2,2)];
    %drdA_Coastal=[drdA_Coastal(:,1:2,1), drdA_Coastal(:,1:2,2)];
    %visualVolume_Coastal=[visualVolume_Coastal(:,1:2,1) visualVolume_Coastal(:,1:2,2)];
    %dVdA_Coastal=[dVdA_Coastal(:,1:2,1), dVdA_Coastal(:,1:2,2)];
    
%  visualRange_River=[visualRange_River(:,1:2,1), visualRange_River(:,1:2,2)];
%     drdA_River=[drdA_River(:,1:2,1), drdA_River(:,1:2,2)];
%     visualVolume_River=[visualVolume_River(:,1:2,1) visualVolume_River(:,1:2,2)];
%     dVdA_River=[dVdA_River(:,1:2,1), dVdA_River(:,1:2,2)];
%     
     % removing 10 m case
     visualRange_River=[visualRange_River(:,2,1), visualRange_River(:,2,2)];
    drdA_River=[smooth(drdA_River(:,2,1)), smooth(drdA_River(:,2,2))];
    visualVolume_River=[visualVolume_River(:,2,1) visualVolume_River(:,2,2)];
    dVdA_River=[smooth(dVdA_River(:,2,1),7), smooth(dVdA_River(:,2,2),7)];
%%    
    figure(); clf;
    subplot(2,2,1);
    plot(pupilValuesAir*10^3, visualRange,'linewidth',linewidthDef);
    xlabel('pupil diameter (mm)'); ylabel('visual range (m)');
    xlim([0.001*10^3 maxpupil*10^3]); ylim1=get(gca,'ylim'); 
    hold on
    fillboxTF = patch([pupil_TF(1) pupil_TF(1) pupil_TF(2) pupil_TF(2)], ...
    [ylim1(1) ylim1(2) ylim1(2) ylim1(1)],[1 0 0]);
    set(fillboxTF,'facealpha',fillboxalpha,'edgecolor','none');
    fillboxST = patch([pupil_ST(1) pupil_ST(1) pupil_ST(2) pupil_ST(2)], ...
        [ylim1(1) ylim1(2) ylim1(2) ylim1(1)],[0 0 1]);
    set(fillboxST,'facealpha',fillboxalpha,'edgecolor','none');
    line([fishpupil,fishpupil],[ylim1(1),ylim1(2)],'linewidth',linewidthDef,'color',[216/256,191/256,216/256],'linestyle',':')
    line([tetrapodpupil,tetrapodpupil],[ylim1(1),ylim1(2)],'linewidth',linewidthDef,'color',[0/256,128/256,128/256],'linestyle',':')
    
    subplot(2,2,2)
    plot(pupilValuesAir*10^3,drdA,'linewidth',linewidthDef);
    xlabel('pupil diameter (mm)'); ylabel('dr/dA (m/mm)');
    xlim([0.001*10^3 maxpupil*10^3]); ylim2=get(gca,'ylim'); 
    hold on
    fillboxTF = patch([pupil_TF(1) pupil_TF(1) pupil_TF(2) pupil_TF(2)], ...
    [ylim2(1) ylim2(2) ylim2(2) ylim2(1)],[1 0 0]);
    set(fillboxTF,'facealpha',fillboxalpha,'edgecolor','none');
    fillboxST = patch([pupil_ST(1) pupil_ST(1) pupil_ST(2) pupil_ST(2)], ...
        [ylim2(1) ylim2(2) ylim2(2) ylim2(1)],[0 0 1]);
    set(fillboxST,'facealpha',fillboxalpha,'edgecolor','none');
    line([fishpupil,fishpupil],[ylim2(1),ylim2(2)],'linewidth',linewidthDef,'color',[216/256,191/256,216/256],'linestyle',':')
    line([tetrapodpupil,tetrapodpupil],[ylim2(1),ylim2(2)],'linewidth',linewidthDef,'color',[0/256,128/256,128/256],'linestyle',':')
    
    subplot(2,2,3)
    plot(pupilValuesAir*10^3,visualVolume,'linewidth',linewidthDef);
    xlabel('pupil diameter (mm)'); ylabel('visual volume (m^3)');
    xlim([0.001*10^3 maxpupil*10^3]); ylim3=get(gca,'ylim'); 
    hold on
    fillboxTF = patch([pupil_TF(1) pupil_TF(1) pupil_TF(2) pupil_TF(2)], ...
    [ylim3(1) ylim3(2) ylim3(2) ylim3(1)],[1 0 0]);
    set(fillboxTF,'facealpha',fillboxalpha,'edgecolor','none');
    fillboxST = patch([pupil_ST(1) pupil_ST(1) pupil_ST(2) pupil_ST(2)], ...
        [ylim3(1) ylim3(2) ylim3(2) ylim3(1)],[0 0 1]);
    set(fillboxST,'facealpha',fillboxalpha,'edgecolor','none');
    line([fishpupil,fishpupil],[ylim3(1),ylim3(2)],'linewidth',linewidthDef,'color',[216/256,191/256,216/256],'linestyle',':')
    line([tetrapodpupil,tetrapodpupil],[ylim3(1),ylim3(2)],'linewidth',linewidthDef,'color',[0/256,128/256,128/256],'linestyle',':')
    
    subplot(2,2,4)
    plot(pupilValuesAir*10^3,dVdA,'linewidth',linewidthDef);
    xlabel('pupil diameter (mm)'); ylabel('dV/dA (m^3/mm)');
    xlim([0.001*10^3 maxpupil*10^3]); ylim4=get(gca,'ylim');
    hold on
    fillboxTF = patch([pupil_TF(1) pupil_TF(1) pupil_TF(2) pupil_TF(2)], ...
    [ylim4(1) ylim4(2) ylim4(2) ylim4(1)],[1 0 0]);
    set(fillboxTF,'facealpha',fillboxalpha,'edgecolor','none');
    fillboxST = patch([pupil_ST(1) pupil_ST(1) pupil_ST(2) pupil_ST(2)], ...
        [ylim4(1) ylim4(2) ylim4(2) ylim4(1)],[0 0 1]);
    set(fillboxST,'facealpha',fillboxalpha,'edgecolor','none');
    line([fishpupil,fishpupil],[ylim4(1),ylim4(2)],'linewidth',linewidthDef,'color',[216/256,191/256,216/256],'linestyle',':')
    line([tetrapodpupil,tetrapodpupil],[ylim4(1),ylim4(2)],'linewidth',linewidthDef,'color',[0/256,128/256,128/256],'linestyle',':')
    
    legend({'Daylight','Moonlight','Starlight'},'location','north',...
        'fontsize',8,'orientation','horizontal');
    legend('boxoff')
%%
    figure(); clf();
    subplot(2,2,1);
    %plot(pupilValues*1e3,visualRange_Coastal,'linewidth',linewidthDef);
    
    %hold on;
    plot(pupilValues*1e3,visualRange_River,'linewidth',linewidthDef);
    xlabel('pupil diameter (mm)'); ylabel('visual range (m)');
    xlim([0.001*10^3 maxpupil*10^3]); ylim1=get(gca,'ylim'); 
    fillboxTF = patch([pupil_TF(1) pupil_TF(1) pupil_TF(2) pupil_TF(2)], ...
    [ylim1(1) ylim1(2) ylim1(2) ylim1(1)],[1 0 0]);
    set(fillboxTF,'facealpha',fillboxalpha,'edgecolor','none');
    fillboxST = patch([pupil_ST(1) pupil_ST(1) pupil_ST(2) pupil_ST(2)], ...
        [ylim1(1) ylim1(2) ylim1(2) ylim1(1)],[0 0 1]);
    set(fillboxST,'facealpha',fillboxalpha,'edgecolor','none');
    line([fishpupil,fishpupil],[ylim1(1),ylim1(2)],'linewidth',linewidthDef,'color',[216/256,191/256,216/256],'linestyle',':')
    line([tetrapodpupil,tetrapodpupil],[ylim1(1),ylim1(2)],'linewidth',linewidthDef,'color',[0/256,128/256,128/256],'linestyle',':')
    
    subplot(2,2,2)
    %plot(pupilValues*1e3,drdA_Coastal,'linewidth',linewidthDef);
    %hold on;
    plot(pupilValues*1e3,drdA_River,'linewidth',linewidthDef);
    xlabel('pupil diameter (mm)'); ylabel('dr/dA (m/mm)');
    xlim([0.001*10^3 maxpupil*10^3]); ylim2=get(gca,'ylim'); 
    fillboxTF = patch([pupil_TF(1) pupil_TF(1) pupil_TF(2) pupil_TF(2)], ...
    [ylim2(1) ylim2(2) ylim2(2) ylim2(1)],[1 0 0]);
    set(fillboxTF,'facealpha',fillboxalpha,'edgecolor','none');
    fillboxST = patch([pupil_ST(1) pupil_ST(1) pupil_ST(2) pupil_ST(2)], ...
        [ylim2(1) ylim2(2) ylim2(2) ylim2(1)],[0 0 1]);
    set(fillboxST,'facealpha',fillboxalpha,'edgecolor','none');
    line([fishpupil,fishpupil],[ylim2(1),ylim2(2)],'linewidth',linewidthDef,'color',[216/256,191/256,216/256],'linestyle',':')
    line([tetrapodpupil,tetrapodpupil],[ylim2(1),ylim2(2)],'linewidth',linewidthDef,'color',[0/256,128/256,128/256],'linestyle',':')
    
    subplot(2,2,3)
    %plot(pupilValues*1e3,visualVolume_Coastal,'linewidth',linewidthDef);
    %hold on;
    plot(pupilValues*1e3,visualVolume_River,'linewidth',linewidthDef);
    xlabel('pupil diameter (mm)'); ylabel('visual volume (m^3)');
    xlim([0.001*10^3 maxpupil*10^3]); ylim3=get(gca,'ylim'); 
    fillboxTF = patch([pupil_TF(1) pupil_TF(1) pupil_TF(2) pupil_TF(2)], ...
    [ylim3(1) ylim3(2) ylim3(2) ylim3(1)],[1 0 0]);
    set(fillboxTF,'facealpha',fillboxalpha,'edgecolor','none');
    fillboxST = patch([pupil_ST(1) pupil_ST(1) pupil_ST(2) pupil_ST(2)], ...
        [ylim3(1) ylim3(2) ylim3(2) ylim3(1)],[0 0 1]);
    set(fillboxST,'facealpha',fillboxalpha,'edgecolor','none');
    line([fishpupil,fishpupil],[ylim3(1),ylim3(2)],'linewidth',linewidthDef,'color',[216/256,191/256,216/256],'linestyle',':')
    line([tetrapodpupil,tetrapodpupil],[ylim3(1),ylim3(2)],'linewidth',linewidthDef,'color',[0/256,128/256,128/256],'linestyle',':')
    
    subplot(2,2,4)
    %plot(pupilValues*1e3,dVdA_Coastal,'linewidth',linewidthDef);
    %hold on;
    plot(pupilValues*1e3,dVdA_River,'linewidth',linewidthDef);
    xlabel('pupil diameter (mm)'); ylabel('dV/dA (m^3/mm)');
    xlim([0.001*10^3 maxpupil*10^3]); ylim4=get(gca,'ylim');
    fillboxTF = patch([pupil_TF(1) pupil_TF(1) pupil_TF(2) pupil_TF(2)], ...
    [ylim4(1) ylim4(2) ylim4(2) ylim4(1)],[1 0 0]);
    set(fillboxTF,'facealpha',fillboxalpha,'edgecolor','none');
    fillboxST = patch([pupil_ST(1) pupil_ST(1) pupil_ST(2) pupil_ST(2)], ...
        [ylim4(1) ylim4(2) ylim4(2) ylim4(1)],[0 0 1]);
    set(fillboxST,'facealpha',fillboxalpha,'edgecolor','none');
    line([fishpupil,fishpupil],[ylim4(1),ylim4(2)],'linewidth',linewidthDef,'color',[216/256,191/256,216/256],'linestyle',':')
    line([tetrapodpupil,tetrapodpupil],[ylim4(1),ylim4(2)],'linewidth',linewidthDef,'color',[0/256,128/256,128/256],'linestyle',':')
    
%     key={'Coastal looking upwards depth 10m','Coastal looking upwards depth 7m',...
%         'Coastal horizontal depth 10m', 'Coastal horizontal depth 7m',...
%         'River looking upwards depth 10m','River looking upwards depth 7m',...
%         'River horizontal depth 10m', 'River horizontal depth 7m'};
%   
        key={'River looking upwards depth 7m',...
        'River horizontal depth 7m'};
    
    columnlegend(2,key,'location','north',...
        'fontsize',8)
%%    
    figure(); clf();
    subplot(2,2,1);
    plot(pupilValuesAir*10^3, visualRange,'linewidth',linewidthDef);
    hold on;
    %plot(pupilValues*1e3,visualRange_Coastal,'linewidth',linewidthDef);
    plot(pupilValues*1e3,visualRange_River,'linewidth',linewidthDef);
    xlabel('pupil diameter (mm)'); ylabel('visual range (m)');
    xlim([0.001*10^3 maxpupil*10^3]); ylim1=get(gca,'ylim'); 
    fillboxTF = patch([pupil_TF(1) pupil_TF(1) pupil_TF(2) pupil_TF(2)], ...
    [ylim1(1) ylim1(2) ylim1(2) ylim1(1)],[1 0 0]);
    set(fillboxTF,'facealpha',fillboxalpha,'edgecolor','none');
    fillboxST = patch([pupil_ST(1) pupil_ST(1) pupil_ST(2) pupil_ST(2)], ...
        [ylim1(1) ylim1(2) ylim1(2) ylim1(1)],[0 0 1]);
    set(fillboxST,'facealpha',fillboxalpha,'edgecolor','none');
    line([fishpupil,fishpupil],[ylim1(1),ylim1(2)],'linewidth',linewidthDef,'color',[216/256,191/256,216/256],'linestyle',':')
    line([tetrapodpupil,tetrapodpupil],[ylim1(1),ylim1(2)],'linewidth',linewidthDef,'color',[0/256,128/256,128/256],'linestyle',':')
    
    subplot(2,2,2)
    plot(pupilValuesAir*10^3,drdA,'linewidth',linewidthDef);
    hold on;
    %plot(pupilValues*1e3,drdA_Coastal,'linewidth',linewidthDef);
    plot(pupilValues*1e3,drdA_River,'linewidth',linewidthDef);
    xlabel('pupil diameter (mm)'); ylabel('dr/dA (m/mm)');
    xlim([0.001*10^3 maxpupil*10^3]); ylim2=get(gca,'ylim'); 
    fillboxTF = patch([pupil_TF(1) pupil_TF(1) pupil_TF(2) pupil_TF(2)], ...
    [ylim2(1) ylim2(2) ylim2(2) ylim2(1)],[1 0 0]);
    set(fillboxTF,'facealpha',fillboxalpha,'edgecolor','none');
    fillboxST = patch([pupil_ST(1) pupil_ST(1) pupil_ST(2) pupil_ST(2)], ...
        [ylim2(1) ylim2(2) ylim2(2) ylim2(1)],[0 0 1]);
    set(fillboxST,'facealpha',fillboxalpha,'edgecolor','none');
    line([fishpupil,fishpupil],[ylim2(1),ylim2(2)],'linewidth',linewidthDef,'color',[216/256,191/256,216/256],'linestyle',':')
    line([tetrapodpupil,tetrapodpupil],[ylim2(1),ylim2(2)],'linewidth',linewidthDef,'color',[0/256,128/256,128/256],'linestyle',':')
    
    subplot(2,2,3)
    plot(pupilValuesAir*10^3,visualVolume,'linewidth',linewidthDef);
    hold on;
    %plot(pupilValues*1e3,visualVolume_Coastal,'linewidth',linewidthDef);
    plot(pupilValues*1e3,visualVolume_River,'linewidth',linewidthDef);
    xlabel('pupil diameter (mm)'); ylabel('visual volume (m^3)');
    xlim([0.001*10^3 maxpupil*10^3]); ylim3=get(gca,'ylim'); 
    fillboxTF = patch([pupil_TF(1) pupil_TF(1) pupil_TF(2) pupil_TF(2)], ...
    [ylim3(1) ylim3(2) ylim3(2) ylim3(1)],[1 0 0]);
    set(fillboxTF,'facealpha',fillboxalpha,'edgecolor','none');
    fillboxST = patch([pupil_ST(1) pupil_ST(1) pupil_ST(2) pupil_ST(2)], ...
        [ylim3(1) ylim3(2) ylim3(2) ylim3(1)],[0 0 1]);
    set(fillboxST,'facealpha',fillboxalpha,'edgecolor','none');
    line([fishpupil,fishpupil],[ylim3(1),ylim3(2)],'linewidth',linewidthDef,'color',[216/256,191/256,216/256],'linestyle',':')
    line([tetrapodpupil,tetrapodpupil],[ylim3(1),ylim3(2)],'linewidth',linewidthDef,'color',[0/256,128/256,128/256],'linestyle',':')
    
    subplot(2,2,4)
    plot(pupilValuesAir*10^3,dVdA,'linewidth',linewidthDef);
    hold on;
    %plot(pupilValues*1e3,dVdA_Coastal,'linewidth',linewidthDef);
    plot(pupilValues*1e3,dVdA_River,'linewidth',linewidthDef);
    xlabel('pupil diameter (mm)'); ylabel('dV/dA (m^3/mm)');
    xlim([0.001*10^3 maxpupil*10^3]); ylim4=get(gca,'ylim');
    fillboxTF = patch([pupil_TF(1) pupil_TF(1) pupil_TF(2) pupil_TF(2)], ...
    [ylim4(1) ylim4(2) ylim4(2) ylim4(1)],[1 0 0]);
    set(fillboxTF,'facealpha',fillboxalpha,'edgecolor','none');
    fillboxST = patch([pupil_ST(1) pupil_ST(1) pupil_ST(2) pupil_ST(2)], ...
        [ylim4(1) ylim4(2) ylim4(2) ylim4(1)],[0 0 1]);
    set(fillboxST,'facealpha',fillboxalpha,'edgecolor','none');
    line([fishpupil,fishpupil],[ylim4(1),ylim4(2)],'linewidth',linewidthDef,'color',[216/256,191/256,216/256],'linestyle',':')
    line([tetrapodpupil,tetrapodpupil],[ylim4(1),ylim4(2)],'linewidth',linewidthDef,'color',[0/256,128/256,128/256],'linestyle',':')
    
%     key={'Daylight','Moonlight','Starlight',...
%         'Coastal looking upwards depth 10m','Coastal looking upwards depth 7m',...
%         'Coastal horizontal depth 10m', 'Coastal horizontal depth 7m',...
%         'River looking upwards depth 10m','River looking upwards depth 7m',...
%         'River horizontal depth 10m', 'River horizontal depth 7m'};
%     
    key={'Daylight','Moonlight','Starlight',...
        'River looking upwards depth 7m',...
        'River horizontal depth 7m'};
    
  
    columnlegend(2,key,'location','north',...
        'fontsize',8)
%%    
    figure(); clf();
    subplot(2,2,1);
    semilogy(pupilValuesAir*10^3, visualRange,'linewidth',linewidthDef);
    hold on;
    %semilogy(pupilValues*1e3,visualRange_Coastal,'linewidth',linewidthDef);
    semilogy(pupilValues*1e3,visualRange_River,'linewidth',linewidthDef);
    xlabel('pupil diameter (mm)'); ylabel('visual range (m)');
    xlim([0.001*10^3 maxpupil*10^3]); ylim1=get(gca,'ylim'); 
    fillboxTF = patch([pupil_TF(1) pupil_TF(1) pupil_TF(2) pupil_TF(2)], ...
    [ylim1(1) ylim1(2) ylim1(2) ylim1(1)],[1 0 0]);
    set(fillboxTF,'facealpha',fillboxalpha,'edgecolor','none');
    fillboxST = patch([pupil_ST(1) pupil_ST(1) pupil_ST(2) pupil_ST(2)], ...
        [ylim1(1) ylim1(2) ylim1(2) ylim1(1)],[0 0 1]);
    set(fillboxST,'facealpha',fillboxalpha,'edgecolor','none');
    line([fishpupil,fishpupil],[ylim1(1),ylim1(2)],'linewidth',linewidthDef,'color',[216/256,191/256,216/256],'linestyle',':')
    line([tetrapodpupil,tetrapodpupil],[ylim1(1),ylim1(2)],'linewidth',linewidthDef,'color',[0/256,128/256,128/256],'linestyle',':')
    
    subplot(2,2,2)
    semilogy(pupilValuesAir*10^3,drdA,'linewidth',linewidthDef);
    hold on;
    %semilogy(pupilValues*1e3,drdA_Coastal,'linewidth',linewidthDef);
    semilogy(pupilValues*1e3,drdA_River,'linewidth',linewidthDef);
    xlabel('pupil diameter (mm)'); ylabel('dr/dA (m/mm)');
    xlim([0.001*10^3 maxpupil*10^3]); ylim2=get(gca,'ylim'); 
    fillboxTF = patch([pupil_TF(1) pupil_TF(1) pupil_TF(2) pupil_TF(2)], ...
    [ylim2(1) ylim2(2) ylim2(2) ylim2(1)],[1 0 0]);
    set(fillboxTF,'facealpha',fillboxalpha,'edgecolor','none');
    fillboxST = patch([pupil_ST(1) pupil_ST(1) pupil_ST(2) pupil_ST(2)], ...
        [ylim2(1) ylim2(2) ylim2(2) ylim2(1)],[0 0 1]);
    set(fillboxST,'facealpha',fillboxalpha,'edgecolor','none');
    line([fishpupil,fishpupil],[ylim2(1),ylim2(2)],'linewidth',linewidthDef,'color',[216/256,191/256,216/256],'linestyle',':')
    line([tetrapodpupil,tetrapodpupil],[ylim2(1),ylim2(2)],'linewidth',linewidthDef,'color',[0/256,128/256,128/256],'linestyle',':')
    
    subplot(2,2,3)
    semilogy(pupilValuesAir*10^3,visualVolume,'linewidth',linewidthDef);
    hold on;
    %semilogy(pupilValues*1e3,visualVolume_Coastal,'linewidth',linewidthDef);
    semilogy(pupilValues*1e3,visualVolume_River,'linewidth',linewidthDef);
    xlabel('pupil diameter (mm)'); ylabel('visual volume (m^3)');
    xlim([0.001*10^3 maxpupil*10^3]); ylim3=get(gca,'ylim'); 
    fillboxTF = patch([pupil_TF(1) pupil_TF(1) pupil_TF(2) pupil_TF(2)], ...
    [ylim3(1) ylim3(2) ylim3(2) ylim3(1)],[1 0 0]);
    set(fillboxTF,'facealpha',fillboxalpha,'edgecolor','none');
    fillboxST = patch([pupil_ST(1) pupil_ST(1) pupil_ST(2) pupil_ST(2)], ...
        [ylim3(1) ylim3(2) ylim3(2) ylim3(1)],[0 0 1]);
    set(fillboxST,'facealpha',fillboxalpha,'edgecolor','none');
    line([fishpupil,fishpupil],[ylim3(1),ylim3(2)],'linewidth',linewidthDef,'color',[216/256,191/256,216/256],'linestyle',':')
    line([tetrapodpupil,tetrapodpupil],[ylim3(1),ylim3(2)],'linewidth',linewidthDef,'color',[0/256,128/256,128/256],'linestyle',':')
    
    subplot(2,2,4)
    semilogy(pupilValuesAir*10^3,dVdA,'linewidth',linewidthDef);
    hold on;
    %semilogy(pupilValues*1e3,dVdA_Coastal,'linewidth',linewidthDef);
    semilogy(pupilValues*1e3,dVdA_River,'linewidth',linewidthDef);
    xlabel('pupil diameter (mm)'); ylabel('dV/dA (m^3/mm)');
    xlim([0.001*10^3 maxpupil*10^3]); ylim4=get(gca,'ylim');
    fillboxTF = patch([pupil_TF(1) pupil_TF(1) pupil_TF(2) pupil_TF(2)], ...
    [ylim4(1) ylim4(2) ylim4(2) ylim4(1)],[1 0 0]);
    set(fillboxTF,'facealpha',fillboxalpha,'edgecolor','none');
    fillboxST = patch([pupil_ST(1) pupil_ST(1) pupil_ST(2) pupil_ST(2)], ...
        [ylim4(1) ylim4(2) ylim4(2) ylim4(1)],[0 0 1]);
    set(fillboxST,'facealpha',fillboxalpha,'edgecolor','none');
    line([fishpupil,fishpupil],[ylim4(1),ylim4(2)],'linewidth',linewidthDef,'color',[216/256,191/256,216/256],'linestyle',':')
    line([tetrapodpupil,tetrapodpupil],[ylim4(1),ylim4(2)],'linewidth',linewidthDef,'color',[0/256,128/256,128/256],'linestyle',':')
    
%     key={'Daylight','Moonlight','Starlight',...
%         'Coastal looking upwards depth 10m','Coastal looking upwards depth 7m',...
%         'Coastal horizontal depth 10m', 'Coastal horizontal depth 7m',...
%         'River looking upwards depth 10m','River looking upwards depth 7m',...
%         'River horizontal depth 10m', 'River horizontal depth 7m'};
%     
    key={'Daylight','Moonlight','Starlight',...
       'River looking upwards depth 7m',...
        'River horizontal depth 7m'};
    
    columnlegend(2,key,'location','north',...
        'fontsize',8);
    
    
    
    