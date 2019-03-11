function [LOCS, totalCells, totalBouts] = getOnsetProbDistribUIFINAL(trials,isOnset)

totalFiles = 0;

MINW = 4;
noiseThresh = 0.4;
stdAway = 5;

LOCS = {};
LOCS{1} = [];
LOCS{2} = [];
roi = {};
totalCells = zeros(1,2);
totalBouts = 0;

for trial = 1:length(trials)
    load(trials{trial});
    totalFiles = totalFiles + 1
    
    roi{1} = data.dF1.dF;
    roi{2} = data.dF2.dF;
    roiData = data;
    
    totalBouts = totalBouts + length(roiData.indOnsets); %number of bouts
    totalCells(1) = totalCells(1) + length(roiData.indOnsets)*size(roi{1},1); %number of d1 cells*bouts
    totalCells(2) = totalCells(2) + length(roiData.indOnsets)*size(roi{2},1); %number of d2 cells*bouts
    
    for cellType = 1:2;
        
        roi2 = zeros(size(roi{cellType}));
        % Z-scoring Cells
        for nCell = 1:size(roi{cellType},1)
            roi2(nCell,:) = smooth(roi{cellType}(nCell,:),5)'; %zscore(roi{cellType}(nCell,:));
        end
        
        timeBefore = ceil(4*roiData.framerate);
        timeAfter = timeBefore;
        onsetMat = [];
        
        if isOnset
            for onset = 1:length(roiData.indOnsets)
                onsetMat = cat(1,onsetMat,roi2(:,roiData.indOnsets(onset) - timeBefore:roiData.indOnsets(onset) + timeAfter));
            end
        else
            for onset = 1:length(roiData.indOnsets)
                onsetMat = cat(1,onsetMat,roi2(:,roiData.indOffsets(onset) - timeBefore:roiData.indOffsets(onset) + timeAfter));
            end
        end
        for nCell = 1:size(onsetMat,1)
            warning('OFF');
            MPP = mean(onsetMat(nCell,onsetMat(nCell,:) < noiseThresh)) + stdAway*std(onsetMat(nCell,onsetMat(nCell,:) < noiseThresh));
            MPH = MPP;
            [tempPKS, tempLOCS] = findpeaks(onsetMat(nCell,:),'MinPeakProminence', MPP, 'MinPeakHeight', MPH, 'MinPeakWidth', MINW);
            LOCS{cellType} = cat(2,LOCS{cellType},(tempLOCS - timeBefore)/roiData.framerate);
        end
        
    end


end

end

