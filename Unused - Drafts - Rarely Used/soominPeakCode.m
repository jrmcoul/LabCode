data = AD0_2.data(1:97000); % change data name; cutting off end of signal because of deflection
baselined = zscore(data); % zscoring to normalize

bigMPP = 7; % min peak prominence
bigMPH = 7; % min peak prominence
smallMPP = 3; % min peak height
smallMPH = 3; % min peak height
MINW = 5; % min peak width

inverted = -baselined; % for finding the downward deflections
[bigPKS, bigLOCS]  = findpeaks(inverted,'MinPeakHeight', bigMPH, 'MinPeakProminence', bigMPP, 'MinPeakWidth', MINW);
[smallPKS, smallLOCS] = findpeaks(baselined,'MinPeakHeight', smallMPH, 'MinPeakProminence', smallMPP, 'MinPeakWidth', MINW);

threshold = 3; % how many stdevs from mean should peak onset be (I found 3 works best... if not, maybe align to peak itself)
isOnset = true; % because looking for peak onset
bigLOCSFinal = iterToMin(inverted, bigLOCS, threshold, isOnset); % final peak onsets

beforeOnset = 15; % points to plot BEFORE peak onset (in samples, NOT time--divide by samplerate to get time)
afterOnset = 100; % points to plot AFTER peak onset (in samples, NOT time--divide by samplerate to get time)
peakMatrix = zeros(length(bigPKS),beforeOnset + afterOnset + 1); % initializes peak matrix
peakDuration = zeros(size(bigLOCSFinal)); % initializes peak duration

% Plotting the overlaid traces and calculating duration of each peak
figure;
for i = 1:length(bigPKS)
%     peakMatrix(i,:) = data(bigLOCS(i) - beforeOnset:bigLOCS(i) + afterOnset);
    peakMatrix(i,:) = data(bigLOCSFinal(i) - beforeOnset:bigLOCSFinal(i) + afterOnset);
    plot(peakMatrix(i,:));
    hold on
    peakDuration(i) = smallLOCS(i) - bigLOCSFinal(i);
end

meanPeak = mean(peakMatrix,1); % Mean peak image

% Plotting mean peak
figure;
plot(meanPeak)

% To check if every peak is captured
figure;
hold on
plot(baselined)
stem(bigLOCS, -bigPKS);
stem(smallLOCS, smallPKS);
% stem(bigLOCSFinal, ones(size(bigLOCSFinal)));
hold off

% Histogram of peak durations
figure;
histogram(peakDuration,100)
