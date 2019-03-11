clear all;
[trials, path] = uigetfile('*.mat','MultiSelect','on');
cd(path)

isOnset = true;
totalFiles = 0;
LOCS = {};
timeHist = {[],[]};
spikeHist = {[],[]};
spikePerFrame = {[],[]};
MPP = 4;
MPH = 3;
MINW = 6;
roi = {};
totalCells = zeros(1,2);
totalBouts = 0;

for trial = 1:length(trials)
    load(trials{trial});
    totalFiles = totalFiles + 1
    
    LOCS{1} = [];
    LOCS{2} = [];
    
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
            roi2(nCell,:) = zscore(roi{cellType}(nCell,:));
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
            [tempPKS, tempLOCS] = findpeaks(onsetMat(nCell,:),'MinPeakProminence', MPP, 'MinPeakHeight', MPH, 'MinPeakWidth', MINW);
            LOCS{cellType} = cat(2,LOCS{cellType},(tempLOCS - timeBefore)/roiData.framerate);
        end
        
        window = -4:.2:4;
        [timeHist{cellType}(trial,:),velHistBins] = histcounts(data.timeDF,window);
        [spikeHist{cellType}(trial,:),spikeHistBins] = histcounts(LOCS{cellType},window);
        timeHist{cellType}(trial,:) = size(onsetMat,1)*timeHist{cellType}(trial,:);
        
    end


end

for cellType = 1:2
    timeHist{cellType}(timeHist{cellType} == 0) = nan; 
    spikePerFrame{cellType} = spikeHist{cellType}./timeHist{cellType};  
end

%%
figure;
hold on
smoothing = 5;
for cellType = 1:2
%     window = 0:.005:.25;
    if cellType == 1
        shadedErrorBar(window(1:size(spikePerFrame{cellType},2)), smooth(nanmean(spikePerFrame{cellType},1),smoothing)', smooth(nanstd(spikePerFrame{cellType},1)/sqrt(size(spikePerFrame{cellType},1)),smoothing)','r',1);
    else
        shadedErrorBar(window(1:size(spikePerFrame{cellType},2)), smooth(nanmean(spikePerFrame{cellType},1),smoothing)', smooth(nanstd(spikePerFrame{cellType},1)/sqrt(size(spikePerFrame{cellType},1)),smoothing)','g',1);
    end
    
%     if cellType == 1
%         plot(window(1:size(spikePerFrame{cellType},2)), smooth(nanmean(spikePerFrame{cellType},1),5)','r')
%     else
%         plot(window(1:size(spikePerFrame{cellType},2)), smooth(nanmean(spikePerFrame{cellType},1),5)','g')
%     end
    title('Ca2+ Event Probability At Onset');
    xlabel('Time (s)');
    ylabel('Probability');
    ylim([0,.0035]);
end
% [N,X] = hist(LOCS{2},window);
% hold on
% plot(X(1:length(N)),smooth(N/totalCells(2),5)','Color',[0,0.8,0])
% title('Spike Probability Distribution (Norm to # of Cells)');
% xlabel('Time After Onset (s)')
% ylabel('Spike Probability in Frame')
% legend('D1','D2','Location','NorthWest')


