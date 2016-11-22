function calculatePercentChange
global BIGEYEROOT

   [visualRangeParam.Aquatic, visualVolumeParam.Aquatic, drdAParam.Aquatic, dVdAParam.Aquatic] = ...
       Aquatic_calcVolumegetDerSensitivity(1);
   [rawVisualRange.Aquatic, rawVisualVolume.Aquatic, rawdrdA.Aquatic, rawdVdA.Aquatic] =...
       Aquatic_calcVolumegetDer(1);
   [visualRangeParam.Aerial, visualVolumeParam.Aerial,drdAParam.Aerial, dVdAParam.Aerial]=...
       AerialSensitivity_calcVolumegetDerivatives(1);
   [rawVisualRange.Aerial,~,~, rawVisualVolume.Aerial,~,~, rawdrdA.Aerial,~,~,rawdVdA.Aerial,~,~]=...
       Aerial_calcVolumegetDerivatives(1);
   
   allVisualRange.Aquatic=cat(3,[rawVisualRange.Aquatic(:,1,1),rawVisualRange.Aquatic(:,1,2)],visualRangeParam.Aquatic);
   allVisualRange.Aerial=cat(3,rawVisualRange.Aerial,visualRangeParam.Aerial);
   alldrdA.Aquatic=cat(3,[rawdrdA.Aquatic(:,1,1),rawdrdA.Aquatic(:,1,2)],drdAParam.Aquatic);
   alldrdA.Aerial=cat(3,rawdrdA.Aerial',drdAParam.Aerial);
   allVisualVolume.Aquatic=cat(3,[rawVisualVolume.Aquatic(:,1,1),rawVisualVolume.Aquatic(:,1,2)],visualVolumeParam.Aquatic);
   allVisualVolume.Aerial=cat(3,rawVisualVolume.Aerial',visualVolumeParam.Aerial);
   alldVdA.Aquatic=cat(3,[rawdVdA.Aquatic(:,1,1),rawdVdA.Aquatic(:,1,2)],dVdAParam.Aquatic);
   alldVdA.Aerial=cat(3,rawdVdA.Aerial',dVdAParam.Aerial);
   
   visualRange.Aquatic.NoChange=allVisualRange.Aquatic(:,:,1);
   visualRange.Aerial.NoChange=allVisualRange.Aerial(:,:,1);
   drdA.Aquatic.NoChange=alldrdA.Aquatic(:,:,1);
   drdA.Aerial.NoChange=alldrdA.Aerial(:,:,1);
   visualVolume.Aquatic.NoChange=allVisualVolume.Aquatic(:,:,1);
   visualVolume.Aerial.NoChange=allVisualVolume.Aerial(:,:,1);
   dVdA.Aquatic.NoChange=alldVdA.Aquatic(:,:,1);
   dVdA.Aerial.NoChange=alldVdA.Aerial(:,:,1);
   parameters={'X','q','Dt','d','M','contrast'};
   conditions={'Aquatic','Aerial'};
   
   for c=1:length(conditions)
       for i=1:length(parameters)
           visualRange.(conditions{c}).(parameters{i})=allVisualRange.(conditions{c})(:,:,i+1);
           percChangeRange.(conditions{c}).(parameters{i})=abs(visualRange.(conditions{c}).(parameters{i})-visualRange.(conditions{c}).NoChange)./visualRange.(conditions{c}).NoChange;
           meanPercChangeRange.(conditions{c}).(parameters{i})=mean(percChangeRange.(conditions{c}).(parameters{i}));

           drdA.(conditions{c}).(parameters{i})=alldrdA.(conditions{c})(:,:,i+1);
           percChangedrdA.(conditions{c}).(parameters{i})=abs(drdA.(conditions{c}).(parameters{i})-drdA.(conditions{c}).NoChange)./drdA.(conditions{c}).NoChange;
           meanPercChangedrdA.(conditions{c}).(parameters{i})=mean(percChangedrdA.(conditions{c}).(parameters{i}));

           visualVolume.(conditions{c}).(parameters{i})=allVisualVolume.(conditions{c})(:,:,i+1);
           percChangeVolume.(conditions{c}).(parameters{i})=abs(visualVolume.(conditions{c}).(parameters{i})-visualVolume.(conditions{c}).NoChange)./visualVolume.(conditions{c}).NoChange;
           meanPercChangeVolume.(conditions{c}).(parameters{i})=mean(percChangeVolume.(conditions{c}).(parameters{i}));

           dVdA.(conditions{c}).(parameters{i})=alldVdA.(conditions{c})(:,:,i+1);
           percChangedVdA.(conditions{c}).(parameters{i})=abs(dVdA.(conditions{c}).(parameters{i})-dVdA.(conditions{c}).NoChange)./dVdA.(conditions{c}).NoChange;
           meanPercChangedVdA.(conditions{c}).(parameters{i})=mean(percChangedVdA.(conditions{c}).(parameters{i}));
       end
   end
   
    save([BIGEYEROOT 'fig03_visualrange/figure_sensitivity/percChange.mat'],'visualRange','percChangeRange','meanPercChangeRange',...
        'drdA','percChangedrdA','meanPercChangedrdA',...
        'visualVolume','percChangeVolume','meanPercChangeVolume',...
        'dVdA','percChangedVdA','meanPercChangedVdA');
   
   
   

 