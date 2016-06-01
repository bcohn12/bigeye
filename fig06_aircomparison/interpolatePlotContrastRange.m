clear all; close all;

load('contrastRangeAll')

[C0RangeExtended,indices]=sort([C0Range 0]);
daylightRangeExtended = [daylightRange; zeros(1,length(pupilValues))];
moonlightRangeExtended=[moonlightRange;zeros(1,length(pupilValues))];
starlightRangeExtended=[starlightRange;zeros(1,length(pupilValues))];

daylightRangeInterp=[];
moonlightRangeInterp=[];
starlightRangeInterp=[];

C0Query=linspace(-1,4,100);
for i=1:length(pupilValues)
    tempD= daylightRangeExtended(indices,i);
    tempM=moonlightRangeExtended(indices,i);
    tempS=starlightRangeExtended(indices,i);
    
    daylightRangeInterp=[interp1(C0Range,tempD,C0Query,'cubic'),daylightRangeInterp];
    moonlightRangeInterp=[tempM,moonlightRangeInterp];
    starlightRangeInterp=[tempS,starlightRangeInterp];
end


