function figExt07_contrast
global BIGEYEROOT
    close all;
    [e,em]=fileExists;
    while ~all(e)
        notFound=find(e==0);
        warning('Not all *.mat files required are found some are going to be re-run');
        for i=1:length(notFound)
            fprintf('running %s\n',em{notFound(i)});
            run(em{notFound(i)});
        end
        [e,em]=fileExists;
    end
    h=warndlg({'All of the code takes atleast 24hrs to run'},'Warning!');
    waitfor(h);
    choice=questdlg({'All the required *.mat files found!',...
        'Re-run the code?'},'code re-run','yes','no','no');
    if strcmp(choice,'yes')
        for i=1:length(em)
            fprintf('running %s\n',em{i});
            run(em{i})
        end
    end
    load('Aerial_daylightContrastRange.mat')
    load('Aquatic_daylightContrastRange.mat')
    load('imageContrastValues.mat')
    [contrastRange_River,C0RangeNew]=interpolateContrastRange(C0Range,visualRange_River);
    [contrastRange,C0RangeNew]=interpolateContrastRange(C0Range,visualRangeSolns); 
    
    linewidthdef=2;
%% FIND INTERSECTIONS
    visualRange.FishAquaticUp=contrastRange_River(:,1,1);
    visualRange.DigitAquaticUp=contrastRange_River(:,2,1);
    visualRange.FishAquaticHor=contrastRange_River(:,1,2);
    visualRange.DigitAquaticHor=contrastRange_River(:,2,2);
    visualRange.FishAerial=contrastRange(:,1);
    visualRange.DigitAerial=contrastRange(:,2);
    
    conditions={'FishAquaticUp','DigitAquaticUp','FishAquaticHor',...
        'DigitAquaticHor','FishAerial','DigitAerial'};
    contrastinter=[-0.3 -0.1 0.1 0.3];
    
    for i=1:length(conditions)
        func=@(x) interp1q(C0RangeNew,visualRange.(conditions{i}),x);
        for j=1:length(contrastinter)
            intersectval(j,i)=func(contrastinter(j));
        end
    end

%%  PLOT
    fig_props.noYsubplots = 1;
    fig_props.noXsubplots = 2;

    fig_props.figW = 22;   % cm
    fig_props.figH = 12;  % cm

    fig_props.ml = 2;
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

% Aquatic contrast plot 
    plotnoY=1;
    plotnoX=1;
    ha1=create_BE_axes(plotnoX,plotnoY,fig_props);
    
    hl11=line('XData',C0RangeNew,'YData',visualRange.FishAquaticUp,...
        'color',[0 0.4470 0.7410],'linewidth',linewidthdef);
    hold on;
    hl12=line('XData',C0RangeNew,'YData',visualRange.DigitAquaticUp,...
        'color',[0.85,0.325,0.098],'linewidth',linewidthdef);
    hl13=line('XData',C0RangeNew,'YData',visualRange.FishAquaticHor,...
        'color',[0 0.4470 0.7410],'linewidth',linewidthdef,'linestyle',':');
    hl14=line('XData',C0RangeNew,'YData',visualRange.DigitAquaticHor,...
        'color',[0.85,0.325,0.098],'linewidth',linewidthdef,'linestyle',':');
    for i=1:length(conditions)-2
        plot(contrastinter,intersectval(:,i),'o',...
            'markeredgecolor','k','markerfacecolor','k','markersize',5);
    end
    ylim([0 10]); ylim1=get(gca,'ylim');
    for i=1:length(contrastinter)
        line([contrastinter(i) contrastinter(i)],[ylim1(1) ylim1(2)],...
            'color','b','linestyle',':','linewidth',1.2);
    end
    xlabel('\bfcontrast','interpreter','tex',...
        'fontsize',12,'fontname','helvetica');
    ylabel('\bfvisual range (\itr) \rm\bf(m)','interpreter','tex',...
        'fontsize',12,'fontname','helvetica');
    x=2;
    text(x,(interp1q(C0RangeNew,visualRange.DigitAquaticUp,x)+0.9),...
        'upward,','interpreter','tex',...
        'fontsize',9,'fontname','helvetica');
    text(x,(interp1q(C0RangeNew,visualRange.DigitAquaticUp,x)+0.6),...
        'digited pupil diameter','interpreter','tex',...
        'fontsize',9,'fontname','helvetica');
    text(x,(interp1q(C0RangeNew,visualRange.FishAquaticUp,x)-0.2),...
        'upward,','interpreter','tex',...
        'fontsize',9,'fontname','helvetica');
    text(x,(interp1q(C0RangeNew,visualRange.FishAquaticUp,x)-0.5),...
        'finned pupil diameter','interpreter','tex',...
        'fontsize',9,'fontname','helvetica');
    
    text(x,(interp1q(C0RangeNew,visualRange.DigitAquaticHor,x)+0.8),...
        'horizontal,','interpreter','tex',...
        'fontsize',9,'fontname','helvetica');
    text(x,(interp1q(C0RangeNew,visualRange.DigitAquaticHor,x)+0.5),...
        'digited pupil diameter','interpreter','tex',...
        'fontsize',9,'fontname','helvetica');
    text(x,(interp1q(C0RangeNew,visualRange.FishAquaticHor,x)-0.2),...
        'horizontal,','interpreter','tex',...
        'fontsize',9,'fontname','helvetica');
    text(x,(interp1q(C0RangeNew,visualRange.FishAquaticHor,x)-0.5),...
        'finned pupil diameter','interpreter','tex',...
        'fontsize',9,'fontname','helvetica');
    annotation('textbox',...
        [0.091 0.2 0.03 0.05],...
        'String',{'-0.3'},...
        'LineStyle','none',...
        'FontSize',6,...
        'FitBoxToText','off',...
        'BackgroundColor',[1 1 1]);
    annotation('textbox',...
        [0.143 0.2 0.03 0.05],...
        'String',{'0.3'},...
        'LineStyle','none',...
        'FontSize',6,...
        'FitBoxToText','off',...
        'BackgroundColor',[1 1 1]);
    annotation('textbox',...
        [0.11 0.81 0.0278 0.038],...
        'String',{'-0.1'},...
        'FontSize',6,...
        'FitBoxToText','off',...
        'EdgeColor',[1 1 1],...
        'BackgroundColor',[1 1 1]);
    annotation('textbox',...
        [0.128 0.762 0.0278 0.0381],...
        'String','0.1',...
        'FontSize',6,...
        'FitBoxToText','off',...
        'EdgeColor',[1 1 1],...
        'BackgroundColor',[1 1 1]);

    axis square
