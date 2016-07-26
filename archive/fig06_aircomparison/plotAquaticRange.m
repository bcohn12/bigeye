function plotAquaticRange
    close all
    run ../figXX_compviz/Parameters.m
    load('pupilSizevsRangeConstantDepth_Coastal.mat');
    load('pupilSizevsRangeConstantDepth_River.mat');
    
    fillboxalpha=0.2; % transparency of fillbox to show +/- std of pupil size;
    load ../fig02_orbitsize/OM_TF_ST.mat
    pupil_TF = [mean(OM_TF)-std(OM_TF) mean(OM_TF)+std(OM_TF)].*0.449;
    pupil_ST = [mean(OM_ST)-std(OM_ST) mean(OM_ST)+std(OM_ST)].*0.449;

    fishpupil=mean(OM_TF)*.449;
    tetrapodpupil=mean(OM_ST)*.449;

    linewidthDef=2;
    
    visualRange_Coastal=[visualRange_Coastal(:,1:2,1) visualRange_Coastal(:,1:2,2)];
    drdA_Coastal=[drdA_Coastal(:,1:2,1), drdA_Coastal(:,1:2,2)];
    visualVolume_Coastal=[visualVolume_Coastal(:,1:2,1) visualVolume_Coastal(:,1:2,2)];
    dVdA_Coastal=[dVdA_Coastal(:,1:2,1), dVdA_Coastal(:,1:2,2)];
    key_Coastal={'looking upwards, depth=10m','looking upwards, depth=7m',...        
        'horizontal viewing, depth=10m','horizontal viewing, depth=7m'};
    
    visualRange_River=[visualRange_River(:,1:2,1), visualRange_River(:,1:2,2)];
    drdA_River=[drdA_River(:,1:2,1), drdA_River(:,1:2,2)];
    visualVolume_River=[visualVolume_River(:,1:2,1) visualVolume_River(:,1:2,2)];
    dVdA_River=[dVdA_River(:,1:2,1), dVdA_River(:,1:2,2)];
    key_River={'looking upwards, depth=10m','looking upwards, depth=7m',...        
        'horizontal viewing, depth=10m','horizontal viewing, depth=7m'};

    %% GENERATE PLOTS
    
    h1=figure(); clf; 
    ax11=subplot(2,1,1);
    plot(pupilValues*1e3,visualRange_Coastal,'linewidth',linewidthDef);   
    xlabel('pupil diameter (mm)'); ylabel('visual range coastal water(m)');    
    %columnlegend(2,key_Coastal,'location','Northoutside','fontsize',8);
    ylim1=get(gca,'ylim'); ylim1(1)=0; xlim([0.001*10^3 maxpupil*10^3]);
    
    hold on
    fillboxTF = patch([pupil_TF(1) pupil_TF(1) pupil_TF(2) pupil_TF(2)], ...
    [ylim1(1) ylim1(2) ylim1(2) ylim1(1)],[1 0 0]);
    set(fillboxTF,'facealpha',fillboxalpha,'edgecolor','none');
    fillboxST = patch([pupil_ST(1) pupil_ST(1) pupil_ST(2) pupil_ST(2)], ...
        [ylim1(1) ylim1(2) ylim1(2) ylim1(1)],[0 0 1]);
    set(fillboxST,'facealpha',fillboxalpha,'edgecolor','none');
    
    
    ax12=subplot(2,1,2);
    linkaxes([ax11 ax12],'xy')
    plot(pupilValues*1e3,visualRange_River,'linewidth',linewidthDef);
    xlabel('pupil diameter (mm)'); ylabel('visual range river water (m)');
    columnlegend(2,key_River,'location','south','fontsize',8,'Box','off');
    
    hold on; xlim([0.0025*10^3 maxpupil*10^3]);
    fillboxTF = patch([pupil_TF(1) pupil_TF(1) pupil_TF(2) pupil_TF(2)], ...
    [ylim1(1) ylim1(2) ylim1(2) ylim1(1)],[1 0 0]);
    set(fillboxTF,'facealpha',fillboxalpha,'edgecolor','none');
    fillboxST = patch([pupil_ST(1) pupil_ST(1) pupil_ST(2) pupil_ST(2)], ...
        [ylim1(1) ylim1(2) ylim1(2) ylim1(1)],[0 0 1]);
    set(fillboxST,'facealpha',fillboxalpha,'edgecolor','none');
      
    h2=figure(); clf;
    ax21=subplot(2,1,1);
    plot(pupilValues*1e3,drdA_Coastal,'linewidth',linewidthDef);   
    xlabel('pupil diameter (mm)'); ylabel('dr/dA coastal water(m/mm)');    
    ylim2=get(gca,'ylim'); ylim2(1)=0; xlim([0.0025*10^3 maxpupil*10^3]);
    
    hold on
    fillboxTF = patch([pupil_TF(1) pupil_TF(1) pupil_TF(2) pupil_TF(2)], ...
    [ylim2(1) ylim2(2) ylim2(2) ylim2(1)],[1 0 0]);
    set(fillboxTF,'facealpha',fillboxalpha,'edgecolor','none');
    fillboxST = patch([pupil_ST(1) pupil_ST(1) pupil_ST(2) pupil_ST(2)], ...
        [ylim2(1) ylim2(2) ylim2(2) ylim2(1)],[0 0 1]);
    set(fillboxST,'facealpha',fillboxalpha,'edgecolor','none');
    
    ax22=subplot(2,1,2);
    linkaxes([ax21 ax22],'xy')
    plot(pupilValues*1e3,drdA_River,'linewidth',linewidthDef);
    xlabel('pupil diameter (mm)'); ylabel('dr/dA river water (m/mm)');
    columnlegend(2,key_River,'location','south','fontsize',8,'Box','off');
    
    hold on; xlim([0.0025*10^3 maxpupil*10^3]);
    fillboxTF = patch([pupil_TF(1) pupil_TF(1) pupil_TF(2) pupil_TF(2)], ...
    [ylim2(1) ylim2(2) ylim2(2) ylim2(1)],[1 0 0]);
    set(fillboxTF,'facealpha',fillboxalpha,'edgecolor','none');
    fillboxST = patch([pupil_ST(1) pupil_ST(1) pupil_ST(2) pupil_ST(2)], ...
        [ylim2(1) ylim2(2) ylim2(2) ylim2(1)],[0 0 1]);
    set(fillboxST,'facealpha',fillboxalpha,'edgecolor','none');
    
    h3=figure(); clf;
    ax13=subplot(2,1,1);
    plot(pupilValues*1e3,visualVolume_Coastal,'linewidth',linewidthDef);   
    xlabel('pupil diameter (mm)'); ylabel('visual volume coastal water(m^3)');    
    ylim3=get(gca,'ylim'); ylim3(1)=0; xlim([0.001*10^3 maxpupil*10^3]);
    
    hold on
    fillboxTF = patch([pupil_TF(1) pupil_TF(1) pupil_TF(2) pupil_TF(2)], ...
    [ylim3(1) ylim3(2) ylim3(2) ylim3(1)],[1 0 0]);
    set(fillboxTF,'facealpha',fillboxalpha,'edgecolor','none');
    fillboxST = patch([pupil_ST(1) pupil_ST(1) pupil_ST(2) pupil_ST(2)], ...
        [ylim3(1) ylim3(2) ylim3(2) ylim3(1)],[0 0 1]);
    set(fillboxST,'facealpha',fillboxalpha,'edgecolor','none');
    
    ax23=subplot(2,1,2);
    linkaxes([ax13,ax23],'xy')
    plot(pupilValues*1e3,visualVolume_River,'linewidth',linewidthDef);
    xlabel('pupil diameter (mm)'); ylabel('visual volume river water (m^3)');
    columnlegend(2,key_River,'location','south','fontsize',8,'Box','off');
    
    hold on; xlim([0.001*10^3 maxpupil*10^3]);
    fillboxTF = patch([pupil_TF(1) pupil_TF(1) pupil_TF(2) pupil_TF(2)], ...
    [ylim3(1) ylim3(2) ylim3(2) ylim3(1)],[1 0 0]);
    set(fillboxTF,'facealpha',fillboxalpha,'edgecolor','none');
    fillboxST = patch([pupil_ST(1) pupil_ST(1) pupil_ST(2) pupil_ST(2)], ...
        [ylim3(1) ylim3(2) ylim3(2) ylim3(1)],[0 0 1]);
    set(fillboxST,'facealpha',fillboxalpha,'edgecolor','none');
    
    h4=figure(); clf;
    ax14=subplot(2,1,1);
    plot(pupilValues*1e3,dVdA_Coastal,'linewidth',linewidthDef);   
    xlabel('pupil diameter (mm)'); ylabel('dV/dA coastal water(m^3/mm)');    
    ylim4=get(gca,'ylim'); ylim4(1)=0; xlim([0.0025*10^3 maxpupil*10^3]);
    
    hold on
    fillboxTF = patch([pupil_TF(1) pupil_TF(1) pupil_TF(2) pupil_TF(2)], ...
    [ylim4(1) ylim4(2) ylim4(2) ylim4(1)],[1 0 0]);
    set(fillboxTF,'facealpha',fillboxalpha,'edgecolor','none');
    fillboxST = patch([pupil_ST(1) pupil_ST(1) pupil_ST(2) pupil_ST(2)], ...
        [ylim4(1) ylim4(2) ylim4(2) ylim4(1)],[0 0 1]);
    set(fillboxST,'facealpha',fillboxalpha,'edgecolor','none');
    
    ax24=subplot(2,1,2);
    linkaxes([ax14, ax24],'xy')
    plot(pupilValues*1e3,dVdA_River,'linewidth',linewidthDef);
    xlabel('pupil diameter (mm)'); ylabel('dV/dA river water (m^3/mm)');
    columnlegend(2,key_River,'location','south','fontsize',8,'Box','off');
    
    hold on; xlim([0.0025*10^3 maxpupil*10^3]);
    fillboxTF = patch([pupil_TF(1) pupil_TF(1) pupil_TF(2) pupil_TF(2)], ...
    [ylim4(1) ylim4(2) ylim4(2) ylim4(1)],[1 0 0]);
    set(fillboxTF,'facealpha',fillboxalpha,'edgecolor','none');
    fillboxST = patch([pupil_ST(1) pupil_ST(1) pupil_ST(2) pupil_ST(2)], ...
        [ylim4(1) ylim4(2) ylim4(2) ylim4(1)],[0 0 1]);
    set(fillboxST,'facealpha',fillboxalpha,'edgecolor','none');
    