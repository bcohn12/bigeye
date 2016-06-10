function plotTerrestrialRange
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
    pupilValues=linspace(minpupil,maxpupil,25);
    
    fillboxalpha=0.07; % transparency of fillbox to show +/- std of pupil size;
    load ../fig02_orbitsize/OM_TF_ST.mat
    pupil_TF = [mean(OM_TF)-std(OM_TF) mean(OM_TF)+std(OM_TF)].*0.53;
    pupil_ST = [mean(OM_ST)-std(OM_ST) mean(OM_ST)+std(OM_ST)].*0.53;

    fishpupil=mean(OM_TF)*.53;
    tetrapodpupil=mean(OM_ST)*.53;

    linewidthDef=2;
    
    visualRange=[visualRangeDaylight, visualRangeMoonlight, visualRangeStarlight];
    drdA=[drdADaylight;drdAMoonlight;drdAStarlight];
    visualVolume=[visualVolumeDaylight;visualVolumeMoonlight;visualVolumeStarlight];
    dVdA=[dVdADaylight;dVdAMoonlight;dVdAStarlight];
    
    h1=figure(); clf;
    plot(pupilValues*10^3, visualRange,'linewidth',linewidthDef);
    xlabel('pupil diameter (mm'); ylabel('visual range (m)');
    ylim1=get(gca,'ylim');
    hold on
    fillboxTF = patch([pupil_TF(1) pupil_TF(1) pupil_TF(2) pupil_TF(2)], ...
    [ylim1(1) ylim1(2) ylim1(2) ylim1(1)],[1 0 0]);
    set(fillboxTF,'facealpha',fillboxalpha,'edgecolor','none');
    fillboxST = patch([pupil_ST(1) pupil_ST(1) pupil_ST(2) pupil_ST(2)], ...
        [ylim1(1) ylim1(2) ylim1(2) ylim1(1)],[0 0 1]);
    set(fillboxST,'facealpha',fillboxalpha,'edgecolor','none');
    
    legend({'Daylight','Moonlight','Starlight'},'location','northoutside',...
        'fontsize',8,'orientation','horizontal');
    legend('boxoff')
    
    h2=figure(); clf;
    plot(pupilValues*10^3,drdA,'linewidth',linewidthDef);
    xlabel('pupil diameter (mm)'); ylabel('dr/dA (m/mm)');
    ylim2=get(gca,'ylim');
    hold on
    fillboxTF = patch([pupil_TF(1) pupil_TF(1) pupil_TF(2) pupil_TF(2)], ...
    [ylim2(1) ylim2(2) ylim2(2) ylim2(1)],[1 0 0]);
    set(fillboxTF,'facealpha',fillboxalpha,'edgecolor','none');
    fillboxST = patch([pupil_ST(1) pupil_ST(1) pupil_ST(2) pupil_ST(2)], ...
        [ylim2(1) ylim2(2) ylim2(2) ylim2(1)],[0 0 1]);
    set(fillboxST,'facealpha',fillboxalpha,'edgecolor','none');
    
    legend({'Daylight','Moonlight','Starlight'},'location','northoutside',...
        'fontsize',8,'orientation','horizontal');
    legend('boxoff')
    
    h3=figure(); clf;
    plot(pupilValues*10^3,visualVolume,'linewidth',linewidthDef);
    xlabel('pupil diameter (mm)'); ylabel('visual volume (m^3)');
    ylim3=get(gca,'ylim');
    hold on
    fillboxTF = patch([pupil_TF(1) pupil_TF(1) pupil_TF(2) pupil_TF(2)], ...
    [ylim3(1) ylim3(2) ylim3(2) ylim3(1)],[1 0 0]);
    set(fillboxTF,'facealpha',fillboxalpha,'edgecolor','none');
    fillboxST = patch([pupil_ST(1) pupil_ST(1) pupil_ST(2) pupil_ST(2)], ...
        [ylim3(1) ylim3(2) ylim3(2) ylim3(1)],[0 0 1]);
    set(fillboxST,'facealpha',fillboxalpha,'edgecolor','none');
    
    legend({'Daylight','Moonlight','Starlight'},'location','northoutside',...
        'fontsize',8,'orientation','horizontal');
    legend('boxoff')
    
    h2=figure(); clf;
    plot(pupilValues*10^3,dVdA,'linewidth',linewidthDef);
    xlabel('pupil diameter (mm)'); ylabel('dV/dA (m^3/mm)');
    ylim4=get(gca,'ylim');
    hold on
    fillboxTF = patch([pupil_TF(1) pupil_TF(1) pupil_TF(2) pupil_TF(2)], ...
    [ylim4(1) ylim4(2) ylim4(2) ylim4(1)],[1 0 0]);
    set(fillboxTF,'facealpha',fillboxalpha,'edgecolor','none');
    fillboxST = patch([pupil_ST(1) pupil_ST(1) pupil_ST(2) pupil_ST(2)], ...
        [ylim4(1) ylim4(2) ylim4(2) ylim4(1)],[0 0 1]);
    set(fillboxST,'facealpha',fillboxalpha,'edgecolor','none');
    
    legend({'Daylight','Moonlight','Starlight'},'location','northoutside',...
        'fontsize',8,'orientation','horizontal');
    legend('boxoff')
    
    
    
    