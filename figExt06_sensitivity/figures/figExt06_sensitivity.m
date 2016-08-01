function figExt06_sensitivity
    close all;
    run ParametersSensitivity
    load('ParametersSensitivity.mat')
    
    [e,em]=fileExists;  
    while(~all(e))
        notFound=find(e==0);
        warning('Not all *.mat files required are found some are going to be re-run');
        pause(1)
        for i=1:length(notFound)
            fprintf('running %s\n',em{notFound(i)});
            run(em{notFound(i)});
        end
        [e,em]=fileExists;
    end
        
    h=warndlg({'All of the code takes about 1-2hrs to run'},'Warning!');
    waitfor(h);
    choice=questdlg({'All the required *.mat files found!',...
        'Re-run the code?'},'code re-run','yes','no','no');
    if strcmp(choice,'yes')
        for i=1:length(em)
            fprintf('running %s\n',em{i});
            run(em{i})
        end
    end
    
    load('Aquatic_visRangeSensitivity.mat');
    load('meteoAquatic_All.mat');
    
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
    
function [e,em]=fileExists
    e2={exist('Aquatic_visRangeSensitivity.mat','file')==2, 'Aquatic_visRangeSensitivity.m'};
    e1={exist('meteoAquatic_All.mat','file')==2, 'Aquatic_firingThresh.m'};
    e=[e1{1},e2{1}];
    em={e1{2},e2{2}};