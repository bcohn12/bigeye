function bigEye2TexTable()
%% bigEye2TexTable()

% Need to make the columns of the tables fixed width
% See this post for how to do that:
% http://goo.gl/au5WbG

% Row addresses for the tetrapodomorph fish
tetrapodomorph_fish_startRow = 3;
tetrapodomorph_fish_endRow = 23;


% Row addresses for the stem tetrapods
stem_tetrapod_startRow = 27;
stem_tetrapod_endRow = 57;


% Key column addresses in spreadsheet
stageBegin=4;    % start of stratigraphic period
stageEnd=5;      % end of stratigraphic period
genusCol = 2;    % genus
speciesCol = 3;  % species
refKeyCol = 15;  % bibtex ref key
lengthCol = 16;  % PPL
eyeCol = 20;     % OM


circleMax=60;    % max size of normalized eye, points

%%

% Specify Needed Species Here
TFind = [tetrapodomorph_fish_startRow:tetrapodomorph_fish_endRow]' ;    % Tetrapodomorph Fish
STind = [stem_tetrapod_startRow:stem_tetrapod_endRow]' ; % Stem Tetrapods

% Read bigEye
gdat=GetGoogleSpreadsheet('1xlwAnje_WiQ0Owl6vBdQMF9odDUDE439ydRI3mU9cks');

try gdat==0
     disp('REVERTING TO LOCAL BIGEYE FILE')
     load('localBigEye.mat')
catch
    save('localBigEye.mat', 'gdat');
end


%% Convert to LaTeX Table

[TF_orbit_length_span, gsTF]=loc_ConvData(gdat,TFind,lengthCol,refKeyCol,eyeCol,genusCol,speciesCol,stageBegin,stageEnd,'TFout.tex');
[ST_orbit_length_span, gsST]=loc_ConvData(gdat,STind,lengthCol,refKeyCol,eyeCol,genusCol,speciesCol,stageBegin,stageEnd,'STout.tex');

% Set up for two panel figure
close all
fig_props.noYsubplots = 1;
fig_props.noXsubplots = 2;

fig_props.figW = 18;   % cm
fig_props.figH = 10;  % cm

fig_props.ml = 0.8;
fig_props.mt = 0.8;

create_BE_figure
fig_props.sub_pW = fig_props.sub_pW-.5;
time_subsamp = 1;
time_limit = 0.4;
text_pos = [-5,2*time_limit/10,50];
text_color = [0 0 0];
text_size = 12;
pn = {'Color','FontSize','FontWeight',};
pv = {text_color,text_size,'bold'};

plotnoX = 1;
plotnoY = 1;
ha1 = create_BE_axes(plotnoX,plotnoY,fig_props);

% Data analysis on table information

% ratio of OM to PPL
datTF = (TF_orbit_length_span(:,1)./TF_orbit_length_span(:,2));
disp('Mean TF OM')
mean(TF_orbit_length_span(:,1))

disp('Mean ST OM')
mean(ST_orbit_length_span(:,1))

datST = (ST_orbit_length_span(:,1)./ST_orbit_length_span(:,2));
padding =zeros(3,3);
spanTF=[TF_orbit_length_span(:,4) TF_orbit_length_span(:,3)];
spanST=[ST_orbit_length_span(:,4) ST_orbit_length_span(:,3)];

durationTF=spanTF(:,2)-spanTF(:,1);
durationST=spanST(:,2)-spanST(:,1);

% xlswrite('temp.xlsx',[spanTF durationTF; padding; spanST durationST])


%hl=line(1:length(datTF),sort(100.*datTF),'linestyle','none','marker','o','markerEdgeColor','none', ...
%     'markerFaceColor',[1 0 0])

hl1=scatter(1:length(datTF),sort(100.*datTF),35,[1 0 0],'filled');
hold on


alpha(hl1,0.5)
%line(length(datTF)+1:length(datTF)+length(datST),sort(100.*datST),'linestyle','none','marker','o','markerEdgeColor','blue')

hl2=scatter(length(datTF)+1:length(datTF)+length(datST),sort(100.*datST),35,[0 0 1],'filled');
alpha(hl2,0.5)

