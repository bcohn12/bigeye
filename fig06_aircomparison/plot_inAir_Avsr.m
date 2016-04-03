close all;
clear all;

load('inAir_Avsr')
load('constantDepth_rvsA')

warning('If any of the bounds or parameters are changed re run the functions that are loaded')

pupilValues=pupilValues*10^3;
pupilValuesAir=pupilValuesAir*10^3;

NORMDERIVATIVE=0;

load ../fig02_orbitsize/OM_TF_ST.mat

pupil_TF = [prctile(OM_TF,25) prctile(OM_TF,75)].*0.53;
pupil_ST = [prctile(OM_ST,25) prctile(OM_ST,75)].*0.53;

fishpupil=prctile(OM_TF,50)*.53;
tetrapodpupil=prctile(OM_ST,50)*.53;

%% PLOT ONLY AIR

air=figure();

subplot(2,2,1)
lined=plot(pupilValuesAir,visualRangeDaylight);
hold on;
linem=plot(pupilValuesAir,visualRangeMoonlight);
lines=plot(pupilValuesAir,visualRangeStarlight);
xlabel('pupil diameter (mm)'); ylabel('visual range (m)')

subplot(2,2,2)
plot(pupilValuesAir,drdADaylight)
hold on
plot(pupilValuesAir,drdAMoonlight)
plot(pupilValuesAir,drdAStarlight)
xlabel('pupil diameter (mm)'); ylabel('dr/dA');
box on

subplot(2,2,3)
plot(pupilValuesAir,visualVolumeDaylight)
hold on
plot(pupilValuesAir,visualVolumeMoonlight)
plot(pupilValuesAir,visualVolumeStarlight)
xlabel('pupil diameter (mm)'); ylabel('visual volume (m^3)');

subplot(2,2,4)
plot(pupilValuesAir,dVdADaylight);
hold on
plot(pupilValuesAir,dVdAMoonlight);
plot(pupilValuesAir,dVdAStarlight);
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
line1=plot(pupilValuesAir,visualRangeDaylight);
hold on;
line2=plot(pupilValuesAir,visualRangeMoonlight);
line3=plot(pupilValuesAir,visualRangeStarlight);
line4=plot(pupilValues,visualRangeSolutions(1).up,'--');
line5=plot(pupilValues,visualRangeSolutions(2).up,'--');
line6=plot(pupilValues,visualRangeSolutions(1).hor,':');
line7=plot(pupilValues,visualRangeSolutions(2).hor,':');
xlabel('pupil diameter (mm)'); ylabel('visual range (m)');
yrange=get(rvsA,'YLim');
line([fishpupil fishpupil],[yrange(1) yrange(2)],'Color',[0 0 0],...
    'linestyle',':','linewidth',1)
line([tetrapodpupil,tetrapodpupil],[yrange(1) yrange(2)],'Color',[0/255,128/255,128/255],...
    'linestyle',':','linewidth',1)


yminmax=get(gca,'ylim');
hold on
fillboxTF = patch([pupil_TF(1) pupil_TF(1) pupil_TF(2) pupil_TF(2)], ...
    [yminmax(1) yminmax(2) yminmax(2) yminmax(1)],[1 0 0]);

set(fillboxTF,'facealpha',0.2,'edgecolor','none');

fillboxST = patch([pupil_ST(1) pupil_ST(1) pupil_ST(2) pupil_ST(2)], ...
    [yminmax(1) yminmax(2) yminmax(2) yminmax(1)],[0 0 1]);

set(fillboxST,'facealpha',0.2,'edgecolor','none');

drdAvsA=subplot(2,2,2);
yminmax=get(gca,'ylim');
hold on
fillboxTF = patch([pupil_TF(1) pupil_TF(1) pupil_TF(2) pupil_TF(2)], ...
    [yminmax(1) yminmax(2) yminmax(2) yminmax(1)],[1 0 0]);

set(fillboxTF,'facealpha',0.2,'edgecolor','none');

fillboxST = patch([pupil_ST(1) pupil_ST(1) pupil_ST(2) pupil_ST(2)], ...
    [yminmax(1) yminmax(2) yminmax(2) yminmax(1)],[0 0 1]);

set(fillboxST,'facealpha',0.2,'edgecolor','none');
box on

if(NORMDERIVATIVE)
    plot(pupilValuesAir,NderivativeRange(:,1));
    hold on;
    plot(pupilValues,NderivativeRange(:,2),'--');
    plot(pupilValues,NderivativeRange(:,3),'--');
    plot(pupilValues,NderivativeRange(:,4),':');
    plot(pupilValues,NderivativeRange(:,5),':');
    
