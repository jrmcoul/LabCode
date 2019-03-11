[trials, pathname] = uigetfile('*.mat','MultiSelect','on');

cd(pathname);

if ~iscell(trials)
    tempTrials = trials;
    trials = cell(1);
    trials{1} = tempTrials;
end

condition = 0;
norm = false;
avg = false;

[time, finalOnsetsDF, finalOnsetsBeh, finalOffsetsDF, finalOffsetsBeh, numOnsets,meanBaseline] = plotMeanOnsetOffsetUINorm(trials, condition, norm, avg);

%% Diff DF

samplerate = 50; %in Hz
onsetIndex = 1;
diffDF = zeros(1,length(numOnsets));
diffBeh = zeros(1,length(numOnsets));
for i = 1:length(numOnsets)
    preDF = mean(mean(finalOnsetsDF(onsetIndex:onsetIndex + numOnsets(i) - 1,2*samplerate:4*samplerate),2),1);
    preBeh = mean(mean(finalOnsetsBeh(onsetIndex:onsetIndex + numOnsets(i) - 1,2*samplerate:4*samplerate),2),1);
    postDF = mean(mean(finalOnsetsDF(onsetIndex:onsetIndex + numOnsets(i) - 1,5*samplerate + 1:8*samplerate + 1),2),1);
    postBeh = mean(mean(finalOnsetsBeh(onsetIndex:onsetIndex + numOnsets(i) - 1,5*samplerate + 1:8*samplerate + 1),2),1);
    diffDF(i) = postDF - preDF;
    diffBeh(i) = postBeh - preBeh;
    onsetIndex = onsetIndex + numOnsets(i);
end

diffDF = diffDF';
diffBeh = diffBeh';

% diffDF = reshape(diffDF,length(date),length(mouse))';
% diffBeh = reshape(diffBeh,length(date),length(mouse))';


%% Plotting DiffDF

% figure();
% for i = 1:length(mouse)
%    if i <= 3
%        plotString = 'bx-';
%    else
%        plotString = 'rx-';
%    end
%    plot(diffDF(i,:),plotString);
%    hold on
% end
% hold off

%% Plotting

% %Optional
% finalOnsetsDF = finalOnsetsDF/max(max(finalOnsetsDF));
% finalOffsetsDF = finalOffsetsDF/max(max(finalOffsetsDF));
% finalOnsetsBeh = finalOnsetsBeh/max(max(finalOnsetsBeh));
% finalOffsetsBeh = finalOffsetsBeh/max(max(finalOffsetsBeh));

% %plotting full data
% figure;
% h(1) = subplot(2,1,1);
% shadedErrorBar(time, mean(finalOffsetsDF,1), std(finalOffsetsDF,1)/sqrt(size(finalOffsetsDF,1)), 'r',1);
% title('mean fluorescence at Offset')
% h(2) = subplot(2,1,2);
% % hold on
% shadedErrorBar(time, mean(finalOffsetsBeh,1), std(finalOffsetsBeh,1)/sqrt(size(finalOffsetsBeh,1)), 'k',1);
% title('mean velocity at Offset')
% % hold off
% linkaxes(h,'x')
% xlabel('Time (s)')

% figure; 
% h(1) = subplot(2,1,1);
% shadedErrorBar(time, mean(finalOnsetsDF,1), std(finalOnsetsDF,1)/sqrt(size(finalOnsetsDF,1)), 'r',1);
% title('mean fluorescence at Onset')
% h(2) = subplot(2,1,2);
% % hold on
% shadedErrorBar(time, mean(finalOnsetsBeh,1), std(finalOnsetsBeh,1)/sqrt(size(finalOnsetsBeh,1)), 'k',1);
% title('mean velocity at Onset')
% % hold off
% linkaxes(h,'x')
% xlabel('Time (s)')


% WILL NEED TO CREATE ERROR BARS BASED ON NUMBER OF BOUTS!!
%plotting downsampled data
figure;
h(1) = subplot(2,1,1);
shadedErrorBar(time, mean(finalOffsetsDF,1), std(finalOffsetsDF,1)/sqrt(size(finalOffsetsDF,1)), 'r',1);
% shadedErrorBar(downsample(time,100), downsample(mean(finalOffsetsDF,1),100), downsample(std(finalOffsetsDF,1)/sqrt(size(finalOffsetsDF,1)),100), 'r',1);
title('mean fluorescence at Offset')
ylim([-.01,.4])
h(2) = subplot(2,1,2);
% hold on
shadedErrorBar(time, mean(finalOffsetsBeh,1), std(finalOffsetsBeh,1)/sqrt(size(finalOffsetsBeh,1)), 'k',1);
% shadedErrorBar(downsample(time,100), downsample(mean(finalOffsetsBeh,1),100), downsample(std(finalOffsetsBeh,1)/sqrt(size(finalOffsetsBeh,1)),100), 'k',1);
title('mean velocity at Offset')
% hold off
linkaxes(h,'x')
xlabel('Time (s)')
ylim([0,.12])

figure; 
h(1) = subplot(2,1,1);
shadedErrorBar(time, mean(finalOnsetsDF,1), std(finalOnsetsDF,1)/sqrt(size(finalOnsetsDF,1)), 'r',1);
% shadedErrorBar(downsample(time,100), downsample(mean(finalOnsetsDF,1),100), downsample(std(finalOnsetsDF,1)/sqrt(size(finalOnsetsDF,1)),100), 'r',1);
title('mean fluorescence at Onset')
ylim([-.01,.3])
h(2) = subplot(2,1,2);
% hold on
shadedErrorBar(time, mean(finalOnsetsBeh,1), std(finalOnsetsBeh,1)/sqrt(size(finalOnsetsBeh,1)), 'k',1);
% shadedErrorBar(downsample(time,100), downsample(mean(finalOnsetsBeh,1),100), downsample(std(finalOnsetsBeh,1)/sqrt(size(finalOnsetsBeh,1)),100), 'k',1);
title('mean velocity at Onset')
% hold off
linkaxes(h,'x')
xlabel('Time (s)')
ylim([0,.12])


% Plotting all DF/F and Velocity Traces for ONSET
% figure();
% subplot(2,1,1)
% title('DF Traces at Onset')
% hold on
% for trace = 1:size(finalOnsetsDF,1)
%     plot(time, finalOnsetsDF(trace,:));  
% end
% hold off
% subplot(2,1,2)
% title('Velocity Traces at Onset')
% hold on
% for trace = 1:size(finalOnsetsBeh,1)
%     plot(time, finalOnsetsBeh(trace,:));  
% end
% xlabel('Time (s)')
% hold off

% Plotting all DF and Velocity Traces for OFFSET
% figure();
% subplot(2,1,1);
% title('DF Traces at Offset')
% hold on
% for trace = 1:size(finalOffsetsDF,1)
%     plot(time, finalOffsetsDF(trace,:));  
% end
% hold off
% subplot(2,1,2);
% title('Velocity Traces at Offset')
% hold on
% for trace = 1:size(finalOffsetsBeh,1)
%     plot(time, finalOffsetsBeh(trace,:));  
% end
% xlabel('Time (s)')
% hold off