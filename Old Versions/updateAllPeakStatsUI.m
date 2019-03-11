[trials, pathname] = uigetfile('*.mat','MultiSelect','on');

cd(pathname)
MPP = 4; % minimum peak prominence
MPH = 3; % minimum peak height
MINW = 6; % minimum peak width in frames

PKS = {};
LOCS = {};
roi = {};
totalFiles = 0;

for trial = 1:length(trials);
	load(trials{trial});
    totalFiles = totalFiles + 1
                
    roi{1} = data.dF1;
    roi{2} = data.dF2;
    roiData = data;
                
    for cellType = 1:2;       
                
    	roi2 = zeros(size(roi{cellType}.dF));
    	% Z-scoring Cells
    	for cell = 1:size(roi{cellType}.dF,1)
        	roi2(cell,:) = zscore(roi{cellType}.dF(cell,:));
        end %for cell
        
        peakHeights = zeros(size(roi2,1),1);       
        riseTimes = zeros(size(roi2,1),1);
        decayTimes = zeros(size(roi2,1),1);
        
        for cell = 1:size(roi2,1)
        	onsetThresh = 1;
        	[PKS, LOCS] = findpeaks(roi2(cell,:), 'MinPeakProminence', MPP, 'MinPeakHeight', MPH, 'MinPeakWidth', MINW);
        	decayThreshArray = PKS/3;
            PKS = roi{cellType}.dF(cell,LOCS);
            if isempty(PKS)
                peakHeights(cell) = nan;
            	riseTimes(cell) = nan;
            	decayTimes(cell) = nan;
            else
                peakHeights(cell) = nanmean(PKS);
            	riseTimes(cell) = nanmean((LOCS - iterToMin(roi2(cell,:),LOCS,onsetThresh,true))/roiData.framerate);
            	decayTimes(cell) = nanmean((iterToMin(roi2(cell,:),LOCS,decayThreshArray,false) - LOCS)/roiData.framerate);
            end % if else
        end %for cell

        roi{cellType}.peakHeights = peakHeights;
        roi{cellType}.riseTimes = riseTimes;
        roi{cellType}.decayTimes = decayTimes;
        
                              
    end %for cellType
    
    data.dF1 = roi{1};
    data.dF2 = roi{2};
    
    save(trials{trial},'data')  

end %for trial