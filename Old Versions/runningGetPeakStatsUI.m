[trials] = uigetfile('*.mat','MultiSelect','on');

[PKS, LOCS, peakHeightsArray, riseTimesArray, decayTimesArray] = getPeakStatsUI(trials);

Labels = {'Rise Times','Decay Times'};
figure;
plot(ones(1,length(peakHeightsArray{1})),riseTimesArray{1},'kx', ...
    2*ones(1,length(peakHeightsArray{1})),decayTimesArray{1},'kx');
axis([0.8 2.2 0 7]);
title('D1 Peak Kinetics')
ylabel('Time (s)')
set(gca, 'XTick', 1:2, 'XTickLabel', Labels);

Labels = {'Rise Times','Decay Times'};
figure;
plot(ones(1,length(peakHeightsArray{2})),riseTimesArray{2},'kx', ...
    2*ones(1,length(peakHeightsArray{2})),decayTimesArray{2},'kx');
axis([0.8 2.25 0 7]);
title('D2 Peak Kinetics')
ylabel('Time (s)')
set(gca, 'XTick', 1:2, 'XTickLabel', Labels);

for cellType = 1:2
    avgPeakHeight(cellType) = nanmean(peakHeightsArray{cellType});
    avgRiseTime(cellType) = nanmean(riseTimesArray{cellType});
    avgDecayTime(cellType) = nanmean(decayTimesArray{cellType});
end
