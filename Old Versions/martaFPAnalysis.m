%% Behavior + Fiber Photometry Data

clear all
% close all
clc
data = struct; % Defining data as an empty structure


data.imageFile = 'F008'; %CHANGE
data.date = '170323'; %CHANGE
newDirectory = cat(2,'C:\Users\labadmin\Documents\MATLAB\Marta\',data.imageFile,'\',data.date,'\');
cd(newDirectory)

totalTime = 600; % in seconds
timeFreq = 2000; % in hz

warning off;

firstFile = 2; %CHANGE
lastFile = firstFile; %CHANGE
mirror = true;
wheelRadius = .06; %in m
circumference = 2*wheelRadius*pi; %in m

% Opening behavior and mirror files according to the filenames
[data.rawData, data.FP] = getBehAndFP(firstFile, lastFile, mirror);
data.FP = smooth(data.FP,40)'; % Can change smoothing

% Unwrap the periodic behavior signal to get total distance]
data.finalData = unwrapBeh(data.rawData);
data.finalData = smooth(data.finalData,650)';
data.finalData = circumference*data.finalData;

time = 1/timeFreq : 1/timeFreq : length(data.finalData)/timeFreq; %time scale
vel = timeFreq*[diff(data.finalData), data.finalData(end) - data.finalData(end-1)]; %in m/s
data.vel = medfilt1(vel,10); %in m/s

accel = timeFreq*[diff(data.vel), data.vel(end) - data.vel(end-1)];
data.accel = medfilt1(accel,5);
data.accel = smooth(accel,100)';   %%%MARTA


data.sampleRate = timeFreq; %in hz
data.sampleTime = (1:length(data.finalData))/data.sampleRate;
data.totalDistance = data.finalData(end) - data.finalData(1);
data.acqNum = firstFile; %Acquisition number for file naming
data.totalTime = totalTime; %Total time elapsed in s
data.timeFreq = timeFreq; %Acquisition rate of behavior in hz

clearvars -except data

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
%% Normalizing all data

baseline1 = min(data.FP(1:2*data.sampleRate));
baseline2 = min(data.FP(end - 2*data.sampleRate:end));
baselineTrace = ((baseline2-baseline1)/length(data.FP))*[1:length(data.FP)] + baseline1;

% data.FPNorm = data.FP;
% data.FPNorm = fourierFilt(data.FP,0.01,data.sampleRate,'high');
% data.FPNorm = fourierFilt(data.FP,[0.01,5],data.sampleRate,'pass');
data.FPNorm = (data.FP - baselineTrace)./baselineTrace;


data.FPNorm = fourierFilt(data.FPNorm,5,data.sampleRate,'low');
% data.FPNorm = temp/max(temp);
% data.FPNorm = fourierFilt(data.FPNorm,[0.01,5],data.sampleRate,'pass');


clearvars -except data

%% Creating Movement Onset/Offset Data

roi = data.FPNorm; %CHANGE THIS

%frame information (both behavior and imaging)
sampleRate = data.sampleRate;
vel = data.vel;
fRatio = size(roi,2)/length(vel);

timeThreshold = 4*sampleRate; %CHANGE number 4,5,6,7.. a seconda dimensione finestra pre post onset
velThreshold = 0.005; %CHANGE
minRestTime = 4*sampleRate; %CHANGE number 4,5,6,7.. a seconda dimensione finestra pre post onset
minRunTime = 4*sampleRate; %CHANGE
behavior = true; %CHANGE
% signal = vel; %This can be either absolute value or not
signal = abs(vel); %This can be either absolute value or not

% Determining onset/offset indices for mirror
[onsetsBeh, offsetsBeh] = ...
    getOnsetOffset(signal, velThreshold, minRestTime, minRunTime, behavior);   %%Absolute value of vel CHANGE MARTA

% Making on/offsets adhere to time/length constraints
onsetsBeh = onsetsBeh(1:length(offsetsBeh));
offsetsFinal = offsetsBeh((offsetsBeh - onsetsBeh) > timeThreshold);
onsetsFinal = onsetsBeh((offsetsBeh - onsetsBeh) > timeThreshold);
offsetsFinal = offsetsFinal(onsetsFinal > timeThreshold);
onsetsFinal = onsetsFinal(onsetsFinal > timeThreshold);

threshold = 2*std(signal(offsetsFinal(1)+round(sampleRate):offsetsFinal(1)+3*round(sampleRate))); % Velocity threshold is 2*stdev of noise
onsetsFinal = iterToMin(signal,onsetsFinal,threshold,true); % Final onsets array
offsetsFinal = iterToMin(signal,offsetsFinal,threshold,false); % Final offsets array

