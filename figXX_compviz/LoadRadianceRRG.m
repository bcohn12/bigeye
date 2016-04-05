clear all;

lambdaQueryMicro=linspace(0.4,0.7,3000)'; lambdaQueryNano=linspace(400,700,3000)';

lambdaDaylight=csvread('daylightRadiance.csv');
lambdaD=lambdaDaylight(:,1); daylightRadiance=lambdaDaylight(:,2);
IlambdaDaylight=@(l)(interp1(lambdaD,daylightRadiance,l,'pchip'));
daylightRadianceInterp=interp1(lambdaD,daylightRadiance,lambdaQueryMicro,'pchip')*10;

lambdaVegetative=csvread('vegetativeRadiance.csv');
lambdaV=lambdaVegetative(:,1); vegetativeRadiance=lambdaVegetative(:,2);
IlambdaVegetative=@(l) interp1(lambdaV,vegetativeRadiance,l,'pchip');
vegetativeRadianceInterp=interp1(lambdaV,vegetativeRadiance,lambdaQueryNano,'pchip');

lambdaStarlight=csvread('starlightRadiance.csv');
lambdaS=lambdaStarlight(:,1); starlightRadiance=lambdaStarlight(:,2);
IlambdaStarlight=@(l) interp1(lambdaS,starlightRadiance,l,'pchip');
starlightRadianceInterp=interp1(lambdaS,starlightRadiance,lambdaQueryMicro,'pchip');

lambdaMoonlight=csvread('moonlightRadiance.csv');
lambdaM=lambdaMoonlight(:,1); moonlightRadiance=lambdaMoonlight(:,2);
IlambdaMoonlight=@(l) (interp1(lambdaM,moonlightRadiance,l,'pchip'));
moonlightRadianceInterp=interp1(lambdaM,moonlightRadiance,lambdaQueryMicro,'pchip');

figure()
subplot(2,1,1)
plot(lambdaQueryMicro,daylightRadianceInterp);
hold on;
plot(lambdaQueryNano*10^-3,vegetativeRadianceInterp*10^3)
xlabel('\lambda (\mu m)'); ylabel('W/m^2srs\mu m')
legend('daylight radiance','vegetative radiance','location','northoutside','orientation','horizontal');
hold off;

subplot(2,1,2)
plot(lambdaQueryMicro,moonlightRadianceInterp);
hold on;
plot(lambdaQueryMicro,starlightRadianceInterp);
xlabel('\lambda (\mu m)'); ylabel('W/m^2srs\mu m')
legend('moonlight radiance','starlight radiance','location','northoutside','orientation','horizontal')
hold off;

RRGGreen=csvread('RRGGreen.csv');
lambdaRRGGreen=RRGGreen(:,1); RRGGreen=RRGGreen(:,2);
RRGGreenFunc=@(l) interp1(lambdaRRGGreen,RRGGreen,l,'pchip');
RRGGreenInterp=interp1(lambdaRRGGreen,RRGGreen,lambdaQueryNano,'pchip');

RRGBlack=csvread('RRGBlack.csv');
lambdaRRGBlack=RRGBlack(:,1); RRGBlack=RRGBlack(:,2);
RRGBlackFunc=@(l) interp1(lambdaRRGBlack,RRGBlack,l,'pchip');
RRGBlackInterp=interp1(lambdaRRGBlack,RRGBlack,lambdaQueryNano,'pchip');

figure()
plot(lambdaQueryNano,RRGGreenInterp);
hold on
plot(lambdaQueryNano,RRGBlackInterp);
xlabel('\lambda (nm)'); ylabel('RRG');
legend('green horizontal','black','location','southoutside','orientation','horizontal');

save('RadianceRRG','daylightRadianceInterp','vegetativeRadianceInterp',...
    'moonlightRadianceInterp','starlightRadianceInterp',...
    'RRGGreenInterp','RRGBlackInterp',...
    'IlambdaDaylight','IlambdaVegetative','IlambdaMoonlight','IlambdaStarlight',...
    'RRGGreenFunc','RRGBlackFunc','lambdaQueryMicro','lambdaQueryNano')


