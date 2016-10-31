function tabExt01_compviz
global BIGEYEROOT
    run Parameters.m
    load('Parameters.mat')

    columnLabels={' ';
        'Parameter';
        'Value';
        'Definition';
        'Reference'};

%% AERIAL VISION MODEL
    %DAYLIGHT
    daylightAerialParameters={'$\eta$';
        '$\Delta t$';
        '$F$';
        '$\mathtt{L}$'};
    daylightAerialValues={num2str(qAerial.Daylight);...
        num2str(DtAerial.Daylight,'%.2f');...
        num2str(FAerial.Daylight);...
        num2str(BAerial.Daylight,'%10.1e')};
    daylightAerialDef={'detection efficiency';
        'integration time (s)';
        'f-number, ratio of focal length and pupil diameter';
        'daylight luminance ($\text{cd}\, \text{m}^{-2}$)'};
    daylightAerialRefKey={'\cite{Pirh07a}';
        '\cite{Donn95a}';...
        '\cite{Snyd79a}';
        '\cite{Midd52a}'};
    %MOONLIGHT
    moonlightAerialParameters={'$\eta$';
        '$\Delta t$';
        '$F$';
        '$\mathtt{L}$'};
    moonlightAerialValues={num2str(qAerial.Moonlight);...
        num2str(DtAerial.Moonlight,'%.2f');...
        num2str(FAerial.Moonlight);...
        num2str(BAerial.Moonlight,'%10.1e')};
    moonlightAerialDef={'detection efficiency';
        'integration time (s)';
        'f-number, ratio of focal length and pupil diameter';
        'moonlight luminance ($\text{cd}\, \text{m}^{-2}$)'};
    moonlightAerialRefKey={'\cite{Nils14a}';
        '\cite{Donn95a}';...
        '\cite{Mill79a}';
        '\cite{Midd52a}'};
    %STARLIGHT
    starlightAerialParameters={'$\eta$';
        '$\Delta t$';
        '$F$';
        '$\mathtt{L}$'};
    starlightAerialValues={num2str(qAerial.Starlight);...
        num2str(DtAerial.Starlight,'%.2f');...
        num2str(FAerial.Starlight);...
        num2str(BAerial.Starlight,'%10.1e')};
    starlightAerialDef={'detection efficiency';
        'integration time (s)';
        'f-number, ratio of focal length and pupil diameter';
        'starlight luminance ($\text{cd}\, \text{m}^{-2}$)'};
    starlightAerialRefKey={'\cite{Nils14a}';
        '\cite{Donn95a}';...
        '\cite{Mill79a}';
        '\cite{Midd52a}'};
    %ALL
    commonAerialParameters={'$\mathtt{X}$';...
        '$\sigma_{\text{km}} (\lambda_{\mu \text{m}})$';...
        '$\bar{\beta}$'};
    commonAerialValues={num2str(XAerial);...
        '$0.0011 \lambda_{\mu \text{m}}^{-4} + 0.008 \lambda_{\mu \text{m}}^{-2.09}$';...
        num2str(BbarAerial,'%10.2e')};
    commonAerialDef={'dark noise rate @$23.5^{\circ}\,\text{C}$ ($\text{Rh}\, \text{s}^{-1}$)';
        'extinction factor ($\text{km}^{-1}$)';...
        'intensity parameter coefficient'};
    commonAerialRefKey={'\cite{Aho93a}';
        '\cite{Midd52a}';
        '\cite{Snyd79a}'};
 %% AQUATIC VISION MODEL  
    aquaticParameters={'$\eta$';
        '$\Delta t$';
        '$M$';
        '$c(\lambda)$';
        '$\mathtt{X}$'};
    aquaticValues={num2str(qAquatic);...
        num2str(DtAquatic);
        num2str(M);...
        '$c(\lambda)=b(\lambda)+a(\lambda)$'
        num2str(XAquatic)};
    aquaticDef={'detection efficiency';
        'integration time (s)';
        'ratio of focal length and pupil radius, $2f/D$ (Matthiessen''s ratio)';
        'beam attenuation coefficient ($\text{m}^{-1}$)';
        'dark noise rate @$16.5^{\circ} \, \text{C}$ ($\text{Rh } \,\text{s}^{-1}$)'};
    aquaticRefKey={'\cite{Nils14a}';
        '\cite{Donn95a} via \cite{Nils14a}';
        '\cite{Nils14a}';
        '\cite{Midd52a}';...
        '\cite{Aho93a}'};
