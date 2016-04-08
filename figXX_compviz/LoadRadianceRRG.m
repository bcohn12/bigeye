clear all;

%EVERYTHING CONVERTED TO nm
lambdaQueryNano=linspace(400,700,3000)';

lambdaDaylight=csvread('daylightRadiance.csv');
lambdaD=lambdaDaylight(:,1)*10^3;%nm
daylightRadiance=lambdaDaylight(:,2)*10*1e-3; %W/(m^2 sr s nm)
IlambdaDaylight=@(l)(interp1(lambdaD,daylightRadiance,l,'pchip'));
daylightRadianceInterp=interp1(lambdaD,daylightRadiance,lambdaQueryNano,'pchip');

lambdaVegetative=csvread('vegetativeRadiance.csv');
lambdaV=lambdaVegetative(:,1); %nm
vegetativeRadiance=lambdaVegetative(:,2); %W/(m^2 sr s nm)
IlambdaVegetative=@(l) interp1(lambdaV,vegetativeRadiance,l,'pchip');
vegetativeRadianceInterp=interp1(lambdaV,vegetativeRadiance,lambdaQueryNano,'pchip');

lambdaStarlight=csvread('starlightRadiance.csv');
lambdaS=lambdaStarlight(:,1)*10^3;  %nm
starlightRadiance=lambdaStarlight(:,2)*1e-3; %W/(m^2 sr s nm)
IlambdaStarlight=@(l) interp1(lambdaS,starlightRadiance,l,'pchip');
starlightRadianceInterp=interp1(lambdaS,starlightRadiance,lambdaQueryNano,'pchip');

lambdaMoonlight=csvread('moonlightRadiance.csv');
lambdaM=lambdaMoonlight(:,1)*10^3; %nm 
moonlightRadiance=lambdaMoonlight(:,2)*1e-3; %W/(m^2 sr s nm)
IlambdaMoonlight=@(l) (interp1(lambdaM,moonlightRadiance,l,'pchip'));
moonlightRadianceInterp=interp1(lambdaM,moonlightRadiance,lambdaQueryNano,'pchip');

figure()
subplot(2,1,1)
plot(lambdaQueryNano,daylightRadianceInterp);
hold on;
plot(lambdaQueryNano,vegetativeRadianceInterp)
xlabel('\lambda (nm)'); ylabel('W/m^2srsnm')
legend('daylight radiance','vegetative radiance','location','northoutside','orientation','horizontal');
hold off;

subplot(2,1,2)
plot(lambdaQueryNano,moonlightRadianceInterp);
hold on;
plot(lambdaQueryNano,starlightRadianceInterp);
xlabel('\lambda (nm)'); ylabel('W/m^2srsnm')
legend('moonlight radiance','starlight radiance','location','northoutside','orientation','horizontal')
hold off;

RRGGreen=csvread('RRGGreen.csv');
lambdaRRGGreen=RRGGreen(:,1); %nm
RRGGreen=RRGGreen(:,2); %unitless ratio
RRGGreenFunc=@(l) interp1(lambdaRRGGreen,RRGGreen,l,'pchip');
RRGGreenInterp=interp1(lambdaRRGGreen,RRGGreen,lambdaQueryNano,'pchip');

RRGBlack=csvread('RRGBlack.csv');
lambdaRRGBlack=RRGBlack(:,1);  %nm
RRGBlack=RRGBlack(:,2); %unitless ratio
RRGBlackFunc=@(l) interp1(lambdaRRGBlack,RRGBlack,l,'pchip');
RRGBlackInterp=interp1(lambdaRRGBlack,RRGBlack,lambdaQueryNano,'pchip');

figure()
plot(lambdaQueryNano,RRGGreenInterp);
hold on
plot(lambdaQueryNano,RRGBlackInterp);
xlabel('\lambda (nm)'); ylabel('RRG');
legend('green horizontal','black','location','southoutside','orientation','horizontal');

save('RadianceRRG',...
    'lambdaD', 'lambdaV','lambdaM','lambdaS','lambdaRRGGreen','lambdaRRGBlack',...
    'daylightRadiance','vegetativeRadiance','moonlightRadiance','starlightRadiance',...
    'RRGGreen','RRGBlack')


