function plotAquaticSensitivityDaylight
    close all;
    
    if exist('meteoAquatic_All.mat','file')==2
        load('meteoAquatic_All.mat')
    else
        [visualRange_River,pupilValues]=Aquatic_firingThresh;
    end
    if exist('Aquatic_visRangeSensitivity.mat','file')==2
        load('Aquatic_visRangeSensitivity.mat')
    else
        [visualRangeSensitivity,pupilValues]=Aquatic_visRangeSensitivity;
    end
    
    linewidthdef=2;
    figure();
    plot(pupilValues*10^3,visualRangeSensitivity(:,:,1),'linewidth',linewidthdef);
    hold on;
    plot(pupilValues*10^3,visualRange_River(:,1,1),'linewidth',linewidthdef);
    xlabel('pupil diameter (mm)'); ylabel('visual range (m)')

    key={'high turbidity up @8m','clear up @8m','absorption dominated up @8m','scattering dominated up @8m',...
        'baseline up @8m'};

    columnlegend(2,key,'location','north',...
        'fontsize',8)

    figure();
    plot(pupilValues*10^3,visualRangeSensitivity(:,:,2),'linewidth',linewidthdef);
    hold on;
    plot(pupilValues*10^3,visualRange_River(:,1,2),'linewidth',linewidthdef);
    xlabel('pupil diameter (mm)'); ylabel('visual range (m)')

    key={'high turbidity hor @8m','clear hor @8m','absorption dominated hor @8m','scattering dominated hor @8m',...
        'baseline hor @8m'};

    columnlegend(2,key,'location','north',...
        'fontsize',8)