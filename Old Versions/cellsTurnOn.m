roi = data.dF1.dF;
npeaks = 1;
MPH = 5;
MINW = 6;
LOCS = zeros(1,size(roi,1));
PKS = zeros(1,size(roi,1));
for cell = 1:size(roi,1)
    roi(cell,:) = zscore(roi(cell,:));
%     figure(1)
%     plot(roi(cell,:));
%     hold on
    
    [PKS(cell), LOCS(cell)] = findpeaks(roi(cell,:),'MinPeakProminence', MPH, 'MinPeakWidth', MINW,'NPeaks',npeaks);
end

distForCell = zeros(2,length(LOCS));
distForCell(2,:) = (1:length(LOCS))/length(LOCS);
cumDist = cumsum(abs(data.vel))/data.framerate;
distForCell(1,:) = sort(cumDist(LOCS))/data.totalDistance;

figure(4);
plot(distForCell(1,:),distForCell(2,:),'x')
xlim([0,1]);
ylim([0,1]);
hold on