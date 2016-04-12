clear all;
run ../figXX_compviz/Parameters.m

% rangeInput=input('In vector form input range values:\n');
% rangeInput=sort(rangeInput,'descend');

minpupil=0.001; maxpupil=0.03;
minTargetSize=0; maxTargetSize=.01;

pupilValuesTarget=linspace(minpupil,maxpupil,30);
targetValues=linspace(minTargetSize,maxTargetSize,2000000);
r=20;
    
possibleSolD=zeros(length(targetValues),1);
possibleSolM=zeros(length(targetValues),1);
possibleSolS=zeros(length(targetValues),1);

for loop1=1:length(pupilValuesTarget)
    A=pupilValuesTarget(loop1);

    for loop2=1:length(targetValues)
        T=targetValues(loop2);

        eq_daylight=((R*sqrt((q*Dt_daylight*0.617*(T/r)^2*...
            (2*Ispace_daylight+((Iref_daylight-Ispace_daylight)*exp(-a_air*r))))))...
            /abs(q*Dt_daylight*0.617*(T/r)^2*...
            ((Iref_daylight-Ispace_daylight)*exp(-a_air*r))));

        eq_moonlight=((R*sqrt((q*Dt*0.617*(T/r)^2*...
            (2*Ispace_moonlight+((Iref_moonlight-Ispace_moonlight)*exp(-a_air*r))))+...
            2*((T*M)/(2*r*d))^2)*X_night*Dt)...
            /abs(q*Dt*0.617*(T/r)^2*...
            ((Iref_moonlight-Ispace_moonlight)*exp(-a_air*r))));

        eq_starlight=((R*sqrt((q*Dt*0.617*(T/r)^2*...
            (2*Ispace_starlight+((Iref_starlight-Ispace_starlight)*exp(-a_air*r))))+...
            2*((T*M)/(2*r*d))^2)*X_night*Dt)...
            /abs(q*Dt*0.617*(T/r)^2*...
            ((Iref_starlight-Ispace_starlight)*exp(-a_air*r))));

        possibleSolD(loop2)=eq_daylight;
        possibleSolM(loop2)=eq_moonlight;
        possibleSolS(loop2)=eq_starlight;
    end
    IDXDaylight=knnsearch(possibleSolD,A,'NSMethod','exhaustive','distance','seuclidean');
    IDXMoonlight=knnsearch(possibleSolM,A,'NSMethod','exhaustive','distance','seuclidean');
    IDXStarlight=knnsearch(possibleSolS,A,'NSMethod','exhaustive','distance','seuclidean');

    targetSizeDaylight(loop1)=targetValues(IDXDaylight);
    targetSizeMoonlight(loop1)=targetValues(IDXMoonlight);
    targetSizeStarlight(loop1)=targetValues(IDXStarlight);
end
    
    
        