function var = tab01_results()
clc
global EROOT
rib3path = [EROOT '/papers/rib3'];
BigDatapath = [rib3path '/data'];

ray_length = ray_length_func();
filename{1} = [BigDatapath '/Analyzed_experimental_hover'];
filename{2} = [BigDatapath '/Analyzed_experimental_surge_03cm_s'];
filename{3} = [BigDatapath '/Analyzed_experimental_surge_06cm_s'];
filename{4} = [BigDatapath '/Analyzed_experimental_surge_15cm_s'];
filename{5} = [BigDatapath '/Analyzed_experimental_surge_20cm_s'];
filename{6} = [BigDatapath '/Analyzed_experimental_surge_33cm_s'];

rpm = [2.2933/.1311 37 64 131 168 266];
flowvel = .1311*rpm-2.2933;
collision = [64 74 84 95 100 100];

no_waves = zeros(1,length(filename));
std_waves = zeros(1,length(filename));
max_power_freq = zeros(1,length(filename));
std_freq = zeros(1,length(filename));

time_limit = 0.9;
fin_length = [9.5 10.5 10.5 10.5 10.5 10.5];

syms fv spwl wv f lambda
wave_eff_sym = fv/(10*spwl*wv);
wave_speed_sym = fv*spwl*10;
flambda_sym = f*lambda*10;

mean_vel = nan(2,length(filename));
std_vel  = nan(2,length(filename));
max_power_freq  = nan(2,length(filename));
std_freq = nan(2,length(filename));
f_lambda = nan(2,length(filename));
f_lambda_std = nan(2,length(filename));
sp_wavelength = nan(2,length(filename));
std_sp_wavelength = nan(2,length(filename));
no_waves = nan(2,length(filename));
std_waves = nan(2,length(filename));

for iFile = 1:length(filename)
    load(filename{iFile},'S','T','ymovement','Fs','fin_base_length','SHalf')
%     pixels_per_cm = mean(fin_base_length)/120;
%     if iFile == 1
%         pixels_per_cm = mean(fin_base_length)/95;
%     else
%         pixels_per_cm = mean(fin_base_length)/105;
%     end
       
    % Wave speed
    ymovement = ymovement/100;
    ymovement = ymovement*fin_length(1)*10;
    ymovement = ymovement - repmat(mean(ymovement),size(ymovement,1),1);
    ray_length = max(max(abs(ymovement)),ray_length);
    ymovement = asin(ymovement./repmat(ray_length,size(ymovement,1),1))*180/pi;

%     ymovement = ymovement/pixels_per_cm;
%     ymovement = ymovement - repmat(mean(ymovement),size(ymovement,1),1);
%     ymovement = asin(ymovement./repmat(ray_length,size(ymovement,1),1))*180/pi;
    if iFile <= 4
        num_halves = 2;
    else
        num_halves = 1;
    end
    for iHalf = 1:num_halves
        
        % Specific wavelength
        [temp_max maxInd] = max(SHalf(iHalf).p);
        no_waves(iHalf,iFile) = SHalf(iHalf).freq(round(mean(maxInd)));
        std_waves(iHalf,iFile) = SHalf(iHalf).freq(round(std(maxInd)));
        sp_wavelength(iHalf,iFile) = 1/SHalf(iHalf).freq(round(mean(maxInd)));
        std_sp_wavelength(iHalf,iFile) = sp_wavelength(iHalf,iFile)*std_waves(iHalf,iFile)/no_waves(iHalf,iFile);
        
        
%         if iFile < 4
            ranges = [1 collision(iFile);collision(iFile)+1 100];
