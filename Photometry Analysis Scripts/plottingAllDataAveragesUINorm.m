%% Summary:
% 
% This script calculates and plots the average photometry trace at movement
% onset, normalized to preslesion. It relies on the function 
% plotMeanOnsetOffsetUINorm(), and it normalizes the second photometry trace 
% at onset to the same scale as the first photometry trace for a given 
% mouse, across two or more conditions. The scale for the first trace is 
% given so that the average before onset should be 0 and the average after 
% onset should be 1. The script also takes user input for which trials to 
% analyze for each experimental condition, the first selection being 
% prelesion, and every selection after that to be an experimental condition. 
% Important: no data from after the first condition can not have a 
% counterpart in the first condition (ie. each mouse in later conditions 
% must appear in the first condition).
% 
% Inputs:
% 
% user-selected .mat file names
%
% Outputs:
% 
% 'avgDF' - cell array containing all normalized average DF/F traces at
% onset across all conditions.
% 
% 'avgBeh' - cell array containing all normalized average velocity traces at
% onset across all conditions.
% 
% average FOV DF/F trace at onset, normalized to the prelesion condition,
% along with the average FOV velocity trace at onset.
% 
% Author: Jeffrey March, 2018

%% Plotting the multiple conditions

avgDF = {[],[]};
avgBeh = {[],[]};

for expCondit = 1:2
    
[trials, pathname] = selectFiles();

condition = 0; % Keep this as 0 (condition for photometry)
norm = false; % Keep this as false (this is vestigial)
avg = false; % Keep this as false (this is vestigial)

% Keeping the values of minMax and names for just the first data selection
if expCondit == 1
    [time, finalOnsetsDF, finalOnsetsBeh, finalOffsetsDF, finalOffsetsBeh, numOnsets, meanBaseline, minMax, names] = plotMeanOnsetOffsetUINorm(trials, condition, norm, avg);
else
    [time, finalOnsetsDF, finalOnsetsBeh, finalOffsetsDF, finalOffsetsBeh, numOnsets, meanBaseline] = plotMeanOnsetOffsetUINorm(trials, condition, norm, avg);
end

% Normalizing later traces to its corresponding first trace
onsetIndex = 1;
for i = 1:length(numOnsets)
    for name = 1:length(names)
        if strcmp(trials{i}(1:4),names{name})
            avgDF{expCondit}(i,:) = (mean(finalOnsetsDF(onsetIndex:onsetIndex + numOnsets(i) - 1,:),1) - minMax(name,1))/(minMax(name,2)-minMax(name,1));
            avgBeh{expCondit}(i,:) = mean(finalOnsetsBeh(onsetIndex:onsetIndex + numOnsets(i) - 1,:),1);            
        end
    end
    onsetIndex = onsetIndex + numOnsets(i);
end

% Plotting
figure; 
h(1) = subplot(2,1,1);
shadedErrorBar(time, mean(avgDF{expCondit},1), std(avgDF{expCondit},1)/sqrt(size(avgDF{expCondit},1)), 'r',1);
% shadedErrorBar(downsample(time,100), downsample(mean(finalOnsetsDF,1),100), downsample(std(finalOnsetsDF,1)/sqrt(size(finalOnsetsDF,1)),100), 'r',1);
title('mean fluorescence at Onset')
xlim([-4,4])
ylim([-.1,1.1])
h(2) = subplot(2,1,2);
% hold on
shadedErrorBar(time, mean(avgBeh{expCondit},1), std(avgBeh{expCondit},1)/sqrt(size(avgBeh{expCondit},1)), 'k',1);
% shadedErrorBar(downsample(time,100), downsample(mean(finalOnsetsBeh,1),100), downsample(std(finalOnsetsBeh,1)/sqrt(size(finalOnsetsBeh,1)),100), 'k',1);
title('mean velocity at Onset')
% hold off
linkaxes(h,'x')
xlabel('Time (s)')
xlim([-4,4])
ylim([0,.2])

end

%% Finding the Difference in DF Before and After Onset.

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
% for i = 1:size(diffDF,1)
%    if i <= 3
%        plotString = 'bx-';
%    else
%        plotString = 'rx-';
%    end
%    plot(diffDF(i,:),plotString);
%    hold on
% end
% hold off