[h,icons,plots,s]=legend('TF','ST','Location','NorthWest');
set(icons(3).Children,'FaceAlpha',0.5)
set(icons(4).Children,'FaceAlpha',0.5)

legend('boxoff')
xlabel('Specimen #')
ylabel('Orbit length as % of skull length')


plotnoX = 2;
plotnoY = 1;
ha2 = create_BE_axes(plotnoX,plotnoY,fig_props);
histogram(log10(datST), 5)
hold on
histogram(log10(datTF), 5)
xlim([-1.4 -0.2])
legend('ST', 'TF','Location','NorthWest')
legend('boxoff')
xlabel('log(orbit/skull length)')
box off

print(gcf, '-dpdf', mfilename('fullpath'));




%% T test
disp('T Test')
%[h, p, ci, stats] = ttest2(datST, datTF, 'Vartype', 'unequal','tail','right')
[htt, ptt, citt, statstt] = ttest2(datST, datTF, 'Vartype', 'unequal')

%% Rank Sum?
disp('Rank Sum:')
[prs,hrs,statsrs] = ranksum(datST, datTF)

%% ks test on skull length
disp('KS Test')
[hks,pks,ks2stat] = kstest2(datST,datTF)


% Format stat result text for paper
formattedstring = [ ...
    ' The ' ...
    'tetrapodomorph fish had orbits that were $' num2str(mean(TF_orbit_length_span(:,1)),2) ...
    ' \pm ' num2str(std(TF_orbit_length_span(:,1)),2) '$~mm long (all numbers mean $\pm$ standard deviation), ' ...
    'while the stem tetrapods had orbits that were $' num2str(mean(ST_orbit_length_span(:,1)),2) ...
    ' \pm ' num2str(std(ST_orbit_length_span(:,1)),2) '$~mm long. The ratio of orbit length to skull length ' ...
    'was $' num2str(mean(datTF),'%2.2f') ' \pm ' num2str(std(datTF),'%2.2f')  ...
    '$  ($N=' num2str(length(datTF)) '$) for the' ...
    ' tetrapodomorph fish, and $' num2str(mean(datST),'%2.2f') ' \pm  ' num2str(std(datST),'%2.2f')  ...
    '$ ($N=' num2str(length(datST)) '$) for the stem tetrapods.'];

fid = fopen('stat_string1.tex','w');
fprintf(fid, '%s', formattedstring);
fclose(fid);


% Set up for two panel figure
fig_props.noYsubplots = 1;
fig_props.noXsubplots = 1;

fig_props.figW = 18;   % cm
fig_props.figH = 29;  % cm

fig_props.ml = 0.8;
fig_props.mt = 0.8;

create_BE_figure
fig_props.sub_pW = fig_props.sub_pW-.5;
text_color = [0 0 0];
text_size = 12;
pn = {'Color','FontSize','FontWeight',};
pv = {text_color,text_size,'bold'};

plotnoX = 1;
plotnoY = 1;
ha3 = create_BE_axes(plotnoX,plotnoY,fig_props);

totalspecies = length(datTF)+length(datST);


yinc=3

yaxpointsTF = [yinc:yinc:yinc*length(TF_orbit_length_span)]';

linevecTF = [TF_orbit_length_span(:,4) TF_orbit_length_span(:,3) ...
    yaxpointsTF yaxpointsTF];

yoffset = yinc*(length(TF_orbit_length_span)-1)+2*yinc;
yaxpointsST = [yoffset:yinc:yinc*(length(ST_orbit_length_span)-1)+yoffset]';

hold on

% sort by linevecTF(:,1)

[b,idxTF]=sort(linevecTF(:,2),'descend');
% form new ordered span matrix
linevecTFS = [linevecTF(idxTF,1:2) linevecTF(1:length(datTF),3:4)];


% plot horizontal lines for age span of fossil
for j=1:length(linevecTF)
    line(linevecTFS(j,1:2),linevecTFS(j,3:4),'Color',[1 0 0],'LineWidth',3)
end

% yoffsets for the stem tetrapods
linevecST = [ST_orbit_length_span(:,4) ST_orbit_length_span(:,3) ...
    yaxpointsST yaxpointsST];

