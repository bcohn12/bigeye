function var = tab02_simulation_parameters()
clc
global EROOT
rib3path = [EROOT '/papers/rib3'];
BigDatapath = [rib3path '/bigdata'];

ray_length = ray_length_func();
iFile = 1;
filename{iFile} = [BigDatapath '/simulation_hover_B'];
iFile = iFile+1;
filename{iFile} = [BigDatapath '/simulation_surge_03cm_s'];
iFile = iFile+1;
filename{iFile} = [BigDatapath '/simulation_surge_06cm_s'];
iFile = iFile+1;
filename{iFile} = [BigDatapath '/simulation_surge_15cm_s'];
iFile = iFile+1;
filename{iFile} = [BigDatapath '/simulation_surge_20cm_s_B'];
iFile = iFile+1;
filename{iFile} = [BigDatapath '/simulation_surge_33cm_s'];

rpm = [2.2933/.1311 37 64 131 168 266];
flowvel = .1311*rpm-2.2933;

table_mat = nan(length(filename),5);
for iFile = 1:length(filename)
    load(filename{iFile},'dStart','dCenter','dEnd','xCenter','cv1','cv2','cr1','cr2')
    table_mat(iFile,:) = [flowvel(iFile) dStart dCenter dEnd xCenter];
end

table_columns = {'\specialcell{Simulated\\swim speed\\(\cus)}',...
    '$d_a$','$d_b$','$d_c$','$x_b$'};

results_table_cell = cell(length(filename),length(table_columns));
strformat = '%2.2f';

for iFile = 1:length(filename)
    if iFile < 4
        results_table_cell{iFile,1} = ['\;' num2str(table_mat(iFile,1),'%2.1f')];
    else
        results_table_cell{iFile,1} = num2str(table_mat(iFile,1),'%2.1f');
    end
    for iCol = 2:size(table_mat,2)
        results_table_cell{iFile,iCol} = num2str(table_mat(iFile,iCol),strformat);
    end
end

matrix2latex(results_table_cell, [mfilename('fullpath') '.tex'], ...'rowLabels', rowLabels,...
    'columnLabels', table_columns, 'alignment', 'c', 'format', strformat, 'size', 'normalsize')

end

function tex = data2tex(varargin)
    tex = [];
    strformat = varargin{end};
    if (nargin == 3 || (~isnan(varargin{1}) && isnan(varargin{4})))
        left = num2str(varargin{1},strformat);
        right = num2str(varargin{2},strformat);
        if length(left) > length(right)
            right = [right '\;\:'];
        elseif length(left) < length(right)
            left = ['\;' left];
        end
        tex = [left ' $\pm$ ' right]; 
    elseif (nargin == 5 && isnan(varargin{1}))
        tex = 'N/A';
    else
        top_left = num2str(varargin{1},strformat);
        top_right = num2str(varargin{2},strformat);
        bottom_left = num2str(varargin{3},strformat);
        bottom_right = num2str(varargin{4},strformat);
        if length(top_left)>length(top_right)
            top_right = [top_right '\;\:'];
        elseif length(top_left)<length(top_right)
            top_left = ['\;' top_left];
        end
        if length(bottom_left)>length(bottom_right)
            bottom_right = [bottom_right '\;\:'];
        elseif length(bottom_left)<length(bottom_right)
            bottom_left = ['\;\:' bottom_left];
        end
        tex = ['\specialcell{' top_left ' $\pm$ ' top_right ...
            '\\' bottom_left ' $\pm$ ' bottom_right '}'];
    end
    
end