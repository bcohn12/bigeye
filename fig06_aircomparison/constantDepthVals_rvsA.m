clear all;

run ../figXX_compviz/Parameters.m

%% CONSTANT DEPTH VALUE RANGE OF VISION VS PUPIL SIZE

coastalWaterDepth=input('In vector form input depth values:\n');
coastalWaterDepth=sort(coastalWaterDepth,'descend');

minpupil=0.001; maxpupil=0.03;
minvisualrange=0.1; maxvisualrange=60;

pupilValues=linspace(minpupil,maxpupil,30); rangeValues=linspace(minvisualrange,maxvisualrange,2500);

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
                2*((T*R)/(2*r*d))^2*X*Dt))/...
                (abs(q*Dt*(-0.617*(T/r)^2*(newIspaceUp*exp((K_up-a)*r)))));

            %HORIZONTAL
            eq_hor=(R*sqrt(q*Dt*(0.617*(T/r)^2*(newIspaceHor*(2-exp((K_hor-a)*r))))+...
                2*((T*R)/(2*r*d))^2*X*Dt))/...
                (abs(q*Dt*(-0.617*(T/r)^2*(newIspaceHor*exp((K_hor-a)*r)))));  

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
    
end

R=[visualRangeSolutions(1).up', visualRangeSolutions(1).hor', ...
    visualRangeSolutions(2).up', visualRangeSolutions(2).hor'];
AA=pupilValues;
indx=1;

for loop1=1:2:size(R,2)
    visualRangeUp=R(:,loop1);
    visualRangeHor=R(:,loop1+1);
    
    visualVolumeUp=zeros(length(visualRangeUp),1);
    visualVolumeHor=zeros(length(visualRangeUp),1);

        for loop2=1:length(visualRangeUp)
        %f(rho,phi,theta)
            visualVolumeUp(loop2)=integral3(f,0,visualRangeUp(loop2),...
                elevationMin,elevationMax,...
                azimuthMin,azimuthMax);

            visualVolumeHor(loop2)=integral3(f,0,visualRangeHor(loop2),...
                elevationMin,elevationMax,...
                azimuthMin,azimuthMax);
        end

    visualVolumeSolutions(indx).up=visualVolumeUp;
    visualVolumeSolutions(indx).hor=visualVolumeHor;
    indx=indx+1;
end

V=[visualVolumeSolutions(1).up, visualVolumeSolutions(1).hor,...
    visualVolumeSolutions(2).up, visualVolumeSolutions(2).hor];
indx=1;   
for loop1=1:2:size(R,2)
    visualRangeUp=R(:,loop1);
    visualRangeHor=R(:,loop1+1);
    
    visualVolumeUp=V(:,loop1);
    visualVolumeHor=V(:,loop1+1);
    
    derivativeVisualRange(indx).up=derivative(AA*10^3,visualRangeUp);
    derivativeVisualRange(indx).hor=derivative(AA*10^3,visualRangeHor);
    
    derivativeVisualVolume(indx).up=derivative(AA*10^3,visualVolumeUp);
    derivativeVisualVolume(indx).hor=derivative(AA*10^3,visualVolumeHor);
    
    MDerRange(:,loop1)=derivativeVisualRange(indx).up;
    MDerRange(:,loop1+1)=derivativeVisualRange(indx).hor;
    MDerVolume(:,loop1)=derivativeVisualVolume(indx).up;
    MDerVolume(:,loop1+1)=derivativeVisualVolume(indx).hor;
    
    indx=indx+1;
end

NDerRange=(MDerRange-min(min(MDerRange)))/(max(max(MDerRange))-min(min(MDerRange)));
NDerVolume=(MDerVolume-min(min(MDerVolume)))/(max(max(MDerVolume))-min(min(MDerVolume)));

indx=1;

for loop1=1:2:size(NDerRange,2);
    NderivativeVisualRange(indx).up=NDerRange(:,loop1);
    NderivativeVisualRange(indx).hor=NDerRange(:,loop1+1);
    
    NderivativeVisualVolume(indx).up=NDerVolume(:,loop1);
    NderivativeVisualVolume(indx).hor=NDerVolume(:,loop1+1);
    indx=indx+1;
end


save('constantDepth_rvsA.mat','coastalWaterDepth','pupilValues','rangeValues',...
    'visualRangeSolutions','visualVolumeSolutions',...
    'derivativeVisualRange','derivativeVisualVolume',...
    'NderivativeVisualRange','NderivativeVisualVolume');
    