else
    plot(pupilValuesAir,drdADaylight);
    hold on;
    plot(pupilValuesAir,drdAMoonlight)
    plot(pupilValuesAir,drdAStarlight)
    plot(pupilValues,derivativeVisualRange(1).up,'--');
    plot(pupilValues,derivativeVisualRange(2).up,'--');
    plot(pupilValues,derivativeVisualRange(1).hor,':');
    plot(pupilValues,derivativeVisualRange(2).hor,':');
    
    
    yminmax=get(gca,'ylim');
    hold on
    fillboxTF = patch([pupil_TF(1) pupil_TF(1) pupil_TF(2) pupil_TF(2)], ...
        [yminmax(1) yminmax(2) yminmax(2) yminmax(1)],[1 0 0]);
    
    set(fillboxTF,'facealpha',0.2,'edgecolor','none');
    
    fillboxST = patch([pupil_ST(1) pupil_ST(1) pupil_ST(2) pupil_ST(2)], ...
        [yminmax(1) yminmax(2) yminmax(2) yminmax(1)],[0 0 1]);
    
    set(fillboxST,'facealpha',0.2,'edgecolor','none');
    
end
yrange2=get(drdAvsA,'YLim');
line([fishpupil fishpupil],[yrange2(1) yrange2(2)],'Color',[0 0 0],...
    'linestyle',':','linewidth',1)
line([tetrapodpupil,tetrapodpupil],[yrange2(1) yrange2(2)],'Color',[0/255,128/255,128/255],...
    'linestyle',':','linewidth',1)
xlabel('pupil diameter (mm)'); ylabel('dr/dA (m/mm)');
%
% MderivativeVolume=[dVdAAir',...
%     derivativeVisualVolume(1).up', derivativeVisualVolume(2).up',...
%     derivativeVisualVolume(1).hor', derivativeVisualVolume(2).hor'];
%
% NderivativeVolume=(MderivativeVolume-min(min(MderivativeVolume)))...
%     /(max(max(MderivativeVolume))-min(min(MderivativeVolume)));

VvsA=subplot(2,2,3);
plot(pupilValuesAir,visualVolumeDaylight);
hold on;
plot(pupilValuesAir,visualVolumeMoonlight)
plot(pupilValuesAir,visualVolumeStarlight)
plot(pupilValues,visualVolumeSolutions(1).up,'--');
plot(pupilValues,visualVolumeSolutions(2).up,'--');
plot(pupilValues,visualVolumeSolutions(1).hor,':');
plot(pupilValues,visualVolumeSolutions(2).hor,':');
xlabel('pupil diameter (mm)'); ylabel('visual volume (m^3)');
yrange3=get(VvsA,'YLim');
line([fishpupil fishpupil],[yrange3(1) yrange3(2)],'Color',[0 0 0],...
    'linestyle',':','linewidth',1)
line([tetrapodpupil,tetrapodpupil],[yrange3(1) yrange3(2)],'Color',[0/255,128/255,128/255],...
    'linestyle',':','linewidth',1)


yminmax=get(gca,'ylim');
hold on
fillboxTF = patch([pupil_TF(1) pupil_TF(1) pupil_TF(2) pupil_TF(2)], ...
    [yminmax(1) yminmax(2) yminmax(2) yminmax(1)],[1 0 0]);

set(fillboxTF,'facealpha',0.2,'edgecolor','none')

fillboxST = patch([pupil_ST(1) pupil_ST(1) pupil_ST(2) pupil_ST(2)], ...
    [yminmax(1) yminmax(2) yminmax(2) yminmax(1)],[0 0 1]);

set(fillboxST,'facealpha',0.2,'edgecolor','none')

dVdAvsA=subplot(2,2,4);
if(NORMDERIVATIVE)
    plot(pupilValuesAir,NderivativeVolume(:,1));
    hold on;
    plot(pupilValues,NderivativeVolume(:,2),'--');
    plot(pupilValues,NderivativeVolume(:,3),'--');
    plot(pupilValues,NderivativeVolume(:,4),':');
    plot(pupilValues,NderivativeVolume(:,5),':');
else
    plot(pupilValuesAir,dVdADaylight);
    hold on;
    plot(pupilValuesAir,dVdAMoonlight);
    plot(pupilValuesAir,dVdAStarlight);
    plot(pupilValues,derivativeVisualVolume(1).up,'--');
    plot(pupilValues,derivativeVisualVolume(2).up,'--');
    plot(pupilValues,derivativeVisualVolume(1).hor,':');
    plot(pupilValues,derivativeVisualVolume(2).hor,':');
    
    
    yminmax=get(gca,'ylim');
    hold on
    fillboxTF = patch([pupil_TF(1) pupil_TF(1) pupil_TF(2) pupil_TF(2)], ...
        [yminmax(1) yminmax(2) yminmax(2) yminmax(1)],[1 0 0]);
    
    set(fillboxTF,'facealpha',0.2,'edgecolor','none')
    
    fillboxST = patch([pupil_ST(1) pupil_ST(1) pupil_ST(2) pupil_ST(2)], ...
        [yminmax(1) yminmax(2) yminmax(2) yminmax(1)],[0 0 1]);
    
    set(fillboxST,'facealpha',0.2,'edgecolor','none')
