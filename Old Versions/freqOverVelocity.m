clear all;
[trials, path] = uigetfile('*.mat','MultiSelect','on');
cd(path)

totalFiles = 0;
velDistrib = {};
VELS = {};
MPP = 4;
MPH = 3;
MINW = 6;
roi = {};
spikePerFrame = {};

for trial = 1:length(trials);
    load(trials{trial});
    totalFiles = totalFiles + 1
     
    roi{1} = data.dF1.dF;
    roi{2} = data.dF2.dF;
    roiData = data;
    
    for cellType = 1:2;
        
        velDistrib{1} = [];
        velDistrib{2} = [];
        VELS{1} = [];
        VELS{2} = [];
        
        roi2 = zeros(size(roi{cellType}));
        % Z-scoring Cells
        for nCell = 1:size(roi{cellType},1)
            roi2(nCell,:) = zscore(roi{cellType}(nCell,:));
        end
        
        timeBefore = ceil(4*roiData.framerate);
        timeAfter = timeBefore;
        onsetMat = [];
        
        for nCell = 1:size(roi2,1)
            warning('OFF');
            [tempPKS, tempLOCS] = findpeaks(roi2(nCell,:),'MinPeakProminence', MPP, 'MinPeakHeight', MPH, 'MinPeakWidth', MINW);
            VELS{cellType} = cat(2,VELS{cellType},abs(data.vel(tempLOCS)));
            velDistrib{cellType} = cat(2,velDistrib{cellType},abs(data.vel));
        end
        
        window = 0:.005:.1;
%         window = [0:.001:.004, .006:.002:.01, .02:.01:.25];
        [velHist{cellType}(trial,:),velHistBins] = histcounts(velDistrib{cellType},window);
        [spikeHist{cellType}(trial,:),spikeHistBins] = histcounts(VELS{cellType},window);
    end
    
end

for cellType = 1:2
    velHist{cellType}(velHist{cellType} < 100) = nan; 
    spikePerFrame{cellType} = spikeHist{cellType}./velHist{cellType};  
end

%%



figure;
hold on
for cellType = 1:2
%     window = 0:.005:.25;
    if cellType == 1
        shadedErrorBar(window(1:size(spikePerFrame{cellType},2)), smooth(nanmean(spikePerFrame{cellType},1),5)', smooth(nanstd(spikePerFrame{cellType},1)/sqrt(size(spikePerFrame{cellType},1)),5)','r',1);
    else
        shadedErrorBar(window(1:size(spikePerFrame{cellType},2)), smooth(nanmean(spikePerFrame{cellType},1),5)', smooth(nanstd(spikePerFrame{cellType},1)/sqrt(size(spikePerFrame{cellType},1)),5)','g',1);
    end
    title('Ca2+ Event Probability Over Velocity');
    xlabel('Speed (m/s)');
    ylabel('Probability');
    ylim([0,.004]);
end
% [N,X] = hist(LOCS{2},window);
% hold on
% plot(X(1:length(N)),smooth(N/totalCells(2),5)','Color',[0,0.8,0])
% title('Spike Probability Distribution (Norm to # of Cells)');
% xlabel('Time After Onset (s)')
% ylabel('Spike Probability in Frame')
% legend('D1','D2','Location','NorthWest')
