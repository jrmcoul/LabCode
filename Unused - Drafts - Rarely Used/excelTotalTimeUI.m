[trials, pathname] = uigetfile('*.mat','MultiSelect','on');

if ~iscell(trials)
    tempTrials = trials;
    trials = cell(1);
    trials{1} = tempTrials;
end

cd(pathname)
totalFiles = 0;

peakFreqRestMot = zeros(length(trials),2);

for trial = 1:length(trials);
	load(trials{trial});                               
	totalFiles = totalFiles + 1  
    
    for isMoving = [0, 1];
        roiData = data;
        
        if isMoving == 0;
            roiData.indOnsets = data.indOnsetsRest;
            roiData.indOffsets = data.indOffsetsRest;
        end
        
        totalTime = sum(roiData.indOffsets-roiData.indOnsets)/roiData.framerate;
        
        peakFreqRestMot(trial,isMoving + 1) = totalTime;
    end
    
end