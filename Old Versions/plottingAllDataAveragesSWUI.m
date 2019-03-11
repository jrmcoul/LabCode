[trials, pathname] = uigetfile('*.mat','MultiSelect','on');

if ~iscell(trials)
    tempTrials = trials;
    trials = cell(1);
    trials{1} = tempTrials;
end

cd(pathname)

condition = 2; % 1 = D1, 2 = D2, 3 = other
norm = false; % true if you want to normalize each trace
avg = true; % true if you want the mean signal at onset/offset instead of summed signal/ false for the sum

[time, finalOnsetsDF, finalOnsetsBeh, finalOffsetsDF, finalOffsetsBeh, meanBaseline] = plotMeanOnsetOffsetUI(trials, condition, norm, avg);

%%
% %Optional
% finalOnsetsDF = finalOnsetsDF/max(max(finalOnsetsDF));
% finalOffsetsDF = finalOffsetsDF/max(max(finalOffsetsDF));
% finalOnsetsBeh = finalOnsetsBeh/max(max(finalOnsetsBeh));
% finalOffsetsBeh = finalOffsetsBeh/max(max(finalOffsetsBeh));

%plotting
figure();
h(1) = subplot(2,1,1);
% shadedErrorBar(time, mean(finalOffsetsDF,1), std(finalOffsetsDF,1)/sqrt(size(finalOffsetsDF,1)), 'r',1);
shadedErrorBar(downsample(time,5), downsample(mean(finalOffsetsDF,1),5), downsample(std(finalOffsetsDF,1),5)/sqrt(size(finalOffsetsDF,1)), 'r',1);
title('mean fluorescence at Offset')
h(2) = subplot(2,1,2);
% hold on
% shadedErrorBar(time, mean(finalOffsetsBeh,1), std(finalOffsetsBeh,1)/sqrt(size(finalOffsetsBeh,1)), 'k',1);
shadedErrorBar(downsample(time,5), downsample(mean(finalOffsetsBeh,1),5), downsample(std(finalOffsetsBeh,1),5)/sqrt(size(finalOffsetsBeh,1)), 'k',1);
title('mean velocity at Offset')
% hold off
linkaxes(h,'x')
xlabel('Time (s)')

figure(); 
h(1) = subplot(2,1,1);
% shadedErrorBar(time, mean(finalOnsetsDF,1), std(finalOnsetsDF,1)/sqrt(size(finalOnsetsDF,1)), 'r',1);
shadedErrorBar(downsample(time,5), downsample(mean(finalOnsetsDF,1),5), downsample(std(finalOnsetsDF,1),5)/sqrt(size(finalOnsetsDF,1)), 'r',1);
title('mean fluorescence at Onset')
h(2) = subplot(2,1,2);
% hold on
% shadedErrorBar(time, mean(finalOnsetsBeh,1), std(finalOnsetsBeh,1)/sqrt(size(finalOnsetsBeh,1)), 'k',1);
shadedErrorBar(downsample(time,5), downsample(mean(finalOnsetsBeh,1),5), downsample(std(finalOnsetsBeh,1),5)/sqrt(size(finalOnsetsBeh,1)), 'k',1);
title('mean velocity at Onset')
% hold off
linkaxes(h,'x')
xlabel('Time (s)')

% Plotting all DF/F and Velocity Traces for ONSET
figure();
subplot(2,1,1)
title('DF Traces at Onset')
hold on
for trace = 1:size(finalOnsetsDF,1)
    plot(time, finalOnsetsDF(trace,:));  
end
hold off
subplot(2,1,2)
title('Velocity Traces at Onset')
hold on
for trace = 1:size(finalOnsetsBeh,1)
    plot(time, finalOnsetsBeh(trace,:));  
end
xlabel('Time (s)')
hold off

% Plotting all DF and Velocity Traces for OFFSET
figure();
subplot(2,1,1);
title('DF Traces at Offset')
hold on
for trace = 1:size(finalOffsetsDF,1)
    plot(time, finalOffsetsDF(trace,:));  
