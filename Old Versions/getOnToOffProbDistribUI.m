function [LOCS, totalCells, totalBouts] = getOnToOffProbDistribUI(trials)

totalFiles = 0;
LOCS = {};
MPP = 4;
MPH = 3;
MINW = 6;
LOCS{1} = [];
LOCS{2} = [];
roi = {};
totalCells = zeros(1,2);
totalBouts = 0;
window = 6;

for trial = 1:length(trials)
    load(trials{trial});
    totalFiles = totalFiles + 1
    
    roi{1} = data.dF1.dF;
    roi{2} = data.dF2.dF;
    roiData = data;
    
    timeBefore = ceil(4*roiData.framerate);
    timeAfter = timeBefore;
%     totalBouts = totalBouts + length(roiData.indOnsets);
%     totalCells(1) = totalCells(1) + length(roiData.indOnsets)*size(roi{1},1);
%     totalCells(2) = totalCells(2) + length(roiData.indOnsets)*size(roi{2},1);
    boutsConsidered = 0;
    
    for cellType = 1:2;
        
        roi2 = zeros(size(roi{cellType}));
        % Z-scoring Cells
        for cell = 1:size(roi{cellType},1)
            roi2(cell,:) = zscore(roi{cellType}(cell,:));
        end
        
        %                 onsetMat = [];
        for onset = 1:length(roiData.indOnsets)
            range = roiData.indOffsets(onset) - roiData.indOnsets(onset);
            if range/roiData.framerate > window + 1
                onsetMat = roi2(:,roiData.indOnsets(onset)-timeBefore:roiData.indOffsets(onset)+timeAfter);
                for cell = 1:size(onsetMat,1)
                    [tempPKS, tempLOCS] = findpeaks(onsetMat(cell,:),'MinPeakProminence', MPP, 'MinPeakHeight', MPH, 'MinPeakWidth', MINW);
                    tempLOCS = (tempLOCS - timeBefore)/roiData.framerate;
                    tempLOCS = tempLOCS(tempLOCS > (range/roiData.framerate)/2 - window/2 & tempLOCS < (range/roiData.framerate)/2 + window/2) - ((range/roiData.framerate)/2 - window/2);
                    LOCS{cellType} = cat(2,LOCS{cellType}, tempLOCS);
                    %                 LOCS{cellType} = cat(2,LOCS{cellType},round(100*tempLOCS/size(onsetMat,2)));
                end
                
                if cellType == 2
                    boutsConsidered = boutsConsidered + 1;
                end
            end
        end
        
    end
    
    totalBouts = totalBouts + boutsConsidered;
    totalCells(1) = totalCells(1) + boutsConsidered*size(roi{1},1);
    totalCells(2) = totalCells(2) + boutsConsidered*size(roi{2},1);
    
    
end

end
