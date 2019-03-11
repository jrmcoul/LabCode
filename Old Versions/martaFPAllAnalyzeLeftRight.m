%% Behavior + Fiber Photometry Data

% mouse = {'F006','F007','F008'};
% date = {'170303','170307','170309','170315','170321','170323'};
% acq = {'1','2','3','4','5','6'};

% mouse = {'F014','F015','F016','F017','F018'};
% date = {'170517','170524'};
% acq = {'1','2','3','4'};


% mouse = {'F009','F010','F011','F012','F013'};
% date = {'170426'};
% acq = {'1','2','3'};


mouse = {'F019', 'F020'};
date = {'170620'};
acq = {'1'};


totalFiles = length(mouse)*length(date)*length(acq);
completeFiles = 0;

for mouseNum = 1:length(mouse)
    for dateNum = 1:length(date);
        for acqNum = 1:length(acq);
tic

clearvars -except mouse mouseNum date dateNum acq acqNum totalFiles completeFiles
data = struct; % Defining data as an empty structure

data.imageFile = mouse{mouseNum};
data.date = date{dateNum};
newDirectory = cat(2,'C:\Users\labadmin\Documents\MATLAB\Marta\',data.imageFile,'\',data.date,'\');

for FPCondit = 1:2;
    
cd(newDirectory)

totalTime = 600; % in seconds
timeFreq = 2000; % in hz

warning off;

filename = cat(2,'AD0_',acq{acqNum},'.mat');
if exist(filename)
    
firstFile = str2double(acq{acqNum}); %CHANGE
lastFile = firstFile; %CHANGE
wheelRadius = .06; %in m
circumference = 2*wheelRadius*pi; %in m

% Opening behavior and mirror files according to the filenames
[data.rawData, data.FP] = getBehAndFP(firstFile, lastFile, FPCondit);
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

data.sampleRate = length(data.finalData)/totalTime; %in hz
data.sampleTime = (1:length(data.finalData))/data.sampleRate;
data.totalDistance = sum(abs(data.vel))/data.sampleRate;
data.acqNum = firstFile; %Acquisition number for file naming
data.totalTime = totalTime; %Total time elapsed in s
data.timeFreq = timeFreq; %Acquisition rate of behavior in hz

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
offsetsBeh = offsetsBeh(offsetsBeh < length(signal) - timeThreshold); % Making sure last offsets is at least timeThreshold from the end
onsetsBeh = onsetsBeh(1:length(offsetsBeh)); % Removing onsets that correspond to removed offsets
offsetsFinal = offsetsBeh((offsetsBeh - onsetsBeh) > timeThreshold); % Making sure onset to offset is at least timeThreshold in length
onsetsFinal = onsetsBeh((offsetsBeh - onsetsBeh) > timeThreshold); % Making sure onset to offset is at least timeThreshold in length
offsetsFinal = offsetsFinal(onsetsFinal > timeThreshold); % Making sure first onset is at least timeThreshold from the beginning (corresponding offset)
onsetsFinal = onsetsFinal(onsetsFinal > timeThreshold); % Making sure first onset is at least timeThreshold from the beginning

threshold = 2*std(signal(offsetsFinal(1)+round(sampleRate):offsetsFinal(1)+3*round(sampleRate))); % Velocity threshold is 2*stdev of noise
onsetsFinal = iterToMin(signal,onsetsFinal,threshold,true); % Final onsets array
offsetsFinal = iterToMin(signal,offsetsFinal,threshold,false); % Final offsets array

timeBefore = 4*sampleRate; % Time before onset/offset (coeff is in seconds)
timeAfter = 4*sampleRate; % Time after onset/offset (coeff is in seconds)
dffOnsets = round(onsetsFinal*fRatio);
dffOffsets = round(offsetsFinal*fRatio);

% Chopping off onsets/offsets within timeBefore of start or timeAfter of end
onsetsFinal = onsetsFinal(dffOnsets > timeBefore & dffOnsets < length(roi) - timeAfter);
offsetsFinal = offsetsFinal(dffOnsets > timeBefore & dffOnsets < length(roi) - timeAfter);
dffOffsets = dffOffsets(dffOnsets > timeBefore & dffOnsets < length(roi) - timeAfter);
dffOnsets = dffOnsets(dffOnsets > timeBefore & dffOnsets < length(roi) - timeAfter);

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

%% Saving Files

cd('C:\Users\labadmin\Documents\MATLAB\Photometry Data\')
dataSave = [data.imageFile,'_',data.date,'_Acq',num2str(data.acqNum)];
if FPCondit == 2;
    dataSave = [dataSave,'_left'];
end
save([dataSave,'.mat'],'data')
cd ..
completeFiles = completeFiles + 1;
display([num2str(completeFiles),' out of ',num2str(2*totalFiles),' files complete.'])

toc
end

end
        end
    end
end