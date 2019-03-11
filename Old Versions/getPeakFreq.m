function [LOCS, totalTimeCells, totalTime, freqCell] = getPeakFreq(mouse,date,acq)

totalFiles = 0;
LOCS = {};
MPH = 5;
MINW = 6;
LOCS = {[],[];[],[]};
roi = {};
totalTimeCells = {0,0;0,0};
totalBouts = 0;
totalTime = {0;0};
numCells = [0,0];
totalTimeMotionOrRest = {};
numSpikesCell = {};
freqCell = {};

for mouseNum = 1:length(mouse)
    for dateNum = 1:length(date)
%         if ~((strcmp(mouse{mouseNum},'F007') || strcmp(mouse{mouseNum},'F007')) && strcmp(date{dateNum},'170406'));
        for acqNum = 1:length(acq)
            filename = cat(2,mouse{mouseNum},'_',date{dateNum},'_Acq',acq{acqNum},'.mat');            
            if exist(filename)
                load(filename);                               
                totalFiles = totalFiles + 1
                                          
                for isMoving = [0, 1];
                    
                roi{1} = data.dF1.dF;
                roi{2} = data.dF2.dF;
                roiData = data;
                
                if isMoving == 0;
                    roiData.indOnsets = data.indOnsetsRest;
                    roiData.indOffsets = data.indOffsetsRest;
                end
                
                totalTime{isMoving + 1,1} = totalTime{isMoving + 1,1} + sum(roiData.indOffsets-roiData.indOnsets)/roiData.framerate;
                totalTimeCells{isMoving + 1,1} = totalTimeCells{isMoving + 1,1} + size(roi{1},1)*sum(roiData.indOffsets-roiData.indOnsets)/roiData.framerate;
                totalTimeCells{isMoving + 1,2} = totalTimeCells{isMoving + 1,2} + size(roi{2},1)*sum(roiData.indOffsets-roiData.indOnsets)/roiData.framerate;
                
                for cellType = 1:2;
                    
                % Z-scoring Cells
                for cell = 1:size(roi{cellType},1)
                    roi{cellType}(cell,:) = zscore(roi{cellType}(cell,:));
                end
                
%                 onsetMat = [];
                for onset = 1:length(roiData.indOnsets)                    
                    onsetMat = roi{cellType}(:,roiData.indOnsets(onset):roiData.indOffsets(onset));                
                    for cell = 1:size(onsetMat,1)
                        if onset == 1;
                            numSpikesCell{cell + numCells(cellType), cellType} = 0;
                            totalTimeMotionOrRest{cell + numCells(cellType), cellType} = 0;
                        end
                        [tempPKS, tempLOCS] = findpeaks(onsetMat(cell,:),'MinPeakProminence', MPH, 'MinPeakWidth', MINW);
                        LOCS{isMoving + 1, cellType} = cat(2,LOCS{isMoving + 1, cellType},round(100*tempLOCS/size(onsetMat,2)));
                        numSpikesCell{cell + numCells(cellType), cellType} =  numSpikesCell{cell + numCells(cellType), cellType} + length(tempLOCS);
                        totalTimeMotionOrRest{cell + numCells(cellType), cellType} = totalTimeMotionOrRest{cell + numCells(cellType), cellType} + size(onsetMat,2)/roiData.framerate;
                        if onset == length(roiData.indOnsets)
                            freqCell{isMoving + 1}{cell + numCells(cellType), cellType} = numSpikesCell{cell + numCells(cellType), cellType}/totalTimeMotionOrRest{cell + numCells(cellType), cellType};
                        end
                    end
                end
                
                if isMoving == 1 %only update this once you are done with second iteration through isMoving
                    numCells(cellType) = numCells(cellType) + size(roi{cellType},1);
                end
                
                end
                
                end

            end
        end
%         end
    end
end

end
