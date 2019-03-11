function [LOCS, totalCells, totalBouts] = getOnsetProbDistrib(mouse,date,acq)

totalFiles = 0;
LOCS = {};
MPH = 5;
MINW = 6;
LOCS{1} = [];
LOCS{2} = [];
roi = {};
totalCells = zeros(1,2);
totalBouts = 0;

for mouseNum = 1:length(mouse)
    for dateNum = 1:length(date)
%         if ~((strcmp(mouse{mouseNum},'F007') || strcmp(mouse{mouseNum},'F007')) && strcmp(date{dateNum},'170406'));
        for acqNum = 1:length(acq)
            filename = cat(2,mouse{mouseNum},'_',date{dateNum},'_Acq',acq{acqNum},'.mat');            
            if exist(filename)
                load(filename);
                totalFiles = totalFiles + 1
                
                roi{1} = data.dF1.dF;
                roi{2} = data.dF2.dF;
                roiData = data;
                
                totalBouts = totalBouts + length(roiData.indOnsets);
                totalCells(1) = totalCells(1) + length(roiData.indOnsets)*size(roi{1},1);
                totalCells(2) = totalCells(2) + length(roiData.indOnsets)*size(roi{2},1);
                
                for cellType = 1:2;
                    
                % Z-scoring Cells
                for cell = 1:size(roi{cellType},1)
                    roi{cellType}(cell,:) = zscore(roi{cellType}(cell,:));
                end
                
%                 onsetMat = [];
                for onset = 1:length(roiData.indOnsets)                    
                    onsetMat = roi{cellType}(:,roiData.indOnsets(onset):roiData.indOffsets(onset));                
                    for cell = 1:size(onsetMat,1)    
                        [tempPKS, tempLOCS] = findpeaks(onsetMat(cell,:),'MinPeakProminence', MPH, 'MinPeakWidth', MINW);
                        LOCS{cellType} = cat(2,LOCS{cellType},round(100*tempLOCS/size(onsetMat,2)));
                    end
                end
                
                end

            end
        end
%         end
    end
end

end
