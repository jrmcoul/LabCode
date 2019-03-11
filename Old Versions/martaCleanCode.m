%% Getting ROIs

clear all;
close all;
clc;

data = struct; % Defining data as an empty structure

data.imageFile = 'SW033'; %CHANGE
data.date = '170925'; %CHANGE

load([data.imageFile,'.mat']);  %Loading the obj file associated with data.imagefile
myObj = eval(data.imageFile); %Bad practice, I know...


[sliceNum, channelNum] = getDF(myObj); %Opening object and prepping for extraction

roiGroup = 1; %Getting D1 Neuron Data

% Getting the fluorescence traces for D1 and D2 MSNs
[dF1,traces1,rawF1,roiList1] = extractROIsBin(myObj,roiGroup,sliceNum,channelNum);
data.dF1.dF = dF1; %DF/F for D1 Neurons
data.dF1.roiList = roiList1; %ROI info for D1 Neurons

roiGroup = 2; %Getting D2 Neuron Data

% Getting the fluorescence traces for D1 and D2 MSNs
[dF2,traces2,rawF2,roiList2] = extractROIsBin(myObj,roiGroup,sliceNum,channelNum);
data.dF2.dF = dF2; %DF/F for D2 Neurons
data.dF2.roiList = roiList2; %ROI info for D2 Neurons

roiGroup = 3; %Getting Other Neuron Data

% Getting the fluorescence traces for ChIs
[dF3,traces3,rawF3,roiList3] = extractROIsBin(myObj,roiGroup,sliceNum,channelNum);
data.dF3.dF = dF3; %DF/F for Other Neurons
data.dF3.roiList = roiList3;%ROI info for Other Neurons

clearvars -except data

%% Behavior & Mirror: Opening and Synchronization
totalTime = 600; % in seconds
timeFreq = 2000; % in hz

firstFile = 2; %CHANGE
lastFile = firstFile;  %%firstFile originale
mirror = true;
circumference = 2*.04*pi; %in m

warning off;

% Opening behavior and mirror files according to the filenames
[data.rawData, mirArray] = getBehAndMir(firstFile, lastFile, mirror);

% Unwrap the periodic behavior signal to get total distance
data.finalData = unwrapBeh(data.rawData);
data.finalData = circumference*data.finalData;

% Determining onset/offset indices for mirror
mirThreshold = 4;
minBelowTimeMir = 1;
minAboveTimeMir = 0;
behavior = false;

[frameStarts, frameEnds] = ...
    getOnsetOffset(mirArray, mirThreshold, minBelowTimeMir, minAboveTimeMir, behavior);

% Averaging behavior data during each corresponding frame
data.behFrame = [];
for frameInd = 1:length(frameStarts)
    data.behFrame(frameInd) = mean(data.finalData(frameStarts(frameInd):frameEnds(frameInd)));
end

% In case there is one more frame than behavior
if size(data.dF1.dF, 2) > length(data.behFrame);
    data.dF1.dF = data.dF1.dF(:,1:length(data.behFrame));
    data.dF2.dF = data.dF2.dF(:,1:length(data.behFrame));
    data.dF3.dF = data.dF3.dF(:,1:length(data.behFrame));
else if size(data.dF1.dF, 2) < length(data.behFrame);
        data.behFrame = data.behFrame(1:size(data.dF1.dF, 2));
    end
end

framerate = length(data.behFrame)/totalTime; %in hz
data.time = 1/timeFreq : 1/timeFreq : length(data.finalData)/timeFreq; %time scale
vel = framerate*[diff(data.behFrame), data.behFrame(end) - data.behFrame(end-1)]; %in m/s
data.vel = medfilt1(vel,10); %in m/s

accel = framerate*[diff(data.vel), data.vel(end) - data.vel(end-1)];
data.accel = medfilt1(accel,5);

data.framerate = framerate; %in hz
data.frameTime = (1:length(data.behFrame))/data.framerate;
data.totalDistance = sum(abs(data.vel))/data.framerate;
data.acqNum = firstFile; %Acquisition number for file naming
data.totalTime = totalTime; %Total time elapsed in s
data.timeFreq = timeFreq; %Acquisition rate of behavior in hz

