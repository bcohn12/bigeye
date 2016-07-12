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
    load('riverMoonlightFiringRange.mat');
    
    pupilValuesAir=linspace(minpupil,maxpupil,25);
    
    fillboxalpha=0.18; % transparency of fillbox to show +/- std of pupil size;
    load ../fig02_orbitsize/OM_TF_ST.mat
    pupil_TF = [mean(OM_TF)-std(OM_TF) mean(OM_TF)+std(OM_TF)].*0.449;
    pupil_ST = [mean(OM_ST)-std(OM_ST) mean(OM_ST)+std(OM_ST)].*0.449;

    fishpupil=mean(OM_TF)*.449;
    tetrapodpupil=mean(OM_ST)*.449;

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
    visualRange_River=[visualRange_River(:,:,1), visualRange_River(:,:,2)];
    drdA_River=[smooth(drdA_River(:,:,1)), smooth(drdA_River(:,:,2))];
    visualVolume_River=[visualVolume_River(:,:,1) visualVolume_River(:,:,2)];
    dVdA_River=[smooth(dVdA_River(:,:,1),7), smooth(dVdA_River(:,:,2),7)];
    
    visualRange_RiverM=[visualRange_Moonlight(:,:,1), visualRange_Moonlight(:,:,2)];
    drdA_RiverM=[smooth(drdA_Moonlight(:,:,1)), smooth(drdA_Moonlight(:,:,2))];
    visualVolume_RiverM=[visualVolume_Moonlight(:,:,1) visualVolume_Moonlight(:,:,2)];
    dVdA_RiverM=[smooth(dVdA_Moonlight(:,:,1),7), smooth(dVdA_Moonlight(:,:,2),7)];

