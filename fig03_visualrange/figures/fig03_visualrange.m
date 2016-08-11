function fig03_visualrange
%% INITIALIZATION
    close all;
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

    fig_props.figW = 18*2;   % cm
    fig_props.figH = 10*2;  % cm

    fig_props.ml = 1.5;
    fig_props.mt = 0.8;

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
    xlim([1,25]); ylim1=get(gca,'ylim'); 
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
    x=15;
    text(x,interp1q(pupilValues,visualRange_River(:,1),x*1e-3)+0.5,'daylight,up',...
        'fontsize',10,'interpreter','latex')
    text(x,interp1q(pupilValues,visualRange_River(:,2),x*1e-3)+0.5,'daylight,horizontal',...
        'fontsize',10,'interpreter','latex')
    text(x,interp1q(pupilValues,visualRange_River(:,3),x*1e-3)+0.5,'moonlight,up',...
        'fontsize',10,'interpreter','latex')
    text(x,interp1q(pupilValues,visualRange_River(:,4),x*1e-3)+0.5,'starlight,up',...
        'fontsize',10,'interpreter','latex')
    num1=sprintf('\\textbf{%s~m}',num2str(round(interp1q(pupilValues,visualRange_River(:,1),fishpupil*1e-3))));
    num2=sprintf('\\textbf{%s~m}',num2str(round(interp1q(pupilValues,visualRange_River(:,2),fishpupil*1e-3))));
    text(fishpupil+0.5,interp1q(pupilValues,visualRange_River(:,1),fishpupil*1e-3)-0.3,num1,...
        'fontsize',10,'interpreter','latex');
    text(fishpupil+0.5,interp1(pupilValues,visualRange_River(:,2),fishpupil*1e-3)-0.3,num2,...
        'fontsize',10,'interpreter','latex');
    ylabel('visual range ($r$) (m)','interpreter','latex','fontsize',10,'fontname','helvetica');
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
    xlim([1,25]); ylim1=get(gca,'ylim'); 
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
    ylabel('d$r$/d$D$ (m/mm)','interpreter','latex','fontsize',10,'fontname','helvetica');
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
    xlim([1,25]); ylim1=get(gca,'ylim'); 
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
    ylabel('visual volume ($V$) ($10^2$m$^3$)','interpreter','latex','fontsize',10,'fontname','helvetica');
    xlabel('pupil diamter ($D$) (mm)', 'interpreter','latex','fontsize',10,'fontname','helvetica');
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
    xlim([1,25]); ylim1=get(gca,'ylim'); 
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
    num1=sprintf('\\textbf{%s~m$^3$/mm}',num2str(round(interp1q(pupilValues,dVdA_River(:,1),fishpupil*1e-3))));
    text(fishpupil+0.5,(interp1q(pupilValues,dVdA_River(:,1),fishpupil*1e-3)/1e1)+.2,num1,...
        'fontsize',10,'interpreter','latex');
    ylabel('d$V$/d$D$ ($10$m$^3$/mm)','interpreter','latex','fontsize',10,'fontname','helvetica');
    xlabel('pupil diameter ($D$) (mm)','interpreter','latex','fontsize',10,'fontname','helvetica');
    axis square

% Aerial Range
    plotnoX = 3;
    plotnoY = 1;
    ha31 = create_BE_axes(plotnoX,plotnoY,fig_props);

    hl31_1=line('XData',pupilValuesAir*1e3,'YData',visualRange(:,1)/1e2,...
        'linewidth',linewidthDef,'color',[0 0.4470 0.7410]);
    hold on
    hl31_2=line('XData',pupilValuesAir*1e3,'YData',visualRange(:,2)/1e2,...
        'linewidth',linewidthDef,'color','k');
    hl31_3=line('XData',pupilValuesAir*1e3,'YData',visualRange(:,3)/1e2,...
        'linewidth',linewidthDef,'color',[0.9290 0.6940 0.1250]);
    xlim([1,25]); ylim1=get(gca,'ylim'); 
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
    x=18;
    text(x,(interp1q(pupilValuesAir,visualRange(:,1),x*1e-3)+145)/1e2,'daylight',...
        'fontsize',10,'interpreter','latex')
    text(x,(interp1q(pupilValuesAir,visualRange(:,2),x*1e-3)+110)/1e2,'moonlight',...
        'fontsize',10,'interpreter','latex')
    text(x,(interp1q(pupilValuesAir,visualRange(:,3),x*1e-3)+75)/1e2,'starlight',...
        'fontsize',10,'interpreter','latex')
    num1=sprintf('\\textbf{%s~m}',num2str(round(interp1q(pupilValuesAir,visualRange(:,1),fishpupil*1e-3))));
    num2=sprintf('\\textbf{%s~m}',num2str(round(interp1q(pupilValuesAir,visualRange(:,1),tetrapodpupil*1e-3))));
    text(fishpupil+0.5,(interp1q(pupilValuesAir,visualRange(:,1),fishpupil*1e-3)-10)/1e2,num1,...
        'fontsize',10,'interpreter','latex');
    text(tetrapodpupil-0.5,(interp1(pupilValuesAir,visualRange(:,1),tetrapodpupil*1e-3)+25)/1e2,num2,...
        'fontsize',10,'interpreter','latex','horizontalalignment','right');
    ylabel('visual range ($r$) ($10^2$m)','interpreter','latex','fontsize',10,'fontname','helvetica');
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
    ylabel('d$r$/d$D$ ($10^2$m/mm)','interpreter','latex','fontsize',10,'fontname','helvetica');
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
    xlim([1,25]); ylim1=get(gca,'ylim'); 
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
    ylabel('visual volume ($V$) ($10^8$m$^3$/mm)','interpreter','latex','fontsize',10,'fontname','helvetica');
    xlabel('pupil diameter ($D$) (mm)','interpreter','latex','fontsize',10,...
        'fontname','helvetica');
    axis square

% Aerial Derivative Volume wrt Pupil Diameter
    plotnoX = 4;
    plotnoY = 2;
    ha42 = create_BE_axes(plotnoX,plotnoY,fig_props);

    hl42_1=line('XData',pupilValuesAir*1e3,'YData',dVdA(1,:)/1e7,...
        'linewidth',linewidthDef,'color',[0 0.4470 0.7410]);
    hold on
    hl42_2=line('XData',pupilValuesAir*1e3,'YData',dVdA(1,:)/1e7,...
        'linewidth',linewidthDef,'color','k');
    hl42_3=line('XData',pupilValuesAir*1e3,'YData',dVdA(3,:)/1e7,...
        'linewidth',linewidthDef,'color',[0.9290 0.6940 0.1250]);
    xlim([1,25]); ylim1=get(gca,'ylim'); 
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
    num1=sprintf('\\textbf{%s~m$^3$/mm}',num2str(round(interp1q(pupilValuesAir,dVdA(1,:)',fishpupil*1e-3)),'%10.1e'));
    text(fishpupil+.5,(interp1q(pupilValuesAir,dVdA(1,:)',fishpupil*1e-3)/1e7)-0.3,num1,...
        'fontsize',10,'interpreter','latex');
    ylabel('d$V$/d$D$ ($10^7$m$^3$/mm)','interpreter','latex','fontsize',10,'fontname','helvetica');
    xlabel('pupil diameter ($D$) (mm)','interpreter','latex','fontsize',10,...
        'fontname','helvetica');
    axis square


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