function figExt06_sensitivity
global BIGEYEROOT
%% INITIALIZE
    close all;   
    load OM_TF_ST.mat
    load FinnedDigitedOrbitLength.mat
    
    pupil_TF = [mean(noElpistoOrb)-std(noElpistoOrb) mean(noElpistoOrb)+std(noElpistoOrb)].*0.449;
    pupil_ST = [mean(noSecAqOrb)-std(noSecAqOrb) mean(noSecAqOrb)+std(noSecAqOrb)].*0.449;
    fishpupil=mean(noElpistoOrb)*.449;
    tetrapodpupil=mean(noSecAqOrb)*.449;
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
    load('visibilityAquatic_All.mat');
    visualRangeSensitivity=[smooth(visualRangeSensitivity(:,1,1),7),smooth(visualRangeSensitivity(:,2,1),7),smooth(visualRangeSensitivity(:,3,1),7),...
        smooth(visualRangeSensitivity(:,4,1),7),smooth(visualRangeSensitivity(:,1,2),7),smooth(visualRangeSensitivity(:,2,2),7),...
        smooth(visualRangeSensitivity(:,3,2),7),smooth(visualRangeSensitivity(:,4,2),7)];
    linewidthdef=2;

%% PLOT
    fig_props.noYsubplots = 1;
    fig_props.noXsubplots = 2;

    fig_props.figW = 25;   % cm
    fig_props.figH = 10;  % cm

    fig_props.ml = 0.8;
    fig_props.mt = 0.8;
    fig_props.bottom_margin=2;
    create_BE_figure
    fig_props.sub_pW = fig_props.sub_pW-.5;
    time_subsamp = 1;
    time_limit = 0.4;
    text_pos = [-5,2*time_limit/10,50];
    text_color = [0 0 0];
    text_size = 12;
    pn = {'Color','FontSize','FontWeight',};
    pv = {text_color,text_size,'bold'};
    colors=get(gca,'colororder'); clf;
    x=17;
% Sensitivity Upward Viewing
    plotnoX= 1;
    plotnoY= 1;
    ha1 = create_BE_axes(plotnoX,plotnoY,fig_props);
    hl1.A=line('XData',pupilValues*10^3,'YData',visualRangeSensitivity(:,1),...
        'color',colors(1,:),'linewidth',linewidthdef);
    hold on;
    for i=2:4
        str=char(i+'A'-1);
        hl1.(str)=line('XData',pupilValues*10^3,'YData',visualRangeSensitivity(:,i),...
            'color',colors(i,:),'linewidth',linewidthdef);
    end
    hl1.E=line('XData',pupilValues*10^3,'YData',visualRange_River(:,1,1),...
        'color',colors(5,:),'linewidth',linewidthdef);
    ylim1=get(gca,'ylim');
    line([fishpupil,fishpupil],[ylim1(1),ylim1(2)],...
        'linewidth',linewidthdef,'color','r','linestyle',':');
    line([tetrapodpupil,tetrapodpupil],[ylim1(1),ylim1(2)],...
            'linewidth',linewidthdef,'color','b','linestyle',':');
    ylabel('\bfvisual range (\itr) \rm\bf(m)','interpreter','tex',...
        'fontsize',12,'fontname','helvetica');
    xlabel('\bfpupil diameter (\itD) \rm\bf(mm)','interpreter','tex',...
        'fontsize',12,'fontname','helvetica');
    text(x,1.8*ylim1(2)/5,'\bfupward viewing','interpreter',...
        'tex','fontsize',13,'fontname','helvetica');
    axis square
        
% Sensitivity Horizontal Viewing
    plotnoX=2;
    plotnoY=1;
    ha2=create_BE_axes(plotnoX,plotnoY,fig_props);
    hl2.A=line('XData',pupilValues*10^3,'YData',visualRangeSensitivity(:,5),...
        'color',colors(1,:),'linewidth',linewidthdef);
    hold on;
    for i=6:8
        str=char(i+'A'-4);
        hl1.(str)=line('XData',pupilValues*10^3,'YData',visualRangeSensitivity(:,i),...
            'color',colors(i-4,:),'linewidth',linewidthdef);
    end
    hl1.E=line('XData',pupilValues*10^3,'YData',visualRange_River(:,1,2),...
        'color',colors(5,:),'linewidth',linewidthdef);
    line([fishpupil,fishpupil],[ylim1(1),ylim1(2)],...
        'linewidth',linewidthdef,'color','r','linestyle',':');
    line([tetrapodpupil,tetrapodpupil],[ylim1(1),ylim1(2)],...
            'linewidth',linewidthdef,'color','b','linestyle',':');
    ylabel('\bfvisual range (\itr) \rm\bf(m)','interpreter','tex',...
        'fontsize',12,'fontname','helvetica');
    xlabel('\bfpupil diameter (\itD) \rm\bf(mm)','interpreter','tex',...
        'fontsize',12,'fontname','helvetica');
    text(x,1.8*ylim1(2)/5,'\bfhorizontal viewing','interpreter','tex',...
        'fontsize',13,'fontname','helvetica');
    axis square
    
hLegend=legend('high turbidity @15 m','clear @15 m',...
    'absorption  dominated @15 m','scattering dominated @15 m','baseline @8 m');
set(hLegend,'box','off'); set(hLegend,'interpreter','tex'); 
set(hLegend,'fontsize',11,'fontname','helvetica'); set(hLegend,'orientation','horizontal')
rect=[0.375 0 0.25 0.1]; set(hLegend,'Position',rect)

filename=[BIGEYEROOT 'figExt06_sensitivity/figures/core_figures/water_sensitivity.pdf'];
print(filename,'-painters','-dpdf','-r600');
    
function [e,em]=fileExists
    e4={exist('Aquatic_visRangeSensitivity.mat','file')==2, 'Aquatic_contrastLimitedSensitivity.m'};
    e3={exist('Aquatic_meteoRangeSensitivity.mat','file')==2, 'Aquatic_firingThreshSensitivity.m'};
    %e2={exist('visibilityAquatic_All.mat','file')==2, 'Aquatic_contrastLimiting.m'};
    %e1={exist('meteoAquatic_All.mat','file')==2,'Aquatic_firingThresh.m'};
    e=[e3{1},e4{1}];
    em={e3{2},e4{2}};