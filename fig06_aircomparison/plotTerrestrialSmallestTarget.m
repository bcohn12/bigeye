function plotTerrestrialSmallestTarget
    close all
    
    load terrestrialSmallestTarget.mat

    fillboxalpha=0.07; % transparency of fillbox to show +/- std of pupil size;
    load ../fig02_orbitsize/OM_TF_ST.mat
    pupil_TF = [mean(OM_TF)-std(OM_TF) mean(OM_TF)+std(OM_TF)].*0.53;
    pupil_ST = [mean(OM_ST)-std(OM_ST) mean(OM_ST)+std(OM_ST)].*0.53;

    fishpupil=mean(OM_TF)*.53;
    tetrapodpupil=mean(OM_ST)*.53;

    linewidthDef=2;

    figure(); clf()
    
    ax3=subplot(3,1,1);
    plot(pupilValues*10^3,starlightTargetSize,'linewidth',linewidthDef);
    xlabel('pupil diameter (mm)'); ylabel('starlight target size (m)');
    hold on;
    ylim1=get(gca,'ylim'); ylim1(1)=0;
    fillboxTF = patch([pupil_TF(1) pupil_TF(1) pupil_TF(2) pupil_TF(2)], ...
    [ylim1(1) ylim1(2) ylim1(2) ylim1(1)],[1 0 0]);
    set(fillboxTF,'facealpha',fillboxalpha,'edgecolor','none');
    fillboxST = patch([pupil_ST(1) pupil_ST(1) pupil_ST(2) pupil_ST(2)], ...
        [ylim1(1) ylim1(2) ylim1(2) ylim1(1)],[0 0 1]);
    set(fillboxST,'facealpha',fillboxalpha,'edgecolor','none');
    
    ax2=subplot(3,1,2);
    plot(pupilValues*10^3,moonlightTargetSize,'linewidth',linewidthDef);
    xlabel('pupil diameter (mm)'); ylabel('moonlight target size (m)');
    hold on;
    ylim1=get(gca,'ylim'); ylim1(1)=0;
    fillboxTF = patch([pupil_TF(1) pupil_TF(1) pupil_TF(2) pupil_TF(2)], ...
    [ylim1(1) ylim1(2) ylim1(2) ylim1(1)],[1 0 0]);
    set(fillboxTF,'facealpha',fillboxalpha,'edgecolor','none');
    fillboxST = patch([pupil_ST(1) pupil_ST(1) pupil_ST(2) pupil_ST(2)], ...
        [ylim1(1) ylim1(2) ylim1(2) ylim1(1)],[0 0 1]);
    set(fillboxST,'facealpha',fillboxalpha,'edgecolor','none');
    
    ax1=subplot(3,1,3);
    %linkaxes([ax1,ax2,ax3],'xy');
    plot(pupilValues*10^3,daylightTargetSize,'linewidth',linewidthDef);
    xlabel('pupil diameter (mm)'); ylabel('daylight target size (m)');
    hold on;
    ylim1=get(gca,'ylim'); ylim([ylim1(1) ylim1(2)]);
    fillboxTF = patch([pupil_TF(1) pupil_TF(1) pupil_TF(2) pupil_TF(2)], ...
    [ylim1(1) ylim1(2) ylim1(2) ylim1(1)],[1 0 0]);
    set(fillboxTF,'facealpha',fillboxalpha,'edgecolor','none');
    fillboxST = patch([pupil_ST(1) pupil_ST(1) pupil_ST(2) pupil_ST(2)], ...
        [ylim1(1) ylim1(2) ylim1(2) ylim1(1)],[0 0 1]);
    set(fillboxST,'facealpha',fillboxalpha,'edgecolor','none');
    
    key={'5m','20m','80m'};
    columnlegend(3,key,'location','south','fontsize',8,'Box','off');
    

    
    
    
