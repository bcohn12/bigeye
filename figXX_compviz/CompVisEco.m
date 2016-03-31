clear all; close all;

%% PARAMETERS
q=0.36;
Dt=1.16; %s
X=2.8e-5; %1/s
R=1.96;
d=3e-6; %m
M=2.55;
E=10e11; %quanta/s from Fig 3
x=0.3; %m

a_oceanic=0.0468;
K_oceanic_up=0.0385;
K_oceanic_hor=0;
K_oceanic_down=-0.0385;

a_coastal=0.3;
K_coastal_up=0.14;
K_coastal_hor=0;
K_coastal_down=-0.14;

Ispace_oceanic_up=6.28e14; %quanta/m^2ssr
Ispace_oceanic_hor=5.11e13; %quanta/m^2ssr
Ispace_oceanic_down=2.9e13; %quanta/m^2ssr

Ispace_coastal_up=7.94e13; %quanta/m^2ssr
Ispace_coastal_hor=6.46e12; %quanta/m^2ssr
Ispace_coastal_down=3.67e12; %quanta/m^2ssr

att_oceanic_up=1.638; %dB/100m
att_oceanic_hor=1.677; %dB/100m
att_oceanic_down=1.6680; %dB/100m

att_coastal_up=2.29; %dB/100m
att_coastal_hor=2.34; %dB/100m
att_coastal_down=2.33; %dB/100m

%% FIG 3
T =0.3; %m width of prey
P=(pi*T^3)/(2.86*x^3); %Section 2f SB, approaching target - number of point sources seen by a visual channel
                                    % viewing an extended target
 % Setting P to zero for black object WITHOUT bioluminescence, different from what Nilsson et al did for fig 3
 
 % P=0

%based on depth and known attenuation calculate new Ispace values for
%caostal and oceanic, must be normalized with respect to 200 since the
%values are taken at 200, and divided by 100 due to per 100m attenuation

coastal_depth = 120;
newIspace_coastal= 10^(att_coastal_down/100*(200-coastal_depth))*Ispace_coastal_up;

oceanic_depth = 470;
newIspace_oceanic=10^(att_oceanic_hor/100*(200-oceanic_depth))*Ispace_oceanic_up;

%Create a list of pupil diameter (A) values, and corresponding range of
%vision (r) values.
Avals=linspace(0,0.03,50);rvals=linspace(0.001,100,700);
possibleSol_coastal=zeros(length(rvals),length(Avals)); possibleSol_oceanic=zeros(length(rvals),length(Avals));

%For each of the A values and r values calculate the equation given in
%(2.31). The result of the equation should equal A, therefore after all r
%values are iterated through do a nearest neighbor search with distance
%metric normalized euclidean to find the idx in r that is closest to A,
%store it as a solution to the equation. 
for loop1=1:length(Avals)
    A=Avals(loop1);
    for loop2=1:length(rvals)  
        r=rvals(loop2);
        eq1_coastal=(R*sqrt(q*Dt*(P*((E*A^2)/(16*r^2))*exp(-a_coastal*r)+...
            0.617*(T/r)^2*(newIspace_coastal*(2-exp((K_coastal_up-a_coastal)*r))))+...
            2*((T*M)/(2*r*d))^2*X*Dt))/...
            (abs(q*Dt*((P*((E*A^2)/(16*r^2))*exp(-a_coastal*r))-...
            0.617*(T/r)^2*(newIspace_coastal*exp((K_coastal_up-a_coastal)*r)))));

        eq1_oceanic=(R*sqrt(q*Dt*(P*((E*A^2)/(16*r^2))*exp(-a_oceanic*r)+...
            0.617*(0.1/r)^2*(newIspace_oceanic*(2-exp((K_oceanic_up-a_oceanic)*r))))+...
            2*((0.1*M)/(2*r*d))^2*X*Dt))/...
            (abs(q*Dt*((P*((E*A^2)/(16*r^2))*exp(-a_oceanic*r))-...
            0.617*(0.1/r)^2*(newIspace_oceanic*exp((K_oceanic_up-a_oceanic)*r)))));

        possibleSol_coastal(loop2,loop1)=eq1_coastal;
        possibleSol_oceanic(loop2,loop1)=eq1_oceanic;
    
    end

    IDX_coastal = knnsearch(possibleSol_coastal(:,loop1),A,'distance','seuclidean');
    IDX_oceanic=knnsearch(possibleSol_oceanic(:,loop1),A,'distance','seuclidean');
    visRange_coastal(loop1) = rvals(IDX_coastal);
    visRange_oceanic(loop1)=rvals(IDX_oceanic);
