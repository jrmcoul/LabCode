function [time, finalOnsetsDF, finalOnsetsBeh, finalOffsetsDF, finalOffsetsBeh, numOnsets, meanBaseline, minMax, names] = plotMeanOnsetOffsetUINorm(trials, condition, norm, avg)

% [time, finalOnsetsDF, finalOnsetsBeh, finalOffsetsDF, finalOffsetsBeh, numOnsets, meanBaseline, minMax, names] = plotMeanOnsetOffsetUINorm(trials, condition, norm, avg)
% 
% Summary: This function collects and organizes onset, offest, baseline, 
% and normalization data for FP traces. It is called by 
% plottingAllDataAveragesUINorm. It can also be used for DF/F from 2P
% traces, but that code is a little vestigial.
% 
% Inputs:
% 
% 'trials' - .mat filenames of the files to be analyzed
%
% 'condition' - 0 for photometry, 1-3 for cell type from 2P movie
%
% 'norm' - boolean stating whether or not 2P data will be normalized
%
% 'avg' - boolean stating whether 2P data will be average DF/F or summed
% DF/F
%
% Outputs:
% 
% 'time' - array of time points for DF/F at onset/offset trace
% 
% 'finalOnsetsDF' - matrix of all DF/F at onset traces for all FOVs
% 
% 'finalOnsetsBeh' - matrix of all velocity at onset traces for all FOVs
% 
% 'finalOffsetsDF' - matrix of all DF/F at offset traces for all FOVs
% 
% 'finalOffsetsBeh' - matrix of all velocity at offset traces for all FOVs
% 
% 'numOnsets' - array of number of onsets for each FOV
% 
% 'meanBaseline' - the mean baseline for the raw FP trace
% 
% 'minMax' - the mean fluorescence before and after onset (columns) for
% each FOV (rows)
% 
% 'names' - the mouse names for each FOV being analyzed
% 
% Author: Jeffrey March, 2018

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
minMax = zeros(length(trials),2);
names = {};

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
    
    % Take the mean of data points 0-3 seconds before onset, and 1-4
    % seconds after onset. Call the former the "min" call the latter the
    % "max" for normalization purposes
    meanTrace = mean(roi.onsetsMatrixDF,1);
    minMax(trial,:) = [mean(meanTrace(1:round((3/8)*length(meanTrace)))),mean(meanTrace(round((5/8)*length(meanTrace)):end))];
    names{trial} = trials{trial}(1:4);

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

