function tab02_watermodel
global BIGEYEROOT
    run Parameters.m
    load('Parameters.mat');
    run ParametersSensitivity.m
    load('ParametersSensitivity.mat')
    
    model_param=xlsread('MAbsDom.xls','model_param');
    Chl_AbsDom=model_param(1); mineral_AbsDom=model_param(2);
    CDOM_AbsDom=model_param(3); omega0_AbsDom=model_param(4);
    secchi_AbsDom=model_param(5);
    
    model_param=xlsread('MClear.xls','model_param');
    Chl_Clear=model_param(1); minearl_Clear=model_param(2);
    CDOM_Clear=model_param(3); omega0_Clear=model_param(4);
    secchi_Clear=model_param(5);
    
    model_param=xlsread('MHighTurbidity.xls','model_param');
    Chl_HighTurbidity=model_param(1); minearl_HighTurbidity=model_param(2);
    CDOM_HighTurbidity=model_param(3); omega0_HighTurbidity=model_param(4);
    secchi_HighTurbidity=model_param(5);
    
    model_param=xlsread('MScatDom.xls','model_param');
    Chl_ScatDom=model_param(1); minearl_ScatDom=model_param(2);
    CDOM_ScatDom=model_param(3); omega0_ScatDom=model_param(4);
    secchi_ScatDom=model_param(5);
    
    model_param=xlsread('Hydrolight_BrownWater.xlsx','model_param');
    Chl_Baseline=model_param(1); minearl_Baseline=model_param(2);
    CDOM_Baseline=model_param(3); omega0_Baseline=model_param(4);
    secchi_Baseline=model_param(5);
    
    