end

%Calculate dr/dA, as diff(r)./diff(A)
aa=Avals;

%Calculate the diff by using forward, central and backward difference.
%Should be slightly more accurate than MATLAB's diff. 
delta=1;
drda_c(1)=(visRange_coastal(delta+1)-visRange_coastal(1))/(aa(delta+1)-aa(1));
drda_o(1)=(visRange_oceanic(delta+1)-visRange_oceanic(1))/(aa(delta+1)-aa(1));
indx=2;
for n=2*delta:delta:length(visRange_coastal)-1
    drda_c(indx)=(visRange_coastal(n+1)-visRange_coastal(n-1))/(aa(n+1)-aa(n-1)); 
    drda_o(indx)=(visRange_oceanic(n+1)-visRange_oceanic(n-1))/(aa(n+1)-aa(n-1));
    indx=indx+1;
end
drda_c(length(visRange_coastal))=(visRange_coastal(end)-visRange_coastal(end-delta))/(aa(end)-aa(end-delta));
drda_o(length(visRange_oceanic))=(visRange_oceanic(end)-visRange_oceanic(end-delta))/(aa(end)-aa(end-delta));

%Normalize to 1
drda_c=drda_c/max(drda_c);
drda_o=drda_o/max(drda_o);

%Calculate visual volume
%This seems to work for a sphere but that doesn't make sense to me
solid_angle=((aa./visRange_coastal).^2).*...
    newIspace_coastal.*(2-exp((K_coastal_up-a_coastal).*visRange_coastal)); %solid angle created by pupil diameter and visual range

r_volume_coastal = solid_angle.*(1/3).*(visRange_coastal).^3;
r_volume_oceanic = (4/3)*pi*(visRange_oceanic).^3;

%Plot visual range(1,1), derivative(1,2), visual volume(2,1),
%derivative(2,2)
fig3=figure();
Avsrange=subplot(2,2,1);
plot(aa,visRange_coastal,':','color','k')
hold on;
plot(aa,visRange_oceanic,'--','color','k')
xlabel('pupil diameter (m)'); ylabel('visual range (m)');
set(Avsrange,'YTick',[0 20 40 60],'XTick',[0.01,0.02,0.03]);
hold off;
Avsdrda=subplot(2,2,2);
plot(aa,(drda_c),':','color','k')
hold on
plot(aa,(drda_o),'--','color','k')
xlabel('pupil diameter (m)'); ylabel('performance return');
set(Avsdrda,'YTick',[0 1], 'XTick', [0.01 0.02 0.03]);
hold off

% Avsv=subplot(2,2,3);
% plot(Avals,r_volume_coastal,':','color','k')
% hold on
% plot(Avals,r_volume_oceanic,'--','color','k')
% xlabel('pupil diameter (m)'); ylabel('visual volume (m^3)')
% set(Avsv,'XTick', [0.01 0.02 0.03]);
% hold off;
% 
% Avsdvda=subplot(2,2,4);
% plot(Avals(2:end),drvda_coastal,':','color','k')
% hold on;
% plot(Avals(2:end),drvda_oceanic,'--','color','k')
% 

%% Fig 5
T_d=0.1;

%Visual range of black extended targets with no bioluminesence reduces the
%equation given in (2.31) since E=0, which gets rid of the
%P((EA^2)/(rd^2))exp(-ar) term

