function plotAquaticSmallestTarget
    close all
    run ../figXX_compviz/Parameters.m
    load aqaticSmallestTarget_Coastal
    load aqaticSmallestTarget_River
    
    fillboxalpha=0.07; % transparency of fillbox to show +/- std of pupil size;
    load ../fig02_orbitsize/OM_TF_ST.mat
    pupil_TF = [mean(OM_TF)-std(OM_TF) mean(OM_TF)+std(OM_TF)].*0.53;
    pupil_ST = [mean(OM_ST)-std(OM_ST) mean(OM_ST)+std(OM_ST)].*0.53;

    fishpupil=mean(OM_TF)*.53;
    tetrapodpupil=mean(OM_ST)*.53;

    linewidthDef=2;
    
    figure(); clf();
    ax1=subplot(2,1,1);
    plot(pupilValues*10^3,targetSizeSolns_Coastal(:,:,1),'linewidth',linewidthDef)
    hold on;
    
    xlabel('pupil diameter (mm)'); ylabel('target size looking upwards (m)');
    xlim([0.0025*10^3 maxpupil*10^3]); ylim1=get(gca,'ylim'); ylim1(2)=max(targetSizeSolns_Coastal(:,2,2));
    %ylim([ylim1(1) max(targetSizeSolns_Coastal(:,2,1))]); ylim1=get(gca,'ylim');
    fillboxTF = patch([pupil_TF(1) pupil_TF(1) pupil_TF(2) pupil_TF(2)], ...
    [ylim1(1) ylim1(2) ylim1(2) ylim1(1)],[1 0 0]);
    set(fillboxTF,'facealpha',fillboxalpha,'edgecolor','none');
    fillboxST = patch([pupil_ST(1) pupil_ST(1) pupil_ST(2) pupil_ST(2)], ...
        [ylim1(1) ylim1(2) ylim1(2) ylim1(1)],[0 0 1]);
    set(fillboxST,'facealpha',fillboxalpha,'edgecolor','none');
    
    ax2=subplot(2,1,2);
    linkaxes([ax1 ax2],'xy')
    plot(pupilValues*10^3,targetSizeSolns_Coastal(:,:,2),'linewidth',linewidthDef)
    hold on;  
    xlabel('pupil diameter (mm)'); ylabel('target size horizontal viewing (m)');
    xlim([0.0025*10^3 maxpupil*10^3]); ylim1=get(gca,'ylim'); ylim1(2)=max(targetSizeSolns_Coastal(:,2,2));
    ylim([ylim1(1) ylim1(2)]); ylim1=get(gca,'ylim');
    fillboxTF = patch([pupil_TF(1) pupil_TF(1) pupil_TF(2) pupil_TF(2)], ...
    [ylim1(1) ylim1(2) ylim1(2) ylim1(1)],[1 0 0]);
    set(fillboxTF,'facealpha',fillboxalpha,'edgecolor','none');
    fillboxST = patch([pupil_ST(1) pupil_ST(1) pupil_ST(2) pupil_ST(2)], ...
        [ylim1(1) ylim1(2) ylim1(2) ylim1(1)],[0 0 1]);
    set(fillboxST,'facealpha',fillboxalpha,'edgecolor','none');
    
    key={'1m','2m','4m'};
    columnlegend(3,key,'location','south','fontsize',8,'Box','off');
    
    figure(); clf();
    ax3=subplot(2,1,1);
    plot(pupilValues*10^3,targetSizeSolns_River(:,:,1),'linewidth',linewidthDef)
    hold on;
    
    xlabel('pupil diameter (mm)'); ylabel('target size looking upwards (m)');
    xlim([0.0025*10^3 maxpupil*10^3]); ylim1=get(gca,'ylim'); ylim1(2)=max(targetSizeSolns_River(:,2,2));
    %ylim([ylim1(1) max(targetSizeSolns_Coastal(:,2,1))]); ylim1=get(gca,'ylim');
    fillboxTF = patch([pupil_TF(1) pupil_TF(1) pupil_TF(2) pupil_TF(2)], ...
    [ylim1(1) ylim1(2) ylim1(2) ylim1(1)],[1 0 0]);
    set(fillboxTF,'facealpha',fillboxalpha,'edgecolor','none');
    fillboxST = patch([pupil_ST(1) pupil_ST(1) pupil_ST(2) pupil_ST(2)], ...
        [ylim1(1) ylim1(2) ylim1(2) ylim1(1)],[0 0 1]);
    set(fillboxST,'facealpha',fillboxalpha,'edgecolor','none');
    
    ax4=subplot(2,1,2);
    linkaxes([ax3 ax4],'xy')
    plot(pupilValues*10^3,targetSizeSolns_River(:,:,2),'linewidth',linewidthDef)
    hold on;  
    xlabel('pupil diameter (mm)'); ylabel('target size horizontal viewing (m)');
    xlim([0.0025*10^3 maxpupil*10^3]); ylim1=get(gca,'ylim'); ylim1(2)=max(targetSizeSolns_River(:,2,2));
    ylim([ylim1(1) ylim1(2)]); ylim1=get(gca,'ylim');
    fillboxTF = patch([pupil_TF(1) pupil_TF(1) pupil_TF(2) pupil_TF(2)], ...
    [ylim1(1) ylim1(2) ylim1(2) ylim1(1)],[1 0 0]);
    set(fillboxTF,'facealpha',fillboxalpha,'edgecolor','none');
    fillboxST = patch([pupil_ST(1) pupil_ST(1) pupil_ST(2) pupil_ST(2)], ...
        [ylim1(1) ylim1(2) ylim1(2) ylim1(1)],[0 0 1]);
    set(fillboxST,'facealpha',fillboxalpha,'edgecolor','none');
    
    key={'1m','2m','4m'};
    columnlegend(3,key,'location','south','fontsize',8,'Box','off');
    
    
    