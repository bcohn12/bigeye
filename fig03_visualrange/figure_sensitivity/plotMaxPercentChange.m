function plotMaxPercentChange
global BIGEYEROOT
%% INITIALIZATION
    close all;
    load('percChange.mat');
    load OM_TF_ST.mat
    load FinnedDigitedOrbitLength.mat
    
    pupil_TF = [mean(noElpistoOrb)-std(noElpistoOrb) mean(noElpistoOrb)+std(noElpistoOrb)].*0.449;
    pupil_ST = [mean(noSecAqOrb)-std(noSecAqOrb) mean(noSecAqOrb)+std(noSecAqOrb)].*0.449;
    fishpupil=mean(noElpistoOrb)*.449;
    tetrapodpupil=mean(noSecAqOrb)*.449;

%% CHECK FOR FILES
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

%% REARRANGEMENTS AND CALCULATIONS

    conditions={'Aquatic','AqUp','AqHor','Aerial','ArHor'};

    for c=1:3:length(conditions)
        visualRangeCell.(conditions{c})=struct2cell(visualRange.(conditions{c}));
        drdACell.(conditions{c})=struct2cell(drdA.(conditions{c}));
        visualVolumeCell.(conditions{c})=struct2cell(visualVolume.(conditions{c}));
        dVdACell.(conditions{c})=struct2cell(dVdA.(conditions{c}));
        direction=1;
        if strcmp(conditions{c},'Aquatic')
            direction=2;
        end
        for i=1:direction
            visualRangeMat.(conditions{c+i})=[];
            drdAMat.(conditions{c+i})=[];
            visualVolumeMat.(conditions{c+i})=[];
            dVdAMat.(conditions{c+i})=[];
            for j=2:length(visualRangeCell.Aquatic);
                visualRangeMat.(conditions{c+i})=[visualRangeCell.(conditions{c}){j}(:,i) visualRangeMat.(conditions{c+i})];
                drdAMat.(conditions{c+i})=[drdACell.(conditions{c}){j}(:,i) drdAMat.(conditions{c+i})];
                visualVolumeMat.(conditions{c+i})=[visualVolumeCell.(conditions{c}){j}(:,i) visualVolumeMat.(conditions{c+i})];
                dVdAMat.(conditions{c+i})=[dVdACell.(conditions{c}){j}(:,i) dVdAMat.(conditions{c+i})];
            end
            maxVisualRange.(conditions{c+i})=max(visualRangeMat.(conditions{c+i}),[],2);
            minVisualRange.(conditions{c+i})=min(visualRangeMat.(conditions{c+i}),[],2);
            maxdrdA.(conditions{c+i})=max(drdAMat.(conditions{c+i}),[],2);
            mindrdA.(conditions{c+i})=min(drdAMat.(conditions{c+i}),[],2);
            maxVisualVolume.(conditions{c+i})=max(visualVolumeMat.(conditions{c+i}),[],2);
            minVisualVolume.(conditions{c+i})=min(visualVolumeMat.(conditions{c+i}),[],2);
            maxdVdA.(conditions{c+i})=max(dVdAMat.(conditions{c+i}),[],2);
            mindVdA.(conditions{c+i})=min(dVdAMat.(conditions{c+i}),[],2);
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
        smooth(dVdA_River(:,3,1),7)];
    
    visual.rangeAquatic=visualRange_River; visual.rangeAerial=visualRange;
    visual.drdAAquatic=drdA_River; visual.drdAAerial=drdA';
    visual.volumeAquatic=visualVolume_River; visual.volumeAerial=visualVolume';
    visual.dVdAAquatic=dVdA_River; visual.dVdAAerial=dVdA';
    
%% FIND INTERSECTIONS
    cond={'rangeAquatic','rangeAerial','drdAAquatic','drdAAerial',...
        'volumeAquatic','volumeAerial','dVdAAquatic','dVdAAerial'};

    for i=1:length(cond)
        dum=visual.(cond{i});
        if ~isempty(findstr(cond{i},'Aerial'))
            diam=pupilValuesAir;
        else
            diam=pupilValues;
        end
        for j=1:size(dum,2)
            func=@(x) interp1(diam,dum(:,j),x,'pchip');
            intersectFish.(cond{i})(j)=func(fishpupil*1e-3);
            intersectDigited.(cond{i})(j)=func(tetrapodpupil*1e-3);
        end
    end
    
