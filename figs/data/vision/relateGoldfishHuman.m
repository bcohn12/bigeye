function relateGoldfishHuman
close all
goldfishRaw=[0.03084944191759974, 192.8056103295762
    0.04641588833612784, 90.21005399537937
    0.17028751022217933, 43.92717395867535
    0.4203934240157969, 25.54643642446791
    1.4497406703726314, 16.344711868182074
    0.059455707085444, 193.83494397901887
    0.105076446271293, 90.53485635350776
    0.4203934240157969, 43.50239053771829
    1.2651748135966805, 25.560042276385097
    2.2920023245825405, 16.064305303909602
    0.1767306309557254, 191.5776226899104
    0.96354270508342, 88.40316212841037
    3.364199333410333, 42.540345957181025
    6.897785379387644, 25.098142285660167
    29.72475471559778, 15.979848859653243
    44.392727392981165, 15.9110785015798
    22.414942772544673, 24.65968433794763
    5.630379061341868, 42.72648740541902
    2.34364848003374, 87.99693963953894
    0.41831686716881, 191.22602595522045];

minSubtendGoldfish=min(goldfishRaw(:,2));
maxSubtendGoldfish=max(goldfishRaw(:,2));
goldFishRawSubtend=reshape(goldfishRaw(:,2),[5,4]);
goldFishRawContrast=reshape(goldfishRaw(:,1),[5,4]);

humanRawContrast=[10^-2.132;
    10^-2.062;
    10^-1.889;
    10^-1.730;
    10^-1.5;
    10^-2.130;
    10^-2.060;
    10^-1.857;
    10^-1.658;
    10^-1.111;
    10^-2.114;
    10^-2.020;
    10^-1.738;
    10^-1.437;
    10^-0.812;
    10^-1.959;
    10^-1.857;
    10^-1.421;
    10^-1.070;
    10^-0.385];
humanRawContrast=reshape(humanRawContrast,[5,4]);
humanRawSubtend=[121.0;
    55.2;
    18.2;
    9.68;
    3.60];
minHumanSubtend=min(humanRawSubtend);
maxHumanSubtend=max(humanRawSubtend);

minSubtend=min([minHumanSubtend,minSubtendGoldfish]);
maxSubtend=max([maxHumanSubtend,maxSubtendGoldfish]);

querySubtend=linspace(minSubtend,maxSubtend,100);
chooseColor=parula(4);
fig1=figure();
hold on;
for i=1:4
    goldfishInterpContrast(:,i)=interp1(goldFishRawSubtend(:,i),goldFishRawContrast(:,i),...
        querySubtend);
    humanInterpContrast(:,i)=interp1(humanRawSubtend,humanRawContrast(:,i),...
        querySubtend);
    for j=1:100
        if (goldfishInterpContrast(j,i)>1) 
            goldfishInterpContrast(j,i)=1;
        end
        if isnan(goldfishInterpContrast(j,i))
            if j==1
                goldfishInterpContrast(j,i)=1;
            else
            goldfishInterpContrast(j,i)=goldfishInterpContrast(j-1,i);
            end
        end
        if isnan(humanInterpContrast(j,i))
            humanInterpContrast(j,i)=humanInterpContrast(j-1,i);
        end
    end
    prctDifference(:,i)=abs(goldfishInterpContrast(:,i)-humanInterpContrast(:,i))./humanInterpContrast(:,i);
    meanprctDifference(:,i)=mean(prctDifference(:,i));

   line('XData',goldfishInterpContrast(:,i),'YData',querySubtend,...
        'linewidth',1.5,'color',chooseColor(i,:),'linestyle',':');
   line('XData',humanInterpContrast(:,i),'YData',querySubtend,...
        'linewidth',1.5,'color',chooseColor(i,:));
    xlabel('Contrast'); ylabel('Angular Diameter (minutes of arc)');
    
end
        
