%% Getting ROIs

clear all;
close all;
clc;

for acqNum = 1:2; %CHANGE depending on which acquisitions you have
    
data = struct; % Defining data as an empty structure

data.imageFile = 'SW027'; %CHANGE
data.date = '170621'; %CHANGE
additionalFolderSring = ' acq1-2'; %%CHANGE NAME FOLDER

load([data.imageFile,'.mat']);  %Loading the obj file associated with data.imagefile
myObj = eval(data.imageFile); %Bad practice, I know...

numFramesAcq1 = 17928; %CHANGE depending on how many frames in first acquisition

data.acqNum = acqNum;
    
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

if data.acqNum == 1 || data.acqNum == 3;
    data.dF1.dF = data.dF1.dF(:,1:numFramesAcq1);
    data.dF2.dF = data.dF2.dF(:,1:numFramesAcq1);
    data.dF3.dF = data.dF3.dF(:,1:numFramesAcq1);
end
if data.acqNum == 2 || data.acqNum == 4;
    data.dF1.dF = data.dF1.dF(:,numFramesAcq1 + 1:end);
    data.dF2.dF = data.dF2.dF(:,numFramesAcq1 + 1:end);
    data.dF3.dF = data.dF3.dF(:,numFramesAcq1 + 1:end);
end
clearvars -except data acqNum additionalFolderSring
%% Behavior & Mirror: Opening and Synchronization

cd(['C:\Users\labadmin\Documents\MATLAB\Marta\',data.imageFile,'\',data.date,additionalFolderSring,'\beh\'])

totalTime = 600; % in seconds
timeFreq = 2000; % in hz

% firstFile = 1; %CHANGE
firstFile = data.acqNum; %CHANGE
lastFile = firstFile;
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

clearvars -except data acqNum
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

clearvars -except data acqNum
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
data.timeDF = (-round(timeBefore*fRatio):round(timeAfter*fRatio))/framerate;

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

clearvars -except data dffOnsets dffOffsets onsetsFinal offsetsFinal acqNum

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

clearvars -except data acqNum

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

cd('C:\Users\labadmin\Documents\MATLAB\Calcium Data\')
save([data.imageFile,'_',data.date,'_Acq',num2str(data.acqNum),'.mat'],'data')
cd ..

clearvars -except acqNum

end
