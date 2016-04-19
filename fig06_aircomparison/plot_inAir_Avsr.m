close all;
clear all;
%% COMMENTS


load daylight.mat
load moonlight.mat
load starlight.mat
load terrestrial_Avsr.mat
load('constantDepth_rvsA')

pupilValues=pupilValues*10^3;
pupilValuesAir=pupilValuesAir*10^3;

fillboxalpha=0.07; % transparency of fillbox to show +/- std of pupil size

NORMDERIVATIVE=0;
DAYAERIAL=1;

load ../fig02_orbitsize/OM_TF_ST.mat

pupil_TF = [mean(OM_TF)-std(OM_TF) mean(OM_TF)+std(OM_TF)].*0.53;
pupil_ST = [mean(OM_ST)-std(OM_ST) mean(OM_ST)+std(OM_ST)].*0.53;

fishpupil=mean(OM_TF)*.53;
tetrapodpupil=mean(OM_ST)*.53;

linewidthDef=2;


%% PLOT ONLY AIR

air=figure();

subplot(2,2,1)
lined=plot(pupilValuesAir,visualRangeDaylight,'linewidth',linewidthDef);
hold on;
linem=plot(pupilValuesAir,visualRangeMoonlight,'linewidth',linewidthDef);
lines=plot(pupilValuesAir,visualRangeStarlight,'linewidth',linewidthDef);
xlabel('pupil diameter (mm)'); ylabel('visual range (m)')

subplot(2,2,2)
plot(pupilValuesAir,drdADaylight,'linewidth',linewidthDef)
hold on
plot(pupilValuesAir,drdAMoonlight,'linewidth',linewidthDef)
plot(pupilValuesAir,drdAStarlight,'linewidth',linewidthDef)
xlabel('pupil diameter (mm)'); ylabel('dr/dA');
box on

subplot(2,2,3)
plot(pupilValuesAir,visualVolumeDaylight,'linewidth',linewidthDef)
hold on
plot(pupilValuesAir,visualVolumeMoonlight,'linewidth',linewidthDef)
plot(pupilValuesAir,visualVolumeStarlight,'linewidth',linewidthDef)
xlabel('pupil diameter (mm)'); ylabel('visual volume (m^3)');

subplot(2,2,4)
plot(pupilValuesAir,dVdADaylight,'linewidth',linewidthDef);
hold on
plot(pupilValuesAir,dVdAMoonlight,'linewidth',linewidthDef);
plot(pupilValuesAir,dVdAStarlight,'linewidth',linewidthDef);
xlabel('pupil diameter (mm)'); ylabel('dV/dA');

hL = legend([lined,linem,lines],...
    {'daylight','moonlight','starlight'});

newPosition = [0.4 0.4 0.2 0.2];
newUnits = 'normalized';
set(hL,'Position', newPosition,'Units', newUnits,'Orientation','horizontal');

%% PLOT AIR VS WATER COMPARISON

% MderivativeRange=[drdAAir',...
%     derivativeVisualRange(1).up', derivativeVisualRange(2).up',...
%     derivativeVisualRange(1).hor',derivativeVisualRange(2).hor'];
%
% NderivativeRange=(MderivativeRange-min(min(MderivativeRange)))...
%     /(max(max(MderivativeRange))-min(min(MderivativeRange)));

comparison=figure();
rvsA=subplot(2,2,1);
line1=plot(pupilValuesAir,visualRangeDaylight,'linewidth',linewidthDef);
hold on;
line2=plot(pupilValuesAir,visualRangeMoonlight,'linewidth',linewidthDef);
line3=plot(pupilValuesAir,visualRangeStarlight,'linewidth',linewidthDef);
line4=plot(pupilValues,visualRangeSolutions(1).up,'--','linewidth',linewidthDef);
line5=plot(pupilValues,visualRangeSolutions(2).up,'--','linewidth',linewidthDef);
line6=plot(pupilValues,visualRangeSolutions(1).hor,':','linewidth',linewidthDef);
line7=plot(pupilValues,visualRangeSolutions(2).hor,':','linewidth',linewidthDef);
xlabel('pupil diameter (mm)'); ylabel('visual range (m)');
yrange=get(rvsA,'YLim');
line([fishpupil fishpupil],[yrange(1) yrange(2)],'Color',[0 0 0],...
    'linestyle',':','linewidth',linewidthDef)