% plot horizontal lines

[b,idxST]=sort(linevecST(:,2),'descend');

for j=1:length(linevecST)
    line(linevecST(idxST(j),1:2),linevecST(j,3:4),'Color',[0 0 1],'LineWidth',3)
    hold on
end



for j=1:length(linevecTF)
    circleSize = round(datTF(idxTF(j))*circleMax);
    line(405,yaxpointsTF(j),'marker','o','markersize',circleSize,'markeredgecolor','none','markerfacecolor',[.5 .5 .5])
    genus=cell2mat(gsTF(idxTF(j),1));
    %     genusclip=[genus(1) '. '];
    %     species=cell2mat(gsTF(idxTF(j),2));
    text(410,yaxpointsTF(j),['\it ' genus])
end
set(gca,'xlim',[260 440])

for j=1:length(linevecST)
    circleSize = round(datST(idxST(j))*circleMax);
    line(405,yaxpointsST(j),'marker','o','markersize',circleSize,'markeredgecolor','none','markerfacecolor',[.5 .5 .5])
    genus=cell2mat(gsST(idxST(j),1));
    %genusclip=[genus(1) '. '];
    %species=cell2mat(gsST(idxST(j),2));
    %if isempty(species)
    %    genusclip = genus;
    %end
    text(410,yaxpointsST(j),['\it ' genus])
end

set(gca,'YTick',[])
set(gca,'XTick',[260:20:400])
%curr_ylim=get(gca,'ylim');
%set(gca,'ylim',curr_ylim*.99)
xlabel('Age of fossil (Myr)')
print(gcf, '-dpdf','orbit_vs_time')


% prepare data for box plot
orbit_length=[TF_orbit_length_span(:,1);ST_orbit_length_span(:,1)];
tetgroup=[repmat('TF',length(TF_orbit_length_span(:,1)),1); ...
    repmat('ST',length(ST_orbit_length_span(:,1)),1)]

fig_props.noYsubplots = 1;
fig_props.noXsubplots = 2;

fig_props.figW = 18;   % cm
fig_props.figH = 10;  % cm

fig_props.ml = 0.8;
fig_props.mt = 0.8;

create_BE_figure
fig_props.sub_pW = fig_props.sub_pW-.5;
time_subsamp = 1;
time_limit = 0.4;
text_pos = [-5,2*time_limit/10,50];
text_color = [0 0 0];
text_size = 12;
pn = {'Color','FontSize','FontWeight',};
pv = {text_color,text_size,'bold'};

plotnoX = 1;
plotnoY = 1;
ha1 = create_BE_axes(plotnoX,plotnoY,fig_props);
boxplot(orbit_length,tetgroup,'notch','on','labels',{'TF', 'ST'})
set(gca,'ylim',[0 70])
ylabel('orbit length (mm)')

plotnoX = 2;
plotnoY = 1;
ha2 = create_BE_axes(plotnoX,plotnoY,fig_props);
hl1=scatter(1:length(datTF),sort(TF_orbit_length_span(:,1)),35,[1 0 0],'filled');
alpha(hl1,0.5)
hold on
hl2=scatter(length(datTF)+1:length(datTF)+length(datST), ...
     sort(ST_orbit_length_span(:,1)),35,[0 0 1],'filled');
alpha(hl2,0.5)
[h,icons,plots,s]=legend('TF','ST','Location','NorthWest');
set(icons(3).Children,'FaceAlpha',0.5)
set(icons(4).Children,'FaceAlpha',0.5)
box on

set(gca,'ylim',[0 70])
set(gca,'xtick','')

x=TF_orbit_length_span(:,1);
disp(['The median orbit length for TF was ' num2str(median(x)) '; the 1st quartile is ' ...
     num2str(prctile(x,25))])
disp(['; the 3rd quartile is ' num2str(prctile(x,75))])
disp(' ')

OM_TF=x;

x=ST_orbit_length_span(:,1);
disp(['The median orbit length for ST was ' num2str(median(x)) '; the 1st quartile is ' ...
     num2str(prctile(x,25))])
disp(['; the 3rd quartile is ' num2str(prctile(x,75))])
 
