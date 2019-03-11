cd('C:\MATLAB\Calcium Data\')
[trials] = uigetfile('*.mat','MultiSelect','on');

totalFiles = 0;
mousePeakFreq = {};
cellNum = [1,1];
prevMouse = '';
prevDate = '';
numCondits = 5;

roi = {};
statsMats = {[],[]};

for trial = 1:length(trials);
    load(trials{trial});
    totalFiles = totalFiles + 1
    
    roi = {data.dF1, data.dF2};
               
    if ~(strcmp(data.imageFile,prevMouse))
        mousePeakFreq{cellNum(1),1} = data.imageFile;
    end
    
    if  ~(strcmp(data.date,prevDate))
        mousePeakFreq{cellNum(1),2} = data.date;
    end
                
    mousePeakFreq{cellNum(1),3} = data.acqNum;
    
    for cellType = 1:2;
        
        for cellROI = 1:length(roi{cellType}.roiList)
            mousePeakFreq{cellNum(cellType) + cellROI - 1, 4 + (cellType-1)*numCondits} = roi{cellType}.peakFreqRestMot(cellROI,1);
            mousePeakFreq{cellNum(cellType) + cellROI - 1, 5 + (cellType-1)*numCondits} = roi{cellType}.peakFreqRestMot(cellROI,2);
            mousePeakFreq{cellNum(cellType) + cellROI - 1, 6 + (cellType-1)*numCondits} = roi{cellType}.peakHeights(cellROI);    
            mousePeakFreq{cellNum(cellType) + cellROI - 1, 7 + (cellType-1)*numCondits} = roi{cellType}.riseTimes(cellROI);
            mousePeakFreq{cellNum(cellType) + cellROI - 1, 8 + (cellType-1)*numCondits} = roi{cellType}.decayTimes(cellROI);
        end
        
        cellNum(cellType) = cellNum(cellType) + length(roi{cellType}.roiList);
                
    end
    
    for cellType = 1:2
        cellNum(cellType) = max(cellNum);
    end
                
    prevMouse = data.imageFile;
    prevDate = data.date;
                
end