line([tetrapodpupil,tetrapodpupil],[yrange(1) yrange(2)],'Color',[0/255,128/255,128/255],...
    'linestyle',':','linewidth',linewidthDef)
yminmax=get(gca,'ylim');
if( DAYAERIAL)
    dumAerial=[visualRangeMoonlight' visualRangeStarlight'];
    dumCoastal=[visualRangeSolutions(1).up' visualRangeSolutions(2).up'...
        visualRangeSolutions(1).hor' visualRangeSolutions(2).hor'];
    ymin=yminmax(1);
    ymax=max([max(max(dumAerial)) max(max(dumCoastal))]);
    ylim([ymin ymax]); yminmax=[ymin ymax];    
end
hold on
fillboxTF = patch([pupil_TF(1) pupil_TF(1) pupil_TF(2) pupil_TF(2)], ...
    [yminmax(1) yminmax(2) yminmax(2) yminmax(1)],[1 0 0]);

set(fillboxTF,'facealpha',fillboxalpha,'edgecolor','none');

fillboxST = patch([pupil_ST(1) pupil_ST(1) pupil_ST(2) pupil_ST(2)], ...
    [yminmax(1) yminmax(2) yminmax(2) yminmax(1)],[0 0 1]);

set(fillboxST,'facealpha',fillboxalpha,'edgecolor','none');

drdAvsA=subplot(2,2,2);
yminmax=get(gca,'ylim');
hold on
fillboxTF = patch([pupil_TF(1) pupil_TF(1) pupil_TF(2) pupil_TF(2)], ...
    [yminmax(1) yminmax(2) yminmax(2) yminmax(1)],[1 0 0]);

set(fillboxTF,'facealpha',fillboxalpha,'edgecolor','none');

fillboxST = patch([pupil_ST(1) pupil_ST(1) pupil_ST(2) pupil_ST(2)], ...
    [yminmax(1) yminmax(2) yminmax(2) yminmax(1)],[0 0 1]);

set(fillboxST,'facealpha',fillboxalpha,'edgecolor','none');
box on

if(NORMDERIVATIVE)
    plot(pupilValuesAir,NderivativeRange(:,1));
    hold on;
    plot(pupilValues,NderivativeRange(:,2),'--');
    plot(pupilValues,NderivativeRange(:,3),'--');
    plot(pupilValues,NderivativeRange(:,4),':');
    plot(pupilValues,NderivativeRange(:,5),':');
    
else
    plot(pupilValuesAir,drdADaylight,'linewidth',linewidthDef);
    hold on;
    plot(pupilValuesAir,drdAMoonlight,'linewidth',linewidthDef)
    plot(pupilValuesAir,drdAStarlight,'linewidth',linewidthDef)
    plot(pupilValues,derivativeVisualRange(1).up,'--','linewidth',linewidthDef);
    plot(pupilValues,derivativeVisualRange(2).up,'--','linewidth',linewidthDef);
    plot(pupilValues,derivativeVisualRange(1).hor,':','linewidth',linewidthDef);
    plot(pupilValues,derivativeVisualRange(2).hor,':','linewidth',linewidthDef);
    
    if( DAYAERIAL)
        dumAerial=[drdAMoonlight' drdAStarlight'];
        dumCoastal=[derivativeVisualRange(1).up' derivativeVisualRange(2).up'...
            derivativeVisualRange(1).hor' derivativeVisualRange(2).hor'];
        ymin=yminmax(1);
        ymax=max([max(max(dumAerial)) max(max(dumCoastal))]);
        ylim([ymin ymax]); yminmax=[ymin ymax];    
    end
    
    yminmax=get(gca,'ylim');
    hold on
    fillboxTF = patch([pupil_TF(1) pupil_TF(1) pupil_TF(2) pupil_TF(2)], ...
        [yminmax(1) yminmax(2) yminmax(2) yminmax(1)],[1 0 0]);
    
    set(fillboxTF,'facealpha',fillboxalpha,'edgecolor','none');
    
    fillboxST = patch([pupil_ST(1) pupil_ST(1) pupil_ST(2) pupil_ST(2)], ...
        [yminmax(1) yminmax(2) yminmax(2) yminmax(1)],[0 0 1]);
    
    set(fillboxST,'facealpha',fillboxalpha,'edgecolor','none');
    
