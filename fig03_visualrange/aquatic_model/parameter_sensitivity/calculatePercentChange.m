function calculatePercentChange
global BIGEYEROOT
   [visualRangeSens_River, visualVolumeSens_River, drdASens_River, dVdASens_River,pupilValues] = Aquatic_calcVolumegetDerSensitivity(1);
   [visualRange_River, visualVolume_River, drdA_River, dVdA_River,pupilValues] =Aquatic_calcVolumegetDer(1);
   
   visualRangeAquatic.NoChange=[visualRange_River(:,1,1) visualRange_River(:,1,2)];
   drdAAquatic.NoChange=[drdA_River(:,1,1) drdA_River(:,1,2)];
   visualVolumeAquatic.NoChange=[visualVolume_River(:,1,1) visualVolume_River(:,1,2)];
   dVdAAquatic.NoChange=[dVdA_River(:,1,1) dVdA_River(:,1,2)];
   parameters={'XAquatic','qAquatic','DtAquatic','d','M','contrast'};
   
   for i=1:length(parameters)
       visualRangeAquatic.(parameters{i})=visualRangeSens_River(:,:,i);
       percChangeRange.(parameters{i})=abs(visualRangeAquatic.(parameters{i})-visualRangeAquatic.NoChange)./visualRangeAquatic.NoChange;
       meanPercChangeRange.(parameters{i})=mean(percChangeRange.(parameters{i}));
      
       drdAAquatic.(parameters{i})=drdASens_River(:,:,i);
       percChangedrdA.(parameters{i})=abs(drdAAquatic.(parameters{i})-drdAAquatic.NoChange)./drdAAquatic.NoChange;
       meanPercChangedrdA.(parameters{i})=mean(percChangedrdA.(parameters{i}));
       
       visualVolumeAquatic.(parameters{i})=visualVolumeSens_River(:,:,i);
       percChangeVolume.(parameters{i})=abs(visualVolumeAquatic.(parameters{i})-visualVolumeAquatic.NoChange)./visualVolumeAquatic.NoChange;
       meanPercChangeVolume.(parameters{i})=mean(percChangeVolume.(parameters{i}));
       
       dVdAAquatic.(parameters{i})=dVdASens_River(:,:,i);
       percChangedVdA.(parameters{i})=abs(dVdAAquatic.(parameters{i})-dVdAAquatic.NoChange)./dVdAAquatic.NoChange; 
       meanPercChangedVdA.(parameters{i})=mean(percChangedVdA.(parameters{i}));
   end
   
    save([BIGEYEROOT 'fig03_visualrange/aquatic_model/parameter_sensitivity/percChange.mat'],'visualRangeAquatic','percChangeRange','meanPercChangeRange',...
        'drdAAquatic','percChangedrdA','meanPercChangedrdA',...
        'visualVolumeAquatic','percChangeVolume','meanPercChangeVolume',...
        'dVdAAquatic','percChangedVdA','meanPercChangedVdA');
   
   
   

 