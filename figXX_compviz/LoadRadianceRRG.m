clear all;

%EVERYTHING CONVERTED TO nm

lambdaDaylight=csvread('convertedDaylight.csv');
lambdaD=lambdaDaylight(:,1); %m
daylightRadiance=lambdaDaylight(:,2); %W/(m^2 sr m)

lambdaVegetative=csvread('vegetativeRadiance.csv');
lambdaV=lambdaVegetative(:,1); %m
vegetativeRadiance=lambdaVegetative(:,2); %W/(m^2 sr s m)

lambdaStarlight=csvread('starlightRadiance.csv');
lambdaS=lambdaStarlight(:,1)*10^3;  %m
starlightRadiance=lambdaStarlight(:,2)*1e-3; %W/(m^2 sr s m)

lambdaMoonlight=csvread('moonlightRadiance.csv');
lambdaM=lambdaMoonlight(:,1)*10^3; %m 
moonlightRadiance=lambdaMoonlight(:,2)*1e-3; %W/(m^2 sr s m)

RRGGreen=csvread('RRGGreen.csv');
lambdaRRGGreen=RRGGreen(:,1); %m
RRGGreen=RRGGreen(:,2); %unitless ratio

RRGBlack=csvread('RRGBlack.csv');
lambdaRRGBlack=RRGBlack(:,1);  %m
RRGBlack=RRGBlack(:,2); %unitless ratio

save('RadianceRRG',...
    'lambdaD', 'lambdaV','lambdaM','lambdaS','lambdaRRGGreen','lambdaRRGBlack',...
    'daylightRadiance','vegetativeRadiance','moonlightRadiance','starlightRadiance',...
    'RRGGreen','RRGBlack')


