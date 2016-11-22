function tableMaxPercentChange
global BIGEYEROOT
    load('percChange.mat');
    conditions={'Aquatic','AqUp','AqHor','Aerial','ArHor'};

    for c=1:3:length(conditions)
        visualRangeCell.(conditions{c})=struct2cell(visualRange.(conditions{c}));
        drdACell.(conditions{c})=struct2cell(drdA.(conditions{c}));
        visualVolumeCell.(conditions{c})=struct2cell(visualVolume.(conditions{c}));
        dVdACell.(conditions{c})=struct2cell(dVdA.(conditions{c}));
        direction=1;
        if strcmp(conditions{c},'Aquatic')
            direction=2;
        end
        for i=1:direction
            visualRangeMat.(conditions{c+i})=[];
            drdAMat.(conditions{c+i})=[];
            visualVolumeMat.(conditions{c+i})=[];
            dVdAMat.(conditions{c+i})=[];
            for j=2:length(visualRangeCell.Aquatic);
                visualRangeMat.(conditions{c+i})=[visualRangeCell.(conditions{c}){j}(:,i) visualRangeMat.(conditions{c+i})];
                drdAMat.(conditions{c+i})=[drdACell.(conditions{c}){j}(:,i) drdAMat.(conditions{c+i})];
                visualVolumeMat.(conditions{c+i})=[visualVolumeCell.(conditions{c}){j}(:,i) visualVolumeMat.(conditions{c+i})];
                dVdAMat.(conditions{c+i})=[dVdACell.(conditions{c}){j}(:,i) dVdAMat.(conditions{c+i})];
            end
            maxVisualRange.(conditions{c+i})=max(visualRangeMat.(conditions{c+i}),[],2);
            minVisiualRange.(conditions{c+i})=min(visualRangeMat.(conditions{c+i}),[],2);
            maxdrdA.(conditions{c+i})=max(drdAMat.(conditions{c+i}),[],2);
            mindrdA.(conditions{c+i})=min(drdAMat.(conditions{c+i}),[],2);
            maxVisualVolume.(conditions{c+i})=max(visualVolumeMat.(conditions{c+i}),[],2);
            minVisualVolume.(conditions{c+i})=min(visualVolumeMat.(conditions{c+i}),[],2);
            maxdVdA.(conditions{c+i})=max(dVdAMat.(conditions{c+i}),[],2);
            mindVdA.(conditions{c+i})=min(dVdAMat.(conditions{c+i}),[],2);
        end
    end