timeBefore = 4*sampleRate; % Time before onset/offset (coeff is in seconds)
timeAfter = 4*sampleRate; % Time after onset/offset (coeff is in seconds)
dffOnsets = round(onsetsFinal*fRatio);
dffOffsets = round(offsetsFinal*fRatio);

onsetsMatrixBeh = []; %Initializing
offsetsMatrixBeh = []; %Initializing
onsetsMatrixDF = []; %Initializing
offsetsMatrixDF = []; %Initializing
onsetToOffsetDF = {}; %Initializing
onsetToOffsetBeh = {}; %Initializing
onsetToOffsetTime = {}; %Initializing

for n = 1:length(dffOnsets)
    onsetsMatrixDF(n,:) = roi(dffOnsets(n) - round(timeBefore*fRatio):dffOnsets(n) + round(timeAfter*fRatio));
    offsetsMatrixDF(n,:) = roi(dffOffsets(n) - round(timeBefore*fRatio):dffOffsets(n) + round(timeAfter*fRatio));
    onsetsMatrixBeh(n,:) = signal(onsetsFinal(n) - round(timeBefore):onsetsFinal(n) + round(timeAfter));
    offsetsMatrixBeh(n,:) = signal(offsetsFinal(n) - round(timeBefore):offsetsFinal(n) + round(timeAfter));
    onsetToOffsetDF{n} = roi(dffOnsets(n) - round(timeBefore*fRatio):dffOffsets(n) + round(timeAfter*fRatio));
    onsetToOffsetBeh{n} = signal(onsetsFinal(n) - round(timeBefore):offsetsFinal(n) + round(timeAfter));
    onsetToOffsetTime{n} = (-round(timeBefore*fRatio):length(onsetToOffsetDF{n}) - (1 + round(timeBefore*fRatio)))/sampleRate;
end

% for n = 1:length(dffOnsets)
%     onsetsMatrixDF(n,:) = roi(dffOnsets(n) - round(timeBefore*fRatio):dffOnsets(n) + round(timeAfter*fRatio));
%     onsetsMatrixDF(n,:) = onsetsMatrixDF(n,:) - median(onsetsMatrixDF(n,round(5*timeBefore/8):round(7*timeBefore/8)));
%     offsetsMatrixDF(n,:) = roi(dffOffsets(n) - round(timeBefore*fRatio):dffOffsets(n) + round(timeAfter*fRatio));
%     offsetsMatrixDF(n,:) = offsetsMatrixDF(n,:) - median(offsetsMatrixDF(n,round(9*timeBefore/8):end-round(3*timeAfter/8)));
%     onsetsMatrixBeh(n,:) = signal(onsetsFinal(n) - round(timeBefore):onsetsFinal(n) + round(timeAfter));
%     offsetsMatrixBeh(n,:) = signal(offsetsFinal(n) - round(timeBefore):offsetsFinal(n) + round(timeAfter));
%     onsetToOffsetDF{n} = roi(dffOnsets(n) - round(timeBefore*fRatio):dffOffsets(n) + round(timeAfter*fRatio));
%     onsetToOffsetBeh{n} = signal(onsetsFinal(n) - round(timeBefore):offsetsFinal(n) + round(timeAfter));
%     onsetToOffsetTime{n} = (-round(timeBefore*fRatio):length(onsetToOffsetDF{n}) - (1 + round(timeBefore*fRatio)))/sampleRate;
% end

data.indOnsets = onsetsFinal; % Final onset indices
data.indOffsets = offsetsFinal; % Final offset indices
data.numBouts = length(onsetsFinal); % Number of bouts
data.avgBoutDuration = mean(offsetsFinal - onsetsFinal)/sampleRate; % Avg bout duration
data.stdBoutDuration = std(offsetsFinal - onsetsFinal)/sampleRate; % STD bout duration
data.timeDF = [-round(timeBefore*fRatio):round(timeAfter*fRatio)]/sampleRate;

% Saving data into structure

tempstructure = data;
tempstructure.onsetsMatrixDF = onsetsMatrixDF;
tempstructure.offsetsMatrixDF = offsetsMatrixDF;
tempstructure.onsetToOffsetDF = onsetToOffsetDF;
tempstructure.onsetsMatrixBeh = onsetsMatrixBeh;
tempstructure.offsetsMatrixBeh = offsetsMatrixBeh;
tempstructure.onsetToOffsetBeh = onsetToOffsetBeh;
tempstructure.onsetToOffsetTime = onsetToOffsetTime;

data = tempstructure;

clearvars -except data

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

%% Saving Files

cd('C:\Users\labadmin\Documents\MATLAB\Photometry Data\')
save([data.imageFile,'_',data.date,'_Acq',num2str(data.acqNum),'.mat'],'data')
cd ..