%%
figure(); clf();
    subplot(2,2,1);
    %plot(pupilValues*1e3,visualRange_Coastal,'linewidth',linewidthDef);
    
    %hold on;
    plot(pupilValues*1e3,visualRange_RiverM,'linewidth',linewidthDef);
    xlabel('pupil diameter (mm)'); ylabel('visual range (m)');
    xlim([0.001*10^3 0.025*10^3]); ylim1=get(gca,'ylim'); 
    fillboxTF = patch([pupil_TF(1) pupil_TF(1) pupil_TF(2) pupil_TF(2)], ...
    [ylim1(1) ylim1(2) ylim1(2) ylim1(1)],[1 0 0]);
    set(fillboxTF,'facealpha',fillboxalpha,'edgecolor','none');
    fillboxST = patch([pupil_ST(1) pupil_ST(1) pupil_ST(2) pupil_ST(2)], ...
        [ylim1(1) ylim1(2) ylim1(2) ylim1(1)],[0 0 1]);
    set(fillboxST,'facealpha',fillboxalpha,'edgecolor','none');
    line([fishpupil,fishpupil],[ylim1(1),ylim1(2)],'linewidth',linewidthDef,'color','r','linestyle',':')
    line([tetrapodpupil,tetrapodpupil],[ylim1(1),ylim1(2)],'linewidth',linewidthDef,'color','b','linestyle',':')
    
    subplot(2,2,2)
    %plot(pupilValues*1e3,drdA_Coastal,'linewidth',linewidthDef);
    %hold on;
    plot(pupilValues*1e3,drdA_RiverM,'linewidth',linewidthDef);
    xlabel('pupil diameter (mm)'); ylabel('dr/dA (m/mm)');
    xlim([0.001*10^3 0.025*10^3]); ylim2=get(gca,'ylim'); 
    fillboxTF = patch([pupil_TF(1) pupil_TF(1) pupil_TF(2) pupil_TF(2)], ...
    [ylim2(1) ylim2(2) ylim2(2) ylim2(1)],[1 0 0]);
    set(fillboxTF,'facealpha',fillboxalpha,'edgecolor','none');
    fillboxST = patch([pupil_ST(1) pupil_ST(1) pupil_ST(2) pupil_ST(2)], ...
        [ylim2(1) ylim2(2) ylim2(2) ylim2(1)],[0 0 1]);
    set(fillboxST,'facealpha',fillboxalpha,'edgecolor','none');
    line([fishpupil,fishpupil],[ylim2(1),ylim2(2)],'linewidth',linewidthDef,'color','r','linestyle',':')
    line([tetrapodpupil,tetrapodpupil],[ylim2(1),ylim2(2)],'linewidth',linewidthDef,'color','b','linestyle',':')
    
    subplot(2,2,3)
    %plot(pupilValues*1e3,visualVolume_Coastal,'linewidth',linewidthDef);
    %hold on;
    plot(pupilValues*1e3,visualVolume_RiverM,'linewidth',linewidthDef);
    xlabel('pupil diameter (mm)'); ylabel('visual volume (m^3)');
    xlim([0.001*10^3 0.025*10^3]); ylim3=get(gca,'ylim'); 
    fillboxTF = patch([pupil_TF(1) pupil_TF(1) pupil_TF(2) pupil_TF(2)], ...
    [ylim3(1) ylim3(2) ylim3(2) ylim3(1)],[1 0 0]);
    set(fillboxTF,'facealpha',fillboxalpha,'edgecolor','none');
    fillboxST = patch([pupil_ST(1) pupil_ST(1) pupil_ST(2) pupil_ST(2)], ...
        [ylim3(1) ylim3(2) ylim3(2) ylim3(1)],[0 0 1]);
    set(fillboxST,'facealpha',fillboxalpha,'edgecolor','none');
    line([fishpupil,fishpupil],[ylim3(1),ylim3(2)],'linewidth',linewidthDef,'color','r','linestyle',':')
    line([tetrapodpupil,tetrapodpupil],[ylim3(1),ylim3(2)],'linewidth',linewidthDef,'color','b','linestyle',':')
    
    subplot(2,2,4)
    %plot(pupilValues*1e3,dVdA_Coastal,'linewidth',linewidthDef);
    %hold on;
    plot(pupilValues*1e3,dVdA_RiverM,'linewidth',linewidthDef);
    xlabel('pupil diameter (mm)'); ylabel('dV/dA (m^3/mm)');
    xlim([0.001*10^3 0.025*10^3]); ylim4=get(gca,'ylim');
    fillboxTF = patch([pupil_TF(1) pupil_TF(1) pupil_TF(2) pupil_TF(2)], ...
    [ylim4(1) ylim4(2) ylim4(2) ylim4(1)],[1 0 0]);
    set(fillboxTF,'facealpha',fillboxalpha,'edgecolor','none');
    fillboxST = patch([pupil_ST(1) pupil_ST(1) pupil_ST(2) pupil_ST(2)], ...
        [ylim4(1) ylim4(2) ylim4(2) ylim4(1)],[0 0 1]);
    set(fillboxST,'facealpha',fillboxalpha,'edgecolor','none');
    line([fishpupil,fishpupil],[ylim4(1),ylim4(2)],'linewidth',linewidthDef,'color','r','linestyle',':')
    line([tetrapodpupil,tetrapodpupil],[ylim4(1),ylim4(2)],'linewidth',linewidthDef,'color','b','linestyle',':')
    
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
    figure(); clf;
    subplot(2,2,1);
    plot(pupilValuesAir*10^3, visualRange,'linewidth',linewidthDef);
    xlabel('pupil diameter (mm)'); ylabel('visual range (m)');
    xlim([0.001*10^3 0.025*10^3]); ylim1=get(gca,'ylim'); 
    hold on
    fillboxTF = patch([pupil_TF(1) pupil_TF(1) pupil_TF(2) pupil_TF(2)], ...
    [ylim1(1) ylim1(2) ylim1(2) ylim1(1)],[1 0 0]);
    set(fillboxTF,'facealpha',fillboxalpha,'edgecolor','none');
    fillboxST = patch([pupil_ST(1) pupil_ST(1) pupil_ST(2) pupil_ST(2)], ...
        [ylim1(1) ylim1(2) ylim1(2) ylim1(1)],[0 0 1]);
    set(fillboxST,'facealpha',fillboxalpha,'edgecolor','none');
    line([fishpupil,fishpupil],[ylim1(1),ylim1(2)],'linewidth',linewidthDef,'color','r','linestyle',':')
    line([tetrapodpupil,tetrapodpupil],[ylim1(1),ylim1(2)],'linewidth',linewidthDef,'color','b','linestyle',':')
    
    subplot(2,2,2)
    plot(pupilValuesAir*10^3,drdA,'linewidth',linewidthDef);
    xlabel('pupil diameter (mm)'); ylabel('dr/dA (m/mm)');
    xlim([0.001*10^3 0.025*10^3]); ylim2=get(gca,'ylim'); 
    hold on
    fillboxTF = patch([pupil_TF(1) pupil_TF(1) pupil_TF(2) pupil_TF(2)], ...
    [ylim2(1) ylim2(2) ylim2(2) ylim2(1)],[1 0 0]);
    set(fillboxTF,'facealpha',fillboxalpha,'edgecolor','none');
    fillboxST = patch([pupil_ST(1) pupil_ST(1) pupil_ST(2) pupil_ST(2)], ...
        [ylim2(1) ylim2(2) ylim2(2) ylim2(1)],[0 0 1]);
    set(fillboxST,'facealpha',fillboxalpha,'edgecolor','none');
    line([fishpupil,fishpupil],[ylim2(1),ylim2(2)],'linewidth',linewidthDef,'color','r','linestyle',':')
    line([tetrapodpupil,tetrapodpupil],[ylim2(1),ylim2(2)],'linewidth',linewidthDef,'color','b','linestyle',':')
    
    subplot(2,2,3)
    plot(pupilValuesAir*10^3,visualVolume,'linewidth',linewidthDef);
    xlabel('pupil diameter (mm)'); ylabel('visual volume (m^3)');
    xlim([0.001*10^3 0.025*10^3]); ylim3=get(gca,'ylim'); 
    hold on
    fillboxTF = patch([pupil_TF(1) pupil_TF(1) pupil_TF(2) pupil_TF(2)], ...
    [ylim3(1) ylim3(2) ylim3(2) ylim3(1)],[1 0 0]);
    set(fillboxTF,'facealpha',fillboxalpha,'edgecolor','none');
    fillboxST = patch([pupil_ST(1) pupil_ST(1) pupil_ST(2) pupil_ST(2)], ...
        [ylim3(1) ylim3(2) ylim3(2) ylim3(1)],[0 0 1]);
    set(fillboxST,'facealpha',fillboxalpha,'edgecolor','none');
    line([fishpupil,fishpupil],[ylim3(1),ylim3(2)],'linewidth',linewidthDef,'color','r','linestyle',':')
    line([tetrapodpupil,tetrapodpupil],[ylim3(1),ylim3(2)],'linewidth',linewidthDef,'color','b','linestyle',':')
    
    subplot(2,2,4)
    plot(pupilValuesAir*10^3,dVdA,'linewidth',linewidthDef);
    xlabel('pupil diameter (mm)'); ylabel('dV/dA (m^3/mm)');
    xlim([0.001*10^3 0.025*10^3]); ylim4=get(gca,'ylim');
    hold on
    fillboxTF = patch([pupil_TF(1) pupil_TF(1) pupil_TF(2) pupil_TF(2)], ...
    [ylim4(1) ylim4(2) ylim4(2) ylim4(1)],[1 0 0]);
    set(fillboxTF,'facealpha',fillboxalpha,'edgecolor','none');
    fillboxST = patch([pupil_ST(1) pupil_ST(1) pupil_ST(2) pupil_ST(2)], ...
        [ylim4(1) ylim4(2) ylim4(2) ylim4(1)],[0 0 1]);
    set(fillboxST,'facealpha',fillboxalpha,'edgecolor','none');
    line([fishpupil,fishpupil],[ylim4(1),ylim4(2)],'linewidth',linewidthDef,'color','r','linestyle',':')
    line([tetrapodpupil,tetrapodpupil],[ylim4(1),ylim4(2)],'linewidth',linewidthDef,'color','b','linestyle',':')
    
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
    xlim([0.001*10^3 0.025*10^3]); ylim1=get(gca,'ylim'); 
    fillboxTF = patch([pupil_TF(1) pupil_TF(1) pupil_TF(2) pupil_TF(2)], ...
    [ylim1(1) ylim1(2) ylim1(2) ylim1(1)],[1 0 0]);
    set(fillboxTF,'facealpha',fillboxalpha,'edgecolor','none');
    fillboxST = patch([pupil_ST(1) pupil_ST(1) pupil_ST(2) pupil_ST(2)], ...
        [ylim1(1) ylim1(2) ylim1(2) ylim1(1)],[0 0 1]);
    set(fillboxST,'facealpha',fillboxalpha,'edgecolor','none');
    line([fishpupil,fishpupil],[ylim1(1),ylim1(2)],'linewidth',linewidthDef,'color','r','linestyle',':')
    line([tetrapodpupil,tetrapodpupil],[ylim1(1),ylim1(2)],'linewidth',linewidthDef,'color','b','linestyle',':')
    
    subplot(2,2,2)
    %plot(pupilValues*1e3,drdA_Coastal,'linewidth',linewidthDef);
    %hold on;
    plot(pupilValues*1e3,drdA_River,'linewidth',linewidthDef);
    xlabel('pupil diameter (mm)'); ylabel('dr/dA (m/mm)');
    xlim([0.001*10^3 0.025*10^3]); ylim2=get(gca,'ylim'); 
    fillboxTF = patch([pupil_TF(1) pupil_TF(1) pupil_TF(2) pupil_TF(2)], ...
    [ylim2(1) ylim2(2) ylim2(2) ylim2(1)],[1 0 0]);
    set(fillboxTF,'facealpha',fillboxalpha,'edgecolor','none');
    fillboxST = patch([pupil_ST(1) pupil_ST(1) pupil_ST(2) pupil_ST(2)], ...
        [ylim2(1) ylim2(2) ylim2(2) ylim2(1)],[0 0 1]);
    set(fillboxST,'facealpha',fillboxalpha,'edgecolor','none');
    line([fishpupil,fishpupil],[ylim2(1),ylim2(2)],'linewidth',linewidthDef,'color','r','linestyle',':')
    line([tetrapodpupil,tetrapodpupil],[ylim2(1),ylim2(2)],'linewidth',linewidthDef,'color','b','linestyle',':')
    
    subplot(2,2,3)
    %plot(pupilValues*1e3,visualVolume_Coastal,'linewidth',linewidthDef);
    %hold on;
    plot(pupilValues*1e3,visualVolume_River,'linewidth',linewidthDef);
    xlabel('pupil diameter (mm)'); ylabel('visual volume (m^3)');
    xlim([0.001*10^3 0.025*10^3]); ylim3=get(gca,'ylim'); 
    fillboxTF = patch([pupil_TF(1) pupil_TF(1) pupil_TF(2) pupil_TF(2)], ...
    [ylim3(1) ylim3(2) ylim3(2) ylim3(1)],[1 0 0]);
    set(fillboxTF,'facealpha',fillboxalpha,'edgecolor','none');
    fillboxST = patch([pupil_ST(1) pupil_ST(1) pupil_ST(2) pupil_ST(2)], ...
        [ylim3(1) ylim3(2) ylim3(2) ylim3(1)],[0 0 1]);
    set(fillboxST,'facealpha',fillboxalpha,'edgecolor','none');
    line([fishpupil,fishpupil],[ylim3(1),ylim3(2)],'linewidth',linewidthDef,'color','r','linestyle',':')
    line([tetrapodpupil,tetrapodpupil],[ylim3(1),ylim3(2)],'linewidth',linewidthDef,'color','b','linestyle',':')
    
    subplot(2,2,4)
    %plot(pupilValues*1e3,dVdA_Coastal,'linewidth',linewidthDef);
    %hold on;
    plot(pupilValues*1e3,dVdA_River,'linewidth',linewidthDef);
    xlabel('pupil diameter (mm)'); ylabel('dV/dA (m^3/mm)');
    xlim([0.001*10^3 0.025*10^3]); ylim4=get(gca,'ylim');
    fillboxTF = patch([pupil_TF(1) pupil_TF(1) pupil_TF(2) pupil_TF(2)], ...
    [ylim4(1) ylim4(2) ylim4(2) ylim4(1)],[1 0 0]);
    set(fillboxTF,'facealpha',fillboxalpha,'edgecolor','none');
    fillboxST = patch([pupil_ST(1) pupil_ST(1) pupil_ST(2) pupil_ST(2)], ...
        [ylim4(1) ylim4(2) ylim4(2) ylim4(1)],[0 0 1]);
    set(fillboxST,'facealpha',fillboxalpha,'edgecolor','none');
    line([fishpupil,fishpupil],[ylim4(1),ylim4(2)],'linewidth',linewidthDef,'color','r','linestyle',':')
    line([tetrapodpupil,tetrapodpupil],[ylim4(1),ylim4(2)],'linewidth',linewidthDef,'color','b','linestyle',':')
    
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
    xlim([0.001*10^3 0.025*10^3]); ylim1=get(gca,'ylim'); 
    fillboxTF = patch([pupil_TF(1) pupil_TF(1) pupil_TF(2) pupil_TF(2)], ...
    [ylim1(1) ylim1(2) ylim1(2) ylim1(1)],[1 0 0]);
    set(fillboxTF,'facealpha',fillboxalpha,'edgecolor','none');
    fillboxST = patch([pupil_ST(1) pupil_ST(1) pupil_ST(2) pupil_ST(2)], ...
        [ylim1(1) ylim1(2) ylim1(2) ylim1(1)],[0 0 1]);
    set(fillboxST,'facealpha',fillboxalpha,'edgecolor','none');
    line([fishpupil,fishpupil],[ylim1(1),ylim1(2)],'linewidth',linewidthDef,'color','r','linestyle',':')
    line([tetrapodpupil,tetrapodpupil],[ylim1(1),ylim1(2)],'linewidth',linewidthDef,'color','b','linestyle',':')
    
    subplot(2,2,2)
    plot(pupilValuesAir*10^3,drdA,'linewidth',linewidthDef);
    hold on;
    %plot(pupilValues*1e3,drdA_Coastal,'linewidth',linewidthDef);
    plot(pupilValues*1e3,drdA_River,'linewidth',linewidthDef);
    xlabel('pupil diameter (mm)'); ylabel('dr/dA (m/mm)');
    xlim([0.001*10^3 0.025*10^3]); ylim2=get(gca,'ylim'); 
    fillboxTF = patch([pupil_TF(1) pupil_TF(1) pupil_TF(2) pupil_TF(2)], ...
    [ylim2(1) ylim2(2) ylim2(2) ylim2(1)],[1 0 0]);
    set(fillboxTF,'facealpha',fillboxalpha,'edgecolor','none');
    fillboxST = patch([pupil_ST(1) pupil_ST(1) pupil_ST(2) pupil_ST(2)], ...
        [ylim2(1) ylim2(2) ylim2(2) ylim2(1)],[0 0 1]);
    set(fillboxST,'facealpha',fillboxalpha,'edgecolor','none');
    line([fishpupil,fishpupil],[ylim2(1),ylim2(2)],'linewidth',linewidthDef,'color','r','linestyle',':')
    line([tetrapodpupil,tetrapodpupil],[ylim2(1),ylim2(2)],'linewidth',linewidthDef,'color','b','linestyle',':')
    
    subplot(2,2,3)
    plot(pupilValuesAir*10^3,visualVolume,'linewidth',linewidthDef);
    hold on;
    %plot(pupilValues*1e3,visualVolume_Coastal,'linewidth',linewidthDef);
    plot(pupilValues*1e3,visualVolume_River,'linewidth',linewidthDef);
    xlabel('pupil diameter (mm)'); ylabel('visual volume (m^3)');
    xlim([0.001*10^3 0.025*10^3]); ylim3=get(gca,'ylim'); 
    fillboxTF = patch([pupil_TF(1) pupil_TF(1) pupil_TF(2) pupil_TF(2)], ...
    [ylim3(1) ylim3(2) ylim3(2) ylim3(1)],[1 0 0]);
    set(fillboxTF,'facealpha',fillboxalpha,'edgecolor','none');
    fillboxST = patch([pupil_ST(1) pupil_ST(1) pupil_ST(2) pupil_ST(2)], ...
        [ylim3(1) ylim3(2) ylim3(2) ylim3(1)],[0 0 1]);
    set(fillboxST,'facealpha',fillboxalpha,'edgecolor','none');
    line([fishpupil,fishpupil],[ylim3(1),ylim3(2)],'linewidth',linewidthDef,'color','r','linestyle',':')
    line([tetrapodpupil,tetrapodpupil],[ylim3(1),ylim3(2)],'linewidth',linewidthDef,'color','b','linestyle',':')
    
    subplot(2,2,4)
    plot(pupilValuesAir*10^3,dVdA,'linewidth',linewidthDef);
    hold on;
    %plot(pupilValues*1e3,dVdA_Coastal,'linewidth',linewidthDef);
    plot(pupilValues*1e3,dVdA_River,'linewidth',linewidthDef);
    xlabel('pupil diameter (mm)'); ylabel('dV/dA (m^3/mm)');
    xlim([0.001*10^3 0.025*10^3]); ylim4=get(gca,'ylim');
    fillboxTF = patch([pupil_TF(1) pupil_TF(1) pupil_TF(2) pupil_TF(2)], ...
    [ylim4(1) ylim4(2) ylim4(2) ylim4(1)],[1 0 0]);
    set(fillboxTF,'facealpha',fillboxalpha,'edgecolor','none');
    fillboxST = patch([pupil_ST(1) pupil_ST(1) pupil_ST(2) pupil_ST(2)], ...
        [ylim4(1) ylim4(2) ylim4(2) ylim4(1)],[0 0 1]);
    set(fillboxST,'facealpha',fillboxalpha,'edgecolor','none');
    line([fishpupil,fishpupil],[ylim4(1),ylim4(2)],'linewidth',linewidthDef,'color','r','linestyle',':')
    line([tetrapodpupil,tetrapodpupil],[ylim4(1),ylim4(2)],'linewidth',linewidthDef,'color','b','linestyle',':')
    
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
    xlim([0.001*10^3 0.025*10^3]); ylim1=get(gca,'ylim'); 
    fillboxTF = patch([pupil_TF(1) pupil_TF(1) pupil_TF(2) pupil_TF(2)], ...
    [ylim1(1) ylim1(2) ylim1(2) ylim1(1)],[1 0 0]);
    set(fillboxTF,'facealpha',fillboxalpha,'edgecolor','none');
    fillboxST = patch([pupil_ST(1) pupil_ST(1) pupil_ST(2) pupil_ST(2)], ...
        [ylim1(1) ylim1(2) ylim1(2) ylim1(1)],[0 0 1]);
    set(fillboxST,'facealpha',fillboxalpha,'edgecolor','none');
    line([fishpupil,fishpupil],[ylim1(1),ylim1(2)],'linewidth',linewidthDef,'color','r','linestyle',':')
    line([tetrapodpupil,tetrapodpupil],[ylim1(1),ylim1(2)],'linewidth',linewidthDef,'color','b','linestyle',':')
    
    subplot(2,2,2)
    semilogy(pupilValuesAir*10^3,drdA,'linewidth',linewidthDef);
    hold on;
    %semilogy(pupilValues*1e3,drdA_Coastal,'linewidth',linewidthDef);
    semilogy(pupilValues*1e3,drdA_River,'linewidth',linewidthDef);
    xlabel('pupil diameter (mm)'); ylabel('dr/dA (m/mm)');
    xlim([0.001*10^3 0.025*10^3]); ylim2=get(gca,'ylim'); 
    fillboxTF = patch([pupil_TF(1) pupil_TF(1) pupil_TF(2) pupil_TF(2)], ...
    [ylim2(1) ylim2(2) ylim2(2) ylim2(1)],[1 0 0]);
    set(fillboxTF,'facealpha',fillboxalpha,'edgecolor','none');
    fillboxST = patch([pupil_ST(1) pupil_ST(1) pupil_ST(2) pupil_ST(2)], ...
        [ylim2(1) ylim2(2) ylim2(2) ylim2(1)],[0 0 1]);
    set(fillboxST,'facealpha',fillboxalpha,'edgecolor','none');
    line([fishpupil,fishpupil],[ylim2(1),ylim2(2)],'linewidth',linewidthDef,'color','r','linestyle',':')
    line([tetrapodpupil,tetrapodpupil],[ylim2(1),ylim2(2)],'linewidth',linewidthDef,'color','b','linestyle',':')
    
    subplot(2,2,3)
    semilogy(pupilValuesAir*10^3,visualVolume,'linewidth',linewidthDef);
    hold on;
    %semilogy(pupilValues*1e3,visualVolume_Coastal,'linewidth',linewidthDef);
    semilogy(pupilValues*1e3,visualVolume_River,'linewidth',linewidthDef);
    xlabel('pupil diameter (mm)'); ylabel('visual volume (m^3)');
    xlim([0.001*10^3 0.025*10^3]); ylim3=get(gca,'ylim'); 
    fillboxTF = patch([pupil_TF(1) pupil_TF(1) pupil_TF(2) pupil_TF(2)], ...
    [ylim3(1) ylim3(2) ylim3(2) ylim3(1)],[1 0 0]);
    set(fillboxTF,'facealpha',fillboxalpha,'edgecolor','none');
    fillboxST = patch([pupil_ST(1) pupil_ST(1) pupil_ST(2) pupil_ST(2)], ...
        [ylim3(1) ylim3(2) ylim3(2) ylim3(1)],[0 0 1]);
    set(fillboxST,'facealpha',fillboxalpha,'edgecolor','none');
    line([fishpupil,fishpupil],[ylim3(1),ylim3(2)],'linewidth',linewidthDef,'color','r','linestyle',':')
    line([tetrapodpupil,tetrapodpupil],[ylim3(1),ylim3(2)],'linewidth',linewidthDef,'color','b','linestyle',':')
    
    subplot(2,2,4)
    semilogy(pupilValuesAir*10^3,dVdA,'linewidth',linewidthDef);
    hold on;
    %semilogy(pupilValues*1e3,dVdA_Coastal,'linewidth',linewidthDef);
    semilogy(pupilValues*1e3,dVdA_River,'linewidth',linewidthDef);
    xlabel('pupil diameter (mm)'); ylabel('dV/dA (m^3/mm)');
    xlim([0.001*10^3 0.025*10^3]); ylim4=get(gca,'ylim');
    fillboxTF = patch([pupil_TF(1) pupil_TF(1) pupil_TF(2) pupil_TF(2)], ...
    [ylim4(1) ylim4(2) ylim4(2) ylim4(1)],[1 0 0]);
    set(fillboxTF,'facealpha',fillboxalpha,'edgecolor','none');
    fillboxST = patch([pupil_ST(1) pupil_ST(1) pupil_ST(2) pupil_ST(2)], ...
        [ylim4(1) ylim4(2) ylim4(2) ylim4(1)],[0 0 1]);
    set(fillboxST,'facealpha',fillboxalpha,'edgecolor','none');
    line([fishpupil,fishpupil],[ylim4(1),ylim4(2)],'linewidth',linewidthDef,'color','r','linestyle',':')
    line([tetrapodpupil,tetrapodpupil],[ylim4(1),ylim4(2)],'linewidth',linewidthDef,'color','b','linestyle',':')
    
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
    

    fprintf('fish pupil and daylight intersection %f \n',interp1q(pupilValuesAir,visualRangeDaylight,fishpupil*10^-3));
    fprintf('fish pupil and moonlight intersection %f \n',interp1q(pupilValuesAir,visualRangeMoonlight,fishpupil*10^-3));
    fprintf('fish pupil and starlight intersection %f \n',interp1q(pupilValuesAir,visualRangeStarlight,fishpupil*10^-3));
    fprintf('fish pupil and river up intersection %f \n',interp1q(pupilValuesAir,visualRange_River(:,1),fishpupil*10^-3));
    fprintf('fish pupil and river hor intersection %f \n',interp1q(pupilValuesAir,visualRange_River(:,2),fishpupil*10^-3));
    
    fprintf('tetrapod pupil and daylight intersection %f \n',interp1q(pupilValuesAir,visualRangeDaylight,tetrapodpupil*10^-3));
    fprintf('tetrapod pupil and moonlight intersection %f \n',interp1q(pupilValuesAir,visualRangeMoonlight,tetrapodpupil*10^-3));
    fprintf('tetrapod pupil and starlight intersection %f \n',interp1q(pupilValuesAir,visualRangeStarlight,tetrapodpupil*10^-3));
    fprintf('tetrapod pupil and river up intersection %f \n',interp1q(pupilValuesAir,visualRange_River(:,1),tetrapodpupil*10^-3));
    fprintf('tetrapod pupil and river hor intersection %f \n',interp1q(pupilValuesAir,visualRange_River(:,2),tetrapodpupil*10^-3));
    
    fprintf('TF Minus and daylight intersection %f\n',interp1q(pupilValuesAir,visualRangeDaylight,pupil_TF(1)*10^-3));
    fprintf('TF Minus and moonlight intersection %f\n',interp1q(pupilValuesAir,visualRangeMoonlight,pupil_TF(1)*10^-3));
    fprintf('TF Minus and starlight intersection %f\n',interp1q(pupilValuesAir,visualRangeStarlight,pupil_TF(1)*10^-3));
    fprintf('TF Minus and river up intersection %f\n',interp1q(pupilValuesAir,visualRange_River(:,1),pupil_TF(1)*10^-3));
    fprintf('TF Minus and river hor intersection %f\n',interp1q(pupilValuesAir,visualRange_River(:,2),pupil_TF(1)*10^-3));
    
    fprintf('TF Plus and daylight intersection %f\n',interp1q(pupilValuesAir,visualRangeDaylight,pupil_TF(2)*10^-3));
    fprintf('TF Plus and moonlight intersection %f\n',interp1q(pupilValuesAir,visualRangeMoonlight,pupil_TF(2)*10^-3));
    fprintf('TF Plus and starlight intersection %f\n',interp1q(pupilValuesAir,visualRangeStarlight,pupil_TF(2)*10^-3));
    fprintf('TF Plus and river up intersection %f\n',interp1q(pupilValuesAir,visualRange_River(:,1),pupil_TF(2)*10^-3));
    fprintf('TF Plus and river hor intersection %f\n',interp1q(pupilValuesAir,visualRange_River(:,2),pupil_TF(2)*10^-3));
    
     fprintf('ST Minus and daylight intersection %f\n',interp1q(pupilValuesAir,visualRangeDaylight,pupil_ST(1)*10^-3));
    fprintf('ST Minus and moonlight intersection %f\n',interp1q(pupilValuesAir,visualRangeMoonlight,pupil_ST(1)*10^-3));
    fprintf('ST Minus and starlight intersection %f\n',interp1q(pupilValuesAir,visualRangeStarlight,pupil_ST(1)*10^-3));
    fprintf('ST Minus and river up intersection %f\n',interp1q(pupilValuesAir,visualRange_River(:,1),pupil_ST(1)*10^-3));
    fprintf('ST Minus and river hor intersection %f\n',interp1q(pupilValuesAir,visualRange_River(:,2),pupil_ST(1)*10^-3));
    
    fprintf('ST Plus and daylight intersection %f\n',interp1q(pupilValuesAir,visualRangeDaylight,pupil_ST(2)*10^-3));
    fprintf('ST Plus and moonlight intersection %f\n',interp1q(pupilValuesAir,visualRangeMoonlight,pupil_ST(2)*10^-3));
    fprintf('ST Plus and starlight intersection %f\n',interp1q(pupilValuesAir,visualRangeStarlight,pupil_ST(2)*10^-3));
    fprintf('ST Plus and river up intersection %f\n',interp1q(pupilValuesAir,visualRange_River(:,1),pupil_ST(2)*10^-3));
    fprintf('ST Plus and river hor intersection %f\n',interp1q(pupilValuesAir,visualRange_River(:,2),pupil_ST(2)*10^-3));
    
    
    