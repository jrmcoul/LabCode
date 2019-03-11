function [time, finalOnsetsDF, finalOnsetsBeh, finalOffsetsDF, finalOffsetsBeh, numOnsets, meanBaseline] = plotMeanOnsetOffsetUI(trials, condition, norm, avg)

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
    if condition == 0
        roi = data;
    end %if
    if condition == 1
    	if norm == true
        	roi = data.normDF1;
        else
        	roi = data.dF1;
        end %if
    end %if
    if condition == 2
    	if norm == true
        	roi = data.normDF2;
        else
        	roi = data.dF2;
        end %if
    end %if
	if condition == 3
    	if norm == true
        	roi = data.normDF3;
        else
        	roi = data.dF3;
        end %if
    end %if
	if condition > 0 && avg == false
    	roi.onsetsMatrixDF = size(roi.dF,1)*roi.onsetsMatrixDF;
    	roi.offsetsMatrixDF = size(roi.dF,1)*roi.offsetsMatrixDF;
    end %if
                
	if condition > 0 && isempty(roi.dF)
    	continue
    end %if
    
	tempOnsetsDF = cat(1,tempOnsetsDF,roi.onsetsMatrixDF);
	tempOffsetsDF = cat(1,tempOffsetsDF,roi.offsetsMatrixDF);
	tempOnsetsBeh = cat(1,tempOnsetsBeh,roi.onsetsMatrixBeh);
	tempOffsetsBeh = cat(1,tempOffsetsBeh,roi.offsetsMatrixBeh);

    if condition == 0
        
        binSecs = 30;

        behBins = 0:data.sampleRate*binSecs:data.sampleRate*data.totalTime;
        baselines = zeros(1,length(behBins) - 1);
        for bin = 1:length(behBins)-1
            [N,X] = histcounts(data.FP(behBins(bin)+1:behBins(bin+1)),100);
            baselines(bin) = X(find(N > 5,1));
        end
        C = polyfit(behBins(1:end-1),baselines,1);
        fitLine = C(1)*(1:length(data.FP)) + C(2);
        meanBaseline = cat(2,meanBaseline,mean(fitLine));
        
%         baseline1 = min(roi.FP(1:2*roi.sampleRate));
%         baseline2 = min(roi.FP(end - 2*roi.sampleRate:end));
%         meanBaseline = cat(2,meanBaseline,mean([baseline1,baseline2]));
        
    end %if
    
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

