[trials] = uigetfile('*.mat','MultiSelect','on');

cd('L:\tritsn01labspace\Marta\2p_Data\Calcium Data\sL7\')
% cd('C:\MATLAB\Calcium Data\')
totalFiles = 0;

for trial = 1:length(trials);
    totalFiles = totalFiles + 1               
    load(trials{trial});  
    
    framerate = data.framerate;
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
                
	save(trials{trial},'data')                

end
cd ..