clearvars -except data
%% Normalizing all data
% close all

tempData1 = data.dF1.dF;

for i = 1:size(tempData1,1);
    tempData1(i,:) = smooth(tempData1(i,:),5); % Optional smoothing
end
data.normDF1.dF = normalizeDF(tempData1);

tempData2 = data.dF2.dF;

for i = 1:size(tempData2,1);
    tempData2(i,:) = smooth(tempData2(i,:),5); % Optional smoothing
end
data.normDF2.dF = normalizeDF(tempData2);

tempData3 = data.dF3.dF;

for i = 1:size(tempData3,1);
    tempData3(i,:) = smooth(tempData3(i,:),5); % Optional smoothing
end
data.normDF3.dF = normalizeDF(tempData3);

clearvars -except data
%% Creating Movement Onset/Offset Data

for condition = 1:.5:3.5; % Run through all conditions

if condition == 1;
    roi = data.dF1.dF;
end
if condition == 1.5
    roi = data.normDF1.dF; %Normalized
end
if condition == 2
    roi = data.dF2.dF;
end
if condition == 2.5
    roi = data.normDF2.dF; %Normalized
end
if condition == 3
    roi = data.dF3.dF;
end
if condition == 3.5
    roi = data.normDF3.dF; %Normalized
end

%frame information (both behavior and imaging)
framerate = data.framerate;
vel = data.vel;
fRatio = size(roi,2)/length(vel);

timeThreshold = 4*framerate; %CHANGE number 4,5,6,7.. a seconda dimensione finestra pre post onset
velThreshold = 0.004; %CHANGE was .004
minRestTime = 4*framerate; %CHANGE number 4,5,6,7.. a seconda dimensione finestra pre post onset
minRunTime = 4*framerate; %CHANGE
behavior = true; %CHANGE
% signal = vel; %This can be either absolute value or not
signal = abs(vel); %This can be either absolute value or not

% Determining onset/offset indices for mirror
[onsetsBeh, offsetsBeh] = ...
    getOnsetOffset(signal, velThreshold, minRestTime, minRunTime, behavior);   %%Absolute value of vel CHANGE MARTA

% Making on/offsets adhere to time/length constraints
offsetsBeh = offsetsBeh(offsetsBeh < length(signal) - timeThreshold); % Making sure last offsets is at least timeThreshold from the end
onsetsBeh = onsetsBeh(1:length(offsetsBeh)); % Removing onsets that correspond to removed offsets
offsetsFinal = offsetsBeh((offsetsBeh - onsetsBeh) > timeThreshold); % Making sure onset to offset is at least timeThreshold in length
onsetsFinal = onsetsBeh((offsetsBeh - onsetsBeh) > timeThreshold); % Making sure onset to offset is at least timeThreshold in length
offsetsFinal = offsetsFinal(onsetsFinal > timeThreshold); % Making sure first onset is at least timeThreshold from the beginning (corresponding offset)
onsetsFinal = onsetsFinal(onsetsFinal > timeThreshold); % Making sure first onset is at least timeThreshold from the beginning

threshold = 2*std(signal(offsetsFinal(1)+round(framerate):offsetsFinal(1)+3*round(framerate))); % Velocity threshold is 2*stdev of noise
onsetsFinal = iterToMin(signal,onsetsFinal,threshold,true); % Final onsets array
offsetsFinal = iterToMin(signal,offsetsFinal,threshold,false); % Final offsets array

% Necessary again, in case there are problems after iterToMin
offsetsBeh = offsetsBeh(offsetsBeh < length(signal) - timeThreshold); % Making sure last offsets is at least timeThreshold from the end
onsetsBeh = onsetsBeh(1:length(offsetsBeh)); % Removing onsets that correspond to removed offsets
offsetsFinal = offsetsBeh((offsetsBeh - onsetsBeh) > timeThreshold); % Making sure onset to offset is at least timeThreshold in length
onsetsFinal = onsetsBeh((offsetsBeh - onsetsBeh) > timeThreshold); % Making sure onset to offset is at least timeThreshold in length
offsetsFinal = offsetsFinal(onsetsFinal > timeThreshold); % Making sure first onset is at least timeThreshold from the beginning (corresponding offset)
onsetsFinal = onsetsFinal(onsetsFinal > timeThreshold); % Making sure first onset is at least timeThreshold from the beginning

