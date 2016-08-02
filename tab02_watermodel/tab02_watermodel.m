function tab02_watermodel
global BIGEYEROOT
%% VARIABLE INITIALIZATIONS
    run Parameters.m
    load('Parameters.mat');
    run ParametersSensitivity.m
    load('ParametersSensitivity.mat')
    a_Baseline=aAquatic_Daylight; b_Baseline=bAquatic_Daylight;
    
    model_param=xlsread('MAbsDom.xls','model_param');
    Chl.AbsDom=model_param(1); mineral.AbsDom=model_param(2);
    CDOM.AbsDom=model_param(3); omega0.AbsDom=model_param(4);
    secchi.AbsDom=model_param(5);
    
    model_param=xlsread('MClear.xls','model_param');
    Chl.Clear=model_param(1); mineral.Clear=model_param(2);
    CDOM.Clear=model_param(3); omega0.Clear=model_param(4);
    secchi.Clear=model_param(5);
    
    model_param=xlsread('MHighTurbidity.xls','model_param');
    Chl.HighTurbidity=model_param(1); mineral.HighTurbidity=model_param(2);
    CDOM.HighTurbidity=model_param(3); omega0.HighTurbidity=model_param(4);
    secchi.HighTurbidity=model_param(5);
    
    model_param=xlsread('MScatDom.xls','model_param');
    Chl.ScatDom=model_param(1); mineral.ScatDom=model_param(2);
    CDOM.ScatDom=model_param(3); omega0.ScatDom=model_param(4);
    secchi.ScatDom=model_param(5);
    
    model_param=xlsread('Hydrolight_BrownWater.xlsx','model_param');
    Chl.Baseline=model_param(1); mineral.Baseline=model_param(2);
    CDOM.Baseline=model_param(3); omega0.Baseline=model_param(4);
    secchi.Baseline=model_param(5);
    
    columnlabels={' '; 
        'Clear';
        'Absorption Dominated';
        'Baseline River';
        'High Turbidity';
        'Scattering Dominated'};
waterConditions={'Clear','AbsDom','Baseline','HighTurbidity','ScatDom'};
%% ROW DEFINTIONS

%Concentraation parameters

concParam={'Chlorophyll-\emph{a}, mg/m$^3$';
    '"brown earth" minearl particles, gm/m$^3$';
    'CDOM absorption, 1/m at 440~nm'};
for i=1:length(waterConditions)
    ChlValue=Chl.(waterConditions{i});
    mineralValue=mineral.(waterConditions{i});
    CDOMValue=CDOM.(waterConditions{i});
    
    colConc.(waterConditions{i})={num2str(ChlValue);
        num2str(mineralValue);
        num2str(CDOMValue)};
end

IOPParam={'\emph{a}, 1/m';
    '\emph{b}, 1/m';
    '\emph{c}, 1/m';
    'Attenuation length (1/c), m';
    '$\omega_\text{o}$';
    'Secchi depth, m'};
ind=find(lambda==575);
for i=1:length(waterConditions)
    a=eval(strcat('a_',waterConditions{i})); a=a(ind);
    b=eval(strcat('b_',waterConditions{i})); b=b(ind);
    c=a+b; attLength=(1/c);
    omega0Value=omega0.(waterConditions{i});
    secchiValue=secchi.(waterConditions{i});
    
    colIOP.(waterConditions{i})={num2str(a);
        num2str(b);
        num2str(c);
        num2str(attLength);
        num2str(omega0Value);
        num2str(secchiValue)};
end
    
rowLabels=['\textbf{Concentration parameters}';concParam;
    '\textbf{IOPs at 575nm}'; IOPParam];
for i=1:length(waterConditions)
    tab.(waterConditions{i})={' ';colConc.(waterConditions{i});
        ' '; colIOP.(waterConditions{i})};
end

    
    
    
