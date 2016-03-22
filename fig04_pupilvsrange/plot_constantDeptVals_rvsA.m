close all; clear all;

warning('If parameters or bounds are changed rerun constantDepthVals_rvsA to refresh values')

load('constantDepth_rvsA')

%% PLOT FIG 4

rangevspupilsize=figure();

subplot(2,2,1)
line1=plot(pupilValues,visualRangeSolutions(1).up);
hold on;
line2=plot(pupilValues,visualRangeSolutions(2).up);
line3=plot(pupilValues,visualRangeSolutions(1).hor,'--');
line4=plot(pupilValues,visualRangeSolutions(2).hor,'--');
xlabel('pupil diameter (m)'); ylabel('visual range (m)');

subplot(2,2,2)
plot(pupilValues,derivativeVisualRange(1).up);
hold on;
plot(pupilValues,derivativeVisualRange(2).up);
plot(pupilValues,derivativeVisualRange(1).hor,'--');
plot(pupilValues,derivativeVisualRange(2).hor,'--');
xlabel('pupil diameter (m)'); ylabel('dr/dA');

subplot(2,2,3)
plot(pupilValues,visualVolumeSolutions(1).up);
hold on;
plot(pupilValues,visualVolumeSolutions(2).up);
plot(pupilValues,visualVolumeSolutions(1).hor,'--');
plot(pupilValues,visualVolumeSolutions(2).hor,'--');
xlabel('pupil diameter (m)'); ylabel('visual volume (m^3)');

subplot(2,2,4)
plot(pupilValues,derivativeVisualVolume(1).up);
hold on;
plot(pupilValues,derivativeVisualVolume(2).up);
plot(pupilValues,derivativeVisualVolume(1).hor,'--');
plot(pupilValues,derivativeVisualVolume(2).hor,'--');
xlabel('pupil diameter (m)'); ylabel('dV/dA');

hL = legend([line1,line2,line3,line4],...
    {'100m, looking up','10m, looking up','100m, horizontal viewing','10m, horizontal viewing'});

newPosition = [0.4 0.4 0.2 0.2];
newUnits = 'normalized';
set(hL,'Position', newPosition,'Units', newUnits,'Orientation','horizontal');