timeBefore = 4*framerate; % Time before onset/offset (coeff is in seconds)
timeAfter = 4*framerate; % Time after onset/offset (coeff is in seconds)
dffOnsets = round(onsetsFinal*fRatio);
dffOffsets = round(offsetsFinal*fRatio);

avgdF = mean(roi,1); %Avg dF for roi (roi = dF1 or roi = dF2)
onsetsMatrixBeh = []; %Initializing
offsetsMatrixBeh = []; %Initializing
onsetsMatrixDF = []; %Initializing
offsetsMatrixDF = []; %Initializing
onsetToOffsetDF = {}; %Initializing
onsetToOffsetBeh = {}; %Initializing
onsetToOffsetTime = {}; %Initializing

for n = 1:length(dffOnsets)
    onsetsMatrixDF(n,:) = avgdF(dffOnsets(n) - ceil(timeBefore*fRatio):dffOnsets(n) + ceil(timeAfter*fRatio));
    offsetsMatrixDF(n,:) = avgdF(dffOffsets(n) - ceil(timeBefore*fRatio):dffOffsets(n) + ceil(timeAfter*fRatio));
    onsetsMatrixBeh(n,:) = signal(onsetsFinal(n) - ceil(timeBefore):onsetsFinal(n) + ceil(timeAfter));
    offsetsMatrixBeh(n,:) = signal(offsetsFinal(n) - ceil(timeBefore):offsetsFinal(n) + ceil(timeAfter));
    onsetToOffsetDF{n} = avgdF(dffOnsets(n) - ceil(timeBefore*fRatio):dffOffsets(n) + ceil(timeAfter*fRatio));
    onsetToOffsetBeh{n} = signal(onsetsFinal(n) - ceil(timeBefore):offsetsFinal(n) + ceil(timeAfter));
    onsetToOffsetTime{n} = (-ceil(timeBefore*fRatio):length(onsetToOffsetDF{n}) - 1 - ceil(timeAfter*fRatio))/framerate;
end

data.indOnsets = onsetsFinal; % Final onset indices
data.indOffsets = offsetsFinal; % Final offset indices
data.numBouts = length(onsetsFinal); % Number of bouts
data.avgBoutDuration = mean(offsetsFinal - onsetsFinal)/framerate; % Avg bout duration
data.stdBoutDuration = std(offsetsFinal - onsetsFinal)/framerate; % STD bout duration
data.timeDF = (-ceil(timeBefore*fRatio):ceil(timeAfter*fRatio))/framerate;

% Saving data into structure
if condition == 1;
    tempstruct = data.dF1;
end
if condition == 1.5;
    tempstruct = data.normDF1;
end
if condition == 2;
    tempstruct = data.dF2;
end
if condition == 2.5;
    tempstruct = data.normDF2;
end
if condition == 3;
    tempstruct = data.dF3;
end
if condition == 3.5;
    tempstruct = data.normDF3;
end

tempstruct.onsetsMatrixDF = onsetsMatrixDF;
tempstruct.offsetsMatrixDF = offsetsMatrixDF;
tempstruct.onsetToOffsetDF = onsetToOffsetDF;
tempstruct.onsetsMatrixBeh = onsetsMatrixBeh;
tempstruct.offsetsMatrixBeh = offsetsMatrixBeh;
tempstruct.onsetToOffsetBeh = onsetToOffsetBeh;
tempstruct.onsetToOffsetTime = onsetToOffsetTime;

if condition == 1;
    data.dF1 = tempstruct;
end
if condition == 1.5;
    data.normDF1 = tempstruct;
end
if condition == 2;
    data.dF2 = tempstruct;
end
if condition == 2.5;
    data.normDF2 = tempstruct;
