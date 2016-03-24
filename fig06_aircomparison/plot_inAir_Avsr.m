close all; 
clear all;

load('inAir_Avsr')
load('constantDepth_rvsA')

warning('If any of the bounds or parameters are changed re run the functions that are loaded')

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

comparison=figure();
subplot(2,2,1)
line1=plot(pupilValuesAir,visualRangeAir);
hold on;
line2=plot(pupilValues,visualRangeSolutions(1).up,'--');
line3=plot(pupilValues,visualRangeSolutions(2).up,'--');
line4=plot(pupilValues,visualRangeSolutions(1).hor,':');
line5=plot(pupilValues,visualRangeSolutions(2).hor,':');
xlabel('pupil diameter (m)'); ylabel('visual range (m)');

subplot(2,2,2)
plot(pupilValuesAir,drdAAir/max(drdAAir));
hold on;
plot(pupilValues,derivativeVisualRange(1).up/max(derivativeVisualRange(1).up),'--');
plot(pupilValues,derivativeVisualRange(2).up/max(derivativeVisualRange(2).up),'--');
plot(pupilValues,derivativeVisualRange(1).hor/max(derivativeVisualRange(1).hor),':');
plot(pupilValues,derivativeVisualRange(2).hor/max(derivativeVisualRange(2).hor),':');
xlabel('pupil diameter (m)'); ylabel('dr/dA');

subplot(2,2,3)
plot(pupilValuesAir,visualVolumeAir);
hold on;
plot(pupilValues,visualVolumeSolutions(1).up,'--');
plot(pupilValues,visualVolumeSolutions(2).up,'--');
plot(pupilValues,visualVolumeSolutions(1).hor,':');
plot(pupilValues,visualVolumeSolutions(2).hor,':');
xlabel('pupil diameter (m)'); ylabel('visual volume (m^3)');

subplot(2,2,4)
plot(pupilValuesAir,dVdAAir/max(dVdAAir));
hold on;
plot(pupilValues,derivativeVisualVolume(1).up/max(derivativeVisualVolume(1).up),'--');
plot(pupilValues,derivativeVisualVolume(2).up/max(derivativeVisualVolume(2).up),'--');
plot(pupilValues,derivativeVisualVolume(1).hor/max(derivativeVisualVolume(1).hor),':');
plot(pupilValues,derivativeVisualVolume(2).hor/max(derivativeVisualVolume(2).hor),':');
xlabel('pupil diameter (m)'); ylabel('dV/dA');

hL = legend([line1,line2,line3,line4,line5],...
    {'in air','100m, looking up','10m, looking up','100m, horizontal viewing','10m, horizontal viewing'});

newPosition = [0.4 0.4 0.2 0.2];
newUnits = 'normalized';
set(hL,'Position', newPosition,'Units', newUnits,'Orientation','horizontal');
