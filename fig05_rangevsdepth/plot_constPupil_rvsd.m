close all; clear all;

warning('If parameters or bounds are changed rerun constantDepthVals_rvsA to refresh values')

load('constantPupil_rvsd')

%% PLOT FIG 4

rangevsdepth=figure();

subplot(2,2,1)
line1=plot(rangeFOVValues,depthSolutions{1});
hold on;
line2=plot(rangeFOVValues,depthSolutions{2});
line3=plot(rangeFOVValues,depthSolutions{3},'--');
line4=plot(rangeFOVValues,depthSolutions{4},'--');
xlabel('visual range (m)'); ylabel('depth in coastal water (m)');

subplot(2,2,2)
plot(derivativeDepthValues{1},drdD{1});
hold on;
plot(derivativeDepthValues{2},drdD{2});
plot(derivativeDepthValues{3},drdD{3},'--');
plot(derivativeDepthValues{4},drdD{4},'--');
xlabel('depth in coastal water (m)'); ylabel('dr/dD');

subplot(2,2,3)
plot(depthSolutions{1},volumeSolution);
hold on;
plot(depthSolutions{2},volumeSolution);
plot(depthSolutions{3},volumeSolution,'--');
plot(depthSolutions{4},volumeSolution,'--');
xlabel('depth in coastal water (m)'); ylabel('visual volume (m^3)');

subplot(2,2,4)
plot(derivativeDepthValues{1},dVdD{1});
hold on;
plot(derivativeDepthValues{2},dVdD{2});
plot(derivativeDepthValues{3},dVdD{3},'--');
plot(derivativeDepthValues{4},dVdD{4},'--');
xlabel('depth in coastal water(m)'); ylabel('dV/dD');

hL = legend([line1,line2,line3,line4],...
    {'7.4mm pupil diameter, looking up','16.2mm pupil diameter, looking up',...
    '7.4mm pupil diameter, horizontal viewing','16.2mm pupil diameter, horizontal viewing'});

newPosition = [0.4 0.4 0.2 0.2];
newUnits = 'normalized';
set(hL,'Position', newPosition,'Units', newUnits,'Orientation','horizontal');