%% PLOT
    fig_props.noYsubplots = 2;
    fig_props.noXsubplots = 4;

    fig_props.figW = 18*2+5;   % cm
    fig_props.figH = 18;  % cm

    fig_props.ml = 2.5;
    fig_props.mt = 1;
    
    fig_props.left_margin = 2.2; 

    create_BE_figure
    fig_props.sub_pW = fig_props.sub_pW-.5;
    time_subsamp = 1;
    time_limit = 0.4;
    text_pos = [-5,2*time_limit/10,50];
    text_color = [0 0 0];
    text_size = 12;
    pn = {'Color','FontSize','FontWeight',};
    pv = {text_color,text_size,'bold'};
    
% Aquatic Range
    plotnoX = 1;
    plotnoY = 1;
    ha11 = create_BE_axes(plotnoX,plotnoY,fig_props);

    hl11_1=line('XData',pupilValues*1e3,'YData',visualRange_River(:,1),...
        'linewidth',linewidthDef,'color',[0 0.4470 0.7410]);
    hold on
    hl11_2=line('XData',pupilValues*1e3,'YData',visualRange_River(:,2),...
        'linewidth',linewidthDef,'color',[0 0.4470 0.7410],'linestyle',':');
    hl11_3=line('XData',pupilValues*1e3,'YData',visualRange_River(:,3),...
        'linewidth',linewidthDef,'color','k');
    hl11_4=line('XData',pupilValues*1e3,'YData',visualRange_River(:,4),...
        'linewidth',linewidthDef,'color',[0.9290 0.6940 0.1250]);
    xlim([1,25]); ylim1=get(gca,'ylim'); ylim([ylim1(1) 10]); ylim1=get(gca,'ylim');
    fillboxTF = patch([pupil_TF(1) pupil_TF(1) pupil_TF(2) pupil_TF(2)], ...
        [ylim1(1) ylim1(2) ylim1(2) ylim1(1)],[1 0 0]);
        set(fillboxTF,'facealpha',fillboxalpha,'edgecolor','none');
    fillboxST = patch([pupil_ST(1) pupil_ST(1) pupil_ST(2) pupil_ST(2)], ...
            [ylim1(1) ylim1(2) ylim1(2) ylim1(1)],[0 0 1]);
    set(fillboxST,'facealpha',fillboxalpha,'edgecolor','none');
    line([fishpupil,fishpupil],[ylim1(1),ylim1(2)],...
        'linewidth',linewidthDef,'color','r','linestyle',':');
    line([tetrapodpupil,tetrapodpupil],[ylim1(1),ylim1(2)],...
            'linewidth',linewidthDef,'color','b','linestyle',':');
    plot(fishpupil,intersectFish.rangeAquatic(1:2),'o',...
        'markeredgecolor','k','markerfacecolor','k','markersize',5);
    e1=errorbar(pupilValues*1e3,visualRange_River(:,1)',minVisualRange.AqUp'-visualRange_River(:,1)',maxVisualRange.AqUp'-visualRange_River(:,1)');
    e1.Color='black'; e1.LineWidth=linewidthDef;  hl11_1.Color=[0 0.4470 0.7410];
    x=15;
    text(x,interp1q(pupilValues,visualRange_River(:,1),x*1e-3)+0.8,'daylight,up',...
        'fontsize',11,'interpreter','tex','fontname','helvetica')
    text(x,interp1q(pupilValues,visualRange_River(:,2),x*1e-3)+0.8,'daylight,horizontal',...
        'fontsize',11,'interpreter','tex','fontname','helvetica')
    text(x,interp1q(pupilValues,visualRange_River(:,3),x*1e-3)+0.8,'moonlight,up',...
        'fontsize',11,'interpreter','tex','fontname','helvetica')
    text(x,interp1q(pupilValues,visualRange_River(:,4),x*1e-3)+0.8,'starlight,up',...
        'fontsize',11,'interpreter','tex','fontname','helvetica')
    num1=sprintf('\\bf%.1f m',interp1q(pupilValues,visualRange_River(:,1),fishpupil*1e-3));
    num2=sprintf('\\bf%.1f m',interp1q(pupilValues,visualRange_River(:,2),fishpupil*1e-3));
    text(fishpupil+0.5,interp1q(pupilValues,visualRange_River(:,1),fishpupil*1e-3)-0.3,num1,...
        'fontsize',11,'interpreter','tex','fontname','helvetica');
    text(fishpupil+0.5,interp1(pupilValues,visualRange_River(:,2),fishpupil*1e-3)-0.3,num2,...
        'fontsize',11,'interpreter','tex','fontname','helvetica');
    y11=ylabel('\bf visual range (\itr\rm\bf) (m)',...
        'fontsize',12,'fontname','helvetica','interpreter','tex');
    annotation('textbox',...
    [0.01 0.94 0.021 0.051],...
    'String',{'A1'},...
    'FontSize',13,...
    'FitBoxToText','off',...
    'EdgeColor',[1 1 1]);
    NumTicks = 5;
    L = get(gca,'YLim');
    set(gca,'YTick',[0 2 4 6 8 10])
    %yticks([0 2 4 6 8]);
    axis square
    
% Aquatic Derivative Range wrt Pupil Diameter
    plotnoX=2;
    plotnoY=1;
    ha12=create_BE_axes(plotnoX,plotnoY,fig_props);

    hl12_1=line('XData',pupilValues*1e3,'YData',drdA_River(:,1),...
        'linewidth',linewidthDef,'color',[0 0.4470 0.7410]);
    hold on
    hl12_2=line('XData',pupilValues*1e3,'YData',drdA_River(:,2),...
        'linewidth',linewidthDef,'color',[0 0.4470 0.7410],'linestyle',':');
    hl12_3=line('XData',pupilValues*1e3,'YData',drdA_River(:,3),...
        'linewidth',linewidthDef,'color','k');
    hl12_4=line('XData',pupilValues*1e3,'YData',drdA_River(:,4),...
        'linewidth',linewidthDef,'color',[0.9290 0.6940 0.1250]);
    xlim([1,25]); ylim1=get(gca,'ylim'); ylim([ylim1(1) 0.6]); ylim1=get(gca,'ylim');
    fillboxTF = patch([pupil_TF(1) pupil_TF(1) pupil_TF(2) pupil_TF(2)], ...
        [ylim1(1) ylim1(2) ylim1(2) ylim1(1)],[1 0 0]);
        set(fillboxTF,'facealpha',fillboxalpha,'edgecolor','none');
    fillboxST = patch([pupil_ST(1) pupil_ST(1) pupil_ST(2) pupil_ST(2)], ...
            [ylim1(1) ylim1(2) ylim1(2) ylim1(1)],[0 0 1]);
    set(fillboxST,'facealpha',fillboxalpha,'edgecolor','none');
    line([fishpupil,fishpupil],[ylim1(1),ylim1(2)],...
        'linewidth',linewidthDef,'color','r','linestyle',':');
    line([tetrapodpupil,tetrapodpupil],[ylim1(1),ylim1(2)],...
            'linewidth',linewidthDef,'color','b','linestyle',':');
    e2=errorbar(pupilValues*1e3,drdA_River(:,1)',mindrdA.AqUp'-drdA_River(:,1)',maxdrdA.AqUp'-drdA_River(:,1)');
    e2.Color='black'; e2.LineWidth=linewidthDef;  hl12_1.Color=[0 0.4470 0.7410];
    ylabel('\bfd\itr\rm\bf/d\itD \rm\bf(m/mm)','interpreter','tex',...
        'fontsize',12,'fontname','helvetica');
    annotation('textbox',...
    [0.25 0.94 0.021 0.051],...
    'String','B1',...
    'FontSize',13,...
    'FitBoxToText','off',...
    'EdgeColor',[1 1 1]);
    NumTicks = 5;
    L = get(gca,'YLim');
    set(gca,'YTick',[0 0.2 0.4 0.6])
    axis square 
   
% Aquatic Volume
    plotnoX=1;
    plotnoY=2;
    ha21=create_BE_axes(plotnoX,plotnoY,fig_props);

    hl21_1=line('XData',pupilValues*1e3,'YData',visualVolume_River(:,1)/1e2,...
        'linewidth',linewidthDef,'color',[0 0.4470 0.7410]);
    hold on
    hl21_2=line('XData',pupilValues*1e3,'YData',visualVolume_River(:,2)/1e2,...
        'linewidth',linewidthDef,'color',[0 0.4470 0.7410],'linestyle',':');
    hl21_3=line('XData',pupilValues*1e3,'YData',visualVolume_River(:,3)/1e2,...
        'linewidth',linewidthDef,'color','k');
    hl21_4=line('XData',pupilValues*1e3,'YData',visualVolume_River(:,4)/1e2,...
        'linewidth',linewidthDef,'color',[0.9290 0.6940 0.1250]);
    xlim([1,25]); ylim1=get(gca,'ylim');  ylim([ylim1(1) 8]); ylim1=get(gca,'ylim');
    fillboxTF = patch([pupil_TF(1) pupil_TF(1) pupil_TF(2) pupil_TF(2)], ...
        [ylim1(1) ylim1(2) ylim1(2) ylim1(1)],[1 0 0]);
        set(fillboxTF,'facealpha',fillboxalpha,'edgecolor','none');
    fillboxST = patch([pupil_ST(1) pupil_ST(1) pupil_ST(2) pupil_ST(2)], ...
            [ylim1(1) ylim1(2) ylim1(2) ylim1(1)],[0 0 1]);
    set(fillboxST,'facealpha',fillboxalpha,'edgecolor','none');
    line([fishpupil,fishpupil],[ylim1(1),ylim1(2)],...
        'linewidth',linewidthDef,'color','r','linestyle',':');
    line([tetrapodpupil,tetrapodpupil],[ylim1(1),ylim1(2)],...
            'linewidth',linewidthDef,'color','b','linestyle',':');
    e3=errorbar(pupilValues*1e3,(visualVolume_River(:,1)')/1e2,...
        (minVisualVolume.AqUp'-visualVolume_River(:,1)')/1e2,(maxVisualVolume.AqUp'-visualVolume_River(:,1)')/1e2);
    e3.Color='black'; e3.LineWidth=linewidthDef;  hl21_1.Color=[0 0.4470 0.7410];
    ylabel('\bfvisual volume (\itV\rm\bf) (10^2m^3)','interpreter','tex',...
        'fontsize',12,'fontname','helvetica');
    xlabel('\bfpupil diameter (\itD\rm\bf) (mm)', 'interpreter','tex',...
        'fontsize',12,'fontname','helvetica');
    annotation('textbox',...
    [0.01 0.46 0.021 0.051],...
    'String','C1',...
    'FontSize',13,...
    'FitBoxToText','off',...
    'EdgeColor',[1 1 1]);
    NumTicks = 5;
    L = get(gca,'YLim');
    set(gca,'YTick',[0 2 4 6 8])
    axis square

% Aquatic Derivative Volume wrt Pupil Diameter
    plotnoX=2;
    plotnoY=2;
    ha22=create_BE_axes(plotnoX,plotnoY,fig_props);

    hl22_1=line('XData',pupilValues*1e3,'YData',dVdA_River(:,1)/1e1,...
        'linewidth',linewidthDef,'color',[0 0.4470 0.7410]);
    hold on
    hl22_2=line('XData',pupilValues*1e3,'YData',dVdA_River(:,2)/1e1,...
        'linewidth',linewidthDef,'color',[0 0.4470 0.7410],'linestyle',':');
    hl22_3=line('XData',pupilValues*1e3,'YData',dVdA_River(:,3)/1e1,...
        'linewidth',linewidthDef,'color','k');
    hl22_4=line('XData',pupilValues*1e3,'YData',dVdA_River(:,4)/1e1,...
        'linewidth',linewidthDef,'color',[0.9290 0.6940 0.1250]);
    xlim([1,25]); ylim1=get(gca,'ylim'); ylim([ylim1(1) 8]); ylim1=get(gca,'ylim');
    fillboxTF = patch([pupil_TF(1) pupil_TF(1) pupil_TF(2) pupil_TF(2)], ...
        [ylim1(1) ylim1(2) ylim1(2) ylim1(1)],[1 0 0]);
        set(fillboxTF,'facealpha',fillboxalpha,'edgecolor','none');
    fillboxST = patch([pupil_ST(1) pupil_ST(1) pupil_ST(2) pupil_ST(2)], ...
            [ylim1(1) ylim1(2) ylim1(2) ylim1(1)],[0 0 1]);
    set(fillboxST,'facealpha',fillboxalpha,'edgecolor','none');
    line([fishpupil,fishpupil],[ylim1(1),ylim1(2)],...
        'linewidth',linewidthDef,'color','r','linestyle',':');
    line([tetrapodpupil,tetrapodpupil],[ylim1(1),ylim1(2)],...
            'linewidth',linewidthDef,'color','b','linestyle',':');
    plot(fishpupil,intersectFish.dVdAAquatic(1)/1e1,'o',...
        'markeredgecolor','k','markerfacecolor','k','markersize',5);
    num1=sprintf('\\bf%.1f m^3/mm',interp1q(pupilValues,dVdA_River(:,1),fishpupil*1e-3));
    text(fishpupil+0.5,(interp1q(pupilValues,dVdA_River(:,1),fishpupil*1e-3)/1e1)+.5,num1,...
        'fontsize',10,'interpreter','tex','fontname','helvetica');
    e4=errorbar(pupilValues*1e3,(dVdA_River(:,1)')/1e1,...
        (mindVdA.AqUp'-dVdA_River(:,1)')/1e1,(maxdVdA.AqUp'-dVdA_River(:,1)')/1e1);
    e4.Color='black'; e4.LineWidth=linewidthDef;  hl22_1.Color=[0 0.4470 0.7410];
    ylabel('\bfd\itV\rm\bf/d\itD \rm\bf(10m^3/mm)','interpreter','tex',...
        'fontsize',12,'fontname','helvetica');
    x22=xlabel('\bfpupil diameter (\itD\rm\bf) (mm)','interpreter','tex',...
    'fontsize',12,'fontname','helvetica');
    annotation('textbox',...
    [0.25 0.46 0.021 0.051],...
    'String','D1',...
    'FontSize',13,...
    'FitBoxToText','off',...
    'EdgeColor',[1 1 1]);
    NumTicks = 5;
    L = get(gca,'YLim');
    set(gca,'YTick',[0 2 4 6 8])
    axis square
    
% Aerial Range
    plotnoX = 3;
    plotnoY = 1;
    ha31 = create_BE_axes(plotnoX,plotnoY,fig_props);

    hl31_1=line('XData',pupilValuesAir*1e3,'YData',visualRange(:,1),...
        'linewidth',linewidthDef,'color',[0 0.4470 0.7410]);
    hold on
    hl31_2=line('XData',pupilValuesAir*1e3,'YData',visualRange(:,2),...
        'linewidth',linewidthDef,'color','k');
    hl31_3=line('XData',pupilValuesAir*1e3,'YData',visualRange(:,3),...
        'linewidth',linewidthDef,'color',[0.9290 0.6940 0.1250]);
    hl31_4=line('XData',pupilValues*1e3,'YData',visualRange_River(:,1),...
        'linewidth',linewidthDef,'color',[0.4940 0.1840 0.5560]);
    xlim([1,25]); ylim1=get(gca,'ylim'); ylim([ylim1(1) 1000]); ylim1=get(gca,'ylim');
    fillboxTF = patch([pupil_TF(1) pupil_TF(1) pupil_TF(2) pupil_TF(2)], ...
        [ylim1(1) ylim1(2) ylim1(2) ylim1(1)],[1 0 0]);
        set(fillboxTF,'facealpha',fillboxalpha,'edgecolor','none');
    fillboxST = patch([pupil_ST(1) pupil_ST(1) pupil_ST(2) pupil_ST(2)], ...
            [ylim1(1) ylim1(2) ylim1(2) ylim1(1)],[0 0 1]);
    set(fillboxST,'facealpha',fillboxalpha,'edgecolor','none');
    line([fishpupil,fishpupil],[ylim1(1),ylim1(2)],...
        'linewidth',linewidthDef,'color','r','linestyle',':');
    line([tetrapodpupil,tetrapodpupil],[ylim1(1),ylim1(2)],...
            'linewidth',linewidthDef,'color','b','linestyle',':');
    plot(fishpupil,intersectFish.rangeAerial(1)/1e2,'o',...
        'markeredgecolor','k','markerfacecolor','k','markersize',5);
    plot(tetrapodpupil,intersectDigited.rangeAerial(1)/1e2,'o',...
        'markeredgecolor','k','markerfacecolor','k','markersize',5);
    e5=errorbar(pupilValuesAir*1e3,visualRange(:,1),...
        (minVisualRange.ArHor-visualRange(:,1)),(maxVisualRange.ArHor-visualRange(:,1)));
    e5.Color='black'; e5.LineWidth=linewidthDef;  hl31_1.Color=[0 0.4470 0.7410];
    x=16;
    text(x,(interp1q(pupilValuesAir,visualRange(:,1),x*1e-3)+188),'daylight',...
        'fontsize',12,'interpreter','tex','fontname','helvetica')
    text(x,(interp1q(pupilValuesAir,visualRange(:,2),x*1e-3)+140),'moonlight',...
        'fontsize',12,'interpreter','tex','fontname','helvetica')
    text(x,(interp1q(pupilValuesAir,visualRange(:,3),x*1e-3)+97),'starlight',...
        'fontsize',12,'interpreter','tex','fontname','helvetica')
    text(x,50,'aquatic','fontsize',12,'interpreter','tex','fontname','helvetica');
    num1=sprintf('\\bf%.1f m',interp1q(pupilValuesAir,visualRange(:,1),fishpupil*1e-3));
    num2=sprintf('\\bf%.1f m',interp1q(pupilValuesAir,visualRange(:,1),tetrapodpupil*1e-3));
    text(fishpupil+0.5,(interp1q(pupilValuesAir,visualRange(:,1),fishpupil*1e-3)-10),num1,...
        'fontsize',11,'interpreter','tex','fontname','helvetica');
    text(tetrapodpupil-0.5,(interp1(pupilValuesAir,visualRange(:,1),tetrapodpupil*1e-3)+25),num2,...
        'fontsize',11,'interpreter','tex','horizontalalignment','right','fontname','helvetica');
    ylabel('\bfvisual range (\itr\rm\bf) (m)','interpreter','tex',...
        'fontsize',12,'fontname','helvetica');
    annotation('textbox',...
    [0.49 0.94 0.021 0.051],...
    'String',{'A2'},...
    'FontSize',13,...
    'FitBoxToText','off',...
    'EdgeColor',[1 1 1]);
    NumTicks = 5;
    L = get(gca,'YLim');
    set(gca,'YTick',[0 200 400 600 800 1000])
    axis square

% Aerial Derivative Range wrt Pupil Diameter
    plotnoX = 4;
    plotnoY = 1;
    ha41 = create_BE_axes(plotnoX,plotnoY,fig_props);

    hl41_1=line('XData',pupilValuesAir*1e3,'YData',drdA(1,:)/1e2,...
        'linewidth',linewidthDef,'color',[0 0.4470 0.7410]);
    hold on
    hl41_2=line('XData',pupilValuesAir*1e3,'YData',drdA(2,:)/1e2,...
        'linewidth',linewidthDef,'color','k');
    hl41_3=line('XData',pupilValuesAir*1e3,'YData',drdA(3,:)/1e2,...
        'linewidth',linewidthDef,'color',[0.9290 0.6940 0.1250]);
    hl41_4=line('XData',pupilValues*1e3,'YData',drdA_River(:,1)/1e2,...
        'linewidth',linewidthDef,'color',[0.4940 0.1840 0.5560]);
    xlim([1,25]); ylim1=get(gca,'ylim'); ylim([ylim1(1) ylim1(2)]);
    fillboxTF = patch([pupil_TF(1) pupil_TF(1) pupil_TF(2) pupil_TF(2)], ...
        [ylim1(1) ylim1(2) ylim1(2) ylim1(1)],[1 0 0]);
        set(fillboxTF,'facealpha',fillboxalpha,'edgecolor','none');
    fillboxST = patch([pupil_ST(1) pupil_ST(1) pupil_ST(2) pupil_ST(2)], ...
            [ylim1(1) ylim1(2) ylim1(2) ylim1(1)],[0 0 1]);
    set(fillboxST,'facealpha',fillboxalpha,'edgecolor','none');
    line([fishpupil,fishpupil],[ylim1(1),ylim1(2)],...
        'linewidth',linewidthDef,'color','r','linestyle',':');
    line([tetrapodpupil,tetrapodpupil],[ylim1(1),ylim1(2)],...
            'linewidth',linewidthDef,'color','b','linestyle',':');
    e6=errorbar(pupilValuesAir*1e3,drdA(1,:)/1e2,...
        (mindrdA.ArHor-drdA(1,:)')/1e2,(maxdrdA.ArHor-drdA(1,:)')/1e2);
    e6.Color='black'; e6.LineWidth=linewidthDef;  hl41_1.Color=[0 0.4470 0.7410];
    ylabel('\bfd\itr\rm\bf/d\itD \rm\bf(10^2m/mm)','interpreter','tex',...
        'fontsize',12,'fontname','helvetica');
    annotation('textbox',...
    [0.72 0.94 0.021 0.051],...
    'String','B2',...
    'FontSize',13,...
    'FitBoxToText','off',...
    'EdgeColor',[1 1 1]);
    NumTicks = 5;
    L = get(gca,'YLim');
    set(gca,'YTick',[0 .20 .40 .60])
    axis square
 
% Aerial Volume
    plotnoX = 3;
    plotnoY = 2;
    ha32 = create_BE_axes(plotnoX,plotnoY,fig_props);

    hl32_1=line('XData',pupilValuesAir*1e3,'YData',visualVolume(1,:)/1e8,...
        'linewidth',linewidthDef,'color',[0 0.4470 0.7410]);
    hold on
    hl32_2=line('XData',pupilValuesAir*1e3,'YData',visualVolume(2,:)/1e8,...
        'linewidth',linewidthDef,'color','k');
    hl32_3=line('XData',pupilValuesAir*1e3,'YData',visualVolume(3,:)/1e8,...
        'linewidth',linewidthDef,'color',[0.9290 0.6940 0.1250]);
    hl42_4=line('XData',pupilValues*1e3,'YData',visualVolume_River(:,1)/1e8,...
        'linewidth',linewidthDef,'color',[0.4940 0.1840 0.5560]);
    xlim([1,25]); ylim1=get(gca,'ylim'); ylim([ylim1(1) 8]); ylim1=get(gca,'ylim');
    fillboxTF = patch([pupil_TF(1) pupil_TF(1) pupil_TF(2) pupil_TF(2)], ...
        [ylim1(1) ylim1(2) ylim1(2) ylim1(1)],[1 0 0]);
        set(fillboxTF,'facealpha',fillboxalpha,'edgecolor','none');
    fillboxST = patch([pupil_ST(1) pupil_ST(1) pupil_ST(2) pupil_ST(2)], ...
            [ylim1(1) ylim1(2) ylim1(2) ylim1(1)],[0 0 1]);
    set(fillboxST,'facealpha',fillboxalpha,'edgecolor','none');
    line([fishpupil,fishpupil],[ylim1(1),ylim1(2)],...
        'linewidth',linewidthDef,'color','r','linestyle',':');
    line([tetrapodpupil,tetrapodpupil],[ylim1(1),ylim1(2)],...
            'linewidth',linewidthDef,'color','b','linestyle',':');
    e7=errorbar(pupilValuesAir*1e3,visualVolume(1,:)/1e8,...
        (minVisualVolume.ArHor-visualVolume(1,:)')/1e8,(maxVisualVolume.ArHor-visualVolume(1,:)')/1e8);
    e7.Color='black'; e7.LineWidth=linewidthDef;  hl32_1.Color=[0 0.4470 0.7410];
    ylabel('\bfvisual volume (\itV\rm\bf) (10^8m^3)','interpreter','tex',...
        'fontsize',12,'fontname','helvetica');
    xlabel('\bfpupil diameter (\itD\rm\bf) (mm)','interpreter','tex',...
        'fontsize',12,'fontname','helvetica');
    annotation('textbox',...
    [0.49 0.46 0.021 0.051],...
    'String','C2',...
    'FontSize',13,...
    'FitBoxToText','off',...
    'EdgeColor',[1 1 1]);
    NumTicks = 5;
    L = get(gca,'YLim');
    set(gca,'YTick',[0 2 4 6 8])
    axis square

% Aerial Derivative Volume wrt Pupil Diameter
    plotnoX = 4;
    plotnoY = 2;
    ha42 = create_BE_axes(plotnoX,plotnoY,fig_props);

    hl42_1=line('XData',pupilValuesAir*1e3,'YData',dVdA(1,:)/1e7,...
        'linewidth',linewidthDef,'color',[0 0.4470 0.7410]);
    hold on
    hl42_2=line('XData',pupilValuesAir*1e3,'YData',dVdA(2,:)/1e7,...
        'linewidth',linewidthDef,'color','k');
    hl42_3=line('XData',pupilValuesAir*1e3,'YData',dVdA(3,:)/1e7,...
        'linewidth',linewidthDef,'color',[0.9290 0.6940 0.1250]);
    hl42_4=line('XData',pupilValues*1e3,'YData',dVdA_River(:,1)/1e7,...
        'linewidth',linewidthDef,'color',[0.4940 0.1840 0.5560]);
    xlim([1,25]); ylim1=get(gca,'ylim'); ylim([ylim1(1) 8]); ylim1=get(gca,'ylim');
    fillboxTF = patch([pupil_TF(1) pupil_TF(1) pupil_TF(2) pupil_TF(2)], ...
        [ylim1(1) ylim1(2) ylim1(2) ylim1(1)],[1 0 0]);
        set(fillboxTF,'facealpha',fillboxalpha,'edgecolor','none');
    fillboxST = patch([pupil_ST(1) pupil_ST(1) pupil_ST(2) pupil_ST(2)], ...
            [ylim1(1) ylim1(2) ylim1(2) ylim1(1)],[0 0 1]);
    set(fillboxST,'facealpha',fillboxalpha,'edgecolor','none');
    line([fishpupil,fishpupil],[ylim1(1),ylim1(2)],...
        'linewidth',linewidthDef,'color','r','linestyle',':');
    line([tetrapodpupil,tetrapodpupil],[ylim1(1),ylim1(2)],...
            'linewidth',linewidthDef,'color','b','linestyle',':');
    plot(fishpupil,intersectFish.dVdAAerial(1)/1e7,'o',...
        'markeredgecolor','k','markerfacecolor','k','markersize',5);
    e8=errorbar(pupilValuesAir*1e3,dVdA(1,:)/1e7,...
        (mindVdA.ArHor-dVdA(1,:)')/1e7,(maxdVdA.ArHor-dVdA(1,:)')/1e7);
    e8.Color='black'; e8.LineWidth=linewidthDef;  hl42_1.Color=[0 0.4470 0.7410];
    num1=sprintf('\\bf%10.2e m^3/mm',interp1q(pupilValuesAir,dVdA(1,:)',fishpupil*1e-3));
    text(fishpupil+.5,(interp1q(pupilValuesAir,dVdA(1,:)',fishpupil*1e-3)/1e7)-0.3,num1,...
        'fontsize',11,'interpreter','tex','fontname','helvetica');
    ylabel('\bfd\itV\rm\bf/d\itD \rm\bf(10^7m^3/mm)','interpreter','tex',...
        'fontsize',12,'fontname','helvetica');
    xlabel('\bfpupil diameter (\itD\rm\bf) (mm)','interpreter','tex',...
        'fontsize',12,...
        'fontname','helvetica');
    annotation('textbox',...
    [0.72 0.46 0.021 0.052],...
    'String','D2',...
    'FontSize',13,...
    'FitBoxToText','off',...
    'EdgeColor',[1 1 1]);
    NumTicks = 5;
    L = get(gca,'YLim');
    set(gca,'YTick',[0 2 4 6 8])
    axis square
    
    filename=[BIGEYEROOT 'fig03_visualrange/figure_sensitivity/sensitivity_superimposed.pdf'];
    print(filename,'-painters','-dpdf','-r600');

    function [e,em]=fileExists
    e2={exist('visibilityAquatic_All.mat','file')==2, 'Aquatic_contrastLimiting.m'};
    e1={exist('meteoAquatic_All.mat','file')==2, 'Aquatic_firingThresh.m'};
    e6={exist('visibilityAerial_Daylight.mat','file')==2, 'Aerial_daylightContrastLimiting.m'};
    e7={exist('visibilityAerial_Moonlight.mat','file')==2, 'Aerial_moonlightContrastLimiting.m'};
    e8={exist('visibilityAerial_Starlight.mat','file')==2, 'Aerial_starlightContrastLimiting.m'};
    e3={exist('meteoAerial_Daylight.mat','file')==2, 'Aerial_daylightFiringThresh.m'};
    e4={exist('meteoAerial_Moonlight.mat','file')==2, 'Aerial_moonlightFiringThresh.m'};
    e5={exist('meteoAerial_Starlight.mat','file')==2,'Aerial_starlightFiringThresh.m'};
    e9={exist('percChange.mat','file')==2, 'percChange.mat'};
    e=[e1{1},e2{1},e3{1},e4{1},e5{1},e6{1},e7{1},e8{1},e9{1}];
    em={e1{2},e2{2},e3{2},e4{2},e5{2},e6{2},e7{2},e8{2},e9{2}};    
    
    
    