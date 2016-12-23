function tabExt02_watermodel
global BIGEYEROOT
%% VARIABLE INITIALIZATIONS
    run Parameters.m
    load('Parameters.mat');
    run ParametersSensitivity.m
    load('ParametersSensitivity.mat')
    a.Baseline=aAquatic.Daylight; b.Baseline=bAquatic.Daylight;
    
    model_param=xlsread('MAbsDom.xls','model_param');
    Chl.AbsDom=model_param(1); mineral.AbsDom=model_param(2);
    CDOM.AbsDom=model_param(3); omega0.AbsDom=model_param(5);
    secchi.AbsDom=model_param(4);
    
    model_param=xlsread('MClear.xls','model_param');
    Chl.Clear=model_param(1); mineral.Clear=model_param(2);
    CDOM.Clear=model_param(3); omega0.Clear=model_param(5);
    secchi.Clear=model_param(4);
    
    model_param=xlsread('MHighTurbidity.xls','model_param');
    Chl.HighTurbidity=model_param(1); mineral.HighTurbidity=model_param(2);
    CDOM.HighTurbidity=model_param(3); omega0.HighTurbidity=model_param(5);
    secchi.HighTurbidity=model_param(4);
    
    model_param=xlsread('MScatDom.xls','model_param');
    Chl.ScatDom=model_param(1); mineral.ScatDom=model_param(2);
    CDOM.ScatDom=model_param(3); omega0.ScatDom=model_param(5);
    secchi.ScatDom=model_param(4);
    
    model_param=xlsread('Hydrolight_BrownWater.xlsx','model_param');
    Chl.Baseline=model_param(1); mineral.Baseline=model_param(2);
    CDOM.Baseline=model_param(3); omega0.Baseline=model_param(5);
    secchi.Baseline=model_param(4);
    
    columnLabels={
        '\textbf{Clear}';
        '\textbf{Absorption} \textbf{Dominated}';
        '\textbf{Baseline} \textbf{River}';
        '\textbf{High} \textbf{Turbidity}';
        '\textbf{Scattering} \textbf{Dominated}'};
    
waterConditions={'ScatDom','HighTurbidity','Baseline','AbsDom','Clear'};
waterConditions=fliplr(waterConditions);
%% ROW DEFINTIONS

%Concentraation parameters
q = char(39);
brownearth = strcat(' `` ', 'brown earth', q, q, ' mineral particles, g/m$^3$' );

concParam={'Chlorophyll-\emph{a}, mg/m$^3$';
    brownearth;
    'CDOM absorption, 1/m at 440~nm'};
for i=1:length(waterConditions)
    ChlValue=Chl.(waterConditions{i});
    mineralValue=mineral.(waterConditions{i});
    CDOMValue=CDOM.(waterConditions{i});
    
    colConc.(waterConditions{i})={num2str(ChlValue,'%.2f');
        num2str(mineralValue,'%.2f');
        num2str(CDOMValue,'%.2f')};
end

IOPParam={'\emph{a}, 1/m';
    '\emph{b}, 1/m';
    '\emph{c}, 1/m';
    'Attenuation length (1/\emph{c}), m';
    '$\omega_\text{o}$';
    'Secchi depth, m'};
ind=find(lambda==575);
waterConditions=fliplr(waterConditions);
for i=1:length(waterConditions)
    aValue=a.(waterConditions{i}); aValue=aValue(ind);
    bValue=b.(waterConditions{i}); bValue=bValue(ind);
    c=aValue+bValue; attLength=(1/c);
    omega0Value=omega0.(waterConditions{i});
    secchiValue=secchi.(waterConditions{i});
    
    colIOP.(waterConditions{i})={num2str(aValue,'%.2f');
        num2str(bValue,'%.2f');
        num2str(c,'%.2f');
        num2str(attLength,'%.2f');
        num2str(omega0Value,'%.2f');
        num2str(secchiValue,'%.2f')};
end
    
rowLabels=[' ';'\textbf{Concentration parameters}';concParam;
    '\textbf{IOPs at 575~nm}'; IOPParam];
rowValues=[];
for i=1:length(waterConditions)
    tab.(waterConditions{i})=[columnLabels{i};' ';colConc.(waterConditions{i});
        ' '; colIOP.(waterConditions{i})];
    rowValues=[tab.(waterConditions{i}) rowValues];
end

filename = [BIGEYEROOT 'tabExt02_watermodel/tabExt02_watermodel.tex']; 
title='Water Type';

matrix2latex(rowValues,rowLabels,title,filename);


function matrix2latex(rowvalues,rowlabels,title,filename)
matrix=[rowlabels rowvalues];
collabels=matrix(1,:);
line1=''; line2='';
for i=1:length(collabels)
    c{i}=strsplit(collabels{i});
    if length(c{i})==1;
        c{i}{2}=' ';
    end
    line1=strcat('&',c{i}{1},line1);
    line2=strcat('&',c{i}{2},line2);
end
line1=line1(1:end-1); line2=line2(1:end-1);
line1=strcat(line1,'\\'); line2=strcat(line2,'\\');

fid = fopen(filename, 'w');

str='';
for i=1:size(matrix,2)
    temp='l';
    str=strcat(str,temp);
end
str(1)='g';
str(4)='a';

fprintf(fid, '\\begin{tabular}{%s}\r\n',str);
fprintf(fid,'\\toprule\r\n');
fprintf(fid,'\\rowcolor{Gray}\r\n');
fprintf(fid,' &\\multicolumn{%s}{c}{\\LARGE\\color{white} %s}\\\\\r\n',num2str(size(rowvalues,2)),title);
%fprintf(fid,'\\\\\\otoprule\r\n');
fprintf(fid, '%s\r\n',line1);
fprintf(fid,'%s\r\n',line2);
for i=2:size(matrix,1)
    str='';
    for j=1:size(matrix,2)
        str=strcat(str,'&',matrix{i,j});      
    end
    str=str(2:end);
    str=strcat('\color{white}',str);
    if ~isempty(findstr(matrix{i,j},'Concentration parameters'))||~isempty(findstr(matrix{i,j},'IOP'))
        str=strrep(str,'\color{white}','');
    end
    fprintf(fid, '%s\\\\\r\n',str);
end
fprintf(fid,'\\bottomrule\r\n');
fprintf(fid,'\\end{tabular}\r\n');
fclose(fid);
        
    