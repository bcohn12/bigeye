close all;
clear all;

load('aquaticRangeSensitivity'); load('pupilSizevsRangeConstantDepth_River');

figure();
plot(pupilValues*10^3,visualRangeSensitivity(:,:,1));
hold on;
plot(pupilValues*10^3,visualRange_River(:,:,1));
plot(pupilValues*10^3,visualRangeSensitivity(:,:,2));
plot(pupilValues*10^3,visualRange_River(:,:,2));
xlabel('pupil diameter (mm)'); ylabel('visual range (m)')

 key={'abs scat equal up @8m','low abs scat up @8m','high abs up @8m','high scat up @8m',...
     'river up @8m','abs scat equal hor @8m','low abs scat hor @8m','high abs hor @8m','high scat hor @8m',...
     'river hor @8m'};
    
    columnlegend(2,key,'location','north',...
        'fontsize',8)
    
figure();
semilogy(pupilValues*10^3,visualRangeSensitivity(:,:,1));
hold on;
semilogy(pupilValues*10^3,visualRange_River(:,:,1));
semilogy(pupilValues*10^3,visualRangeSensitivity(:,:,2));
semilogy(pupilValues*10^3,visualRange_River(:,:,2));
xlabel('pupil diameter (mm)'); ylabel('visual range (m)')

 key={'abs scat equal up @8m','low abs scat up @8m','high abs up @8m','high scat up @8m',...
     'river up @8m','abs scat equal hor @8m','low abs scat hor @8m','high abs hor @8m','high scat hor @8m',...
     'river hor @8m'};
    
    columnlegend(2,key,'location','north',...
        'fontsize',8)