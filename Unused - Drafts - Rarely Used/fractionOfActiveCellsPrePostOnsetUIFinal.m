clear all;
[trials, path] = uigetfile('*.mat','MultiSelect','on');
cd(path)

for isOnset = true %[true, false]
    
totalFiles = 0;
warning('off')
% LOCS = {};
window = -4:.2:4;
spikeHist = {zeros(length(trials),length(window)-1),zeros(length(trials),length(window)-1)};

MINW = 4;
noiseThresh = 0.4;
stdAway = 5;

roi = {};
totalCells = zeros(1,2);
totalBouts = 0;

for trial = 1:length(trials)
    load(trials{trial});
    totalFiles = totalFiles + 1
    
    LOCS{1} = [];
    LOCS{2} = [];
    
    roi{1} = data.dF1;
    roi{2} = data.dF2;
    roiData = data;
    
    totalBouts = totalBouts + length(roiData.indOnsets); %number of bouts
    totalCells(1) = totalCells(1) + length(roiData.indOnsets)*size(roi{1},1); %number of d1 cells*bouts
    totalCells(2) = totalCells(2) + length(roiData.indOnsets)*size(roi{2},1); %number of d2 cells*bouts
    
    for cellType = 1:2;
        
        roi2 = zeros(size(roi{cellType}.dF));
        % Z-scoring Cells
        for nCell = 1:size(roi{cellType}.dF,1)
            roi2(nCell,:) = smooth(roi{cellType}.dF(nCell,:),5)';
        end
        
        timeBefore = ceil(4*roiData.framerate);
        timeAfter = timeBefore;
        onsetMat = [];
        
        if isOnset
            onsets = roiData.indOnsets;
        else
            onsets = roiData.indOffsets;
        end
        
        onsetSpikeHist = zeros(length(onsets),length(window)-1);
        for onset = 1:length(onsets)          
            onsetMat = roi2(:,onsets(onset)-timeBefore:onsets(onset)+timeAfter);
            cellSpikeHist = zeros(size(onsetMat,1),length(window)-1);
            for nCell = 1:size(onsetMat,1)
                MPP = mean(roi2(nCell,roi2(nCell,:) < noiseThresh)) + stdAway*std(roi2(nCell,roi2(nCell,:) < noiseThresh));
                MPH = MPP;
                [tempPKS, tempLOCS] = findpeaks(onsetMat(nCell,:),'MinPeakProminence', MPP, 'MinPeakHeight', MPH, 'MinPeakWidth', MINW);
                tempLOCS = (tempLOCS - timeBefore)/roiData.framerate;
                cellSpikeHist(nCell,:) = histcounts(tempLOCS,window) > 0;
            end
            onsetSpikeHist(onset,:) = sum(cellSpikeHist,1)/roi{cellType}.totalSPNs;
        end      
        spikeHist{cellType}(trial,:) = mean(onsetSpikeHist,1);
        
        preMat(:,cellType) = nanmean(spikeHist{cellType}(:,(window >= -3.5 & window < -0.5)),2);
        postMat(:,cellType) = nanmean(spikeHist{cellType}(:,(window > 1 & window <= 3)),2);
        ratioPrePost(:,cellType) = preMat(:,cellType)./postMat(:,cellType);
        
    end
end

temp = cat(2,preMat,postMat,ratioPrePost);

%%
figure;
hold on
smoothing = 5;
for cellType = 1:2
%     window = 0:.005:.25;
    if cellType == 1
        shadedErrorBar(window(1:size(spikeHist{cellType},2)), smooth(nanmean(spikeHist{cellType},1),smoothing)', smooth(nanstd(spikeHist{cellType},1)/sqrt(size(spikeHist{cellType},1)),smoothing)','r',1);
    else
        shadedErrorBar(window(1:size(spikeHist{cellType},2)), smooth(nanmean(spikeHist{cellType},1),smoothing)', smooth(nanstd(spikeHist{cellType},1)/sqrt(size(spikeHist{cellType},1)),smoothing)','g',1);
    end
    
%     if cellType == 1
%         plot(window(1:size(spikePerFrame{cellType},2)), smooth(nanmean(spikePerFrame{cellType},1),5)','r')
%     else
%         plot(window(1:size(spikePerFrame{cellType},2)), smooth(nanmean(spikePerFrame{cellType},1),5)','g')
%     end
    title('Fraction of Total SPNs Active At Onset');
    xlabel('Time (s)');
    ylabel('Fraction');
    ylim([0,.006]);
    
    
end
% [N,X] = hist(LOCS{2},window);
% hold on
% plot(X(1:length(N)),smooth(N/totalCells(2),5)','Color',[0,0.8,0])
% title('Spike Probability Distribution (Norm to # of Cells)');
% xlabel('Time After Onset (s)')
% ylabel('Spike Probability in Frame')
% legend('D1','D2','Location','NorthWest')

end