OM_ST=x;

save('OM_TF_ST.mat','OM_TF','OM_ST')

print(gcf, '-dpdf','orbit_box')



%
%
%
%
circleSize=3
create_BE_figure
fig_props.sub_pW = fig_props.sub_pW-.5;
time_subsamp = 1;
time_limit = 0.4;
text_pos = [-5,2*time_limit/10,50];
text_color = [0 0 0];
text_size = 12;
pn = {'Color','FontSize','FontWeight',};
pv = {text_color,text_size,'bold'};

plotnoX = 1;
plotnoY = 1;
horiz_line_len=0.07;
ha3= create_BE_axes(plotnoX,plotnoY,fig_props);
line(repmat(1/3,length(TF_orbit_length_span),1),TF_orbit_length_span(:,1), ...
    'linestyle','none', ...
    'marker','o','markersize',circleSize,'markeredgecolor','none','markerfacecolor',[1 0 0])

meanOrb = mean(TF_orbit_length_span(:,1));
line([(1/3)-horiz_line_len (1/3)+horiz_line_len],[meanOrb meanOrb],'color',[1 0 0],'linewidth',1.5)
text((1/3)+horiz_line_len+0.01, meanOrb, [num2str(meanOrb,2) ' mm'])

hold on

secAqColor=[252 130 0]./255;
% Derive sets without seconarily aquatic animals:


secAquatic = {'Adelospondylus','Acherontiscus','Colosteus','Greererpeton','Deltaherpeton'}
noSecAqOrb=ST_orbit_length_span(:,1);
noSecAqSkl=ST_orbit_length_span(:,2);
secAqIdx=zeros(length(ST_orbit_length_span),1);

for i=1:length(secAquatic)
    idx=find(strcmp(gsST(:,1), secAquatic(i)) );
    secAqIdx(idx)=1;
end

% break ST into non secondarily aquatic and aquatic for plotting and means
% all ST but no sec aquatic
noSecAqSkl(find(secAqIdx))=[];
noSecAqOrb(find(secAqIdx))=[];

% sec aquatic only
SecAqOrb=ST_orbit_length_span(:,1);
SecAqSkl=ST_orbit_length_span(:,2);
SecAqOrb(find(~secAqIdx))=[];
SecAqSkl(find(~secAqIdx))=[];

% all ST
Orb=ST_orbit_length_span(:,1);
Skl=ST_orbit_length_span(:,2);

%plot all ST without sec aq
line(repmat(2/3,length(noSecAqOrb),1),noSecAqOrb, ...
        'linestyle','none', ...
    'marker','o','markersize',circleSize,'markeredgecolor','none','markerfacecolor',[0 0 1])

% plot all ST without sec aq mean
meanOrb = mean(noSecAqOrb);
line([(2/3)-horiz_line_len (2/3)+horiz_line_len],[meanOrb meanOrb],'color',[0 0 1],'linewidth',1.5)
text((2/3)+horiz_line_len+0.01, meanOrb+.4, [num2str(meanOrb,2) ' mm'])

% plot all ST including sec aq mean
meanOrb = mean(Orb);
line([(2/3)-horiz_line_len (2/3)+horiz_line_len],[meanOrb meanOrb],'color',[0 0 0],'linewidth',1.5)
text((2/3)+horiz_line_len+0.01, meanOrb, [num2str(meanOrb,2) ' mm'])


%plot only sec aq
line(repmat(2/3,length(SecAqOrb),1),SecAqOrb, ...
        'linestyle','none', ...
    'marker','o','markersize',circleSize,'markeredgecolor','none','markerfacecolor', ...
    secAqColor,'linewidth',1.5)

% plot only sec aq mean
meanOrb = mean(SecAqOrb);
line([(2/3)-horiz_line_len (2/3)+horiz_line_len],[meanOrb meanOrb],'color',secAqColor,'linewidth',1.5)
text((2/3)+horiz_line_len+0.01, meanOrb, [num2str(meanOrb,2) ' mm'])  

set(gca,'ylim',[0 70])
set(gca,'xlim',[0 1])
set(gca,'xtick', [1/3 2/3],'xticklabel',{'finned tetrapod','digited tetrapod'})
ylabel('orbit length (mm)')


