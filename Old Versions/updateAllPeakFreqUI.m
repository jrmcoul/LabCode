[trials, pathname] = uigetfile('*.mat','MultiSelect','on');

cd(pathname)
totalFiles = 0;

MPP = 4;
MPH = 3;
MINW = 6;
roi = {};

for trial = 1:length(trials);
	load(trials{trial});                               
	totalFiles = totalFiles + 1
    
    roi{1} = data.dF1;
    roi{2} = data.dF2;
      
    for cellType = 1:2;
        
%         roi{cellType} = rmfield(roi{cellType}, 'peakFreq');
        roi{cellType}.peakFreqRestMot = zeros(size(roi{cellType}.dF,1),2);
        numSpikesCell = zeros(size(roi{cellType}.dF,1),2);
        
        for isMoving = [0, 1];
            roiData = data;
            
            if isMoving == 0;
                roiData.indOnsets = data.indOnsetsRest;
                roiData.indOffsets = data.indOffsetsRest;
            end

            totalTime = sum(roiData.indOffsets-roiData.indOnsets)/roiData.framerate;
            
            
            roi2 = zeros(size(roi{cellType}.dF));
            % Z-scoring Cells
            for cell = 1:size(roi{cellType}.dF,1)
                roi2(cell,:) = zscore(roi{cellType}.dF(cell,:));
            end            
            
            for onset = 1:length(roiData.indOnsets)                    
                onsetMat = roi2(:,roiData.indOnsets(onset):roiData.indOffsets(onset));                
                for cell = 1:size(onsetMat,1)
                    warning('OFF');
                    [tempPKS, tempLOCS] = findpeaks(onsetMat(cell,:),'MinPeakProminence', MPP, 'MinPeakHeight', MPH, 'MinPeakWidth', MINW);
                    numSpikesCell(cell, isMoving + 1) =  numSpikesCell(cell, isMoving + 1) + length(tempLOCS);
                end
            end    
            
            roi{cellType}.peakFreqRestMot(:,isMoving + 1) = numSpikesCell(:,isMoving + 1)/totalTime;
        end
        
    end
    
    data.dF1 = roi{1};
    data.dF2 = roi{2};
    
    save(trials{trial},'data')  
                    
end