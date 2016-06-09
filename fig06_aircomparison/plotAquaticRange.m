function plotAquaticRange
close all
    load('pupilSizevsRangeConstantDepth_Coastal.mat');
    load('pupilSizevsRangeConstantDepth_River.mat');
    
    visualRange_Coastal=[visualRange_Coastal(:,1:2,1) visualRange_Coastal(:,1:2,2)];
    drdA_Coastal=[drdA_Coastal(:,1:2,1), drdA_Coastal(:,1:2,2)];
    visualVolume_Coastal=[visualVolume_Coastal(:,1:2,1) visualVolume_Coastal(:,1:2,2)];
    dVdA_Coastal=[dVdA_Coastal(:,1:2,1), dVdA_Coastal(:,1:2,2)];
    key_Coastal={'looking upwards, depth=10m','looking upwards, depth=7m',...        
        'horizontal viewing, depth=10m','horizontal viewing, depth=7m'};
    
    visualRange_River=[visualRange_River(:,1:2,1), visualRange_River(:,1:2,2)];
    drdA_River=[drdA_River(:,1:2,1), drdA_River(:,1:2,2)];
    visualVolume_River=[visualVolume_River(:,1:2,1) visualVolume_River(:,1:2,2)];
    dVdA_River=[dVdA_River(:,1:2,1), dVdA_River(:,1:2,2)];
    key_River={'looking upwards, depth=10m','looking upwards, depth=7m',...        
        'horizontal viewing, depth=10m','horizontal viewing, depth=7m'};
    
    h1=figure(); clf; 
    subplot(2,1,1);
    plot(pupilValues*1e3,visualRange_Coastal);   
    xlabel('pupil diameter (mm)'); ylabel('visual range coastal water(m)');    
    %columnlegend(2,key_Coastal,'location','Northoutside','fontsize',8);
    
    subplot(2,1,2);
    plot(pupilValues*1e3,visualRange_River);
    xlabel('pupil diameter (mm)'); ylabel('visual range river water (m)');
    columnlegend(2,key_River,'location','south','fontsize',8,'Box','off');
    
    h2=figure(); clf;
    subplot(2,1,1);
    plot(pupilValues*1e3,drdA_Coastal);   
    xlabel('pupil diameter (mm)'); ylabel('dr/dA coastal water(m/mm)');    
    %columnlegend(2,key_Coastal,'location','Northoutside','fontsize',8);
    
    subplot(2,1,2);
    plot(pupilValues*1e3,drdA_River);
    xlabel('pupil diameter (mm)'); ylabel('dr/dA river water (m/mm)');
    columnlegend(2,key_River,'location','south','fontsize',8,'Box','off');
    
    h3=figure(); clf;
    subplot(2,1,1);
    plot(pupilValues*1e3,visualVolume_Coastal);   
    xlabel('pupil diameter (mm)'); ylabel('visual volume coastal water(m^3)');    
    %columnlegend(2,key_Coastal,'location','Northoutside','fontsize',8);
    
    subplot(2,1,2);
    plot(pupilValues*1e3,visualVolume_River);
    xlabel('pupil diameter (mm)'); ylabel('visual volume river water (m^3)');
    columnlegend(2,key_River,'location','south','fontsize',8,'Box','off');
    
    h4=figure(); clf;
    subplot(2,1,1);
    plot(pupilValues*1e3,dVdA_Coastal);   
    xlabel('pupil diameter (mm)'); ylabel('dV/dA coastal water(m^3/mm)');    
    %columnlegend(2,key_Coastal,'location','Northoutside','fontsize',8);
    
    subplot(2,1,2);
    plot(pupilValues*1e3,dVdA_River);
    xlabel('pupil diameter (mm)'); ylabel('dV/dA river water (m^3/mm)');
    columnlegend(2,key_River,'location','south','fontsize',8,'Box','off');