%         end
        ymovement_half = ymovement(1:Fs*time_limit,[ranges(iHalf,1):ranges(iHalf,2)]);
        if iFile == 1
            Fs = 300;
        end
        mean_wave_speed_half = zeros(1,size(ymovement_half,2));
        max_amp = max(max(ymovement_half))-min(min(ymovement_half));
        for r = 1:size(ymovement_half,2)
            temp = smooth(ymovement_half(:,r),20);
            for t = 2:size(ymovement_half,1)
                mean_wave_speed_half(r) = mean_wave_speed_half(r)+(temp(t-1)<0 & temp(t)>0)+(temp(t-1)>0 & temp(t)<0);
            end        
        end
        mean_wave_speed_half = mean_wave_speed_half/(2*time_limit);
        mean_vel(iHalf,iFile) = mean(mean_wave_speed_half);
        std_vel(iHalf,iFile) = std(mean_wave_speed_half);
        
        % Frequency
        [temp_max maxInd] = max(T.p(:,ranges(iHalf,1):ranges(iHalf,2)));
        max_power_freq(iHalf,iFile) = T.freq(round(mean(maxInd)));
        std_freq(iHalf,iFile) = T.freq(round(std(maxInd)));
        
        % f*lambda
        temp_flambda_sym = PropError(flambda_sym,[f lambda],...
            [max_power_freq(iHalf,iFile) sp_wavelength(iHalf,iFile)],[std_freq(iHalf,iFile) std_sp_wavelength(iHalf,iFile)]);
        f_lambda(iHalf,iFile) = temp_flambda_sym{1};
        f_lambda_std(iHalf,iFile) = temp_flambda_sym{1,3};
    end
    
    
    % Wave speed cm/s
    for iHalf = 1:2
        wave_speed_temp = PropError(wave_speed_sym,[fv spwl],[mean_vel(iHalf,iFile) sp_wavelength(iHalf,iFile)],...
            [std_vel(iHalf,iFile) std_sp_wavelength(iHalf,iFile)]);
        wave_speed(iHalf,iFile) = double(wave_speed_temp{1});
        wave_speed_std(iHalf,iFile) = wave_speed_temp{1,3};
        
        % Wave efficiency
        wave_efficiency_temp = PropError(wave_eff_sym,[fv spwl wv],...
            [flowvel(iFile) sp_wavelength(iHalf,iFile) mean_vel(iHalf,iFile)],...
            [0 std_sp_wavelength(iHalf,iFile) std_vel(iHalf,iFile)]);
        wave_efficiency_mean(iHalf,iFile) = double(wave_efficiency_temp{1});
        wave_efficiency_error(iHalf,iFile) = wave_efficiency_temp{1,3};
        if iFile <=4
            wave_efficiency_mean(iHalf,iFile) = nan;
            wave_efficiency_error(iHalf,iFile) = nan;
        end
    end

    
end

table_columns = {'\specialcell{Swim speed\\(\cus)}',...
    '\specialcell{Frequency\\(Hz)}',...
    'Num waves',...    
    '\specialcell{Wavelength\\(cm/wave)}',... 
    '\specialcell{Wave velocity\\(\cus)}',...
    'Wave efficiency'};

results_table_cell = cell(length(filename),length(table_columns));
strformat = '%2.1f';
max wi
for iFile = 1:length(filename)
    if iFile < 4
        results_table_cell{iFile,1} = ['\;' num2str(flowvel(iFile),strformat)];
    else
        results_table_cell{iFile,1} = num2str(flowvel(iFile),strformat);
    end
    results_table_cell{iFile,2} = data2tex(max_power_freq(1,iFile),std_freq(1,iFile),max_power_freq(2,iFile),std_freq(2,iFile),strformat);
    results_table_cell{iFile,3} = data2tex(no_waves(1,iFile),std_waves(1,iFile),...
        no_waves(2,iFile),std_waves(2,iFile),strformat);
    results_table_cell{iFile,4} = data2tex(fin_length(iFile)*sp_wavelength(1,iFile),fin_length(iFile)*std_sp_wavelength(1,iFile),...
        fin_length(iFile)*sp_wavelength(2,iFile),fin_length(iFile)*std_sp_wavelength(2,iFile),strformat);
    results_table_cell{iFile,5} = data2tex(wave_speed(1,iFile),wave_speed_std(1,iFile),wave_speed(2,iFile),wave_speed_std(2,iFile),strformat);
    results_table_cell{iFile,6} = data2tex(wave_efficiency_mean(1,iFile),wave_efficiency_error(1,iFile),...
        wave_efficiency_mean(2,iFile),wave_efficiency_error(2,iFile),strformat);
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
