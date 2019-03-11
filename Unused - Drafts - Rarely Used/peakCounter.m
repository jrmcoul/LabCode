function nPeaks = peakCounter(data, threshold)

peakTracker = true;
nPeaks = 0;
for iData = 1:length(data);
    if (data(iData) >= threshold) && (peakTracker == true);
        nPeaks = nPeaks + 1;
        peakTracker = false;
    elseif data(iData) < threshold;
        peakTracker = true;
    end
end

%numPeaks = length(findpeaks(Y_Mirror_1.data, 'MinPeakHeight', 2))
end