plotnoX = 2;
plotnoY = 1;
ha4 = create_BE_axes(plotnoX,plotnoY,fig_props);
line(repmat(1/3,length(TF_orbit_length_span),1), ...
    100.*(TF_orbit_length_span(:,1)./TF_orbit_length_span(:,2)), ...
        'linestyle','none', ...
    'marker','o','markersize',circleSize,'markeredgecolor','none','markerfacecolor',[1 0 0])
meanOrbpct = 100*mean(TF_orbit_length_span(:,1)./TF_orbit_length_span(:,2));
line([(1/3)-horiz_line_len (1/3)+horiz_line_len],[meanOrbpct meanOrbpct],'color',[1 0 0], 'linewidth',1.5)

text((1/3)+horiz_line_len+0.01, meanOrbpct, [num2str(meanOrbpct,2) '%'])

hold on

% digited tetrapods
%################

%plot all ST without sec aq
line(repmat(2/3,length(noSecAqOrb),1),100.*(noSecAqOrb./noSecAqSkl), ...
        'linestyle','none', ...
    'marker','o','markersize',circleSize,'markeredgecolor','none','markerfacecolor',[0 0 1])

% plot all ST without sec aq mean
meanOrbSkl = mean(100.*(noSecAqOrb./noSecAqSkl));
line([(2/3)-horiz_line_len (2/3)+horiz_line_len],[meanOrbSkl meanOrbSkl],'color',[0 0 1],'linewidth',1.5)
text((2/3)+horiz_line_len+0.01, meanOrbSkl, [num2str(meanOrbSkl,2) '%'])

%plot only sec aq
line(repmat(2/3,length(SecAqOrb),1),100.*(SecAqOrb./SecAqSkl), ...
        'linestyle','none', ...
    'marker','o','markersize',circleSize,'markeredgecolor','none','markerfacecolor', ...
    secAqColor,'linewidth',1.5)

% plot only sec aq mean
meanOrbSkl = mean(100.*(SecAqOrb./SecAqSkl));
line([(2/3)-horiz_line_len (2/3)+horiz_line_len],[meanOrbSkl meanOrbSkl],'color',secAqColor,'linewidth',1.5)
text((2/3)+horiz_line_len+0.01, meanOrbSkl, [num2str(meanOrbSkl,2)  '%'])  

% plot all ST including sec aq mean
meanOrbSkl = mean(100.*(Orb./Skl));
line([(2/3)-horiz_line_len (2/3)+horiz_line_len],[meanOrbSkl meanOrbSkl],'color',[0 0 0],'linewidth',1.5)
text((2/3)+horiz_line_len+0.01, meanOrbSkl-.4, [num2str(meanOrbSkl,2) '%'])

%#################
% line(repmat(2/3,length(ST_orbit_length_span),1), ...
%     100.*(ST_orbit_length_span(:,1)./ST_orbit_length_span(:,2)), ...
%         'linestyle','none', ...
%     'marker','o','markersize',circleSize,'markeredgecolor','none','markerfacecolor',[0 0 1])
% meanOrbpct = 100*mean(ST_orbit_length_span(:,1)./ST_orbit_length_span(:,2));
% line([(2/3)-horiz_line_len (2/3)+horiz_line_len],[meanOrbpct meanOrbpct],'color',[0 0 1])
% 
% text((2/3)+horiz_line_len+0.01, meanOrbpct, num2str(meanOrbpct,2))
% 
% 

set(gca,'ylim',[0 40])
set(gca,'xlim',[0 1])
ylabel('100 x (orbit length/skull length)')
set(gca,'xtick', [1/3 2/3],'xticklabel',{'finned tetrapod','digited tetrapod'})

print(gcf, '-dpdf','orbitData')
disp('Done!!');


end

