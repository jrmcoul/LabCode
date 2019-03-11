function [PKS, LOCS, peakHeightsArray, riseTimesArray, decayTimesArray] = getPeakStatsUI(trials)

MPP = 4; % minimum peak prominence
MPH = 3; % minimum peak height
MINW = 6; % minimum peak width in frames
riseTimes = {};
decayTimes = {};
PKS = {};
LOCS = {};
LOCS{1} = [];
LOCS{2} = [];
roi = {};
totalFiles = 0;

peakHeightsArray = {[],[]};
riseTimesArray = {[],[]};
decayTimesArray = {[],[]};

avgPeakHeight = zeros(1,2);
avgRiseTime = zeros(1,2);
avgDecayTime = zeros(1,2);

for trial = 1:length(trials);
	load(trials{trial});
    totalFiles = totalFiles + 1
                
    roi{1} = data.dF1.dF;
    roi{2} = data.dF2.dF;
    roiData = data;
                
    for cellType = 1:2;
                
    	roi2 = zeros(size(roi{cellType}));
    	% Z-scoring Cells
    	for cell = 1:size(roi{cellType},1)
        	roi2(cell,:) = zscore(roi{cellType}(cell,:));
        end %for cell
                
        for cell = 1:size(roi2,1)
        	onsetThresh = 1;
        	[PKS{cellType}{cell}, LOCS{cellType}{cell}] = findpeaks(roi2(cell,:), 'MinPeakProminence', MPP, 'MinPeakHeight', MPH, 'MinPeakWidth', MINW);
        	decayThreshArray = PKS{cellType}{cell}/3;
        	PKS{cellType}{cell} = roi{cellType}(cell,LOCS{cellType}{cell});
            if isempty(PKS{cellType}{cell})
            	riseTimes{cellType}{cell} = [];
            	decayTimes{cellType}{cell} = [];
            else
            	riseTimes{cellType}{cell} = (LOCS{cellType}{cell} - iterToMin(roi2(cell,:),LOCS{cellType}{cell},onsetThresh,true))/roiData.framerate;
            	decayTimes{cellType}{cell} = (iterToMin(roi2(cell,:),LOCS{cellType}{cell},decayThreshArray,false) - LOCS{cellType}{cell})/roiData.framerate;
            end % if else
        end %for cell


        for i = 1:length(PKS{cellType})
        	peakHeightsArray{cellType} = cat(2,peakHeightsArray{cellType},PKS{cellType}{i});
        	riseTimesArray{cellType} = cat(2,riseTimesArray{cellType},riseTimes{cellType}{i});
        	decayTimesArray{cellType} = cat(2,decayTimesArray{cellType},decayTimes{cellType}{i});
        end %for i
                              
    end %for cellType

end %for trial

end %function