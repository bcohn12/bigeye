clear all;

warning('If a parameter is changed, run Parameters again with the changed parameter to update\n')

load('parameters')

%% CONSTANT DEPTH VALUE RANGE OF VISION VS PUPIL SIZE

coastalWaterDepth=input('In vector form input depth values:\n');
coastalWaterDepth=sort(coastalWaterDepth,'descend');

minpupil=0.002; maxpupil=0.03;
minvisualrange=0.1; maxvisualrange=60;

pupilValues=linspace(minpupil,maxpupil,20); rangeValues=linspace(minvisualrange,maxvisualrange,1000);

for loop1=1:length(coastalWaterDepth)
    newIspaceUp= 10^((att_up/100)*(200-coastalWaterDepth(loop1)))*Ispace_up;
    newIspaceHor= 10^(att_hor/100*(200-coastalWaterDepth(loop1)))*Ispace_hor;
    newIspaceDown= 10^(att_down/100*(200-coastalWaterDepth(loop1)))*Ispace_down;

    possibleSolUp=zeros(length(rangeValues),1);
    possibleSolHor=zeros(length(rangeValues),1);

    %For each of the A values and r values calculate the equation given in
    %(2.31). The result of the equation should equal A, therefore after all r
    %values are iterated through do a nearest neighbor search with distance
    %metric normalized euclidean to find the idx in r that is closest to A,
    %store it as a solution to the equation. 
    for loop2=1:length(pupilValues)
        A=pupilValues(loop2);
        for loop3=1:length(rangeValues)  
            r=rangeValues(loop3);

            %LOOKING UP
            eq_up=(R*sqrt(q*Dt*(0.617*(T/r)^2*(newIspaceUp*(2-exp((K_up-a)*r))))+...
                2*((T*M)/(2*r*d))^2*X*Dt))/...
                (abs(q*Dt*(-0.617*(T/r)^2*(newIspaceUp*exp((K_up-a)*r)))));

            %HORIZONTAL
            eq_hor=(R*sqrt(q*Dt*(0.617*(T/r)^2*(newIspaceHor*(2-exp((K_hor-a)*r))))+...
                2*((T*M)/(2*r*d))^2*X*Dt))/...
                (abs(q*Dt*(-0.617*(T/r)^2*(newIspaceHor*exp((K_hor-a)*r)))));  

            %LOOKING DOWN
    %         eq1=(R*sqrt(q*Dt*(P*((E*A^2)/(16*r^2))*exp(-a*r)+...
    %             0.617*(T/r)^2*(newIspace_down*(2-exp((K_down-a)*r))))+...
    %             2*((T*M)/(2*r*d))^2*X*Dt))/...
    %             (abs(q*Dt*((P*((E*A^2)/(16*r^2))*exp(-a*r))-...
    %             0.617*(T/r)^2*(newIspace_down*exp((K_down-a)*r)))));

            possibleSolUp(loop3)=eq_up; 
            possibleSolHor(loop3)=eq_hor;
        end
        IDXUp = knnsearch(possibleSolUp,A,'distance','seuclidean');
        IDXHor=knnsearch(possibleSolHor,A,'distance','seuclidean');
        visualRangeUp(loop2) = rangeValues(IDXUp);
        visualRangeHor(loop2)=rangeValues(IDXHor);
    end
    
    visualRangeSolutions(loop1).up=visualRangeUp;
    visualRangeSolutions(loop1).hor=visualRangeHor;
    
    
    AA=pupilValues;
    
    visualVolumeUp=zeros(length(visualRangeUp),1);
    visualVolumeHor=zeros(length(visualRangeHor),1);
    
    for loop2=1:length(visualRangeUp)
        %f(rho,phi,theta)
        visualVolumeUp(loop2)=integral3(f,0,visualRangeUp(loop2),...
            elevationMin,elevationMax,...
            azimuthMin,azimuthMax);
        
        visualVolumeHor(loop2)=integral3(f,0,visualRangeHor(loop2),...
            elevationMin,elevationMax,...
            azimuthMin,azimuthMax);
    end
    
    visualVolumeSolutions(loop1).up=visualVolumeUp;
    visualVolumeSolutions(loop1).hor=visualVolumeHor;
    
    drdAUp(1)=(visualRangeUp(2)-visualRangeUp(1))/(AA(2)-AA(1));
    dVdAUp(1)=(visualVolumeUp(2)-visualVolumeUp(1))/(AA(2)-AA(1));
    
    drdAHor(1)=(visualRangeHor(2)-visualRangeHor(1))/(AA(2)-AA(1));
    dVdAHor(1)=(visualVolumeHor(2)-visualVolumeHor(1))/(AA(2)-AA(1));
    
    for n=2:length(visualRangeUp)-1
        drdAUp(n)=(visualRangeUp(n+1)-visualRangeUp(n-1))/(AA(n+1)-AA(n-1));
        dVdAUp(n)=(visualVolumeUp(n+1)-visualVolumeUp(n-1))/(AA(n+1)-AA(n-1));
        
        drdAHor(n)=(visualRangeHor(n+1)-visualRangeHor(n-1))/(AA(n+1)-AA(n-1));
        dVdAHor(n)=(visualVolumeHor(n+1)-visualVolumeHor(n-1))/(AA(n+1)-AA(n-1));
    end
    
    drdAUp(length(visualRangeUp))=(visualRangeUp(end)-visualRangeUp(end-1))...
        /(AA(end)-AA(end-1));
    dVdAUp(length(visualVolumeUp))=(visualVolumeUp(end)-visualVolumeUp(end-1))...
        /(AA(end)-AA(end-1));
    
    drdAHor(length(visualRangeHor))=(visualRangeHor(end)-visualRangeHor(end-1))...
        /(AA(end)-AA(end-1));
    dVdAHor(length(visualVolumeHor))=(visualVolumeHor(end)-visualVolumeHor(end-1))...
        /(AA(end)-AA(end-1));
    
    derivativeVisualRange(loop1).up=drdAUp; derivativeVisualRange(loop1).hor=drdAHor;
    derivativeVisualVolume(loop1).up=dVdAUp; derivativeVisualVolume(loop1).hor=dVdAHor;
end

save('constantDepth_rvsA.mat','coastalWaterDepth','pupilValues','rangeValues',...
    'visualRangeSolutions','visualVolumeSolutions',...
    'derivativeVisualRange','derivativeVisualVolume');
    