function [orbit_length_span, gs] = loc_ConvData(gdat,speciesIndex,lengthCol, refkeyCol,eyeCol,genusCol,speciesCol,stageBegin,stageEnd,filename)
%% Crop Incomplete Data
validInd = [];
for i = 1:size(speciesIndex)
    if length(gdat{speciesIndex(i),1}) >= 2  && ~(isempty(gdat{speciesIndex(i),lengthCol}) || strcmp(gdat{speciesIndex(i),lengthCol},'x'))
        validInd = [validInd;speciesIndex(i)];
        refkey{speciesIndex(i)} = strrep(gdat{speciesIndex(i),refkeyCol},'*','');
    end
end

%% Convert RefData to Cited Reference
citeRef = refkey(validInd);
for i = 1:numel(citeRef)
    if length(citeRef{i}) > 4
        citeRef{i} = ['\citet{',citeRef{i},'}'];
    else
        citeRef{i} = '-';
    end
end

%% Assemble Format Genus and Species
gs = gdat(validInd,genusCol:speciesCol);
gsFormated = cell(size(gs,1),1);

startend = gdat(validInd,stageBegin:stageEnd); % N x 2, with start stage and end stage

span = [];
for i = 1: length(startend)
    MYaS = era2MYr_ICS2015_v01(cell2mat(startend(i,1))); % Start and end of start stage
    MYaE = era2MYr_ICS2015_v01(cell2mat(startend(i,2))); % Start and end of end stage
    % era2MYr returns the
    span = [span; MYaS(1) MYaE(2)]; % Start of start stage and end of end stage
    
end

for i = 1:size(gs,1)
    gsFormated{i,:} = strcat('\textit{',strjoin(gs(i,:)),'}');
end

osf = cell(size(gs,1),1);
%% Get Average AP Data
orb2skull = str2double(gdat(validInd,eyeCol))./str2double(gdat(validInd,lengthCol));
strOrbSkull = num2str(100.*orb2skull,'%-3.2f');

for i= 1:size(gs,1)
    osf{i,:}=strOrbSkull(i,:);
end