%% ALL MODELS
    commonParameters={'$\gamma$';...
    '$k$';
    '$l$';
    '$d$';
    'R';
    'T';
    '$C_\text{O}$';...
    'D'};
    commonValues={0.449;...
    num2str(k);...
    num2str(len);...
    num2str(d*10^6);...
    num2str(R);...
    num2str(T);...
    num2str(C0Aquatic.Daylight);...
    sprintf('[%d %d]',minpupil*10^3,maxpupil*10^3)};
    commonDef={'socket length to pupil diameter conversion factor';
        'photoreceptor absorption coefficient ($\mu \text{m}^{-1}$)';
        'photoreceptor length ($\mu \text{m}$)';
        'photoreceptor diameter ($\mu \text{m}$)';
        '95\% confidence level for firing threshold';
        'target width (diameter for circular objects) (m)';
        'object/target contrast (Weber contrast)';
        'range of pupil diameters used in calculations (mm)'};
    commonRefKey={'current study';
        '\cite{Part90a} via \cite{Warr98a}';...
        '\cite{Nils14a}';...
        '\cite{Land12a} via \cite{Nils14a}';
        '\cite{Land81a} via \cite{Nils14a}';
        ' ';
        ' ';
        ' '};

    rowLabels=cell(length(commonParameters)+...
        length(commonAerialParameters)+...
        length(daylightAerialParameters)+...
        length(moonlightAerialParameters)+...
        length(starlightAerialParameters)+...
        length(aquaticParameters),1);
    
    for i=1:length(rowLabels)
        rowLabels{i}=' ';
    end
    rowLabels{1}='\textbf{All Models}';
    rowLabels{length(commonParameters)+1}='\textbf{Aerial Vision Model, All}';
    rowLabels{length(commonParameters)+1+...
        length(commonAerialParameters)}='\textbf{Aerial Vision Model, Daylight}';
    rowLabels{length(commonParameters)+1+...
        length(commonAerialParameters)+...
        length(daylightAerialParameters)}='\textbf{Aerial Vision Model, Moonlight}';
    rowLabels{length(commonParameters)+1+...
        length(commonAerialParameters)+...
        length(daylightAerialParameters)+...
        length(moonlightAerialParameters)} = '\textbf{Aerial Vision Model, Starlight}';
    rowLabels{length(commonParameters)+1+...
        length(commonAerialParameters)+...
        length(daylightAerialParameters)+...
        length(moonlightAerialParameters)+...
        length(starlightAerialParameters)} = '\textbf{Aquatic Vision Model}';


    allParameters={commonParameters{:,1},commonAerialParameters{:,1},...
        daylightAerialParameters{:,1},moonlightAerialParameters{:,1},starlightAerialParameters{:,1},aquaticParameters{:,1}}';
    allValues={commonValues{:},commonAerialValues{:},...
        daylightAerialValues{:},moonlightAerialValues{:},starlightAerialValues{:},aquaticValues{:},}';
    allDef={commonDef{:},commonAerialDef{:},...
        daylightAerialDef{:},moonlightAerialDef{:},starlightAerialDef{:},aquaticDef{:},}';
    allRef={commonRefKey{:},commonAerialRefKey{:},...
        daylightAerialRefKey{:},moonlightAerialRefKey{:},starlightAerialRefKey{:},aquaticRefKey{:}}';


    allCellTable=[rowLabels,allParameters,allValues,allDef,allRef];

    filename=[BIGEYEROOT 'tabExt01_compviz/tabExt01_compviz.tex'];
    matrix2latex(allCellTable,filename,...
        'columnLabels',columnLabels)
    %alignment: {|p{0.3\linewidth}|p{0.15\linewidth}|p{0.15\linewidth}|p{0.4\linewidth}|p{0.15\linewidth}|}end
    
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

% M. MacIver 4/18/2016
% Customized this to be left margin only, fixed width at 4.5 cm
% using package array
%fprintf(fid, '%s|', 'L{3.5cm}');

% To return to original uncomment next line 
% fprintf(fid, '%c|', 'l');
for i=1:width-1   % go 2:width for original
    switch i
        case 1
            alignment='L{3.5cm}';
        case {2,3}
            alignment='L{2cm}';
         case 4
            alignment='L{4.5cm}';
    end   
    fprintf(fid, '%s|', alignment);
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

%Changed to highlight rows - UM
for h=1:height
    if(~isempty(rowLabels))
        fprintf(fid, '\\textbf{%s}&', rowLabels{h});
    end
%     if mod(h,2)
%         fprintf(fid,'\\rowcolor{Gray}\r\n');
%     end
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
    %if h==height
        fprintf(fid, '%s\\\\\\hline\r\n', matrix{h, width});
    %else
    %        fprintf(fid, '%s\\\\\r\n', matrix{h, width});
    %end
end

fprintf(fid, '\\end{tabular}\r\n');

if(~isempty(textsize))
    fprintf(fid, '\\end{%s}', textsize);
end

fclose(fid);