%Create visual range (r) and depth values to iterate over
rvals_depth = linspace(0.001,50,100);

mindepth=0;
maxdepth=200;
depthvals=linspace(maxdepth,mindepth,700);
Avals_depth=[0.002,0.01,0.03]; %diameter of pupil for depth

possibleSol_coastal_depth=zeros(length(rvals_depth),1); possibleSol_oceanic_depth=zeros(length(rvals_depth),1);
%Iterate over all diameters
%For a chosen diameter and range of vision (r) iterate over all depth
%values. Based on the depth value Ispace is calculated as:
%Ispace=10^(attenuation/100*(200-depth))*Ispace to account for the
%attenuation. Based on the new Ispace value calculate the modified
%equation. This equation should equal pupil diameter (A). By nearest
%neighbor, search the possible solutions array to find the solution that is
%closest to A, and store it as a solution of depth for a given range of
%vision
for loop1=1:length(Avals_depth)
    A=Avals_depth(loop1);
    for loop2=1:length(rvals_depth)
        r_d=rvals_depth(loop2);
        for loop3=1:length(depthvals);
            cur_depth=depthvals(loop3);
           
            % HORIZONTAL VIEWING
            newIspace_coastal= 10^(att_coastal_hor/100*(200-cur_depth))*Ispace_coastal_hor;
            newIspace_oceanic=10^(att_oceanic_hor/100*(200-cur_depth))*Ispace_oceanic_hor;
            
            eq2_coastal=(R*sqrt(q*Dt*(0.617*(T_d/r_d)^2*(newIspace_coastal*(2-exp((K_coastal_hor-a_coastal)*r_d))))+...
                2*(T_d*M/(2*r_d*d))^2*X*Dt))/...
                (abs(q*Dt*(-0.617*(T_d/r_d)^2*(newIspace_coastal*(exp((K_coastal_hor-a_coastal)*r_d))))));
        
            eq2_oceanic=(R*sqrt(q*Dt*(0.617*(T_d/r_d)^2*(newIspace_oceanic*(2-exp((K_oceanic_hor-a_oceanic)*r_d))))+...
                2*(T_d*M/(2*r_d*d)^2)*X*Dt))/...
                (abs(q*Dt*(-0.617*(T_d/r_d)^2*(newIspace_oceanic*(exp((K_oceanic_hor-a_oceanic)*r_d))))));
           
                 % UP VIEWING  - COASTAL ONLY
            %newIspace_coastal= 10^(att_coastal_up/100*(200-cur_depth))*Ispace_coastal_up;
            
            %eq2_coastal=(R*sqrt(q*Dt*(0.617*(T_d/r_d)^2*(newIspace_coastal*(2-exp((K_coastal_up-a_coastal)*r_d))))+...
              %  2*(T_d*M/(2*r_d*d))^2*X*Dt))/...
                %(abs(q*Dt*(-0.617*(T_d/r_d)^2*(newIspace_coastal*(exp((K_coastal_up-a_coastal)*r_d))))));
        
                
                
                
            possibleSol_coastal_depth(loop3)=eq2_coastal;
            possibleSol_oceanic_depth(loop3)=eq2_oceanic;
        end
        IDX_coastal_depth=knnsearch(possibleSol_coastal_depth,A,'distance','seuclidean');
        IDX_oceanic_depth=knnsearch(possibleSol_oceanic_depth,A,'distance','seuclidean');
        depth_sea_coastal(loop1,loop2)=depthvals(IDX_coastal_depth);
        depth_sea_oceanic(loop1,loop2)=depthvals(IDX_oceanic_depth);
    end
end

viewDepth= 50;

%For a given depth value of viewDepth calculate the Ispace value for each view
%point
newIspacevals_c= [10^(att_coastal_up/100*(200-viewDepth))*Ispace_coastal_up,...
    10^(att_coastal_hor/100*(200-viewDepth))*Ispace_coastal_hor,...
    10^(att_coastal_down/100*(200-viewDepth))*Ispace_coastal_down];
