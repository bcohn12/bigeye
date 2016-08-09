function tab03_gain
global BIGEYEROOT
    run Parameters.m
    load('Parameters.mat')
    
    load('visibilityAerial_Daylight.mat')
    load('visibilityAerial_Moonlight.mat')
    load('visibilityAerial_Starlight.mat')
    load('visibilityAquatic_All.mat');
    load OM_TF_ST.mat
    
    pupil_TF = [mean(OM_TF)-std(OM_TF) mean(OM_TF)+std(OM_TF)].*0.449;
    pupil_ST = [mean(OM_ST)-std(OM_ST) mean(OM_ST)+std(OM_ST)].*0.449;
    fishpupil=mean(OM_TF)*.449;
    tetrapodpupil=mean(OM_ST)*.449;
    CONTRASTTHRESH=1;
    
    [visualRange_River, visualVolume_River, drdA_River, dVdA_River,pupilValues] = Aquatic_calcVolumegetDer(CONTRASTTHRESH);
    [visualRangeDaylight, visualRangeMoonlight, visualRangeStarlight,...
    visualVolumeDaylight, visualVolumeMoonlight, visualVolumeStarlight,...
    drdADaylight,drdAMoonlight,drdAStarlight,...
    dVdADaylight, dVdAMoonlight, dVdAStarlight,pupilValuesAir]=Aerial_calcVolumegetDerivatives(CONTRASTTHRESH);

    visualRange=[visualRangeDaylight, visualRangeMoonlight, smooth(visualRangeStarlight)];
    drdA=[smooth(drdADaylight)';smooth(drdAMoonlight)';smooth(drdAStarlight)'];
    visualVolume=[visualVolumeDaylight;visualVolumeMoonlight;visualVolumeStarlight];
    dVdA=[smooth(dVdADaylight,7)';smooth(dVdAMoonlight,7)';smooth(dVdAStarlight,7)'];
    visualRange_River=[visualRange_River(:,1,1), visualRange_River(:,1,2),...
        visualRange_River(:,2,1),...
        visualRange_River(:,3,1)];
    drdA_River=[smooth(drdA_River(:,1,1)), smooth(drdA_River(:,1,2)),...
        smooth(drdA_River(:,2,1)),...
        smooth(drdA_River(:,3,1))];
    visualVolume_River=[visualVolume_River(:,1,1) visualVolume_River(:,1,2),...
        visualVolume_River(:,2,1),...
        visualRange_River(:,3,1)];
    dVdA_River=[smooth(dVdA_River(:,1,1),7), smooth(dVdA_River(:,1,2),7),...
        smooth(dVdA_River(:,2,1),7),...
        smooth(dVdA_River(:,2,1),7)];
    
    Aquatic.range=visualRange_River; Aquatic.derRange=drdA_River;
    Aquatic.volume=visualVolume_River; Aquatic.derVolume=dVdA_River;
    
    Aerial.range=visualRange; Aerial.derRange=drdA;
    Aerial.volume=visualVolume; Aerial.derVolume=dVdA;
    
    rowlength=12;
    columnlabels={'#','Aquatic Condition','Aerial Condition',...
        'Visual Range,Gain','Visual Range,Derivative Gain',...
        'Visual Voluem,Gain','Visual Voluem,Derivative Gain'};
    m=1;
    for i=1:length(columnlabels)
        c{i}=strsplit(columnlabels{i},',');
        temp=length(c{i});
        if temp>m
            m=temp;
        end
    end
    for i=1:length(columnlabels)
        for j=length(c{i}):m-1
            c{i}{j+1}=' ';
        end
    end
    fullmatrix=[];
    description.Aquatic={'Daylight 8~m depth,.horizontal viewing,.Finned tetrapod pupil'
        'Daylight 8~m depth,.horizontal viewing,.Finned tetrapod pupil'
        'Daylight 8m depth,.upward viewing,.Finned tetrapod pupil'
        'Daylight 8m depth,.upward viewing,.Finned tetrapod pupil'
        'Daylight 8m depth,.upward viewing,.Finned tetrapod pupil'
        'Daylight 8m depth,.upward viewing,.Finned tetrapod pupil'
        'Daylight 8m depth,.upward viewing,.Finned tetrapod pupil'
        'Daylight 8m depth,.upward viewing,.Finned tetrapod pupil'
        'Daylight 8m depth,.upward viewing,.Finned tetrapod pupil'
        'Moonlight 8m depth,.upward viewing,.Finned tetrapod pupil'
        'Moonlight 8m depth,.upward viewing,.Finned tetrapod pupil'
        'Starlight 8m depth,.upward viewing,.Finned tetrapod pupil'
        'Starlight 8m depth,.upward viewing,.Finned tetrapod pupil'};
    description.Aerial={'Daylight,.Finned tetrapod pupil'
        'Daylight,.Digited tetrapod pupil'
        'Daylight,.Finned tetrapod pupil'
        'Daylight,.Digited tetrapod pupil'
        'Moonlight,.Finned tetrapod pupil'
        'Starlight,.Finned tetrapod pupil'
        'Moonlight,.Digited tetrapod pupil'
        'Starlight,.Digited tetrapod pupil'
        'Moonlight,.Finned tetrapod pupil'
        'Moonlight,.Digited tetrapod pupil'
        'Starlight,.Finned tetrapod pupil'
        'Starlight,.Digited tetrapod pupil'};
    n=1; des.Aerial={}; des.Aquatic={};
    for i=1:rowlength
        des.Aerial{i}=strsplit(description.Aerial{i},'.');
        des.Aquatic{i}=strsplit(description.Aquatic{i},'.');
        if length(des.Aerial{i})>n || length(des.Aquatic{i})>n;
            n=max([length(des.Aerial{i}) length(des.Aquatic{i})]);
        end
    end
    
    columncond={'range','derRange','volume','derVolume'}; val={};
    for i=1:length(columncond)
        val{1,i}=num2str(round((interp1q(pupilValuesAir,Aerial.(columncond{i})(:,1),fishpupil*1e-3))/...
           (interp1q(pupilValues,Aquatic.(columncond{i})(:,2),fishpupil*1e-3))));
        val{2,i}=num2str(round((interp1q(pupilValuesAir,Aerial.(columncond{i})(:,1),tetrapodpupil*1e-3))/...
           (interp1q(pupilValues,Aquatic.(columncond{i})(:,2),fishpupil*1e-3))));
        val{3,i}=num2str((interp1q(pupilValuesAir,Aerial.(columncond{i})(:,1),fishpupil*1e-3))/...
          (interp1q(pupilValues,Aquatic.(columncond{i})(:,1),fishpupil*1e-3)));
        val{4,i}=num2str((interp1q(pupilValuesAir,Aerial.(columncond{i})(:,1),tetrapodpupil*1e-3))/...
          (interp1q(pupilValues,Aquatic.(columncond{i})(:,1),fishpupil*1e-3)));
        val{5,i}=num2str((interp1q(pupilValuesAir,Aerial.(columncond{i})(:,2),fishpupil*1e-3))/...
         (interp1q(pupilValues,Aquatic.(columncond{i})(:,1),fishpupil*1e-3)));
        val{6,i}=num2str((interp1q(pupilValuesAir,Aerial.(columncond{i})(:,3),fishpupil*1e-3))/...
         (interp1q(pupilValues,Aquatic.(columncond{i})(:,1),fishpupil*1e-3)));
        val{7,i}=num2str((interp1q(pupilValuesAir,Aerial.(columncond{i})(:,2),tetrapodpupil*1e-3))/...
          (interp1q(pupilValues,Aquatic.(columncond{i})(:,1),fishpupil*1e-3)));
        val{8,i}=num2str((interp1q(pupilValuesAir,Aerial.(columncond{i})(:,3),tetrapodpupil*1e-3))/...
          (interp1q(pupilValues,Aquatic.(columncond{i})(:,1),fishpupil*1e-3)));
        val{9,i}=num2str((interp1q(pupilValuesAir,Aerial.(columncond{i})(:,2),fishpupil*1e-3))/...
          (interp1q(pupilValues,Aquatic.(columncond{i})(:,3),fishpupil*1e-3)));
        val{10,i}=num2str((interp1q(pupilValuesAir,Aerial.(columncond{i})(:,2),tetrapodpupil*1e-3))/...
         (interp1q(pupilValues,Aquatic.(columncond{i})(:,3),fishpupil*1e-3)));
        val{11,i}=num2str((interp1q(pupilValuesAir,Aerial.(columncond{i})(:,3),fishpupil*1e-3))/...
         (interp1q(pupilValues,Aquatic.(columncond{i})(:,4),fishpupil*1e-3)));
        val{12,i}=num2str((interp1q(pupilValuesAir,Aerial.(columncond{i})(:,3),tetrapodpupil*1e-3))/...
         (interp1q(pupilValues,Aquatic.(columncond{i})(:,4),fishpupil*1e-3))); 
    end
    b=5;
    
        
%     for i=1:rowlength
%         cTemp=c{i};
%         dum=[];
%         for j=1:length(cTemp)
%             tempparamcol{j,i}=cTemp{j};
%         end
%         dum=[tempparamcol
%             (interp1q(pupilValuesAir,visualRangeDaylight,fishpupil*1e-3))/...
%                 (interp1q(pupilValues,visualRange_River(:,2),fishpupil*1e-3))
%                  
%         fullmatrix=[fullmatrix tempparamcol];
%     end
%         
        
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
