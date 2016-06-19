function plotTerrestrialSmallestTarget
    close all
    
    run ../figXX_compviz/Parameters.m
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
    plot(pupilValues*10^3,(1e3.*targetSizeSolns(:,:,3)),'linewidth',linewidthDef);
    xlabel('pupil diameter (mm)'); ylabel('log starlight target size (mm)');
    hold on;
    xlim([0.0025*10^3 maxpupil*10^3]); ylim1=get(gca,'ylim'); ylim1(1)=0; 
    %ylim([ylim1(1) max(starlightTargetSize(:,2))]); ylim1=get(gca,'ylim');
    fillboxTF = patch([pupil_TF(1) pupil_TF(1) pupil_TF(2) pupil_TF(2)], ...
    [ylim1(1) ylim1(2) ylim1(2) ylim1(1)],[1 0 0]);
    set(fillboxTF,'facealpha',fillboxalpha,'edgecolor','none');
    fillboxST = patch([pupil_ST(1) pupil_ST(1) pupil_ST(2) pupil_ST(2)], ...
        [ylim1(1) ylim1(2) ylim1(2) ylim1(1)],[0 0 1]);
    set(fillboxST,'facealpha',fillboxalpha,'edgecolor','none');
    key={'2m','10m','20m'};
    columnlegend(3,key,'location','south','fontsize',8,'Box','off');
    
    ax2=subplot(3,1,2);
    plot(pupilValues*10^3,(1e3.*targetSizeSolns(:,:,2)),'linewidth',linewidthDef);
    xlabel('pupil diameter (mm)'); ylabel('log moonlight target size (mm)');
    hold on;
    xlim([0.0025*10^3 maxpupil*10^3]); 
    ylim1=get(gca,'ylim'); ylim1(1)=0;
    %ylim([ylim1(1) max(moonlightTargetSize(:,2))]); ylim1=get(gca,'ylim');
    fillboxTF = patch([pupil_TF(1) pupil_TF(1) pupil_TF(2) pupil_TF(2)], ...
    [ylim1(1) ylim1(2) ylim1(2) ylim1(1)],[1 0 0]);
    set(fillboxTF,'facealpha',fillboxalpha,'edgecolor','none');
    fillboxST = patch([pupil_ST(1) pupil_ST(1) pupil_ST(2) pupil_ST(2)], ...
        [ylim1(1) ylim1(2) ylim1(2) ylim1(1)],[0 0 1]);
    set(fillboxST,'facealpha',fillboxalpha,'edgecolor','none');
    key={'5m','20m','80m'};
    columnlegend(3,key,'location','south','fontsize',8,'Box','off');
    
    ax1=subplot(3,1,3);
    %linkaxes([ax1,ax2,ax3],'xy');
    plot(pupilValues*10^3, (1e3.*targetSizeSolns(:,:,1)),'linewidth',linewidthDef);
    xlabel('pupil diameter (mm)'); ylabel('log daylight target size (mm)');
    hold on; 
    xlim([0.0025*10^3 maxpupil*10^3]);  ylim1=get(gca,'ylim'); 
    %ylim([ylim1(1) max(daylightTargetSize(:,2))]); ylim1=get(gca,'ylim');
    fillboxTF = patch([pupil_TF(1) pupil_TF(1) pupil_TF(2) pupil_TF(2)], ...
    [ylim1(1) ylim1(2) ylim1(2) ylim1(1)],[1 0 0]);
    set(fillboxTF,'facealpha',fillboxalpha,'edgecolor','none');
    fillboxST = patch([pupil_ST(1) pupil_ST(1) pupil_ST(2) pupil_ST(2)], ...
        [ylim1(1) ylim1(2) ylim1(2) ylim1(1)],[0 0 1]);
    set(fillboxST,'facealpha',fillboxalpha,'edgecolor','none');
    key={'50m','250m','750m'};
    columnlegend(3,key,'location','north','fontsize',8,'Box','off');
    
    

    
    
    
