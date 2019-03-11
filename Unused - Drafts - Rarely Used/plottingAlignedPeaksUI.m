[trials] = uigetfile('*.mat','MultiSelect','on');

[onsetsMatrix totalPeaks tempWindow] = alignPeaksUI(trials);

timeBefore = 2*30;
timeAfter = 5*30;
onsetTime = (-timeBefore:timeAfter)/30;

figure;
for cellType = 1:2
%     subplot(3,1,cellType);
%     shadedErrorBar(onsetTime, mean(onsetsMatrix{cellType},1), std(onsetsMatrix{cellType},1)/sqrt(size(onsetsMatrix{cellType},1)), 'r',1);
    plot(onsetTime, onsetsMatrix{cellType})
    xlabel('Time (s)')
    ylabel('Average Fluorescence (DF/F)')
    title(['D',num2str(cellType),' Average Spike'])
%     axis([-2.2, 5.2, 0, 1.5])
    hold on
end
hold off