AveAP = [gsFormated,... % Genus, species
    gdat(validInd,eyeCol),...    % Average AP (mm)
    gdat(validInd,lengthCol),... % Skull Length (mm)
    osf,... % Skull Length (mm)
    citeRef']; % AP-src BibTeX Reference Key

%% Convert to LaTeX Table Format
columnLabels = {'Taxon'; 'Orbit Length (mm)'; 'Skull Length (mm)'; 'Orbit/Skull, \%'; 'Reference'};

matrix2latex(AveAP, filename, ...
    'columnLabels', columnLabels, ...
    'alignment', 'c', ...
    'format', '%-4.0f');

orbit_length = [gdat(validInd,eyeCol), gdat(validInd,lengthCol)];

% (Optional) Convert output from string to double
orbit_length = str2double(orbit_length);

[orbit_length_span] = [orbit_length span];


end

function matrix2latex(matrix, filename, varargin)

% function: matrix2latex(...)
% Author:   M. Koehler
% Contact:  koehler@in.tum.de
% Version:  1.1
% Date:     May 09, 2004

% This software is published under the GNU GPL, by the free software
% foundation. For further reading see: http://www.gnu.org/licenses/licenses.html#GPL

% Usage:
% matrix2late(matrix, filename, varargs)
% where
%   - matrix is a 2 dimensional numerical or cell array
%   - filename is a valid filename, in which the resulting latex code will
%   be stored
%   - varargs is one ore more of the following (denominator, value) combinations
%      + 'rowLabels', array -> Can be used to label the rows of the
%      resulting latex table
%      + 'columnLabels', array -> Can be used to label the columns of the
%      resulting latex table
%      + 'alignment', 'value' -> Can be used to specify the alginment of
%      the table within the latex document. Valid arguments are: 'l', 'c',
%      and 'r' for left, center, and right, respectively
%      + 'format', 'value' -> Can be used to format the input data. 'value'
%      has to be a valid format string, similar to the ones used in
%      fprintf('format', value);
%      + 'size', 'value' -> One of latex' recognized font-sizes, e.g. tiny,
%      HUGE, Large, large, LARGE, etc.
%
% Example input:
%   matrix = [1.5 1.764; 3.523 0.2];
%   rowLabels = {'row 1', 'row 2'};
%   columnLabels = {'col 1', 'col 2'};
%   matrix2latex(matrix, 'out.tex', 'rowLabels', rowLabels, 'columnLabels', columnLabels, 'alignment', 'c', 'format', '%-6.2f', 'size', 'tiny');
%
% The resulting latex file can be included into any latex document by:
% /input{out.tex}
%
% Enjoy life!!!

rowLabels = [];
colLabels = [];
alignment = 'l';
format = [];
textsize = [];
if (rem(nargin,2) == 1 || nargin < 2)
    error('matrix2latex: ', 'Incorrect number of arguments to %s.', mfilename);
end

okargs = {'rowlabels','columnlabels', 'alignment', 'format', 'size'};
for j=1:2:(nargin-2)
    pname = varargin{j};
    pval = varargin{j+1};
    k = strmatch(lower(pname), okargs);
    if isempty(k)
        error('matrix2latex: ', 'Unknown parameter name: %s.', pname);
    elseif length(k)>1
        error('matrix2latex: ', 'Ambiguous parameter name: %s.', pname);
    else
        switch(k)
            case 1  % rowlabels
                rowLabels = pval;
                if isnumeric(rowLabels)
                    rowLabels = cellstr(num2str(rowLabels(:)));
                end
            case 2  % column labels
                colLabels = pval;
                if isnumeric(colLabels)
                    colLabels = cellstr(num2str(colLabels(:)));
                end
            case 3  % alignment
                alignment = lower(pval);
                if alignment == 'right'
                    alignment = 'r';
                end
                if alignment == 'left'
                    alignment = 'l';
                end
                if alignment == 'center'
                    alignment = 'c';
                end
                if alignment ~= 'l' && alignment ~= 'c' && alignment ~= 'r'
                    alignment = 'l';
                    warning('matrix2latex: ', 'Unkown alignment. (Set it to \''left\''.)');
                end
            case 4  % format
                format = lower(pval);
            case 5  % format
                textsize = pval;
        end
    end
end

fid = fopen(filename, 'w');

width = size(matrix, 2);
height = size(matrix, 1);

if isnumeric(matrix)
    matrix = num2cell(matrix);
    for h=1:height
        for w=1:width
            if(~isempty(format))
                matrix{h, w} = num2str(matrix{h, w}, format);
            else
                matrix{h, w} = num2str(matrix{h, w});
            end
        end
    end
end

if(~isempty(textsize))
    fprintf(fid, '\\begin{%s}', textsize);
end

fprintf(fid, '\\begin{tabular}{|');

if(~isempty(rowLabels))
    fprintf(fid, 'l|');
end
% M. MacIver 3/18/2016
% Customized this to be left margin only, fixed width at 4.5 cm
% using package array
fprintf(fid, '%s|', 'L{4.5cm}');
for i=2:width-1
    fprintf(fid, '%c|', alignment);
end
% M. MacIver 3/18/2016
% Customized this to be left margin only, fixed width at 4.5 cm
% using package array
fprintf(fid, '%s|', 'L{4.5cm}')
fprintf(fid, '}\r\n');

fprintf(fid, '\\hline\r\n');

if(~isempty(colLabels))
    if(~isempty(rowLabels))
        fprintf(fid, '&');
    end
    for w=1:width-1
        fprintf(fid, '\\textbf{%s}&', colLabels{w});
    end
    fprintf(fid, '\\textbf{%s}\\\\\\hline\r\n', colLabels{width});
end

for h=1:height
    if(~isempty(rowLabels))
        fprintf(fid, '\\textbf{%s}&', rowLabels{h});
    end
    for w=1:width-1
        if ~isnan(str2double(matrix{h, w}))
            tmpNum = str2double(matrix{h, w});
            if(~isempty(format))
                matrix{h, w} = num2str(tmpNum, format);
            end
        elseif length(matrix{h, w}) <= 8
            matrix{h, w} = '-';
        end
        fprintf(fid, '%s&', matrix{h, w});
    end
    fprintf(fid, '%s\\\\\\hline\r\n', matrix{h, width});
end

fprintf(fid, '\\end{tabular}\r\n');

if(~isempty(textsize))
    fprintf(fid, '\\end{%s}', textsize);
end

fclose(fid);
end