end
hold off
subplot(2,1,2);
title('Velocity Traces at Offset')
hold on
for trace = 1:size(finalOffsetsBeh,1)
    plot(time, finalOffsetsBeh(trace,:));  
end
xlabel('Time (s)')
hold off

% Plotting Onsets Heat Map
figure();
imagesc(finalOffsetsDF,[0,0.25]);
figure();
imagesc(finalOnsetsDF,[0,0.25]);
% colormap gray

%%

%% Plotting avg peak frequency

% [trials] = uigetfile('*.mat','MultiSelect','on');

figure();
for condition = 1:2; % 1 = D1, 2 = D2, 3 = other

[meanDFPerFrameMat, meanSpeedPerFrameMat] = meanDFDuringMovUI(trials, condition);

meanDFPerFrame = nanmean(meanDFPerFrameMat,1);
meanSpeedPerFrame = nanmean(meanSpeedPerFrameMat,1);

errorDFPerFrame = nanstd(meanDFPerFrameMat,1)/size(meanDFPerFrameMat,1);
errorSpeedPerFrame = nanstd(meanSpeedPerFrameMat,1)/size(meanSpeedPerFrameMat,1);

subplot(2,2,1 + 2*(condition-1));
hold on
bar(1.5, meanDFPerFrame(1), 'FaceColor', 'b');
bar(2.5, meanDFPerFrame(2), 'FaceColor', 'r');
bar(3.5, meanDFPerFrame(3), 'FaceColor', 'g');
errorbar([1.5 2.5 3.5], meanDFPerFrame, errorDFPerFrame,'k.')
title('Mean DF/F During Movement or Rest');
set(gca, 'XTick', [1.5 2.5 3.5], 'XTickLabel', {'Movement','Rest','Total'});
ylabel ('Mean DF/F Per Frame');
hold off

% subplot(1,2,2);
% hold on
% bar(1.5, meanSpeedPerFrame(1), 'FaceColor', 'b');
% bar(2.5, meanSpeedPerFrame(2), 'FaceColor', 'r');
% bar(3.5, meanSpeedPerFrame(3), 'FaceColor', 'g');
% errorbar([1.5 2.5 3.5], meanSpeedPerFrame, errorSpeedPerFrame,'k.')
% title('Mean Speed During Movement or Rest');
% set(gca, 'XTick', [1.5 2.5 3.5], 'XTickLabel', {'Movement','Rest','Total'});
% ylabel ('Speed (m/s)');
% hold off

% figure();
subplot(2,2,2 + 2*(condition-1));
hold on
for i = 1:3;
    plot(meanSpeedPerFrameMat(:,i),meanDFPerFrameMat(:,i),'x')
end
hold off
title('Avg DF/F vs. Avg Speed')
ylabel('DF/F')
xlabel('Speed (m/s)')
end

%% Binned Velocity vs. DF

% [trials] = uigetfile('*.mat','MultiSelect','on');

for condition = 1:2; % 1 = D1, 2 = D2, 3 = other
figure(44)
[meanDFPerFrameMat, meanSpeedPerFrameMat] = meanDFDuringBinsUI(trials, condition);

subplot(2,1,condition);
hold on
for i = 1:size(meanDFPerFrameMat,1);
    plot(meanSpeedPerFrameMat(i,:),meanDFPerFrameMat(i,:),'kx')
end
hold off
title('Avg DF/F vs. Avg Speed')
ylabel('DF/F')
xlabel('Speed (m/s)')
xlim([0, 0.25]);
ylim([0, 0.5]);

meanDFPerBin = nanmean(meanDFPerFrameMat,1);
meanSpeedPerBin = nanmean(meanSpeedPerFrameMat,1);
errorDFPerBin = nanstd(meanDFPerFrameMat,1)/size(meanDFPerFrameMat,1);
errorSpeedPerBin = nanstd(meanSpeedPerFrameMat,1)/size(meanSpeedPerFrameMat,1);

figure(45)
H(condition) = subplot(2,1,condition);
shadedErrorBar(meanSpeedPerBin, meanDFPerBin, errorDFPerBin, 'k',1);
linkaxes(H,'x')
end