newIspacevals_o=[10^(att_oceanic_up/100*(200-viewDepth))*Ispace_oceanic_up,...
    10^(att_oceanic_hor/100*(200-viewDepth))*Ispace_oceanic_hor,...
    10^(att_oceanic_down/100*(200-viewDepth))*Ispace_oceanic_down];
Kvals_coastal=[0.14,0,-0.14];
Kvals_oceanic=[0.0385,0,-0.0385];

Avals=linspace(0,0.09,100);
rvals_or=linspace(0.001,200,5000);
possibleSol_or_c=zeros(length(rvals),1); possibleSol_or_o=zeros(length(rvals),1);

%Iterate over all pupil diameters (A) and range of vision (r) to calculate
%the result of the modified equation with E=0. Similar to the procedure
%above find the value in the vector of possible solutions that is closes to
%A (expected solution) and store it as a solution for range of vision given
%a pupil diameter. 
for loop1=1:length(newIspacevals_c)
    newIspace_c=newIspacevals_c(loop1);
    newIspace_o=newIspacevals_o(loop1);
   
    K_c=Kvals_coastal(loop1);
    K_o=Kvals_oceanic(loop1);
    for loop2=1:length(Avals)
        A=Avals(loop2);
        for loop3=1:length(rvals_or)
            r_o=rvals_or(loop3);
            eq2_or_coastal=(R*sqrt(q*Dt*(0.617*(T_d/r_o)^2*(newIspace_c*(2-exp((K_c-a_coastal)*r_o))))+...
                2*(T_d*M/(2*r_o*d))^2*X*Dt))/...
                (abs(q*Dt*(-0.617*(T_d/r_o)^2*(newIspace_c*(exp((K_c-a_coastal)*r_o))))));
            eq2_or_oceanic=(R*sqrt(q*Dt*(0.617*(T_d/r_o)^2*(newIspace_o*(2-exp((K_o-a_oceanic)*r_o))))+...
                2*(T_d*M/(2*r_o*d))^2*X*Dt))/...
                (abs(q*Dt*(-0.617*(T_d/r_o)^2*(newIspace_o*(exp((K_o-a_oceanic)*r_o))))));
            
            possibleSol_or_c(loop3)=eq2_or_coastal;
            possibleSol_or_o(loop3)=eq2_or_oceanic;
        end
        IDX_or_c=knnsearch(possibleSol_or_c,A,'distance','seuclidean');
        IDX_or_o=knnsearch(possibleSol_or_o,A,'distance','seuclidean');
        orientation_coastal(loop1,loop2)=rvals_or(IDX_or_c);
        orientation_oceanic(loop1,loop2)=rvals_or(IDX_or_o);
    end
end

%Plot range of vision vs. depth (1) and pupil diameter vs orientation (2)
fig5=figure();
rvsd=subplot(2,1,1);
plot(rvals_depth,depth_sea_coastal,'--'); 
hold on;
plot(rvals_depth,depth_sea_oceanic); 
axis ij; xlabel('range of vision (m)'); ylabel('depth in the sea (m)');
legend('2mm pupil, coastal water, horizontal viewing, 0.1m black target',...
    '10mm',...
    '30mm',...
    '2mm pupil, oceainic water, horizontal viewing, 0.1m black target',...
    '10mm ',...
    '30mm ',...
    'Location','bestoutside','orientation','horizontal')
%set(rvsd,'YTick',[200 300 400 500 600 700],'XTick',[0 10 20 30 40 50]);

Avsr=subplot(2,1,2);
plot(Avals,orientation_coastal);
hold on;
%plot(Avals,orientation_oceanic);
xlabel('pupil diameter (m)'); ylabel('range of vision (m)');
legend('looking up','horizontal','looking down','location','bestoutside',...
    'orientation','horizontal')
title([ num2str(viewDepth) 'm coastal water, ' num2str(T_d) 'm black target'])
%set(Avsr,'YTick',[0 10 15 20],'XTick',[0.03 0.06 0.09]);