end
if condition == 3;
    data.dF3 = tempstruct;
end
if condition == 3.5;
    data.normDF3 = tempstruct;
end

end

clearvars -except data dffOnsets dffOffsets onsetsFinal offsetsFinal

%% Frequency of peaks during rest/movement

signal = abs(data.vel);
timeLag = 1; % in seconds
MPH = 0.4; % minimum peak height in fraction of tallest peak
MINW = 6; % minimum peak width in frames
velThreshold = 0.002; %CHANGE
behavior = true; %CHANGE
framerate = data.framerate;

[onsetsBeh, offsetsBeh] = ...
    getOnsetOffset(signal, velThreshold, 4*framerate, 4*framerate, behavior);  %%MARTA CHANGES

[onsetsRest, offsetsRest] = ...
    getOnsetOffset(-signal, -velThreshold, .25*framerate, 4*framerate, behavior);   %%MARTA CHANGES

for condition = [1.5, 2.5, 3.5];

if condition == 1.5
    roi = data.normDF1; %Normalized
end
if condition == 2.5
    roi = data.normDF2; %Normalized
end
if condition == 3.5
    roi = data.normDF3; %Normalized
end

[peaksPerSecondBeh, numPeaksMatrixBeh, numFramesMatrixBeh] = countPeaks(roi.dF, onsetsBeh, offsetsBeh, timeLag, framerate, MPH, MINW);
numPeaksBeh = sum(sum(numPeaksMatrixBeh)); %save for later stats
numFramesBeh = sum(sum(numFramesMatrixBeh)); %save for later stats

[peaksPerSecondRest, numPeaksMatrixRest, numFramesMatrixRest] = countPeaks(roi.dF, onsetsRest, offsetsRest, timeLag, framerate, MPH, MINW);
numPeaksRest = sum(sum(numPeaksMatrixRest)); %save for later stats
numFramesRest = sum(sum(numFramesMatrixRest)); %save for later stats

[peaksPerSecondTotal, numPeaksMatrixTotal, numFramesMatrixTotal] = countPeaks(roi.dF, 1, length(roi.dF), 0, framerate, MPH, MINW);
numPeaksTotal = sum(sum(numPeaksMatrixTotal)); %save for later stats
numFramesTotal = sum(sum(numFramesMatrixTotal)); %save for later stats

roi.numPeaksBeh = numPeaksBeh;
roi.numPeaksRest = numPeaksRest;
roi.numPeaksTotal = numPeaksTotal;
roi.numFramesBeh = numFramesBeh;
roi.numFramesRest = numFramesRest;
roi.numFramesTotal = numFramesTotal;
roi.numPeaksMatrixBeh = numPeaksMatrixBeh;
roi.numPeaksMatrixRest = numPeaksMatrixRest;
roi.numPeaksMatrixTotal = numPeaksMatrixTotal;
roi.numFramesMatrixBeh = numFramesMatrixBeh;
roi.numFramesMatrixRest = numFramesMatrixRest;
roi.numFramesMatrixTotal = numFramesMatrixTotal;
roi.peaksPerSecondBeh = peaksPerSecondBeh;
roi.peaksPerSecondRest = peaksPerSecondRest;
roi.peaksPerSecondTotal = peaksPerSecondTotal;

if condition == 1.5
    data.normDF1 = roi; %Normalized
end
if condition == 2.5
    data.normDF2 = roi; %Normalized
end
if condition == 3.5
    data.normDF3 = roi; %Normalized
end

end

clearvars -except data

%% Average DF While Moving/Rest or in Bins

