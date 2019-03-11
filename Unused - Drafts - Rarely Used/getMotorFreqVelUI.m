[trials, pathname] = uigetfile('*.mat','MultiSelect','on');

if ~iscell(trials)
    tempTrials = trials;
    trials = cell(1);
    trials{1} = tempTrials;
end

cd(pathname)
MINW = 4;
noiseThresh = 0.4;
stdAway = 5;

velValues = [.07, .12, .165, .22]; 

cellFreqPerRegion = cell(1,2);
PKS = {};
LOCS = {};
roi = {};
totalFiles = 0;
warning('OFF');

for trial = 1:length(trials);
	load(trials{trial});
    totalFiles = totalFiles + 1
                
    roi{1} = data.dF1;
    roi{2} = data.dF2;
                
    for cellType = 1:2;
        if isempty(roi{cellType}.dF)
            continue
        end
                
        roi2 = zeros(size(roi{cellType}.dF));
        % Z-scoring Cells
        for nCell = 1:size(roi{cellType}.dF,1)
            roi2(nCell,:) = smooth(roi{cellType}.dF(nCell,:),5)';
        end
        
        peakHeights = zeros(size(roi2,1),3);       
        riseTimes = zeros(size(roi2,1),3);
        decayTimes = zeros(size(roi2,1),3);
        
        
        for velBin = 1:3
            roiData = data;
            
            boutMat = roiData.vel > velValues(velBin) & roiData.vel < velValues(velBin + 1);            
            totalTime = sum(boutMat)/roiData.framerate;
            
            for nCell = 1:size(roi2,1)

                MPP = mean(roi2(nCell,roi2(nCell,:) < noiseThresh)) + stdAway*std(roi2(nCell,roi2(nCell,:) < noiseThresh));
                baseline = mean(roi2(nCell,roi2(nCell,:) < noiseThresh));
                MPH = MPP;
                [PKS, LOCS] = findpeaks(roi2(nCell,:), 'MinPeakProminence', MPP, 'MinPeakHeight', MPH, 'MinPeakWidth', MINW);
                PKS = PKS(PKS & boutMat(LOCS));
                LOCS = LOCS(LOCS & boutMat(LOCS)); 

                decayThreshArray = PKS/3;
                peak80 = PKS*.8;
                peak20 = PKS*.2;
                PKS = roi{cellType}.dF(nCell,LOCS);
                
                peakFreq(nCell, velBin) = length(LOCS)/totalTime;
                
                if isempty(PKS)
                    peakHeights(nCell, velBin) = nan;
                    riseTimes(nCell, velBin) = nan;
                    decayTimes(nCell, velBin) = nan;
                else
                    peakHeights(nCell,velBin) = nanmean(PKS);
                    riseTimes(nCell,velBin) = nanmean((iterToMin(roi2(nCell,:),LOCS,peak80,true) - iterToMin(roi2(nCell,:),LOCS,peak20,true))/roiData.framerate);
                    decayTimes(nCell,velBin) = nanmean((iterToMin(roi2(nCell,:),LOCS,decayThreshArray,false) - LOCS)/roiData.framerate);
                end % if else
                
            end %for nCell
        end %for velBins

        cellFreqPerRegion{cellType}(trial,:) = nanmean(peakFreq,1);
%         roi{cellType}.peakHeights = peakHeights;
%         roi{cellType}.riseTimes = riseTimes;
%         roi{cellType}.decayTimes = decayTimes;
        
                              
    end %for cellType
    
    data.dF1 = roi{1};
    data.dF2 = roi{2};
    
%     save(trials{trial},'data')

    

end %for trial