% Aerial Contrast Plot
    plotnoX=2;
    plotnoY=1;
    ha2=create_BE_axes(plotnoX,plotnoY,fig_props);
    
    hl21=line('XData',C0RangeNew,'YData',visualRange.DigitAerial,...
        'color',[0 0.4470 0.7410],'linewidth',linewidthdef);
    hold on;
    hl22=line('XData',C0RangeNew,'YData',visualRange.FishAerial,...
        'color',[0.85,0.325,0.098],'linewidth',linewidthdef);
    for i=length(conditions)-1:length(conditions)
        plot(contrastinter,intersectval(:,i),'o',...
            'markeredgecolor','k','markerfacecolor','k','markersize',5);
    end
    ylim1=get(gca,'ylim');
    for i=1:length(contrastinter)
        line([contrastinter(i) contrastinter(i)],[ylim1(1) ylim1(2)],...
            'color','b','linestyle',':','linewidth',1.2);
    end
    xlabel('\bfcontrast','interpreter','tex',...
        'fontsize',12,'fontname','helvetica');
    ylabel('\bfvisual range (\itr) \rm\bf(m)','interpreter','tex',...
        'fontsize',12,'fontname','helvetica');
    x=1.5;
    text(x,(interp1q(C0RangeNew,visualRange.DigitAerial,x)+140),...
        'digited pupil diameter','interpreter','tex',...
        'fontsize',9,'fontname','helvetica');
    text(x,(interp1q(C0RangeNew,visualRange.FishAerial,x)+100),...
        'finned pupil diameter','interpreter','tex',...
        'fontsize',9,'fontname','helvetica');
    annotation('textbox',...
        [0.579 0.2 0.03 0.05],...      
        'String',{'-0.3'},...
        'LineStyle','none',...
        'FontSize',6,...
        'FitBoxToText','off',...
        'BackgroundColor',[1 1 1]);
    annotation('textbox',...
        [0.633 0.2 0.03 0.05],...
        'String',{'0.3'},...
        'LineStyle','none',...
        'FontSize',6,...
        'FitBoxToText','off',...
        'BackgroundColor',[1 1 1]);
    annotation('textbox',...
        [0.599 0.81 0.0278 0.0381],...
        'String',{'-0.1'},...
        'FontSize',6,...
        'FitBoxToText','off',...
        'EdgeColor',[1 1 1],...
        'BackgroundColor',[1 1 1]);
    annotation('textbox',...
        [0.618 0.762 0.0278 0.0381],...
        'String','0.1',...
        'FontSize',6,...
        'FitBoxToText','off',...
        'EdgeColor',[1 1 1],...
        'BackgroundColor',[1 1 1]);
    axis square
    
filename=[BIGEYEROOT 'figExt07_contrast/figures/core_figures/contrast_sensitivity.pdf'];
print(filename,'-painters','-dpdf','-r600');
function [e,em]=fileExists
    e1={exist('Aerial_daylightContrastRange.mat','file')==2,'Aerial_contrastRangeRelation.m'};
    e2={exist('Aquatic_daylightContrastRange.mat','file')==2, 'Aquatic_daylightContrastRange.m'};
    %e3={exist('imageContrastValues.mat','file')==2,'getBugContrast.m'};
    e=[e1{1} e2{1}];
    em={e1{2} e2{2}};
    
