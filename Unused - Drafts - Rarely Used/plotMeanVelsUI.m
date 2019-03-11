function [time, finalOnsetsDF, finalOnsetsBeh, finalOffsetsDF, finalOffsetsBeh, numOnsets, meanBaseline] = plotMeanVelsUI(trials)

tempOnsetsDF = [];
tempOffsetsDF = [];
tempOnsetsBeh = [];
tempOffsetsBeh = [];
tempDiffDF = [];
tempDiffBeh = [];
prevTrial = '';
numOnsets = zeros(1,length(trials));
numOnsetsInd = 0;
totalFiles = 0;
meanBaseline = [];

for trial = 1:length(trials)
    load(trials{trial});
    totalFiles = totalFiles + 1
    
    roi = data.dF2;
    
    if isempty(roi.dF)
        continue
    end %if
    
    for bout = 1:length(onsetToOffsetBeh)       
        
        roi.onsetToOffsetBeh{bout} = cat(2,LOCS{cellType}, 100*(tempLOCS - timeBefore)/range);
    end
    
    tempOnsetsBeh = cat(1,tempOnsetsBeh,roi.onsetsMatrixBeh);
    tempOffsetsBeh = cat(1,tempOffsetsBeh,roi.offsetsMatrixBeh);
    
    if ~strcmp(trials{trial},prevTrial)
        numOnsetsInd = numOnsetsInd + 1;
    end %if
    numOnsets(numOnsetsInd) = numOnsets(numOnsetsInd) + size(roi.onsetsMatrixDF,1);
    
    
    
    prevTrial = trials{trial};
end %for trial

time = data.timeDF;
finalOnsetsDF = tempOnsetsDF;
finalOnsetsBeh = tempOnsetsBeh;
finalOffsetsDF = tempOffsetsDF;
finalOffsetsBeh = tempOffsetsBeh;

end %function