end
yrange2=get(drdAvsA,'YLim');
line([fishpupil fishpupil],[yrange2(1) yrange2(2)],'Color',[0 0 0],...
    'linestyle',':','linewidth',linewidthDef)
line([tetrapodpupil,tetrapodpupil],[yrange2(1) yrange2(2)],'Color',[0/255,128/255,128/255],...
    'linestyle',':','linewidth',linewidthDef)
xlabel('pupil diameter (mm)'); ylabel('dr/dA (m/mm)');
%
% MderivativeVolume=[dVdAAir',...
%     derivativeVisualVolume(1).up', derivativeVisualVolume(2).up',...
%     derivativeVisualVolume(1).hor', derivativeVisualVolume(2).hor'];
%
% NderivativeVolume=(MderivativeVolume-min(min(MderivativeVolume)))...
%     /(max(max(MderivativeVolume))-min(min(MderivativeVolume)));

VvsA=subplot(2,2,3);
plot(pupilValuesAir,visualVolumeDaylight,'linewidth',linewidthDef);
hold on;
plot(pupilValuesAir,visualVolumeMoonlight,'linewidth',linewidthDef)
plot(pupilValuesAir,visualVolumeStarlight,'linewidth',linewidthDef)
plot(pupilValues,visualVolumeSolutions(1).up,'--','linewidth',linewidthDef);
plot(pupilValues,visualVolumeSolutions(2).up,'--','linewidth',linewidthDef);
plot(pupilValues,visualVolumeSolutions(1).hor,':','linewidth',linewidthDef);
plot(pupilValues,visualVolumeSolutions(2).hor,':','linewidth',linewidthDef);
xlabel('pupil diameter (mm)'); ylabel('visual volume (m^3)');
yrange3=get(VvsA,'YLim');
line([fishpupil fishpupil],[yrange3(1) yrange3(2)],'Color',[0 0 0],...
    'linestyle',':','linewidth',linewidthDef)
line([tetrapodpupil,tetrapodpupil],[yrange3(1) yrange3(2)],'Color',[0/255,128/255,128/255],...
    'linestyle',':','linewidth',linewidthDef)


yminmax=get(gca,'ylim');

if( DAYAERIAL)
    dumAerial=[visualVolumeMoonlight' visualVolumeStarlight'];
    dumCoastal=[visualVolumeSolutions(1).up' visualVolumeSolutions(2).up'...
        visualVolumeSolutions(1).hor' visualVolumeSolutions(2).hor'];
    ymin=yminmax(1);
    ymax=max([max(max(dumAerial)) max(max(dumCoastal))]);
    ylim([ymin ymax]); yminmax=[ymin ymax];    
end
hold on
fillboxTF = patch([pupil_TF(1) pupil_TF(1) pupil_TF(2) pupil_TF(2)], ...
    [yminmax(1) yminmax(2) yminmax(2) yminmax(1)],[1 0 0]);

set(fillboxTF,'facealpha',fillboxalpha,'edgecolor','none')

fillboxST = patch([pupil_ST(1) pupil_ST(1) pupil_ST(2) pupil_ST(2)], ...
    [yminmax(1) yminmax(2) yminmax(2) yminmax(1)],[0 0 1]);

set(fillboxST,'facealpha',fillboxalpha,'edgecolor','none')

dVdAvsA=subplot(2,2,4);
if(NORMDERIVATIVE)
    plot(pupilValuesAir,NderivativeVolume(:,1));
    hold on;
    plot(pupilValues,NderivativeVolume(:,2),'--');
    plot(pupilValues,NderivativeVolume(:,3),'--');
    plot(pupilValues,NderivativeVolume(:,4),':');
    plot(pupilValues,NderivativeVolume(:,5),':');
