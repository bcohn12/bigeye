function fig03_visualrange
    close all;
    run Parameters.m
    load('Parameters.mat')
    load OM_TF_ST.mat
    pupil_TF = [mean(OM_TF)-std(OM_TF) mean(OM_TF)+std(OM_TF)].*0.449;
    pupil_ST = [mean(OM_ST)-std(OM_ST) mean(OM_ST)+std(OM_ST)].*0.449;
    fishpupil=mean(OM_TF)*.449;
    tetrapodpupil=mean(OM_ST)*.449;
    CONTRASTTHRESH=1;
    
    [e,em]=fileExists;  
    while(~all(e))
        notFound=find(e==0);
        warning('Not all *.mat files required are found some are going to be re-run');
        for i=1:length(notFound)
            fprintf('running %s\n',em{notFound(i)});
            run(em{notFound(i)});
        end
        [e,em]=fileExists;
    end
        
    h=warndlg({'All of the code takes about 4-5hrs to run'},'Warning!');
    waitfor(h);
    choice=questdlg({'All the required *.mat files found!',...
        'Re-run the code?'},'code re-run','yes','no','no');
    if strcmp(choice,'yes')
        for i=1:length(em)
            fprintf('running %s\n',em{i});
            run(em{i})
        end
    end
                   
    [visualRange_River, visualVolume_River, drdA_River, dVdA_River,pupilValues] = Aquatic_calcVolumegetDer(CONTRASTTHRESH);
    [visualRangeDaylight, visualRangeMoonlight, visualRangeStarlight,...
    visualVolumeDaylight, visualVolumeMoonlight, visualVolumeStarlight,...
    drdADaylight,drdAMoonlight,drdAStarlight,...
    dVdADaylight, dVdAMoonlight, dVdAStarlight,pupilValuesAir]=Aerial_calcVolumegetDerivatives(CONTRASTTHRESH);
    
    fillboxalpha=0.18; % transparency of fillbox to show +/- std of pupil size;
    linewidthDef=2;
        
    visualRange=[visualRangeDaylight, visualRangeMoonlight, smooth(visualRangeStarlight)];
    drdA=[smooth(drdADaylight)';smooth(drdAMoonlight)';smooth(drdAStarlight)'];
    visualVolume=[visualVolumeDaylight;visualVolumeMoonlight;visualVolumeStarlight];
    dVdA=[smooth(dVdADaylight,7)';smooth(dVdAMoonlight,7)';smooth(dVdAStarlight,7)'];
    visualRange_River=[visualRange_River(:,1,1), visualRange_River(:,1,2),...
        visualRange_River(:,2,1),...
        visualRange_River(:,3,1)];
    drdA_River=[smooth(drdA_River(:,1,1)), smooth(drdA_River(:,1,2)),...
        smooth(drdA_River(:,2,1)),...
        smooth(drdA_River(:,3,1))];
    visualVolume_River=[visualVolume_River(:,1,1) visualVolume_River(:,1,2),...
        visualVolume_River(:,2,1),...
        visualRange_River(:,3,1)];
    dVdA_River=[smooth(dVdA_River(:,1,1),7), smooth(dVdA_River(:,1,2),7),...
        smooth(dVdA_River(:,2,1),7),...
        smooth(dVdA_River(:,2,1),7)];   

%% AQUATIC PLOTS
    figure(); clf();
    subplot(2,2,1);
    plot(pupilValues*1e3,visualRange_River(:,1),'linewidth',linewidthDef);
    hold on;
    plot(pupilValues*1e3,visualRange_River(:,2),':','color',[0 0.4470 0.7410],'linewidth',linewidthDef);
    plot(pupilValues*1e3,visualRange_River(:,3),'color',[0.8500    0.3250    0.0980],'linewidth',linewidthDef);
    plot(pupilValues*1e3,visualRange_River(:,4),'color',[0.9290    0.6940    0.1250],'linewidth',linewidthDef);
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
    plot(pupilValues*1e3,drdA_River(:,1),'linewidth',linewidthDef);
    hold on;
    plot(pupilValues*1e3,drdA_River(:,2),':','color',[0 0.4470 0.7410],'linewidth',linewidthDef);
    plot(pupilValues*1e3,drdA_River(:,3),'color',[0.8500    0.3250    0.0980],'linewidth',linewidthDef);
    plot(pupilValues*1e3,drdA_River(:,4),'color',[0.9290    0.6940    0.1250],'linewidth',linewidthDef);
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
    plot(pupilValues*1e3,visualVolume_River(:,1),'linewidth',linewidthDef);
    hold on;
    plot(pupilValues*1e3,visualVolume_River(:,2),':','color',[0 0.4470 0.7410],'linewidth',linewidthDef);
    plot(pupilValues*1e3,visualVolume_River(:,3),'color',[0.8500    0.3250    0.0980],'linewidth',linewidthDef);
    plot(pupilValues*1e3,visualVolume_River(:,4),'color',[0.9290    0.6940    0.1250],'linewidth',linewidthDef);
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
    plot(pupilValues*1e3,dVdA_River(:,1),'linewidth',linewidthDef);
    hold on;
    plot(pupilValues*1e3,dVdA_River(:,2),':','color',[0 0.4470 0.7410],'linewidth',linewidthDef);
    plot(pupilValues*1e3,dVdA_River(:,3),'color',[0.8500    0.3250    0.0980],'linewidth',linewidthDef);
    plot(pupilValues*1e3,dVdA_River(:,4),'color',[0.9290    0.6940    0.1250],'linewidth',linewidthDef);
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
    
        key={'Sun River up @8m','Sun River hor @8m',...
            'Moon River up @8m',...
            'Stars River up @8m'};
    
    columnlegend(2,key,'location','north',...
        'fontsize',8);
%%  AERIAL AQUATIC
    figure(); clf();
    subplot(2,2,1);
    plot(pupilValuesAir*10^3, visualRange,'linewidth',linewidthDef);
    hold on;
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

    key={'Daylight','Moonlight','Starlight',...
        'Aquatic'};  
    columnlegend(4,key,'location','north',...
        'fontsize',8);

%% CALCULATE INTERSECTION AND GAIN
 
%       DHRD_1=(interp1q(pupilValuesAir,visualRangeDaylight,fishpupil*1e-3))/...
%           (interp1q(pupilValues,visualRange_River(:,2),fishpupil*1e-3))
%       DHRD_2=(interp1q(pupilValuesAir,visualRangeDaylight,tetrapodpupil*1e-3))/...
%           (interp1q(pupilValues,visualRange_River(:,2),fishpupil*1e-3))
%       DURD_3=(interp1q(pupilValuesAir,visualRangeDaylight,fishpupil*1e-3))/...
%           (interp1q(pupilValues,visualRange_River(:,1),fishpupil*1e-3))
%       DURD_4=(interp1q(pupilValuesAir,visualRangeDaylight,tetrapodpupil*1e-3))/...
%           (interp1q(pupilValues,visualRange_River(:,1),fishpupil*1e-3))
%       
%       DURM_5=(interp1q(pupilValuesAir,visualRangeMoonlight,fishpupil*1e-3))/...
%           (interp1q(pupilValues,visualRange_River(:,1),fishpupil*1e-3))
%       DURS_6=(interp1q(pupilValuesAir,visualRangeStarlight,fishpupil*1e-3))/...
%           (interp1q(pupilValues,visualRange_River(:,1),fishpupil*1e-3))
%       DURM_7=(interp1q(pupilValuesAir,visualRangeMoonlight,tetrapodpupil*1e-3))/...
%           (interp1q(pupilValues,visualRange_River(:,1),fishpupil*1e-3))
%       DURS_8=(interp1q(pupilValuesAir,visualRangeStarlight,tetrapodpupil*1e-3))/...
%           (interp1q(pupilValues,visualRange_River(:,1),fishpupil*1e-3))
%       
%       MURM_9=(interp1q(pupilValuesAir,visualRangeMoonlight,fishpupil*1e-3))/...
%            (interp1q(pupilValues,visualRange_River(:,3),fishpupil*1e-3))
%       MURM_10=(interp1q(pupilValuesAir,visualRangeMoonlight,tetrapodpupil*1e-3))/...
%           (interp1q(pupilValues,visualRange_River(:,3),fishpupil*1e-3))
%       
%       SURS_11=(interp1q(pupilValuesAir,visualRangeStarlight,fishpupil*1e-3))/...
%           (interp1q(pupilValues,visualRange_River(:,4),fishpupil*1e-3))
%       SURS_12=(interp1q(pupilValuesAir,visualRangeStarlight,tetrapodpupil*1e-3))/...
%           (interp1q(pupilValues,visualRange_River(:,4),fishpupil*1e-3))

%         dVDdVRU_1=(interp1q(pupilValuesAir,dVdADaylight',fishpupil*1e-3))/...
%             (interp1q(pupilValues',dVdA_River(:,1),fishpupil*1e-3))
%         dVDdVRU_1=(interp1q(pupilValuesAir,dVdADaylight',tetrapodpupil*1e-3))/...
%             (interp1q(pupilValues',dVdA_River(:,1),fishpupil*1e-3))
   
%     fprintf('fish pupil and daylight intersection %f \n',interp1q(pupilValuesAir,visualRangeDaylight,fishpupil*10^-3));
%     fprintf('fish pupil and moonlight intersection %f \n',interp1q(pupilValuesAir,visualRangeMoonlight,fishpupil*10^-3));
%     fprintf('fish pupil and starlight intersection %f \n',interp1q(pupilValuesAir,visualRangeStarlight,fishpupil*10^-3));
%     fprintf('fish pupil and river up intersection %f \n',interp1q(pupilValuesAir,visualRange_River(:,1),fishpupil*10^-3));
%     fprintf('fish pupil and river hor intersection %f \n',interp1q(pupilValuesAir,visualRange_River(:,2),fishpupil*10^-3));
%     
%     
%     fprintf('tetrapod pupil and daylight intersection %f \n',interp1q(pupilValuesAir,visualRangeDaylight,tetrapodpupil*10^-3));
%     fprintf('tetrapod pupil and moonlight intersection %f \n',interp1q(pupilValuesAir,visualRangeMoonlight,tetrapodpupil*10^-3));
%     fprintf('tetrapod pupil and starlight intersection %f \n',interp1q(pupilValuesAir,visualRangeStarlight,tetrapodpupil*10^-3));
%     fprintf('tetrapod pupil and river up intersection %f \n',interp1q(pupilValuesAir,visualRange_River(:,1),tetrapodpupil*10^-3));
%     fprintf('tetrapod pupil and river hor intersection %f \n',interp1q(pupilValuesAir,visualRange_River(:,2),tetrapodpupil*10^-3));
%     
%     fprintf('TF Minus and daylight intersection %f\n',interp1q(pupilValuesAir,visualRangeDaylight,pupil_TF(1)*10^-3));
%     fprintf('TF Minus and moonlight intersection %f\n',interp1q(pupilValuesAir,visualRangeMoonlight,pupil_TF(1)*10^-3));
%     fprintf('TF Minus and starlight intersection %f\n',interp1q(pupilValuesAir,visualRangeStarlight,pupil_TF(1)*10^-3));
%     fprintf('TF Minus and river up intersection %f\n',interp1q(pupilValuesAir,visualRange_River(:,1),pupil_TF(1)*10^-3));
%     fprintf('TF Minus and river hor intersection %f\n',interp1q(pupilValuesAir,visualRange_River(:,2),pupil_TF(1)*10^-3));
%     
%     fprintf('TF Plus and daylight intersection %f\n',interp1q(pupilValuesAir,visualRangeDaylight,pupil_TF(2)*10^-3));
%     fprintf('TF Plus and moonlight intersection %f\n',interp1q(pupilValuesAir,visualRangeMoonlight,pupil_TF(2)*10^-3));
%     fprintf('TF Plus and starlight intersection %f\n',interp1q(pupilValuesAir,visualRangeStarlight,pupil_TF(2)*10^-3));
%     fprintf('TF Plus and river up intersection %f\n',interp1q(pupilValuesAir,visualRange_River(:,1),pupil_TF(2)*10^-3));
%     fprintf('TF Plus and river hor intersection %f\n',interp1q(pupilValuesAir,visualRange_River(:,2),pupil_TF(2)*10^-3));
%     
%      fprintf('ST Minus and daylight intersection %f\n',interp1q(pupilValuesAir,visualRangeDaylight,pupil_ST(1)*10^-3));
%     fprintf('ST Minus and moonlight intersection %f\n',interp1q(pupilValuesAir,visualRangeMoonlight,pupil_ST(1)*10^-3));
%     fprintf('ST Minus and starlight intersection %f\n',interp1q(pupilValuesAir,visualRangeStarlight,pupil_ST(1)*10^-3));
%     fprintf('ST Minus and river up intersection %f\n',interp1q(pupilValuesAir,visualRange_River(:,1),pupil_ST(1)*10^-3));
%     fprintf('ST Minus and river hor intersection %f\n',interp1q(pupilValuesAir,visualRange_River(:,2),pupil_ST(1)*10^-3));
%     
%     fprintf('ST Plus and daylight intersection %f\n',interp1q(pupilValuesAir,visualRangeDaylight,pupil_ST(2)*10^-3));
%     fprintf('ST Plus and moonlight intersection %f\n',interp1q(pupilValuesAir,visualRangeMoonlight,pupil_ST(2)*10^-3));
%     fprintf('ST Plus and starlight intersection %f\n',interp1q(pupilValuesAir,visualRangeStarlight,pupil_ST(2)*10^-3));
%     fprintf('ST Plus and river up intersection %f\n',interp1q(pupilValuesAir,visualRange_River(:,1),pupil_ST(2)*10^-3));
%     fprintf('ST Plus and river hor intersection %f\n',interp1q(pupilValuesAir,visualRange_River(:,2),pupil_ST(2)*10^-3));
%     
    
function [e,em]=fileExists
    e2={exist('visibilityAquatic_All.mat','file')==2, 'Aquatic_contrastLimiting.m'};
    e1={exist('meteoAquatic_All.mat','file')==2, 'Aquatic_firingThresh.m'};
    e6={exist('visibilityAerial_Daylight.mat','file')==2, 'Aerial_daylightContrastLimiting.m'};
    e7={exist('visibilityAerial_Moonlight.mat','file')==2, 'Aerial_moonlightContrastLimiting.m'};
    e8={exist('visibilityAerial_Starlight.mat','file')==2, 'Aerial_starlightContrastLimiting.m'};
    e3={exist('meteoAerial_Daylight.mat','file')==2, 'Aerial_daylightFiringThresh.m'};
    e4={exist('meteoAerial_Moonlight.mat','file')==2, 'Aerial_moonlightFiringThresh.m'};
    e5={exist('meteoAerial_Starlight.mat','file')==2,'Aerial_starlightFiringThresh.m'};
    e=[e1{1},e2{1},e3{1},e4{1},e5{1},e6{1},e7{1},e8{1}];
    em={e1{2},e2{2},e3{2},e4{2},e5{2},e6{2},e7{2},e8{2}};