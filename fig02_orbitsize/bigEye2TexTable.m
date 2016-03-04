function bigEye2TexTable()
%% bigEye2TexTable()

% Need to make the columns of the tables fixed width 
% See this post for how to do that:
% http://goo.gl/au5WbG

% Row addresses for the tetrapodomorph fish 
tetrapodomorph_fish_startRow = 3;
tetrapodomorph_fish_endRow = 25;


% Row addresses for the stem tetrapods 
stem_tetrapod_startRow = 27;
stem_tetrapod_endRow = 46;

% Read bigEye
gdat=GetGoogleSpreadsheet('1xlwAnje_WiQ0Owl6vBdQMF9odDUDE439ydRI3mU9cks');


% Key column addresses in spreadsheet
genusCol = 2;    % genus
speciesCol = 3;  % species
refKeyCol = 13;  % bibtex ref key
lengthCol = 14;  % PPL 
eyeCol = 18;     % OM





TFind = [tetrapodomorph_fish_startRow:tetrapodomorph_fish_endRow]' ;    % Tetrapodomorph Fish
STind = [stem_tetrapod_startRow:stem_tetrapod_endRow]' ; % Stem Tetrapods

%% Convert to LaTeX Table

TF_eye_length=loc_ConvData(gdat,TFind,lengthCol,refKeyCol,eyeCol,genusCol,speciesCol,'TFout.tex');
ST_eye_length=loc_ConvData(gdat,STind,lengthCol,refKeyCol,eyeCol,genusCol,speciesCol,'STout.tex');

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
datTF = (TF_eye_length(:,1)./TF_eye_length(:,2));
datST = (ST_eye_length(:,1)./ST_eye_length(:,2));


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
ylabel('Eye length as % of skull length')


plotnoX = 2;
plotnoY = 1;
ha2 = create_BE_axes(plotnoX,plotnoY,fig_props);
histogram(log10(datST), 6)
hold on
histogram(log10(datTF), 6)
xlim([-1.4 -0.2])
legend('ST', 'TF','Location','NorthWest')
legend('boxoff')
xlabel('log(eye/skull length)')
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
'The ratio was $' num2str(mean(datTF),3) ' \pm ' num2str(std(datTF),1)  ...
'$  ($N=' num2str(length(datTF)) '$) (all numbers $\pm$ standard deviation) for the' ...
' Tetrapodomorph Fish, and ' num2str(mean(datST),3) ' \pm  ' num2str(std(datTF),1)  ...
'$ ($N=' num2str(length(datST)) '$) for the Stem Tetrapods. A two-tailed  ' ...
'T-test (assuming unequal variance) rejected the null hypothesis that the ' ...
'means come from the same distribution ($p = ' sprintf('%.8f',ptt) '$). ' ...
'A Wilcoxon rank sum test also rejects the null hypothesis ($p = ' sprintf('%.7f',prs) '$), ' ...
'as did a two-sample Kolmogorov-Smirnov test ($p = ' sprintf('%.6f',pks)  '$). '];

fid = fopen('stat_string1.tex','w');
fprintf(fid, '%s', formattedstring);
fclose(fid);

disp('Done!!');


end

function eye_length= loc_ConvData(gdat,speciesIndex,lengthCol, refkeyCol,eyeCol,genusCol,speciesCol,filename)
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

eye_length = [gdat(validInd,eyeCol), gdat(validInd,lengthCol)];

% (Optional) Convert output from string to double
eye_length = str2double(eye_length);

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
    fprintf(fid, '%c|', 'l');
    for i=2:width
        fprintf(fid, '%c|', alignment);
    end
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