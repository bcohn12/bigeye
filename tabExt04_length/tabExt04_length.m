function tabExt04_length
%% INITIALIZE
global BIGEYEROOT
    [~,~,XlsData.GS] = xlsread('bigEye.xlsx',1,'B3:C64');
    [~,~,XlsData.Eye] = xlsread('bigEye.xlsx',1,'T3:T64');
    [~,~,XlsData.Length] = xlsread('bigEye.xlsx',1,'P3:P64');
    [~,~,XlsData.RefKey] = xlsread('bigEye.xlsx',1,'O3:O64');
    [~,~,XlsData.startEnd] = xlsread('bigEye.xlsx',1,'D3:E64');

    % Specify Needed Species Here
    % Needed Species' Index in the Spreedsheet File
    TFind = [1:21]' ;    % Tetrapodomorph Fish
    STind = [25:62]' ; % Stem Tetrapods

    global numTF
    numTF=numel(TFind);

    % Key column addresses in spreadsheet
    stageBegin=4;    % start of stratigraphic period
    stageEnd=5;      % end of stratigraphic period
    genusCol = 2;    % genus
    speciesCol = 3;  % species
    refKeyCol = 15;  % bibtex ref key
    lengthCol = 16;  % PPL
    eyeCol = 20;     % OM

%% CREATE TABLE
    TFfilename=[BIGEYEROOT  'tabExt04_length/TFout.tex'];
    STfilename=[BIGEYEROOT 'tabExt04_length/STout.tex'];
    allfilename=[BIGEYEROOT 'tabExt04_length/allout.tex'];
    [TF_orbit_length_span, gsTF]=loc_ConvData(XlsData,TFind,lengthCol,refKeyCol,eyeCol,genusCol,speciesCol,stageBegin,stageEnd,TFfilename);
    [ST_orbit_length_span, gsST]=loc_ConvData(XlsData,STind,lengthCol,refKeyCol,eyeCol,genusCol,speciesCol,stageBegin,stageEnd,STfilename);
    [all_orbit_length_span, allgsTF]=loc_ConvData(XlsData,[TFind; STind],lengthCol,refKeyCol,eyeCol,genusCol,speciesCol,stageBegin,stageEnd,allfilename);
    
function [orbit_length_span, gs] = loc_ConvData(gdat,speciesIndex,lengthCol, refkeyCol,eyeCol,genusCol,speciesCol,stageBegin,stageEnd,filename)
    global numTF

    refkey=[];
    validInd=[];
    count=1;
    for i = 1:numel(speciesIndex)
        tempkey=gdat.RefKey{speciesIndex(i)};

        if isstr(tempkey)
            refkey{speciesIndex(i)} = strrep(gdat.RefKey{speciesIndex(i)},'*','');
            count=count+1;
            validInd=[validInd; speciesIndex(i)];
        end

    end
    %% Convert RefData to Cited Reference
    citeRef = refkey;
    for i = 1:numel(citeRef)
        if length(citeRef{i}) > 4
            citeRef{i} = ['\cite{',citeRef{i},'}'];
        end
    end
    %% Assemble Format Genus and Species

    gs = gdat.GS(validInd,:);
    gsFormatted = cell(size(gs,1),1);

    startend = gdat.startEnd(validInd,:); % N x 2, with start stage and end stage

    span = [];
    for i = 1: length(startend)
        MYaS = era2MYr_ICS2015_v01(cell2mat(startend(i,1))); % Start and end of start stage
        MYaE = era2MYr_ICS2015_v01(cell2mat(startend(i,2))); % Start and end of end stage
        % era2MYr returns the
        span = [span; MYaS(1) MYaE(2)]; % Start of start stage and end of end stage

    end
    for i = 1:size(gs,1)
        if iscellstr(gs(i,1)) && iscellstr(gs(i,2)) % species AND genus
            gsFormatted{i,:} = strcat('\textit{',strjoin(gs(i,:)),'}');
        else
            gsFormatted{i,:} = strcat('\textit{',strjoin(gs(i,1)),'}'); % genus only
        end
    end

    osf = cell(size(gs,1),1);
    %% Get Average AP Data
    orb2skull = cell2mat(gdat.Eye(validInd))./cell2mat(gdat.Length(validInd));
    strOrbSkull = num2str(100.*orb2skull,'%-3.0f');

    for i= 1:size(gs,1)
        osf{i,:}=strOrbSkull(i,:); % orbit to skull fraction
    end

    % hack for full table
    % sort the TF and ST separately
    if length(startend)>40
        [A,sortedIDX]=sort(gsFormatted(1:numTF,:)) ;
        orbits=gdat.Eye(validInd(1:numTF));
        skulls=gdat.Length(validInd(1:numTF));
        cites=[citeRef(validInd(1:numTF))]';
        osfA=[osf(1:numTF)];

        AveAPTF=[A, ...
            repmat({'Finned'},length(A),1), ...
            orbits(sortedIDX),...    % Average AP (mm)
            skulls(sortedIDX),... % Skull Length (mm)
            osfA(sortedIDX),... % orbit skull fraction
            cites(sortedIDX)]; % AP-src BibTeX Reference Key

        [B,sortedIDX]=sort(gsFormatted(numTF+1:end,:)) ;
        orbits=gdat.Eye(validInd(numTF+1:end));
        skulls=gdat.Length(validInd(numTF+1:end));
        cites=[citeRef(validInd(numTF+1:end))]';
        osfB=[osf(numTF+1:end)];

        AveAPST=[B, ...
            repmat({'Digited'},length(B),1), ...
            orbits(sortedIDX),...    % Average AP (mm)
            skulls(sortedIDX),... % Skull Length (mm)
            osfB(sortedIDX),... % orbit skull fraction
            cites(sortedIDX)]; % AP-src BibTeX Reference Key

        AveAP =[AveAPTF; AveAPST];
        %% Convert to LaTeX Table Format
        columnLabels = {'Taxon'; 'Group'; 'Orbit Length (mm)'; 'Skull Length (mm)'; 'Orbit/Skull, \%'; 'Reference'};

    else
        [B,sortedIDX]=sort(gsFormatted);
        orbits=gdat.Eye(validInd);
        skulls=gdat.Length(validInd);
        cites=citeRef';
        AveAP = [B,... % Genus, species
            orbits(sortedIDX),...    % Average AP (mm)
            skulls(sortedIDX),... % Skull Length (mm)
            osf(sortedIDX),... % Skull Length (mm)
            cites(sortedIDX)]; % AP-src BibTeX Reference Key
        %% Convert to LaTeX Table Format
        columnLabels = {'Taxon'; 'Orbit Length (mm)'; 'Skull Length (mm)'; 'Orbit/Skull, \%'; 'Reference'};
    end
    matrix2latex(AveAP, filename, ...
        'columnLabels', columnLabels, ...
        'alignment', 'c', ...
        'format', '%-4.0f');
    orbit_length = [gdat.Eye(validInd), gdat.Length(validInd)];

    % (Optional) Convert output from string to double
    orbit_length = cell2mat(orbit_length);
    [orbit_length_span] = [orbit_length span];

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

            %     if ~isnan(str2double(matrix{h, w}))
            if ~isstr(matrix{h,w})
                tmpNum = matrix{h, w};
                if(~isempty(format))
                    matrix{h, w} = num2str(tmpNum, format);
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