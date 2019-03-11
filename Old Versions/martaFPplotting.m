%% Plotting Behavioral Data

figure();
h(1) = subplot(4,1,1);
plot(data.sampleTime, data.rawData)
title('raw')
ylim([0 1.1])
h(2) = subplot(4,1,2);
plot(data.sampleTime, data.finalData);
title('distance')
h(3) = subplot(4,1,3);
plot(data.sampleTime, data.vel)
title('velocity')
h(4) = subplot(4,1,4);
plot(data.sampleTime, data.accel)
title('acceleration')
xlabel('Time (s)')
linkaxes(h,'x')

figure();
sh(1) = subplot(2,1,1);
plot(data.sampleTime, data.FP);
title('Fluorescence')
ylabel('Fluorescence')
sh(2) = subplot(2,1,2);
plot(data.sampleTime, data.vel)
title('Velocity')
ylabel('Velocity (m/s)')
xlabel('Time (s)')
linkaxes(sh,'x')

%% Plotting at Onset/Offset

roi = data;

%frame information (both behavior and imaging)
sampleRate = data.sampleRate;
vel = abs(data.vel);
fRatio = size(roi.FP,2)/length(vel);
timeBefore = 4*sampleRate; % Time before onset/offset (coeff is in seconds)
timeAfter = 4*sampleRate; % Time after onset/offset (coeff is in seconds)
scaleFactor = max(data.vel); % Scaling to put DF on same scale as velocity


% Plotting all DF/F and Velocity Traces for ONSET
figure();
subplot(2,1,1)
title('DF/F Traces at Onset')
ylabel('Fluorescence (dF/F)')
hold on
for trace = 1:length(data.indOnsets)
    plot(data.timeDF, roi.onsetsMatrixDF(trace,:));  
end
hold off
subplot(2,1,2)
title('Velocity Traces at Onset')
hold on
for trace = 1:length(data.indOnsets)
    plot(data.timeDF, roi.onsetsMatrixBeh(trace,:));  
end
ylabel('Velocity (m/s)')
xlabel('Time (s)')
hold off

% Plotting all DF/F and Velocity Traces for OFFSET
figure();
subplot(2,1,1);
title('F Traces at Offset')
ylabel('Fluorescence (dF/F)')
hold on
for trace = 1:length(data.indOnsets)
    plot(data.timeDF, roi.offsetsMatrixDF(trace,:));  
end
hold off
subplot(2,1,2);
title('Velocity Traces at Offset')
hold on
for trace = 1:length(data.indOnsets)
    plot(data.timeDF, roi.offsetsMatrixBeh(trace,:));  
end
ylabel('Velocity (m/s)')
xlabel('Time (s)')
hold off

% Plotting average DF/F and Velocity for ONSET and OFFSET
fig = figure;
left_color = [0 0 0];
right_color = [1 0 0];
set(fig,'defaultAxesColorOrder',[left_color; right_color]);

subplot(2,1,1);
title('Avg F and Velocity at Onset')
yyaxis right
% shadedErrorBar(data.timeDF, mean(roi.onsetsMatrixDF,1), std(scaleFactor*roi.onsetsMatrixDF,1), 'r');
plot(data.timeDF,mean(roi.onsetsMatrixDF,1),'r');
ylabel('Fluorescence (dF/F)')
yyaxis left
% shadedErrorBar(data.timeDF, mean(roi.onsetsMatrixBeh,1), std(roi.onsetsMatrixBeh,1), 'k');
plot(data.timeDF,mean(roi.onsetsMatrixBeh,1),'k');
ylabel('Velocity (m/s)')
hold off

subplot(2,1,2);
title('Avg F and Velocity at Offset')
yyaxis right
% shadedErrorBar(data.timeDF, mean(roi.offsetsMatrixDF,1), std(scaleFactor*roi.offsetsMatrixDF,1), 'r');
plot(data.timeDF,mean(roi.offsetsMatrixDF,1),'r');
ylabel('Fluorescence (dF/F)')
yyaxis left
% shadedErrorBar(data.timeDF, mean(roi.offsetsMatrixBeh,1), std(roi.offsetsMatrixBeh,1), 'k');
plot(data.timeDF,mean(roi.offsetsMatrixBeh,1),'k');
ylabel('Velocity (m/s)')
xlabel('Time (s)')

% Plotting Onset to Offset Fluorescence
figure();
for onToOff = 1:length(roi.onsetToOffsetDF)
    subplot(length(roi.onsetToOffsetDF),1,onToOff)
    hold on
    plot(roi.onsetToOffsetTime{onToOff},roi.onsetToOffsetDF{onToOff});
    stem(0,0.01)
    stem(roi.onsetToOffsetTime{onToOff}(end - round((timeBefore + 1)*fRatio)),0.01);
    hold off
    if onToOff == 1
        title('Onset to Offset')
    end
end
xlabel('Time (s)')

% Plotting Velocity with Onsets and Offsets
figure();
title('Velocity with Onsets and Offsets')
ylabel('Velocity(m/s)')
xlabel('Time (s)')
hold on
plot(data.sampleTime,vel);
stem(data.sampleTime(data.indOnsets),.01*ones(length(data.indOnsets),1))
stem(data.sampleTime(data.indOffsets),.01*ones(length(data.indOffsets),1))
hold off

clearvars -except data

%% 

data.FPNorm = (data.FP - min(data.FP))/min(data.FP);
data.FPNorm = fourierFilt(data.FPNorm,5,data.sampleRate,'low');

