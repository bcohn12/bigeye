function [interpVisualRange,C0RangeSymExtendedNew] =interpolateContrastRange(C0Range,visualRangeSolns)
    [C0RangeSym,indSym]=sort([C0Range,-C0Range(C0Range<0 & C0Range>-0.3),-C0Range(C0Range>0& C0Range<0.3)]);
    indp=find(C0Range<0 &C0Range>-0.3); indm=find(C0Range>0 &C0Range<0.3);
    [C0RangeSymExt,indExt]=sort([C0RangeSym,0]);
   
    C0RangeSymExtendedNew=linspace(min(C0Range),max(C0Range),101);
    
    interpVisualRange=zeros(length(C0RangeSymExtendedNew),...
        size(visualRangeSolns,2),...
        size(visualRangeSolns,3));
    
    for k=1:size(visualRangeSolns,3)
        for j=1:size(visualRangeSolns,2)
            temp=visualRangeSolns(:,j,k);
            temp=[temp;
                visualRangeSolns(indp(1):indp(end),j,k);
                visualRangeSolns(indm(1):indm(end),j,k)]; temp=temp(indSym); 
            temp=[temp;0]; temp=temp(indExt);
            
            interpRange=interp1(C0RangeSymExt,temp,C0RangeSymExtendedNew,'pchip');
            interpVisualRange(:,j,k)=interpRange;
        end
    end
end
            
    


