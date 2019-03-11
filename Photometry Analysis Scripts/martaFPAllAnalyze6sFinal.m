%% Summary:
% 
% This script calculates and saves all data analyses for FP analysis.
% 
% Instructions:
% This code functions by creating three cell arrays of strings:
% "mouse", "date", and "acq". These contain the information for all the
% acquisitions to be analyzed in bulk. All combinations of mouse, date, and
% acq do not have to exist. If they don't exist, the code will skip that
% analysis.
% 
% "newDirectory" defines the path where all of the raw FP acquisitions from
% scanimage will be found. The code will automatically enter the path
% defined by newDirectory, and the user should update newDirectory to
% properly reflect where the repository for all FP data resides. The format
% currently is in the path Fiberphotometry > Mouse > Date. Then choosing
% the data within the folder reflects the "acquisition number."
% 
% The result of the script will be the creation and saving of a data
% structure called "data" inside the file named "Mouse_Date_Acq.mat". This
% structure will contain the raw behavioral data, the downsampled
% photometry and velocity data, along with onset/offset information.
% 
% The code will fail if there are no onsets or offsets in the spontaneous
% movie. That will be the most common source of an error message.
% 
% **NOTE** Keep an eye on FPCondit! This is the input of the photometry
% signal into the NIDAQ boards and corresponds to the AD_x number that we
% want to be analyzing for photometry. Right now, it is set to 7 and will
% count down until it finds a file that exists, but you need to make sure
% that your calcium signal is a higher AD_x value than any other value,
% otherwise you need to change FPCondit.
% 
% Properties for paper: 
% 
% newDirectory = cat(2,'L:\tritsn01labspace\Marta\Fiberphotometry\new FP exps\',data.imageFile,'\',data.date,'\');
% wheelRadius = .06 m; velThreshold (mov) = 0.004 m/s;
% velThreshold (rest) = 0.002 m/s; FPCondit = 7; timeFreq = 50 Hz;
% 
% Inputs:
% 
% 'mouse' - cell array containing mouse names
% 
% 'date' - cell array containing the dates of acquisition
% 
% 'acq' - cell array containing the acquisition numbers
% 
% photometry file and behavior traces (will be found automatically)
%
% Outputs:
% 
% 'data' - large structure of data containing all relevant analyses. See
% sheet on the "Code List.xls" spreadsheet entitled "FP Data Struct
% Schematic"
% 
% Author: Jeffrey March, 2018

%% Acquisitions to Analyze

% Sham (up to F032)
% mouse = {'F028','F030','F031','F032'};
% date = {'180129','180130','180223','180226'};
% acq = {'1','2'};

% Sham (after F032)
% mouse = {'F034','F035','F036','F037'};
% date = {'180129','180130','180223','180226'};
% acq = {'1','2'};

% Lesion (until F036, which has no bouts)
% mouse = {'F028','F030','F031','F034','F035','F036'};
% date = {'180320','180321','180412','180419','180517','180518','180529','180530','180531','180601'};
% acq = {'1','2'};

% Lesion (to finish up F036)
% mouse = {'F036'};
% date = {'180419','180517','180518','180529','180530','180531','180601'};
% acq = {'1','2'};

% Lesion (after F036, until F051, which has no bouts)
% mouse = {'F037','F044','F046','F048','F049','F050','F051'};
% date = {'180320','180321','180412','180419','180517','180518','180529'};
% acq = {'1','2'};

% Lesion (to finish up F051)
% mouse = {'F051'};
% date = {'180530','180531','180601'};
% acq = {'1','2'};

% Lesion (after F051, until F056, which has no bouts)
% mouse = {'F052','F053','F054','F055','F056'};
% date = {'180320','180321','180412','180419','180517','180518','180529','180530','180531','180601'};
% acq = {'1','2'};

% Lesion (F057)
% mouse = {'F057'};
% date = {'180601'};
% acq = {'1','2'};

% Lesion (starting F059, which has no bouts)
% mouse = {'F059'};
% date = {'180605'};
% acq = {'1','2'};

% Lesion (finishing F059)
% mouse = {'F059'};
% date = {'180606'};
% acq = {'1','2'};

% Lesion (finishing F044)
% % mouse = {'F044'};
% % date = {'180605'};
% % acq = {'1','2'};

% Lesion (finishing F048)
% mouse = {'F037'};
% date = {'180320','180321'};
% acq = {'1','2',};

% Chronic Condition
% mouse = {'F048'};
% date = {'180619'};
% acq = {'1','3'};

% Chronic Condition
% mouse = {'F052','F054','F055','F057'};
% date = {'180619'};
% acq = {'1','2'};

% % Chronic Condition
% mouse = {'F059'};
% date = {'180619'};
% acq = {'1','2'};

% % Chronic Condition (redo)
% mouse = {'F052','F054','F057','F059'};
% date = {'180620'};
% acq = {'1'};

% % Chronic Condition (redo)
% mouse = {'F054','F059'};
% date = {'180620'};
% acq = {'2'};

% % New Cohort
% mouse = {'F063','F064','F065','F066','F067','F070','F071','F072','F075','F076','F077','F079'};
% date = {'181017','181019','181024','181026'};
% acq = {'1'};

% % New Cohort (pre-prelesion)
% mouse = {'F063','F064','F065','F066','F067','F070','F071','F072','F075','F076','F077','F079'};
% date = {'181015','181022'};
% acq = {'1'};

% % New Cohort (pre-prelesion) (actually motor)
% mouse = {'F063'};
% date = {'181015'};
% acq = {'2'};

% % New Cohort (Spont)
% mouse = {'F063','F064','F065','F066','F067','F070','F071','F072','F075','F076','F077','F079'};
% date = {'181017','181019','181024','181026'};
% acq = {'2'};

% % New Cohort (pre-prelesion) (Spont)
% mouse = {'F063','F064','F065','F066','F067','F070','F071','F072','F075','F076','F077','F079'};
% date = {'181015','181022'};
% acq = {'2'};

% % New Cohort (chronic) (Spont + Motor)
% mouse = {'F066','F072'};
% date = {'181031','181109'};
% acq = {'1','2'};

% New Cohort (pre-prelesion) (CORRECTED!! FPCondit == 7)
mouse = {'F063'};
date = {'181015'};
acq = {'1,','2'};


%% Behavior + Fiber Photometry Data

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
newDirectory = cat(2,'L:\tritsn01labspace\Marta\Fiberphotometry\new FP exps\',data.imageFile,'\',data.date,'\');
if exist(newDirectory, 'dir')
cd(newDirectory)

totalTime = 600; % in seconds
originalSamplingRate = 2000; % in Hz
timeFreq = 50; % in Hz (downsampled)

warning off;

filename = cat(2,'AD0_',acq{acqNum},'.mat');

    
firstFile = str2double(acq{acqNum}); %CHANGE
lastFile = firstFile; %CHANGE
FPCondit = 7; %CHANGE
wheelRadius = .06; %in m
circumference = 2*wheelRadius*pi; %in m
donwsampleRate = originalSamplingRate/timeFreq; %downsample by averaging every 40 points

% Opening behavior and mirror files according to the filenames
[data.rawData, data.FP] = getBehAndFP(firstFile, lastFile, FPCondit);
data.FP = downsampleBins(data.FP,donwsampleRate);

% Unwrap the periodic behavior signal and downsample to get total distance
data.finalData = circumference*downsampleBins(unwrapBeh(data.rawData),donwsampleRate);

time = 1/timeFreq : 1/timeFreq : length(data.finalData)/timeFreq; %time scale
vel = timeFreq*[diff(data.finalData), data.finalData(end) - data.finalData(end-1)]; %in m/s
data.vel = medfilt1(vel,10); %in m/s

accel = timeFreq*[diff(data.vel), data.vel(end) - data.vel(end-1)];
data.accel = medfilt1(accel,10);
data.accel = smooth(accel,100)';   %%%MARTA

data.sampleRate = length(data.finalData)/totalTime; %in hz
data.sampleTime = (1:length(data.finalData))/data.sampleRate;
data.totalDistance = sum(abs(data.vel))/data.sampleRate;
data.acqNum = firstFile; %Acquisition number for file naming
data.totalTime = totalTime; %Total time elapsed in s
data.timeFreq = timeFreq; %Acquisition rate of behavior in hz

%% Normalizing all data

% For normalization, the data is divided into 30 second bins, and in each,
% the 5th percentile point is found and deemed to be the minimum of that
% bin. Each of these points is then fit with a linear trace, which is then
% deemed the "baseline" for each point in the photometry trace, converting
% the signal do DF/F.

binSecs = 30;

behBins = 0:data.sampleRate*binSecs:data.sampleRate*data.totalTime;
baselines = zeros(1,length(behBins) - 1);
for bin = 1:length(behBins)-1
    [N,X] = histcounts(data.FP(behBins(bin)+1:behBins(bin+1)),100);
    baselines(bin) = X(find(N > 5,1));
end
C = polyfit(behBins(1:end-1),baselines,1);
fitLine = C(1)*(1:length(data.FP)) + C(2);

data.FPNorm = (data.FP - fitLine)./fitLine;

%% Creating Movement Onset/Offset Data

roi = data.FPNorm;

%frame information (both behavior and imaging)
framerate = data.sampleRate;
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
onsetsBeh = iterToMin(signal,onsetsFinal,threshold,true); % Final onsets array (***I don't know if this was included in the paper...)
offsetsBeh = iterToMin(signal,offsetsFinal,threshold,false); % Final offsets array (***I don't know if this was included in the paper...)

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

onsetsMatrixBeh = []; %Initializing
offsetsMatrixBeh = []; %Initializing
onsetsMatrixDF = []; %Initializing
offsetsMatrixDF = []; %Initializing
onsetToOffsetDF = {}; %Initializing
onsetToOffsetBeh = {}; %Initializing
onsetToOffsetTime = {}; %Initializing

for n = 1:length(dffOnsets)
    onsetsMatrixDF(n,:) = roi(dffOnsets(n) - ceil(timeBefore*fRatio):dffOnsets(n) + ceil(timeAfter*fRatio));
    offsetsMatrixDF(n,:) = roi(dffOffsets(n) - ceil(timeBefore*fRatio):dffOffsets(n) + ceil(timeAfter*fRatio));
    onsetsMatrixBeh(n,:) = signal(onsetsFinal(n) - ceil(timeBefore):onsetsFinal(n) + ceil(timeAfter));
    offsetsMatrixBeh(n,:) = signal(offsetsFinal(n) - ceil(timeBefore):offsetsFinal(n) + ceil(timeAfter));
    onsetToOffsetDF{n} = roi(dffOnsets(n) - ceil(timeBefore*fRatio):dffOffsets(n) + ceil(timeAfter*fRatio));
    onsetToOffsetBeh{n} = signal(onsetsFinal(n) - ceil(timeBefore):offsetsFinal(n) + ceil(timeAfter));
    onsetToOffsetTime{n} = (-ceil(timeBefore*fRatio):length(onsetToOffsetDF{n}) - 1 - ceil(timeAfter*fRatio))/framerate;
end

% Saving data into structure
data.indOnsets = onsetsFinal; % Final onset indices
data.indOffsets = offsetsFinal; % Final offset indices
data.numBouts = length(onsetsFinal); % Number of bouts
data.avgBoutDuration = mean(offsetsFinal - onsetsFinal)/framerate; % Avg bout duration
data.stdBoutDuration = std(offsetsFinal - onsetsFinal)/framerate; % STD bout duration
data.timeDF = (-ceil(timeBefore*fRatio):ceil(timeAfter*fRatio))/framerate;

data.onsetsMatrixDF = onsetsMatrixDF;
data.offsetsMatrixDF = offsetsMatrixDF;
data.onsetToOffsetDF = onsetToOffsetDF;
data.onsetsMatrixBeh = onsetsMatrixBeh;
data.offsetsMatrixBeh = offsetsMatrixBeh;
data.onsetToOffsetBeh = onsetToOffsetBeh;
data.onsetToOffsetTime = onsetToOffsetTime;


clearvars -except mouse mouseNum date dateNum acq acqNum totalFiles completeFiles data

%% Getting rest onset and offset

framerate = data.sampleRate;
timeThreshold = 4*framerate; %CHANGE number 4,5,6,7.. a seconda dimensione finestra pre post onset
velThreshold = 0.002; %CHANGE was .004
minRestTime = 4*framerate; %CHANGE number 4,5,6,7.. a seconda dimensione finestra pre post onset
minRunTime =   1; %CHANGE
behavior = true; %CHANGE
signal = abs(data.vel); %This can be either absolute value or not
timeShift = round(.5*framerate);

[onsetsBeh, offsetsBeh] = getOnsetOffset(-signal, -velThreshold, minRunTime, minRestTime, behavior);   %%MARTA CHANGES

% Making on/offsets adhere to time/length constraints
offsetsBeh = offsetsBeh(offsetsBeh < length(signal) - timeThreshold); % Making sure last offsets is at least timeThreshold from the end
onsetsBeh = onsetsBeh(1:length(offsetsBeh)); % Removing onsets that correspond to removed offsets
offsetsFinal = offsetsBeh((offsetsBeh - onsetsBeh) > timeThreshold); % Making sure onset to offset is at least timeThreshold in length
onsetsFinal = onsetsBeh((offsetsBeh - onsetsBeh) > timeThreshold); % Making sure onset to offset is at least timeThreshold in length
offsetsFinal = offsetsFinal(onsetsFinal > timeThreshold); % Making sure first onset is at least timeThreshold from the beginning (corresponding offset)
onsetsFinal = onsetsFinal(onsetsFinal > timeThreshold); % Making sure first onset is at least timeThreshold from the beginning

onsetsFinal = onsetsFinal + timeShift;
offsetsFinal = offsetsFinal - timeShift;

data.indOnsetsRest = onsetsFinal;
data.indOffsetsRest = offsetsFinal;

clearvars -except mouse mouseNum date dateNum acq acqNum totalFiles completeFiles data
%% Saving Files

cd('L:\tritsn01labspace\Marta\Fiberphotometry\Photometry Data\')
dataSave = [data.imageFile,'_',data.date,'_Acq',num2str(data.acqNum)];
save([dataSave,'.mat'],'data')
cd ..
completeFiles = completeFiles + 1;
display([num2str(completeFiles),' out of ',num2str(totalFiles),' files complete.'])

toc
end
        end
    end
end