else
    plot(pupilValuesAir,dVdADaylight,'linewidth',linewidthDef);
    hold on;
    plot(pupilValuesAir,dVdAMoonlight,'linewidth',linewidthDef);
    plot(pupilValuesAir,dVdAStarlight,'linewidth',linewidthDef);
    plot(pupilValues,derivativeVisualVolume(1).up,'--','linewidth',linewidthDef);
    plot(pupilValues,derivativeVisualVolume(2).up,'--','linewidth',linewidthDef);
    plot(pupilValues,derivativeVisualVolume(1).hor,':','linewidth',linewidthDef);
    plot(pupilValues,derivativeVisualVolume(2).hor,':','linewidth',linewidthDef);
    
    if( DAYAERIAL)
        dumAerial=[dVdAMoonlight' dVdAStarlight'];
        dumCoastal=[derivativeVisualVolume(1).up' derivativeVisualVolume(2).up'...
            derivativeVisualVolume(1).hor' derivativeVisualVolume(2).hor'];
        ymin=yminmax(1);
        ymax=max([max(max(dumAerial)) max(max(dumCoastal))]);
        ylim([ymin ymax]); yminmax=[ymin ymax];    
    end
    yminmax=get(gca,'ylim');
    hold on
    fillboxTF = patch([pupil_TF(1) pupil_TF(1) pupil_TF(2) pupil_TF(2)], ...
        [yminmax(1) yminmax(2) yminmax(2) yminmax(1)],[1 0 0]);
    
    set(fillboxTF,'facealpha',fillboxalpha,'edgecolor','none')
    
    fillboxST = patch([pupil_ST(1) pupil_ST(1) pupil_ST(2) pupil_ST(2)], ...
        [yminmax(1) yminmax(2) yminmax(2) yminmax(1)],[0 0 1]);
    
    set(fillboxST,'facealpha',fillboxalpha,'edgecolor','none')
end
yrange4=get(dVdAvsA,'YLim');
line([fishpupil fishpupil],[yrange4(1) yrange4(2)],'Color',[0 0 0],...
    'linestyle',':','linewidth',linewidthDef)
line([tetrapodpupil,tetrapodpupil],[yrange4(1) yrange4(2)],'Color',[0/255,128/255,128/255],...
    'linestyle',':','linewidth',linewidthDef)
xlabel('pupil diameter (mm)'); ylabel('dV/dA (m^3/mm)');

hL = legend([line1,line2,line3,line4,line5,line6,line7],...
    {'daylight','moonlight','starlight','100m, up','10m, up','100m, hor','10m, hor'});

newPosition = [0.4 0.4 0.2 0.2];
newUnits = 'normalized';
set(hL,'Position', newPosition,'Units', newUnits,'Orientation','horizontal');

%% LOG PLOTS

logplots=figure();

logrvsA=subplot(2,2,1);
line8=semilogy(pupilValuesAir,visualRangeDaylight,'linewidth',linewidthDef);
hold on;
line9=semilogy(pupilValuesAir,visualRangeMoonlight,'linewidth',linewidthDef);
line10=semilogy(pupilValuesAir,visualRangeStarlight,'linewidth',linewidthDef);
line11=semilogy(pupilValues,visualRangeSolutions(1).up,'--','linewidth',linewidthDef);
line12=semilogy(pupilValues,visualRangeSolutions(2).up,'--','linewidth',linewidthDef);
line13=semilogy(pupilValues,visualRangeSolutions(1).hor,':','linewidth',linewidthDef);
line14=semilogy(pupilValues,visualRangeSolutions(2).hor,':','linewidth',linewidthDef);
yrange5=get(logrvsA,'YLim');
line([fishpupil fishpupil],[yrange5(1) yrange5(2)],'Color',[0 0 0],...
    'linestyle',':','linewidth',linewidthDef)
