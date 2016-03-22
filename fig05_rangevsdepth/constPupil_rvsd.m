clear all;

warning('If a parameter is changed, run Parameters again with the changed parameter to update\n')

load('parameters')

pupilValuesFOV=input('Input desired test pupil values in vector form: \n');
%[0.0074,0.0162];
pupilValuesFOV=sort(pupilValuesFOV);

rangeFOVValues=linspace(10,60,100);
%alpha=3, bound 2,5,n=900
%alpha=.3, 10,60,n=100

maxdepth=100;
%alpha=3, maxdepth=10
%alpha=.3,maxdepth=100
mindepth=0;

depthValues=linspace(mindepth,maxdepth,700);
%alpha=3, n=250
%alpha=.3, n=700

viewingDirection={'up','horizontal'};

for loop1=1:length(viewingDirection)
    direction=viewingDirection(loop1);
    s=strcat('current viewing direction: ', direction); disp(s);
   
    if strcmp(direction,'up')
        append='up';
    elseif strcmp(direction,'hor')
        append='hor';
    else
        append='down';
    end
    
    possibleSol=zeros(length(depthValues),1);
    
    for loop2=1:length(pupilValuesFOV)
        A=pupilValuesFOV(loop2);
        for loop3=1:length(rangeFOVValues)
            r=rangeFOVValues(loop3);
            for loop4=1:length(depthValues)
                currentDepth=depthValues(loop4);
                
                attVar=['att_' append];
                IspaceVar=['Ispace_' append];
                KVar=['K_' append];

                newIspace=10^((eval(attVar)/100)*(200-currentDepth))*eval(IspaceVar);

                eq=(R*sqrt(q*Dt*(0.617*(T/r)^2*(newIspace*(2-exp((eval(KVar)-a)*r))))+...
                     2*((T*M)/(2*r*d))^2*X*Dt))/...
                     (abs(q*Dt*(-0.617*(T/r)^2*(newIspace*(exp((eval(KVar)-a)*r))))));

                possibleSol(loop4)=eq;
            end
            IDXFOV=knnsearch(possibleSol,A,'distance','seuclidean');
            tempdepthSolutions(loop3)=depthValues(IDXFOV);
        end
        depthSolutions{((length(pupilValuesFOV)*(loop1-1))+loop2)}=tempdepthSolutions;
    end
end

volumeSolution=zeros(length(rangeFOVValues),1);

for loop1=1:length(rangeFOVValues)
    volumeSolution(loop1)=integral3(f,0,rangeFOVValues(loop1),...
            elevationMin,elevationMax,...
            azimuthMin,azimuthMax);
end

for loop1=1:length(viewingDirection)   
    for loop2=1:length(pupilValuesFOV)
        colnum=((length(pupilValuesFOV)*(loop1-1))+loop2);
        
        [dummy I]=unique(depthSolutions{colnum},'first');

        usableDepthValues=depthSolutions{colnum}(sort(I));
        I=sort(I(1:end-1));
        I=[I(1)-1; I];
        
        correspondingRangeValues=rangeFOVValues(I);
        correspondingVolumeValues=volumeSolution(I);
        
        tempdrdD=zeros(length(correspondingRangeValues),1);
        tempdVdD=zeros(length(correspondingVolumeValues),1);
        
        tempdrdD(1)=(correspondingRangeValues(2)-correspondingRangeValues(1))...
            /(usableDepthValues(2)-usableDepthValues(1));
        tempdVdD(1)=(correspondingVolumeValues(2)-correspondingVolumeValues(1))...
            /(usableDepthValues(2)-usableDepthValues(1));
        
        for n=2:length(correspondingRangeValues)-1
            tempdrdD(n)=(correspondingRangeValues(n+1)-correspondingRangeValues(n-1))...
                /(usableDepthValues(n+1)-usableDepthValues(n-1));
        end
        for m=2:length(correspondingVolumeValues)-1
            tempdVdD(m)=(correspondingVolumeValues(m+1)-correspondingVolumeValues(m-1))...
                /(usableDepthValues(m+1)-usableDepthValues(m-1));
        end
        
        tempdrdD(length(correspondingRangeValues))=(correspondingRangeValues(end)-correspondingRangeValues(end-1))...
            /(usableDepthValues(end)-usableDepthValues(end-1));
        tempdVdD(length(correspondingVolumeValues))=(correspondingVolumeValues(end)-correspondingVolumeValues(end-1))...
            /(usableDepthValues(end)-usableDepthValues(end-1));
        
        drdD{colnum}=tempdrdD;
        dVdD{colnum}=tempdVdD;
        
        derivativeDepthValues{colnum}=usableDepthValues;
    end
end

save('constantPupil_rvsd','pupilValuesFOV','rangeFOVValues',...
    'depthSolutions','volumeSolution',...
    'drdD','dVdD','derivativeDepthValues');
        