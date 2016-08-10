function tabExt03_gain
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
    
    Aerial.range=visualRange; Aerial.derRange=drdA';
    Aerial.volume=visualVolume'; Aerial.derVolume=dVdA';
    
    rowlength=12;
    columnlabels={'\textbf{#}','\textbf{Aquatic Condition}','\textbf{Aerial Condition}',...
        '\textbf{Visual Range,Gain}','\textbf{Visual Range,Derivative Gain}',...
        '\textbf{Visual Volume,Gain}','\textbf{Visual Volume,Derivative Gain}'};
    m=1;
    for i=1:length(columnlabels)
        c{i}=strsplit(columnlabels{i},',')';
        temp=length(c{i});
        if temp>m
            m=temp;
        end
    end
    for i=1:length(columnlabels)
        for j=length(c{i}):m-1
            c{i}{j+1,1}=' ';
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
        des.Aerial{i}=strsplit(description.Aerial{i},'.')';
        des.Aquatic{i}=strsplit(description.Aquatic{i},'.')';
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
        val{3,i}=num2str(round((interp1q(pupilValuesAir,Aerial.(columncond{i})(:,1),fishpupil*1e-3))/...
          (interp1q(pupilValues,Aquatic.(columncond{i})(:,1),fishpupil*1e-3))));
        val{4,i}=num2str(round((interp1q(pupilValuesAir,Aerial.(columncond{i})(:,1),tetrapodpupil*1e-3))/...
          (interp1q(pupilValues,Aquatic.(columncond{i})(:,1),fishpupil*1e-3))));
        val{5,i}=num2str(round((interp1q(pupilValuesAir,Aerial.(columncond{i})(:,2),fishpupil*1e-3))/...
         (interp1q(pupilValues,Aquatic.(columncond{i})(:,1),fishpupil*1e-3))));
        val{6,i}=num2str(round((interp1q(pupilValuesAir,Aerial.(columncond{i})(:,3),fishpupil*1e-3))/...
         (interp1q(pupilValues,Aquatic.(columncond{i})(:,1),fishpupil*1e-3))));
        val{7,i}=num2str(round((interp1q(pupilValuesAir,Aerial.(columncond{i})(:,2),tetrapodpupil*1e-3))/...
          (interp1q(pupilValues,Aquatic.(columncond{i})(:,1),fishpupil*1e-3))));
        val{8,i}=num2str(round((interp1q(pupilValuesAir,Aerial.(columncond{i})(:,3),tetrapodpupil*1e-3))/...
          (interp1q(pupilValues,Aquatic.(columncond{i})(:,1),fishpupil*1e-3))));
        val{9,i}=num2str(round((interp1q(pupilValuesAir,Aerial.(columncond{i})(:,2),fishpupil*1e-3))/...
          (interp1q(pupilValues,Aquatic.(columncond{i})(:,3),fishpupil*1e-3))));
        val{10,i}=num2str(round((interp1q(pupilValuesAir,Aerial.(columncond{i})(:,2),tetrapodpupil*1e-3))/...
         (interp1q(pupilValues,Aquatic.(columncond{i})(:,3),fishpupil*1e-3))));
        val{11,i}=num2str(round((interp1q(pupilValuesAir,Aerial.(columncond{i})(:,3),fishpupil*1e-3))/...
         (interp1q(pupilValues,Aquatic.(columncond{i})(:,4),fishpupil*1e-3))));
        val{12,i}=num2str(round((interp1q(pupilValuesAir,Aerial.(columncond{i})(:,3),tetrapodpupil*1e-3))/...
         (interp1q(pupilValues,Aquatic.(columncond{i})(:,4),fishpupil*1e-3)))); 
    end
    num=(1:1:12);
    for i=1:rowlength
        dTempAerial=des.Aerial{i};
        dTempAquatic=des.Aquatic{i};
        for j=length(dTempAerial):n-1
            des.Aerial{i}{j+1,1}=' ';
        end
        for j=length(dTempAquatic):n-1
            des.Aquatic{i}{j+1,1}=' ';
        end
        for k=1:size(val,2)
            valTemp{i,k}{1}=val{i,k};
            for j=length(valTemp{i,k}):n-1
                valTemp{i,k}{j+1,1}=' ';
            end
        end
        numcell{1,i}=num2str(num(i));
        for j=1:n-1
            numcell{j+1,i}=' ';
        end
    end
    des.Aerial=reshape([des.Aerial{:}],[rowlength*n,1]);
    des.Aquatic=reshape([des.Aquatic{:}],[rowlength*n,1]);
    valTemp=reshape([valTemp{:}],[rowlength*n,length(columncond)]);
    numcell=reshape(numcell,[rowlength*n,1]);
    c=[c{:}];
    
    matrixTemp=[numcell des.Aquatic des.Aerial valTemp];
    %matrix=[c;matrixTemp];
    
    filename='tab03_gain.tex';
    matrix2latex(matrixTemp,c,filename,m,n);
        
function matrix2latex(matrix, columnlabels,filename,labelline,valueline)
    fid = fopen(filename, 'w');
    str='';
    for i=1:size(matrix,2)
        temp='l';
        str=strcat(str,temp);
    end
    fprintf(fid, '\\begin{tabular}{%s}\r\n',str);
    fprintf(fid,'\\toprule\r\n');
    for i=1:size(columnlabels,1);
        str='';
        for j=1:size(columnlabels,2);
            str=strcat(str,'&',columnlabels{i,j});
        end
        str=str(2:end);
        str=strcat(str,'\\\');
        if ~mod(i,labelline)
               str=strcat(str, '\\hline');
        end
        fprintf(fid,'%s\r\n',str);
    end
    for i=1:size(matrix,1)
        str='';
        for j=1:size(matrix,2);
            str=strcat(str,'&',matrix{i,j});
        end
        str=str(2:end);
        str=strcat(str,'\\\');
        if ~mod(i,valueline)
            str=strcat(str,'\\hline');
        end
        fprintf(fid,'%s\r\n',str);
    end
    
    fprintf(fid,'\\bottomrule\r\n');
    fprintf(fid,'\\end{tabular}\r\n');
    fclose(fid);
            