line([tetrapodpupil,tetrapodpupil],[yrange5(1) yrange5(2)],'Color',[0/255,128/255,128/255],...
    'linestyle',':','linewidth',linewidthDef)
xlabel('pupil diameter (mm)'); ylabel('visual range (m)');


yminmax=get(gca,'ylim');
hold on
fillboxTF = patch([pupil_TF(1) pupil_TF(1) pupil_TF(2) pupil_TF(2)], ...
    [yminmax(1) yminmax(2) yminmax(2) yminmax(1)],[1 0 0]);

set(fillboxTF,'facealpha',fillboxalpha,'edgecolor','none')

fillboxST = patch([pupil_ST(1) pupil_ST(1) pupil_ST(2) pupil_ST(2)], ...
    [yminmax(1) yminmax(2) yminmax(2) yminmax(1)],[0 0 1]);

set(fillboxST,'facealpha',fillboxalpha,'edgecolor','none')

logVvsA=subplot(2,2,3);
semilogy(pupilValuesAir,visualVolumeDaylight,'linewidth',linewidthDef);
hold on;
semilogy(pupilValuesAir,visualVolumeMoonlight,'linewidth',linewidthDef);
semilogy(pupilValuesAir,visualVolumeStarlight,'linewidth',linewidthDef);
semilogy(pupilValues,visualVolumeSolutions(1).up,'--','linewidth',linewidthDef);
semilogy(pupilValues,visualVolumeSolutions(2).up,'--','linewidth',linewidthDef);
semilogy(pupilValues,visualVolumeSolutions(1).hor,':','linewidth',linewidthDef);
semilogy(pupilValues,visualVolumeSolutions(2).hor,':','linewidth',linewidthDef);
yrange6=get(logVvsA,'YLim');
line([fishpupil fishpupil],[yrange6(1) yrange6(2)],'Color',[0 0 0],...
    'linestyle',':','linewidth',linewidthDef)
line([tetrapodpupil,tetrapodpupil],[yrange6(1) yrange6(2)],'Color',[0/255,128/255,128/255],...
    'linestyle',':','linewidth',linewidthDef)
xlabel('pupil diameter (mm)'); ylabel('visual volume (m^3)');


yminmax=get(gca,'ylim');
hold on
fillboxTF = patch([pupil_TF(1) pupil_TF(1) pupil_TF(2) pupil_TF(2)], ...
    [yminmax(1) yminmax(2) yminmax(2) yminmax(1)],[1 0 0]);

set(fillboxTF,'facealpha',fillboxalpha,'edgecolor','none')

fillboxST = patch([pupil_ST(1) pupil_ST(1) pupil_ST(2) pupil_ST(2)], ...
    [yminmax(1) yminmax(2) yminmax(2) yminmax(1)],[0 0 1]);

set(fillboxST,'facealpha',fillboxalpha,'edgecolor','none')

logdrdAvsA=subplot(2,2,2);
if(NORMDERIVATIVE)
    semilogy(pupilValuesAir,NderivativeRange(:,1));
    hold on;
    semilogy(pupilValues,NderivativeRange(:,2),'--');
    semilogy(pupilValues,NderivativeRange(:,3),'--');
    semilogy(pupilValues,NderivativeRange(:,4),':');
    semilogy(pupilValues,NderivativeRange(:,5),':');
    
else
    semilogy(pupilValuesAir,drdADaylight,'linewidth',linewidthDef);
    hold on;
    semilogy(pupilValuesAir,drdAMoonlight,'linewidth',linewidthDef);
    semilogy(pupilValuesAir,drdAStarlight,'linewidth',linewidthDef);
    semilogy(pupilValues,derivativeVisualRange(1).up,'--','linewidth',linewidthDef);
    semilogy(pupilValues,derivativeVisualRange(2).up,'--','linewidth',linewidthDef);
    semilogy(pupilValues,derivativeVisualRange(1).hor,':','linewidth',linewidthDef);
    semilogy(pupilValues,derivativeVisualRange(2).hor,':','linewidth',linewidthDef);
    
    
    yminmax=get(gca,'ylim');
    hold on
    fillboxTF = patch([pupil_TF(1) pupil_TF(1) pupil_TF(2) pupil_TF(2)], ...
        [yminmax(1) yminmax(2) yminmax(2) yminmax(1)],[1 0 0]);
    
    set(fillboxTF,'facealpha',fillboxalpha,'edgecolor','none')
    
    fillboxST = patch([pupil_ST(1) pupil_ST(1) pupil_ST(2) pupil_ST(2)], ...
        [yminmax(1) yminmax(2) yminmax(2) yminmax(1)],[0 0 1]);
    
    set(fillboxST,'facealpha',fillboxalpha,'edgecolor','none')
    
