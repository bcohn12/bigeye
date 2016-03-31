clear all; close all;

%% PARAMETERS
q=0.36; %units: n/a, detection efficiency, used typical value
Dt=1.16; %units: s, integration time, used typical value
X=2.8e-5; %units: photons/s, dark-noise rate/photoreceptor, used typical value
R=1.96; %units: n/a, reliability coefficient for 95% confidence, used typical value
d=3e-6; %units: m, photoreceptor diameter, used typical value
M=2.55; %units: n/a, ratio of focal length and pupil radius (2f/A), set to Matthiessen's ratio
E=10e11; %units: photons/s, numer of photons emitted by biolouminescnet point 
%source at the depth of the eyeset to the value given in Fig 3
x=0.3; %units: m, average distance between point sources across an extended object

a=.3; %units: 1/m, beam attenuation coefficient, pg8 supplementary
K_up=0.14; %units: 1/m, attenuation coefficient of background radiance for looking up, pg8 supplementary
K_hor=0;  %units: 1/m, attenuation coefficint of background radiance for horizontal view, pg8 supplementary
K_down=-0.14; %units: 1/m, attenuation coefficint of background radiance for looking down, pg8 supplementary

Ispace_up=0.97*7.94e13; %units: photons/m^2ssr, radiance of space-light 
%background in the direction of view at the depth of the eye for downw-welling radiance at 200m, pg7
%supplementary
Ispace_hor=0.97*6.46e11; %units: photons/m^2ssr, radiance of space-light 
%background in the direction of view at the depth of the eye for horizontal radiance at 200m, pg7
%supplementary
Ispace_down=0.97*3.67e11; %units: photons/m^2ssr, radiance of space-light 
%background in the direction of view at the depth of the eye for up-welling radiance at 200m, pg7
%supplementary

att_up=2.29; %units: dB/100m, attenuation with depth for down-welling radiance,
%pg 8 of supplementary
att_hor=2.34; %units: dB/100m, attenuation with depth for horizontal radiance,
%pg 8 of supplementary
att_down=2.33; %units: dB/100m, attenuation with depth for up-welling radiance,
%pg 8 of supplementary

eye_degree=120;
binocular=35;

single_degree=eye_degree;
halfCone_degree=single_degree/2;
halfCone_binocular=binocular/2;