for condition = 1:3;
    if condition == 1
    roi = data.dF1;
    end
    if condition == 2
    roi = data.dF2;
    end
    if condition == 3
    roi = data.dF3;
    end

    speed = abs(data.vel);
    threshold = .001;
    bins = [0,0.001:0.005:1.001];

    % Calculate binarized data: moving or resting
    moving = speed >= threshold;
    resting = speed < threshold;

    % Calculate mean DF/F when moving or resting
    roi.meanMovDF = nanmean((roi.dF*moving')/sum(moving));
    roi.meanRestDF = nanmean((roi.dF*resting')/sum(resting));
    roi.meanTotDF = nanmean(mean(roi.dF));

    % Calculate mean speed when moving or resting
    roi.meanMovVel = (speed*moving')/sum(moving);
    roi.meanRestVel = (speed*resting')/sum(resting);
    roi.meanTotVel = mean(speed);
    
    % Calculate binarized data: moving or resting
    roi.meanBinDF =[];
    roi.meanBinVel =[];   
    for i = 1:length(bins)-1;
        binNum{i} = speed < bins(i+1) & speed >= bins(i);
        % Calculate mean DF/F when moving or resting
        roi.meanBinDF(i) = nanmean((roi.dF*binNum{i}')/sum(binNum{i}));
        % Calculate mean speed when moving or resting
        roi.meanBinVel(i) = (speed*binNum{i}')/sum(binNum{i});
    end
                    
    if condition == 1
    data.dF1 = roi;
    end
    if condition == 2
    data.dF2 = roi;
    end
    if condition == 3
        data.dF3 = roi;
   end
end        

%% Saving Files

cd('C:\MATLAB\Calcium Data\')
save([data.imageFile,'_',data.date,'_Acq',num2str(data.acqNum),'.mat'],'data')
cd ..

%% Align all spikes to peak

% % Uncomment the one you want:
% roi = data.dF1.dF;
% % roi = data.normDF1.dF; %Normalized
% % roi = data.dF2.dF;
% % roi = data.normDF2.dF; %Normalized
% % roi = data.dF3.dF;
% % roi = data.normDF3.dF; %Normalized
% 
% MPH = 0.4; % minimum peak height in fraction of tallest peak
% MINW = 6; % minimum peak width in frames
% 
% [PKS, LOCS] = findpeaks(roi, 'MinPeakHeight', MPH, 'MinPeakWidth', MINW);
% for spike = 1:length(LOCS)
%     spikeMatrix(spike,:) = a(LOCS-50:LOCS+50);
% end
% % 
%%  Plotting Behavioral Data + Calcium Data

% Plot all behavioral data
figure();
h(1)= subplot(4,1,1);
plot(data.time, data.rawData)
title('raw')
ylim([0 1.1])
h(2) = subplot(4,1,2);
plot(data.frameTime, data.behFrame);
title('distance')
h(3)= subplot(4,1,3);
plot(data.frameTime, data.vel)
title('velocity')
h(4)= subplot(4,1,4);
plot(data.frameTime, data.accel)
title('acceleration')
linkaxes(h,'x')
xlabel('Time (s)')

% Uncomment the one you want:
roi = data.dF1.dF;
% roi = data.normDF1.dF; %Normalized
% roi = data.dF2.dF;
% roi = data.normDF2.dF; %Normalized
% roi = data.dF3.dF;
% roi = data.normDF3.dF; %Normalized

% Plot velocity and calcium data for all cells
figure()
for ii =1:size(roi, 1);  %%% CHANGE if you want one cell at time
    title('fluorescence')
    sh(1)= subplot(2,1,2);
    plot(data.frameTime,data.vel)
    title('vel')
    xlabel('Time (s)')
    sh(2)= subplot(2,1,1);
    plot(data.frameTime,roi(ii,:))
    hold on
   end
hold off

linkaxes(sh,'x')


clearvars -except data

%% Plotting at Onset/Offset

% Uncomment the one you want:
roi = data.dF1;
% roi = data.normDF1; %Normalized
% roi = data.dF2;
% roi = data.normDF2; %Normalized
% roi = data.dF3;
% roi = data.normDF3; %Normalized

%frame information (both behavior and imaging)
framerate = data.framerate;
vel = data.vel;
fRatio = size(roi.dF,2)/length(vel);
timeBefore = 4*framerate; % Time before onset/offset (coeff is in seconds)
timeAfter = 4*framerate; % Time after onset/offset (coeff is in seconds)
% scaleFactor = max(data.vel)/max(max(roi.dF)); % Scaling to put DF on same scale as velocity

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
ylabel('Velocity(m/s)')
xlabel('Time (s)')
hold on
for trace = 1:length(data.indOnsets)
    plot(data.timeDF, roi.onsetsMatrixBeh(trace,:));  
end
hold off

% Plotting all DF/F and Velocity Traces for OFFSET
figure();
subplot(2,1,1);
title('DF/F Traces at Offset')
ylabel('Fluorescence (dF/F)')
hold on
for trace = 1:length(data.indOnsets)
    plot(data.timeDF, roi.offsetsMatrixDF(trace,:));  
end
hold off
subplot(2,1,2);
title('Velocity Traces at Offset')
ylabel('Velocity(m/s)')
xlabel('Time (s)')
hold on
for trace = 1:length(data.indOnsets)
    plot(data.timeDF, roi.offsetsMatrixBeh(trace,:));  
end
hold off

% Plotting average DF/F and Velocity for ONSET and OFFSET
fig = figure;
left_color = [0 0 0];
right_color = [1 0 0];
set(fig,'defaultAxesColorOrder',[left_color; right_color]);

subplot(2,1,1);
title('Avg DF/F and Velocity at Onset')
yyaxis right
plot(data.timeDF,mean(roi.onsetsMatrixDF,1),'r');
ylabel('Fluorescence (dF/F)')
yyaxis left
plot(data.timeDF,mean(roi.onsetsMatrixBeh,1),'k');
ylabel('Velocity (m/s)')

subplot(2,1,2);
title('Avg DF/F and Velocity at Offset')
xlabel('Time (s)')
yyaxis right
plot(data.timeDF,mean(roi.offsetsMatrixDF,1),'r');
ylabel('Fluorescence (dF/F)')
yyaxis left
plot(data.timeDF,mean(roi.offsetsMatrixBeh,1),'k');
ylabel('Velocity (m/s)')

% Plotting DF/F between ONSET and OFFSET
figure();
for onToOff = 1:length(roi.onsetToOffsetDF)
    subplot(length(roi.onsetToOffsetDF),1,onToOff)
    hold on
    plot(roi.onsetToOffsetTime{onToOff},roi.onsetToOffsetDF{onToOff});
    stem(0,0.3)
    stem(roi.onsetToOffsetTime{onToOff}(end - round((timeBefore + 1)*fRatio)),0.3);
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
plot(data.frameTime, vel);
stem(data.indOnsets/framerate,.05*ones(length(data.indOnsets),1))
stem(data.indOffsets/framerate,.05*ones(length(data.indOffsets),1))
hold off

clearvars -except data

%% Plotting Peaks Per Second

% Uncomment the one you want:
roi = data.normDF1; %Normalized
% roi = data.normDF2; %Normalized
% roi = data.normDF3; %Normalized

figure();
behaviorOrRest=[roi.peaksPerSecondBeh, roi.peaksPerSecondRest];
bar(1.5, behaviorOrRest(1), 'FaceColor', 'b'); hold on
bar(2.5, behaviorOrRest(2), 'FaceColor', 'r');
title('Number of Peaks During Movement or Rest');
set(gca, 'XTick', [1.5 2.5], 'XTickLabel', {'Movement','Rest'});
ylabel ('Peaks Per Second');

clearvars -except data

%% Plotting all D1/D2 together

cellData = cat(1,data.dF1.dF,data.dF2.dF,data.dF3.dF); % Concatenated matrix of D1 cells, then D2 cells...
% cellData = real(fourierFilt((data.dF3.dF),5,data.framerate,'low')); % Concatenated matrix of D1 cells, then D2 cells...
% cellData = data.dF3.dF; % Concatenated matrix of D1 cells, then D2 cells...

%%(2,:)
numD1 = size(data.dF1.dF,1); % Number of D1 cells (for plotting purposes)
% numD1 = 0; % Number of D1 cells (for plotting purposes)

plotCellDataFramerate(data.vel', cellData', numD1, data.framerate, 'All Cells', 'line');
axis([0, data.totalTime + 10, -4000, 2000*(1 + size(cellData,1))]);

numframes = length(cellData);

clearvars -except data