end
yrange4=get(dVdAvsA,'YLim');
line([fishpupil fishpupil],[yrange4(1) yrange4(2)],'Color',[0 0 0],...
    'linestyle',':','linewidth',1)
line([tetrapodpupil,tetrapodpupil],[yrange4(1) yrange4(2)],'Color',[0/255,128/255,128/255],...
    'linestyle',':','linewidth',1)
xlabel('pupil diameter (mm)'); ylabel('dV/dA (m^3/mm)');

hL = legend([line1,line2,line3,line4,line5,line6,line7],...
    {'daylight','moonlight','starlight','100m, up','10m, up','100m, hor','10m, hor'});

newPosition = [0.4 0.4 0.2 0.2];
newUnits = 'normalized';
set(hL,'Position', newPosition,'Units', newUnits,'Orientation','horizontal');

%% LOG PLOTS

logplots=figure();

logrvsA=subplot(2,2,1);
line8=semilogy(pupilValuesAir,visualRangeDaylight);
hold on;
line9=semilogy(pupilValuesAir,visualRangeMoonlight);
line10=semilogy(pupilValuesAir,visualRangeStarlight);
line11=semilogy(pupilValues,visualRangeSolutions(1).up,'--');
line12=semilogy(pupilValues,visualRangeSolutions(2).up,'--');
line13=semilogy(pupilValues,visualRangeSolutions(1).hor,':');
line14=semilogy(pupilValues,visualRangeSolutions(2).hor,':');
yrange5=get(logrvsA,'YLim');
line([fishpupil fishpupil],[yrange5(1) yrange5(2)],'Color',[0 0 0],...
    'linestyle',':','linewidth',1)
line([tetrapodpupil,tetrapodpupil],[yrange5(1) yrange5(2)],'Color',[0/255,128/255,128/255],...
    'linestyle',':','linewidth',1)
xlabel('pupil diameter (mm)'); ylabel('log(visual range) (m)');


yminmax=get(gca,'ylim');
hold on
fillboxTF = patch([pupil_TF(1) pupil_TF(1) pupil_TF(2) pupil_TF(2)], ...
    [yminmax(1) yminmax(2) yminmax(2) yminmax(1)],[1 0 0]);

set(fillboxTF,'facealpha',0.2,'edgecolor','none')

fillboxST = patch([pupil_ST(1) pupil_ST(1) pupil_ST(2) pupil_ST(2)], ...
    [yminmax(1) yminmax(2) yminmax(2) yminmax(1)],[0 0 1]);

set(fillboxST,'facealpha',0.2,'edgecolor','none')

logVvsA=subplot(2,2,2);
semilogy(pupilValuesAir,visualVolumeDaylight);
hold on;
semilogy(pupilValuesAir,visualVolumeMoonlight);
semilogy(pupilValuesAir,visualVolumeStarlight);
semilogy(pupilValues,visualVolumeSolutions(1).up,'--');
semilogy(pupilValues,visualVolumeSolutions(2).up,'--');
semilogy(pupilValues,visualVolumeSolutions(1).hor,':');
semilogy(pupilValues,visualVolumeSolutions(2).hor,':');
yrange6=get(logVvsA,'YLim');
line([fishpupil fishpupil],[yrange6(1) yrange6(2)],'Color',[0 0 0],...
    'linestyle',':','linewidth',1)
line([tetrapodpupil,tetrapodpupil],[yrange6(1) yrange6(2)],'Color',[0/255,128/255,128/255],...
    'linestyle',':','linewidth',1)
xlabel('pupil diameter (mm)'); ylabel('log(visual volume) (m^3)');


yminmax=get(gca,'ylim');
hold on
fillboxTF = patch([pupil_TF(1) pupil_TF(1) pupil_TF(2) pupil_TF(2)], ...
    [yminmax(1) yminmax(2) yminmax(2) yminmax(1)],[1 0 0])

set(fillboxTF,'facealpha',0.2,'edgecolor','none')

fillboxST = patch([pupil_ST(1) pupil_ST(1) pupil_ST(2) pupil_ST(2)], ...
    [yminmax(1) yminmax(2) yminmax(2) yminmax(1)],[0 0 1])

set(fillboxST,'facealpha',0.2,'edgecolor','none')

