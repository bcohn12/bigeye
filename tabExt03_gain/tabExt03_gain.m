function tabExt03_gain
global BIGEYEROOT
    %run Parameters.m
    %load('Parameters.mat')
    
    load('visibilityAerial_Daylight.mat')
    load('visibilityAerial_Moonlight.mat')
    load('visibilityAerial_Starlight.mat')
    load('visibilityAquatic_All.mat');
    load OM_TF_ST.mat
    load FinnedDigitedOrbitLength.mat
    
    pupil_TF = [mean(noElpistoOrb)-std(noElpistoOrb) mean(noElpistoOrb)+std(noElpistoOrb)].*0.449;
    pupil_ST = [mean(noSecAqOrb)-std(noSecAqOrb) mean(noSecAqOrb)+std(noSecAqOrb)].*0.449;
    fishpupil=mean(noElpistoOrb)*.449;
    tetrapodpupil=mean(noSecAqOrb)*.449;
    
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
    
    rowlength=13;
    columnlabels={'\textbf{\#}','\textbf{Aquatic Condition}','\textbf{Aerial Condition}',...
        '\textbf{Visual Range},\textbf{Gain}','\textbf{Visual Range},\textbf{Derivative Gain}',...
        '\textbf{Visual Volume},\textbf{Gain}','\textbf{Visual Volume},\textbf{Derivative Gain}'};
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
        'Daylight 8~m depth,.horizontal viewing,.Digited tetrapod pupil'
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
    
    numfunc=@(Y,x) interp1q(pupilValuesAir,Y,x);
    denomfunc=@(Y,x) interp1q(pupilValues,Y,x);
    f=fishpupil*1e-3; t=tetrapodpupil*1e-3;
    
    columncond={'range','derRange','volume','derVolume'}; val={};
    for i=1:length(columncond)
      ratio1=numfunc(Aerial.(columncond{i})(:,1),f)/...
          denomfunc(Aquatic.(columncond{i})(:,2),f);
      val{1,i}=num2str(round(ratio1));

      ratio2=numfunc(Aerial.(columncond{i})(:,1),t)/...
          denomfunc(Aquatic.(columncond{i})(:,2),f);
      val{2,i}=num2str(round(ratio2));
      
      ratio3=numfunc(Aerial.(columncond{i})(:,1),t)/...
          denomfunc(Aquatic.(columncond{i})(:,2),t);
      val{3,i}=num2str(round(ratio3));

      ratio4=numfunc(Aerial.(columncond{i})(:,1),f)/...
          denomfunc(Aquatic.(columncond{i})(:,1),f);
      val{4,i}=num2str(round(ratio4));

      ratio5=numfunc(Aerial.(columncond{i})(:,1),t)/...
          denomfunc(Aquatic.(columncond{i})(:,1),f);
      val{5,i}=num2str(round(ratio5));

      ratio6=numfunc(Aerial.(columncond{i})(:,2),f)/...
          denomfunc(Aquatic.(columncond{i})(:,1),f);
      val{6,i}=num2str(round(ratio6));

      ratio7=numfunc(Aerial.(columncond{i})(:,3),f)/...
          denomfunc(Aquatic.(columncond{i})(:,1),f);
      val{7,i}=num2str(round(ratio7));

      ratio8=numfunc(Aerial.(columncond{i})(:,2),t)/...
          denomfunc(Aquatic.(columncond{i})(:,1),f);
      val{8,i}=num2str(round(ratio8));

      ratio9=numfunc(Aerial.(columncond{i})(:,3),t)/...
          denomfunc(Aquatic.(columncond{i})(:,1),f);
      val{9,i}=num2str(round(ratio9));

      ratio10=numfunc(Aerial.(columncond{i})(:,2),f)/...
          denomfunc(Aquatic.(columncond{i})(:,3),f);
      val{10,i}=num2str(round(ratio10));

      ratio11=numfunc(Aerial.(columncond{i})(:,2),t)/...
          denomfunc(Aquatic.(columncond{i})(:,3),f);
      val{11,i}=num2str(round(ratio11));

      ratio12=numfunc(Aerial.(columncond{i})(:,3),f)/...
          denomfunc(Aquatic.(columncond{i})(:,4),f);
      val{12,i}=num2str(round(ratio12));

      ratio13=numfunc(Aerial.(columncond{i})(:,3),t)/...
          denomfunc(Aquatic.(columncond{i})(:,4),f);
      val{13,i}=num2str(round(ratio13));
    end
    num=(1:1:13);
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
    
    filename=[BIGEYEROOT 'tabExt03_gain/tabExt03_gain.tex'];
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
            