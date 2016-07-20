function interpolateContrastRange

    load('bir')
    
    [C0RangeExtended,indices]=sort([C0Range,0]);
    C0RangeExtendedNew=sort([linspace(min(C0Range),max(C0Range),200),0]);
    
    interpVisualRange=zeros(length(C0RangeExtendedNew),...
        size(visualRangeSolns,2),...
        size(visualRangeSolns,3));
    
    for k=1:size(visualRangeSolns,3)
        for j=1:size(visualRangeSolns,2)
            dum=visualRangeSolns(:,j,k);
            dum=[dum;0]; dum=dum(indices);
            
            interpRange=interp1(C0RangeExtended,dum,C0RangeExtendedNew,'pchip');
            interpVisualRange(:,j,k)=interpRange;
            dum=[];
        end
    end
            
            
    