logdrdAvsA=subplot(2,2,3);
if(NORMDERIVATIVE)
    semilogy(pupilValuesAir,NderivativeRange(:,1));
    hold on;
    semilogy(pupilValues,NderivativeRange(:,2),'--');
    semilogy(pupilValues,NderivativeRange(:,3),'--');
    semilogy(pupilValues,NderivativeRange(:,4),':');
    semilogy(pupilValues,NderivativeRange(:,5),':');
    
else
    semilogy(pupilValuesAir,drdADaylight);
    hold on;
    semilogy(pupilValuesAir,drdAMoonlight);
    semilogy(pupilValuesAir,drdAStarlight);
    semilogy(pupilValues,derivativeVisualRange(1).up,'--');
    semilogy(pupilValues,derivativeVisualRange(2).up,'--');
    semilogy(pupilValues,derivativeVisualRange(1).hor,':');
    semilogy(pupilValues,derivativeVisualRange(2).hor,':');
    
    
    yminmax=get(gca,'ylim');
    hold on
    fillboxTF = patch([pupil_TF(1) pupil_TF(1) pupil_TF(2) pupil_TF(2)], ...
        [yminmax(1) yminmax(2) yminmax(2) yminmax(1)],[1 0 0]);
    
    set(fillboxTF,'facealpha',0.2,'edgecolor','none')
    
    fillboxST = patch([pupil_ST(1) pupil_ST(1) pupil_ST(2) pupil_ST(2)], ...
        [yminmax(1) yminmax(2) yminmax(2) yminmax(1)],[0 0 1]);
    
    set(fillboxST,'facealpha',0.2,'edgecolor','none')
    
end
yrange7=get(logdrdAvsA,'YLim');
line([fishpupil fishpupil],[yrange7(1) yrange7(2)],'Color',[0 0 0],...
    'linestyle',':','linewidth',1)
line([tetrapodpupil,tetrapodpupil],[yrange7(1) yrange7(2)],'Color',[0/255,128/255,128/255],...
    'linestyle',':','linewidth',1)
xlabel('pupil diameter (mm)'); ylabel('log(dr/dA) (m/mm)');

logdVdAvsA=subplot(2,2,4);
if(NORMDERIVATIVE)
    semilogy(pupilValuesAir,NderivativeVolume(:,1));
    hold on;
    semilogy(pupilValues,NderivativeVolume(:,2),'--');
    semilogy(pupilValues,NderivativeVolume(:,3),'--');
    semilogy(pupilValues,NderivativeVolume(:,4),':');
    semilogy(pupilValues,NderivativeVolume(:,5),':');
else
    semilogy(pupilValuesAir,dVdADaylight);
    hold on;
    semilogy(pupilValuesAir,dVdAMoonlight);
    semilogy(pupilValuesAir,dVdAStarlight);
    semilogy(pupilValues,derivativeVisualVolume(1).up,'--');
    semilogy(pupilValues,derivativeVisualVolume(2).up,'--');
    semilogy(pupilValues,derivativeVisualVolume(1).hor,':');
    semilogy(pupilValues,derivativeVisualVolume(2).hor,':');
    
    % plot the 1st and 3rd quartile range for TF and ST pupils
    
    yminmax=get(gca,'ylim');
    hold on
    fillboxTF = patch([pupil_TF(1) pupil_TF(1) pupil_TF(2) pupil_TF(2)], ...
        [yminmax(1) yminmax(2) yminmax(2) yminmax(1)],[1 0 0]);
    
    set(fillboxTF,'facealpha',0.2,'edgecolor','none')
    
    fillboxST = patch([pupil_ST(1) pupil_ST(1) pupil_ST(2) pupil_ST(2)], ...
        [yminmax(1) yminmax(2) yminmax(2) yminmax(1)],[0 0 1]);
    
    set(fillboxST,'facealpha',0.2,'edgecolor','none')
    
end
yrange8=get(logdVdAvsA,'YLim');
line([fishpupil fishpupil],[yrange8(1) yrange8(2)],'Color',[0 0 0],...
    'linestyle',':','linewidth',1)
line([tetrapodpupil,tetrapodpupil],[yrange8(1) yrange8(2)],'Color',[0/255,128/255,128/255],...
    'linestyle',':','linewidth',1)
xlabel('pupil diameter (mm)'); ylabel('log(dV/dA) (m^3/mm)');


hL = legend([line8,line9,line10,line11,line12,line13,line14],...
    {'daylight','moonlight','starlight','100m, up','10m, up','100m, hor','10m, hor'});

newPosition = [0.4 0.4 0.2 0.2];
newUnits = 'normalized';
set(hL,'Position', newPosition,'Units', newUnits,'Orientation','horizontal');

figure(2)
print -dpdf 'linearRangeDeriv'

figure(3)
print -dpdf 'logRangeDeriv'
