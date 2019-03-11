function newWheelData = plotWheelData(mirrorData, wheelData, cellData)


minPeakHeight = 3;
% [peakValue firstPoint] = findpeaks(abs(mirrorData),'MinPeakHeight', minPeakHeight, 'NPeaks', 1);
[peakValue location] = findpeaks(abs(mirrorData),'MinPeakHeight', minPeakHeight);
% newMirrorData = mirrorData(location(1):location(end));
newWheelData = wheelData(location(1):location(end));
samplingRate = length(cellData)/length(newWheelData);
frameNumber = samplingRate:samplingRate:length(cellData);
% xAxisScaling = length(cellData)/length(newWheelData);

% plot(newMirrorData)
figure()
plot(frameNumber, newWheelData)
end