%% FIG 3: FOR A GIVEN DEPTH FIND PUPIL DIAMETER AND RANGE RELATIONSHIPS
T =0.1; %units: m, width of extended target, from figures individually
P=(pi*T^3)/(2.86*x^3); %units: n/a, number of point sources, P, seen by a 
%visual channel viewing an extended target with distributed photophores, or
%with plankton causing stimulated bioluminesnce, based on section 2f type
%of point source used SB approaching target (for a comprehensive list
%refert to Table 2 at pg6 of the article

%based on depth and known attenuation calculate new Ispace values for
%caostal and oceanic, must be normalized with respect to 200 since the
%values are taken at 200, and divided by 100 due to per 100m attenuation

coastal_depth=[100,10]; %set current studied depth value for Ispace adjusments

allRangeSol=cell(length(coastal_depth),2);
dervRange=cell(length(coastal_depth),2); dervVol=cell(length(coastal_depth),2);
allRangeVol=cell(length(coastal_depth),2);

%Create a list of pupil diameter (A) values, and corresponding range of
%vision (r) values.

minpupil=0; %set minimum pupil diameter in meters
maxpupil=0.03; %set maximum pupil diameter in meters
Avals=linspace(minpupil,maxpupil,50);rvals=linspace(.1,60,1000);
%alpha=3, maxrval=5, Aval iteration#=17
%alpha=0.3, maxrval=60, Aval iteration#=17

for depthno=1:length(coastal_depth)
    
    newIspace_up= 10^((att_up/100)*(200-coastal_depth(depthno)))*Ispace_up;
    newIspace_hor= 10^(att_hor/100*(200-coastal_depth(depthno)))*Ispace_hor;
    newIspace_down= 10^(att_down/100*(200-coastal_depth(depthno)))*Ispace_down;

    possibleSol_up=zeros(length(rvals),length(Avals)); 

    %For each of the A values and r values calculate the equation given in
    %(2.31). The result of the equation should equal A, therefore after all r
    %values are iterated through do a nearest neighbor search with distance
    %metric normalized euclidean to find the idx in r that is closest to A,
    %store it as a solution to the equation. 
    for loop1=1:length(Avals)
        A=Avals(loop1);
        for loop2=1:length(rvals)  
            r=rvals(loop2);

            %LOOKING UP
            eq1_up=(R*sqrt(q*Dt*(P*((E*A^2)/(16*r^2))*exp(-a*r)+...
                0.617*(T/r)^2*(newIspace_up*(2-exp((K_up-a)*r))))+...
                2*((T*M)/(2*r*d))^2*X*Dt))/...
                (abs(q*Dt*((P*((E*A^2)/(16*r^2))*exp(-a*r))-...
                0.617*(T/r)^2*(newIspace_up*exp((K_up-a)*r)))));

            %HORIZONTAL
            eq1_hor=(R*sqrt(q*Dt*(P*((E*A^2)/(16*r^2))*exp(-a*r)+...
                0.617*(T/r)^2*(newIspace_hor*(2-exp((K_hor-a)*r))))+...
                2*((T*M)/(2*r*d))^2*X*Dt))/...
                (abs(q*Dt*((P*((E*A^2)/(16*r^2))*exp(-a*r))-...
                0.617*(T/r)^2*(newIspace_hor*exp((K_hor-a)*r)))));   

            %LOOKING DOWN
    %         eq1=(R*sqrt(q*Dt*(P*((E*A^2)/(16*r^2))*exp(-a*r)+...
    %             0.617*(T/r)^2*(newIspace_down*(2-exp((K_down-a)*r))))+...
    %             2*((T*M)/(2*r*d))^2*X*Dt))/...
    %             (abs(q*Dt*((P*((E*A^2)/(16*r^2))*exp(-a*r))-...
    %             0.617*(T/r)^2*(newIspace_down*exp((K_down-a)*r)))));

            possibleSol_up(loop2,loop1)=eq1_up; 
            possibleSol_hor(loop2,loop1)=eq1_hor;
        end
        IDX_range_up = knnsearch(possibleSol_up(:,loop1),A,'distance','seuclidean');
        IDX_range_hor=knnsearch(possibleSol_hor(:,loop1),A,'distance','seuclidean');
        coastal_range_up(loop1) = rvals(IDX_range_up);
        coastal_range_hor(loop1)=rvals(IDX_range_hor);
    end
    
    allRangeSol{depthno,1}=coastal_range_up; allRangeSol{depthno,2}=coastal_range_hor;

    %Calculate dr/dA, as diff(r)./diff(A)
    aa=Avals;
    
    volumeRange_up=zeros(length(coastal_range_up),1);
    volumeRange_hor=zeros(length(coastal_range_hor),1);

    for rangeIDX=1:length(coastal_range_up)
        calcVisRange_up=coastal_range_up(rangeIDX);
        calcVisRange_hor=coastal_range_hor(rangeIDX);

        radius1_up=calcVisRange_up*sind(halfCone_degree);
        radius1_hor=calcVisRange_hor*cosd(halfCone_degree);
        height1_up=calcVisRange_up*cosd(halfCone_binocular);
        height1_hor=calcVisRange_hor*cosd(halfCone_binocular);
        vol1_up= pi*radius1_up^2*(height1_up/3);
        vol1_hor=pi*radius1_hor^2*(height1_hor/3);

        radius2_up=calcVisRange_up*sind(halfCone_binocular);
        height2_up=calcVisRange_up*cosd(halfCone_binocular);
        vol2_up=pi*radius2_up^2*(height2_up/3);
        radius2_hor=calcVisRange_hor*sind(halfCone_binocular);
        height2_hor=calcVisRange_hor*cosd(halfCone_binocular);
        vol2_hor=pi*radius2_hor^2*(height2_hor/3);
        
        totalVol_up=2*vol1_up-vol2_up;
        totalVol_hor=2*vol1_hor-vol2_hor;

        volumeRange_up(rangeIDX)=totalVol_up;
        volumeRange_hor(rangeIDX)=totalVol_hor;
    end
    
    allRangeVol{depthno,1}=volumeRange_up; allRangeVol{depthno,2}=volumeRange_hor;
    
    %Calculate the diff by using forward, central and backward difference.
    %Should be slightly more accurate than MATLAB's diff. 

    drda_up(1)=(coastal_range_up(2)-coastal_range_up(1))/(aa(2)-aa(1));
    dvda_up(1)=(volumeRange_up(2)-volumeRange_up(1))/(aa(2)-aa(1));
    
    drda_hor(1)=(coastal_range_hor(2)-coastal_range_hor(1))/(aa(2)-aa(1));
    dvda_hor(1)=(volumeRange_hor(2)-volumeRange_hor(1))/(aa(2)-aa(1));
    for n=2:length(coastal_range_up)-1
        drda_up(n)=(coastal_range_up(n+1)-coastal_range_up(n-1))/(aa(n+1)-aa(n-1)); 
        dvda_up(n)=(volumeRange_up(n+1)-volumeRange_up(n-1))/(aa(n+1)-aa(n-1));
        
        drda_hor(n)=(coastal_range_hor(n+1)-coastal_range_hor(n-1))/(aa(n+1)-aa(n-1));
        dvda_hor(n)=(volumeRange_hor(n+1)-volumeRange_hor(n-1))/(aa(n+1)-aa(n-1));
    end
    drda_up(length(coastal_range_up))=(coastal_range_up(end)-coastal_range_up(end-1))...
        /(aa(end)-aa(end-1));
    dvda_up(length(coastal_range_up))=(volumeRange_up(end)-volumeRange_up(end-1))...
        /(aa(end)-aa(end-1));
    
    drda_hor(length(coastal_range_hor))=(coastal_range_hor(end)-coastal_range_hor(end-1))...
        /(aa(end)-aa(end-1));
    dvda_hor(length(coastal_range_hor))=(volumeRange_hor(end)-volumeRange_hor(end-1))...
        /(aa(end)-aa(end-1));
    
    %Normalize to 1
    drda_up=drda_up/max(drda_up);
    dvda_up=dvda_up/max(dvda_up);
    
    drda_hor=drda_hor/max(drda_hor);
    dvda_hor=dvda_hor/max(dvda_hor);
    
    dervRange{depthno,1}=drda_up; dervRange{depthno,2}=drda_hor;
    dervVol{depthno,1}=dvda_up; dervVol{depthno,2}=dvda_hor;
end

%Plot visual range(1,1), derivative(1,2), visual volume(2,1),
%derivative(2,2)
fig3=figure();
Avsrange=subplot(2,2,1);
fig3line1=plot(aa,allRangeSol{1,1});
hold on;
fig3line2=plot(aa,allRangeSol{2,1});
fig3line3=plot(aa,allRangeSol{1,2},'--');
fig3line4=plot(aa,allRangeSol{2,2},'--');
xlabel('pupil diameter (m)'); ylabel('visual range (m)');
%set(Avsrange,'YTick',[0 20 40 60],'XTick',[0.01,0.02,0.03]);
hold off;

Avsdrda=subplot(2,2,2);
plot(aa,dervRange{1,1});
hold on;
plot(aa,dervRange{2,1});
plot(aa,dervRange{1,2},'--');
plot(aa,dervRange{2,2},'--');
xlabel('pupil diameter (m)'); ylabel('dr/dA');
%set(Avsdrda,'YTick',[0 1], 'XTick', [0.01 0.02 0.03]);
hold off

subplot(2,2,3);
plot(aa,allRangeVol{1,1});
hold on;
plot(aa,allRangeVol{2,1});
plot(aa,allRangeVol{1,2},'--');
plot(aa,allRangeVol{2,2},'--');
xlabel('pupil diamter (m)'); ylabel('volume (m^3)');
hold off;

subplot(2,2,4);
plot(aa,dervVol{1,1});
hold on;
plot(aa,dervVol{2,1});
plot(aa,dervVol{1,2},'--');
plot(aa,dervVol{2,2},'--');
xlabel('pupil diameter (m)'); ylabel('dV/dA');

hL = legend([fig3line1,fig3line2,fig3line3,fig3line4],...
    {'100m, looking up','10m, looking up','100m, horizontal viewing','10m, horizontal viewing'});


newPosition = [0.4 0.4 0.2 0.2];
newUnits = 'normalized';
set(hL,'Position', newPosition,'Units', newUnits,'Orientation','horizontal');

%% FIELD OF VIEW
Avals=[0.0074,0.0162];
rvals_vol=linspace(10,60,100);
%alpha=3, rvals_vol bound 2,5,n=900
%alpha=.3, rvals_vol bound 10,60,n=100

maxdepth_vol=100;
%alpha=3, maxdepth=10
%alpha=.3,maxdepth=100
mindepth_vol=0;

depthVals_vol=linspace(mindepth_vol,maxdepth_vol,700);
%alpha=3, n=250
%alpha=.3, n=700
view_points={'looking horizontal', 'looking up'};

depthrange_vol=zeros(length(rvals_vol),length(view_points)*length(Avals));

for condition=1:length(view_points)
    viewing=view_points(condition);
    s=strcat('current viewing: ', viewing);
    disp(s)

    possibleSol_vol=zeros(length(depthVals_vol),1);
    if strcmp(viewing,'looking horizontal')
        append='hor';
    elseif strcmp(viewing,'looking up')
        append='up';
    else
        append='down';
    end
    for loop1=1:length(Avals)
        A=Avals(loop1);
        for loop2=1:length(rvals_vol)
            r=rvals_vol(loop2);
            for loop3=1:length(depthVals_vol)
                current_depth=depthVals_vol(loop3);

                attVar=['att_' append];
                IspaceVar=['Ispace_' append];
                KVar=['K_' append];

                newIspace=10^((eval(attVar)/100)*(200-current_depth))*eval(IspaceVar);

                eq2_vol=(R*sqrt(q*Dt*(0.617*(T/r)^2*(newIspace*(2-exp((eval(KVar)-a)*r))))+...
                     2*((T*M)/(2*r*d))^2*X*Dt))/...
                     (abs(q*Dt*(-0.617*(T/r)^2*(newIspace*(exp((eval(KVar)-a)*r))))));

                possibleSol_vol(loop3)=eq2_vol;
            end
            IDX_vol=knnsearch(possibleSol_vol,A,'distance','seuclidean');
            depthrange_vol(loop2,((length(Avals))*(condition-1))+loop1)=depthVals_vol(IDX_vol);
        end
    end
end

single_degree=eye_degree;
halfCone_degree=single_degree/2;
halfCone_binocular=binocular/2;

volumevals=zeros(length(rvals_vol),1);

for rangeIDX=1:length(rvals_vol)
    visualRange=rvals_vol(rangeIDX);

    radius1=visualRange*sind(halfCone_degree);
    height1=visualRange*cosd(halfCone_binocular);
    vol1= pi*radius1^2*(height1/3);

    radius2=visualRange*sind(halfCone_binocular);
    height2=visualRange*cosd(halfCone_binocular);
    vol2=pi*radius2^2*(height2/3);

    totalVol=2*vol1-vol2;

    volumevals(rangeIDX)=totalVol;
end

rateofRangeChange=cell(length(Avals)*length(view_points),1);
rateofVolChange=cell(length(Avals)*length(view_points),1);
correspondingDepth=cell(length(Avals)*length(view_points),1);
for condition=1:length(view_points)
    viewing=view_points(condition);
    s=strcat('current viewing: ', viewing);
    disp(s)
    for pupilno=1:length(Avals)
        colnum=((length(Avals))*(condition-1))+pupilno;

        [dummyRange I]=unique(depthrange_vol(:,colnum),'first');

        currDepthvals=depthrange_vol(sort(I),colnum);
        I=sort(I(1:end-1));
        I=[I(1)-1; I];
        corRangeVals=rvals_vol(I);
        corVolumeVals=volumevals(I);
      
        dumRangeChange=zeros(length(corRangeVals),1);
        dumVolChange=zeros(length(corVolumeVals),1);

        dumRangeChange(1)=(corRangeVals(2)-corRangeVals(1))...
            /(currDepthvals(2)-currDepthvals(1));
        dumVolChange(1)=(corVolumeVals(2)-corVolumeVals(1))...
            /(currDepthvals(2)-currDepthvals(1));
        for n=2:length(corRangeVals)-1
            dumRangeChange(n)=(corRangeVals(n+1)-corRangeVals(n-1))...
                /(currDepthvals(n+1)-currDepthvals(n-1));
        end
        for m=2:length(corVolumeVals)-1
            dumVolChange(m)=(corVolumeVals(m+1)-corVolumeVals(m-1))...
                /(currDepthvals(m+1)-currDepthvals(m-1));
        end
        dumRangeChange(length(corRangeVals))=(corRangeVals(end)-corRangeVals(end-1))...
            /(currDepthvals(end)-currDepthvals(end-1));
        dumVolChange(length(corVolumeVals))=(corVolumeVals(end)-corVolumeVals(end-1))...
            /(currDepthvals(end)-currDepthvals(end-1));

        rateofRangeChange{colnum}=dumRangeChange/max(abs(dumRangeChange));
        rateofVolChange{colnum}=dumVolChange/max(abs(dumVolChange));
        correspondingDepth{colnum}=currDepthvals;
    end
end

figure();
rangevsdepth=subplot(2,2,1);
line1=plot(rvals_vol,depthrange_vol(:,1),'--');
hold on;
line2=plot(rvals_vol,depthrange_vol(:,2),'--');
line3=plot(rvals_vol,depthrange_vol(:,3));
line4=plot(rvals_vol,depthrange_vol(:,4));
axis ij;
xlabel('range of vision (m)'); ylabel('depth in coastal water (m)'); hold off;

rateofrange=subplot(2,2,2);
line13=plot(correspondingDepth{1},rateofRangeChange{1},'--');
hold on
line14=plot(correspondingDepth{2},rateofRangeChange{2},'--');
line15=plot(correspondingDepth{3},rateofRangeChange{3});
line16=plot(correspondingDepth{4},rateofRangeChange{4});
xlabel('depth of coastal water (m)');ylabel('dr/dd');hold off;

depthvsvol=subplot(2,2,3);
line5=plot(depthrange_vol(:,1),volumevals,'--');
hold on;
line6=plot(depthrange_vol(:,2),volumevals,'--');
line7=plot(depthrange_vol(:,3),volumevals);
line8=plot(depthrange_vol(:,4),volumevals);
%set(depthvsvol,'xdir','reverse')
xlabel('depth of coastal water (m)'); ylabel('volume (m^3)'); hold off;

rateofvol=subplot(2,2,4);
line9=plot(correspondingDepth{1},rateofVolChange{1},'--');
hold on
line10=plot(correspondingDepth{2},rateofVolChange{2},'--');
line11=plot(correspondingDepth{3},rateofVolChange{3});
line12=plot(correspondingDepth{4},rateofVolChange{4});
ylabel('dV/dd'); xlabel('depth of coastal water (m)'); hold off;
hL = legend([line1,line2,line3,line4],...
    {'7.4mm, horizontal viewing','16.2mm, horizontal viewing','7.4mm, looking up','16.2mm, looking up'});

newPosition = [0.4 0.4 0.2 0.2];
newUnits = 'normalized';
set(hL,'Position', newPosition,'Units', newUnits,'Orientation','horizontal');


%% AIR COMPARISON

IspaceAir=0.97*8.05464E16;
KAir=K_up*10E-3;
aAir=a*10E-3;
T=0.1;

minpupilAir=0.;
maxpupilAir=0.03;

AvalsAir=linspace(minpupilAir,maxpupilAir,100);
rvalsAir=linspace(1,5000,5000);

possibleSolAir=zeros(length(rvalsAir),1);

rangeAir=zeros(length(AvalsAir),1);

for loop1=1:length(AvalsAir)
    AAir=AvalsAir(loop1);
    for loop2=1:length(rvalsAir)
        rAir=rvalsAir(loop2);
        
        eq2_Air=(R*sqrt(q*Dt*(0.617*(T/rAir)^2*(IspaceAir*(2-exp((KAir-aAir)*rAir))))+...
                     2*((T*M)/(2*rAir*d))^2*X*Dt))/...
                     (abs(q*Dt*(-0.617*(T/rAir)^2*(IspaceAir*(exp((KAir-aAir)*rAir))))));
                 
        possibleSolAir(loop2)=eq2_Air;
    end
    IDX_Air=knnsearch(possibleSolAir,AAir,'distance','seuclidean');
    rangeAir(loop1)=rvalsAir(IDX_Air);
end

drdA_air(1)=(rangeAir(2)-rangeAir(1))/(AvalsAir(2)-AvalsAir(1));
for n=2:length(rangeAir)-1
    drdA_air(n)=(rangeAir(n+1)-rangeAir(n-1))/(AvalsAir(n+1)-AvalsAir(n-1));
end
drdA_air(length(rangeAir))=(rangeAir(end)-rangeAir(end-1))/(AvalsAir(end)-AvalsAir(end-1));

drdA_air=drdA_air/max(drdA_air);

for loop1=1:length(rangeAir)
    radius1Air=rangeAir(loop1)*sind(halfCone_degree);
    height1Air=rangeAir(loop1)*cosd(halfCone_degree);
    vol1Air=pi*radius1Air^2*(height1Air/3);
    
    radius2Air=rangeAir(loop1)*sind(halfCone_binocular);
    height2Air=rangeAir(loop1)*cosd(halfCone_binocular);
    vol2Air=pi*radius2Air^2*(height2Air/3);
    
    totalVolAir=2*vol1Air-vol2Air;
    volAir(loop1)=totalVolAir;
end

dVdA_air(1)=(volAir(2)-volAir(1))/(AvalsAir(2)-AvalsAir(1));
for n=2:length(volAir)-1
    dVdA_air(n)=(volAir(n+1)-volAir(n-1))/(AvalsAir(n+1)-AvalsAir(n-1));
end
dVdA_air(length(volAir))=(volAir(end)-volAir(end-1))/(AvalsAir(end)-AvalsAir(end-1));

dVdA_air=dVdA_air/max(dVdA_air);

% allRangeSol
% {1,1} is 100m looking up 
% {1,2} is 100m horizontal, 
% {2,1} is 10m looking up, and 
% {2,2} is 10m horizontal

airandCoastal=figure();
subplot(2,2,1)
airline1=plot(AvalsAir,rangeAir);
hold on;
airline2=plot(aa,allRangeSol{1,1},'--');
xlabel('pupil diameter (m)'); ylabel('range of vision (m)');
hold off;

subplot(2,2,2)
plot(AvalsAir,drdA_air);
hold on;
plot(aa,dervRange{2,1},'--');
xlabel('pupil diameter (m)'); ylabel('dr/dA');
hold off;

subplot(2,2,3)
plot(AvalsAir,volAir);
hold on;
plot(aa,allRangeVol{2,1});
xlabel('pupil diameter (m)'); ylabel('volume (m^3)');
hold off;

subplot(2,2,4);
plot(AvalsAir,dVdA_air);
hold on;
plot(aa, dervVol{2,1},'--');
xlabel('pupil diamter (m)'); ylabel('dV/dA');
hold off;

hL = legend([airline1,airline2],...
    {'In air','10m coastal water'});

newPosition = [0.4 0.4 0.2 0.2];
newUnits = 'normalized';
set(hL,'Position', newPosition,'Units', newUnits,'Orientation','horizontal');