end
yrange7=get(logdrdAvsA,'YLim');
line([fishpupil fishpupil],[yrange7(1) yrange7(2)],'Color',[0 0 0],...
    'linestyle',':','linewidth',linewidthDef)
line([tetrapodpupil,tetrapodpupil],[yrange7(1) yrange7(2)],'Color',[0/255,128/255,128/255],...
    'linestyle',':','linewidth',linewidthDef)
xlabel('pupil diameter (mm)'); ylabel('dr/dA (m/mm)');

logdVdAvsA=subplot(2,2,4);
if(NORMDERIVATIVE)
    semilogy(pupilValuesAir,NderivativeVolume(:,1));
    hold on;
    semilogy(pupilValues,NderivativeVolume(:,2),'--');
    semilogy(pupilValues,NderivativeVolume(:,3),'--');
    semilogy(pupilValues,NderivativeVolume(:,4),':');
    semilogy(pupilValues,NderivativeVolume(:,5),':');
else
    semilogy(pupilValuesAir,dVdADaylight,'linewidth',linewidthDef);
    hold on;
    semilogy(pupilValuesAir,dVdAMoonlight,'linewidth',linewidthDef);
    semilogy(pupilValuesAir,dVdAStarlight,'linewidth',linewidthDef);
    semilogy(pupilValues,derivativeVisualVolume(1).up,'--','linewidth',linewidthDef);
    semilogy(pupilValues,derivativeVisualVolume(2).up,'--','linewidth',linewidthDef);
    semilogy(pupilValues,derivativeVisualVolume(1).hor,':','linewidth',linewidthDef);
    semilogy(pupilValues,derivativeVisualVolume(2).hor,':','linewidth',linewidthDef);
    
    % plot the 1st and 3rd quartile range for TF and ST pupils
    
    yminmax=get(gca,'ylim');
    hold on
    fillboxTF = patch([pupil_TF(1) pupil_TF(1) pupil_TF(2) pupil_TF(2)], ...
        [yminmax(1) yminmax(2) yminmax(2) yminmax(1)],[1 0 0]);
    
    set(fillboxTF,'facealpha',fillboxalpha,'edgecolor','none')
    
    fillboxST = patch([pupil_ST(1) pupil_ST(1) pupil_ST(2) pupil_ST(2)], ...
        [yminmax(1) yminmax(2) yminmax(2) yminmax(1)],[0 0 1]);
    
    set(fillboxST,'facealpha',fillboxalpha,'edgecolor','none')
    
end
yrange8=get(logdVdAvsA,'YLim');
line([fishpupil fishpupil],[yrange8(1) yrange8(2)],'Color',[0 0 0],...
    'linestyle',':','linewidth',linewidthDef)
line([tetrapodpupil,tetrapodpupil],[yrange8(1) yrange8(2)],'Color',[0/255,128/255,128/255],...
    'linestyle',':','linewidth',linewidthDef)
xlabel('pupil diameter (mm)'); ylabel('dV/dA (m^3/mm)');


hL = legend([line8,line9,line10,line11,line12,line13,line14],...
    {'daylight','moonlight','starlight','100m, up','10m, up','100m, hor','10m, hor'});

newPosition = [0.4 0.4 0.2 0.2];
newUnits = 'normalized';
set(hL,'Position', newPosition,'Units', newUnits,'Orientation','horizontal');

figure(2)
print -dpdf 'linearRangeDeriv'

figure(3)
print -dpdf 'logRangeDeriv'
