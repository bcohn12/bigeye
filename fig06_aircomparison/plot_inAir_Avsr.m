close all; 
clear all;

load('inAir_Avsr')
load('constantDepth_rvsA')

warning('If any of the bounds or parameters are changed re run the functions that are loaded')

fishpupil=7.9;
tetrapodpupil=15.9;

pupilValues=pupilValues*10^3;
pupilValuesAir=pupilValuesAir*10^3;

NORMDERIVATIVE=0;

%% PLOT ONLY AIR

air=figure();

subplot(2,2,1)
plot(pupilValuesAir,visualRangeAir)
xlabel('pupil diameter (m)'); ylabel('visual range (m)')

subplot(2,2,2)
plot(pupilValuesAir,drdAAir)
xlabel('pupil diameter (m)'); ylabel('dr/dA');

subplot(2,2,3)
plot(pupilValuesAir,visualVolumeAir)
xlabel('pupil diameter (m)'); ylabel('visual volume (m^3)');

subplot(2,2,4)
plot(pupilValuesAir,dVdAAir);
xlabel('pupil diameter (m)'); ylabel('dV/dA');

%% PLOT AIR VS WATER COMPARISON

MderivativeRange=[drdAAir',...
    derivativeVisualRange(1).up', derivativeVisualRange(2).up',...
    derivativeVisualRange(1).hor',derivativeVisualRange(2).hor'];

NderivativeRange=(MderivativeRange-min(min(MderivativeRange)))...
    /(max(max(MderivativeRange))-min(min(MderivativeRange)));

comparison=figure();
rvsA=subplot(2,2,1);
line1=plot(pupilValuesAir,visualRangeAir);
hold on;
line2=plot(pupilValues,visualRangeSolutions(1).up,'--');
line3=plot(pupilValues,visualRangeSolutions(2).up,'--');
line4=plot(pupilValues,visualRangeSolutions(1).hor,':');
line5=plot(pupilValues,visualRangeSolutions(2).hor,':');
xlabel('pupil diameter (mm)'); ylabel('visual range (m)');
yrange=get(rvsA,'YLim');
line([fishpupil fishpupil],[yrange(1) yrange(2)],'Color',[0 0 0],...
    'linestyle',':','linewidth',1)
line([tetrapodpupil,tetrapodpupil],[yrange(1) yrange(2)],'Color',[0/255,128/255,128/255],...
    'linestyle',':','linewidth',1)

drdAvsA=subplot(2,2,2);
if(NORMDERIVATIVE)
    plot(pupilValuesAir,NderivativeRange(:,1));
    hold on;
    plot(pupilValues,NderivativeRange(:,2),'--');
    plot(pupilValues,NderivativeRange(:,3),'--');
    plot(pupilValues,NderivativeRange(:,4),':');
    plot(pupilValues,NderivativeRange(:,5),':');
    
else
    plot(pupilValuesAir,drdAAir);
    hold on;
    plot(pupilValues,derivativeVisualRange(1).up,'--');
    plot(pupilValues,derivativeVisualRange(2).up,'--');
    plot(pupilValues,derivativeVisualRange(1).hor,':');
    plot(pupilValues,derivativeVisualRange(2).hor,':');
end
yrange2=get(drdAvsA,'YLim');
line([fishpupil fishpupil],[yrange2(1) yrange2(2)],'Color',[0 0 0],...
    'linestyle',':','linewidth',1)
line([tetrapodpupil,tetrapodpupil],[yrange2(1) yrange2(2)],'Color',[0/255,128/255,128/255],...
    'linestyle',':','linewidth',1)
xlabel('pupil diameter (mm)'); ylabel('dr/dA (m/mm)');

MderivativeVolume=[dVdAAir',...
    derivativeVisualVolume(1).up', derivativeVisualVolume(2).up',...
    derivativeVisualVolume(1).hor', derivativeVisualVolume(2).hor'];

NderivativeVolume=(MderivativeVolume-min(min(MderivativeVolume)))...
    /(max(max(MderivativeVolume))-min(min(MderivativeVolume)));

VvsA=subplot(2,2,3);
plot(pupilValuesAir,visualVolumeAir);
hold on;
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

dVdAvsA=subplot(2,2,4);
if(NORMDERIVATIVE)
    plot(pupilValuesAir,NderivativeVolume(:,1));
    hold on;
    plot(pupilValues,NderivativeVolume(:,2),'--');
    plot(pupilValues,NderivativeVolume(:,3),'--');
    plot(pupilValues,NderivativeVolume(:,4),':');
    plot(pupilValues,NderivativeVolume(:,5),':');
