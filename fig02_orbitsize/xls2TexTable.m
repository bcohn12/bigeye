function xls2TexTable()
%% xls2TexTable()
% Convert xls table fields to LaTeX table format
% 
% Chen Chen
% 2.16.2016

%% Read or Load XLS Data
[~,XlsData.GS,~] = xlsread('bigEye_data.xlsx',3,'A3:B107');
[~,~,XlsData.Eye] = xlsread('bigEye_data.xlsx',3,'O3:O107');
[~,~,XlsData.Length] = xlsread('bigEye_data.xlsx',3,'M3:M107');
[~,~,XlsData.RefKey] = xlsread('bigEye_data.xlsx',3,'I3:I107');

% load('bigEyeData-AP-All.mat');

% Specify Needed Species Here
% Needed Species' Index in the Spreedsheet File
TFind = [3:51]' - 2;    % Tetrapodomorph Fish
STind = [57:107]' - 2; % Stem Tetrapods

%% Convert to LaTeX Table
loc_ConvData(XlsData,TFind,'TFout.tex');
loc_ConvData(XlsData,STind,'STout.tex');

disp('Done!!');

end

function loc_ConvData(XlsData,speciesIndex,filename)
%% Crop Incomplete Data
validInd = [];
for i = 1:size(speciesIndex)
    if length(XlsData.RefKey{speciesIndex(i)}) > 5 && ~isnan(XlsData.Length{speciesIndex(i)}) 
        validInd = [validInd;speciesIndex(i)];
        XlsData.RefKey{speciesIndex(i)} = strrep(XlsData.RefKey{speciesIndex(i)},'*','');
    end
end

%% Convert RefData to Cited Reference
citeRef = XlsData.RefKey(validInd);
for i = 1:numel(citeRef)
    if length(citeRef{i}) > 5
        citeRef{i} = ['\cite{',citeRef{i},'}'];
    else
        citeRef{i} = '-';
    end
end

%% Assemble Format Genus and Species
gs = XlsData.GS(validInd,:);
gsFormated = cell(size(gs,1),1);

for i = 1:size(gs,1)
    gsFormated{i,:} = strcat('\textit{',strjoin(gs(i,:)),'}');
end

%% Get Average AP Data
AveAP = [gsFormated,... % Genus, species
    XlsData.Eye(validInd),...    % Average AP (mm)
    XlsData.Length(validInd),... % Skull Length (mm)
    citeRef]; % AP-src BibTeX Reference Key

%% Convert to LaTeX Table Format
columnLabels = {'Genus, species'; 'Avg AP (mm)'; 'Skull Length (mm)'; 'Reference'};

matrix2latex(AveAP, filename, ...
    'columnLabels', columnLabels, ...
    'alignment', 'c', ...
    'format', '%-4.2f');
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
    for i=1:width
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
            if isnumeric(matrix{h, w})
                if isnan(matrix{h, w})
                    matrix{h, w} = '-';
                else
                    if(~isempty(format))
                        matrix{h, w} = num2str(matrix{h, w}, format);
                    else
                        matrix{h, w} = num2str(matrix{h, w});
                    end
                end
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