else
    plot(pupilValues,dVdAAir);
    hold on;
    plot(pupilValues,derivativeVisualVolume(1).up,'--');
    plot(pupilValues,derivativeVisualVolume(2).up,'--');
    plot(pupilValues,derivativeVisualVolume(1).hor,':');
    plot(pupilValues,derivativeVisualVolume(2).hor,':');
end
yrange4=get(dVdAvsA,'YLim');
line([fishpupil fishpupil],[yrange4(1) yrange4(2)],'Color',[0 0 0],...
    'linestyle',':','linewidth',1)
line([tetrapodpupil,tetrapodpupil],[yrange4(1) yrange4(2)],'Color',[0/255,128/255,128/255],...
    'linestyle',':','linewidth',1)
xlabel('pupil diameter (mm)'); ylabel('dV/dA (m^3/mm)');    

hL = legend([line1,line2,line3,line4,line5],...
    {'in air','100m, looking up','10m, looking up','100m, horizontal viewing','10m, horizontal viewing'});

newPosition = [0.4 0.4 0.2 0.2];
newUnits = 'normalized';
set(hL,'Position', newPosition,'Units', newUnits,'Orientation','horizontal');

%% LOG PLOTS

logplots=figure();

logrvsA=subplot(2,2,1);
line6=semilogy(pupilValuesAir,visualRangeAir);
hold on;
line7=semilogy(pupilValues,visualRangeSolutions(1).up,'--');
line8=semilogy(pupilValues,visualRangeSolutions(2).up,'--');
line9=semilogy(pupilValues,visualRangeSolutions(1).hor,':');
line10=semilogy(pupilValues,visualRangeSolutions(2).hor,':');
yrange5=get(logrvsA,'YLim');
line([fishpupil fishpupil],[yrange5(1) yrange5(2)],'Color',[0 0 0],...
    'linestyle',':','linewidth',1)
line([tetrapodpupil,tetrapodpupil],[yrange5(1) yrange5(2)],'Color',[0/255,128/255,128/255],...
    'linestyle',':','linewidth',1)
xlabel('pupil diameter (mm)'); ylabel('log(visual range) (m)');

logVvsA=subplot(2,2,2);
semilogy(pupilValuesAir,visualVolumeAir);
hold on;
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

logdrdAvsA=subplot(2,2,3);
if(NORMDERIVATIVE)
    semilogy(pupilValuesAir,NderivativeRange(:,1));
    hold on;
    semilogy(pupilValues,NderivativeRange(:,2),'--');
    semilogy(pupilValues,NderivativeRange(:,3),'--');
    semilogy(pupilValues,NderivativeRange(:,4),':');
    semilogy(pupilValues,NderivativeRange(:,5),':');
    
else
    line11=semilogy(pupilValuesAir,drdAAir);
    hold on;
    line12=semilogy(pupilValues,derivativeVisualRange(1).up,'--');
    line13=semilogy(pupilValues,derivativeVisualRange(2).up,'--');
    line14=semilogy(pupilValues,derivativeVisualRange(1).hor,':');
    line15=semilogy(pupilValues,derivativeVisualRange(2).hor,':');
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
    semilogy(pupilValues,dVdAAir);
    hold on;
    semilogy(pupilValues,derivativeVisualVolume(1).up,'--');
    semilogy(pupilValues,derivativeVisualVolume(2).up,'--');
    semilogy(pupilValues,derivativeVisualVolume(1).hor,':');
    semilogy(pupilValues,derivativeVisualVolume(2).hor,':');
end
yrange8=get(logdVdAvsA,'YLim');
line([fishpupil fishpupil],[yrange8(1) yrange8(2)],'Color',[0 0 0],...
    'linestyle',':','linewidth',1)
line([tetrapodpupil,tetrapodpupil],[yrange8(1) yrange8(2)],'Color',[0/255,128/255,128/255],...
    'linestyle',':','linewidth',1)
xlabel('pupil diameter (mm)'); ylabel('log(dV/dA) (m^3/mm)');


hL = legend([line6,line7,line8,line9,line10],...
    {'in air','100m, looking up','10m, looking up','100m, horizontal viewing','10m, horizontal viewing'});

newPosition = [0.4 0.4 0.2 0.2];
newUnits = 'normalized';
set(hL,'Position', newPosition,'Units', newUnits,'Orientation','horizontal');