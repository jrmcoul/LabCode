clear all;
[trials, path] = uigetfile('*.mat','MultiSelect','on');
cd(path)

if ~iscell(trials)
    tempTrials = trials;
    trials = cell(1);
    trials{1} = tempTrials;
end

totalFiles = 0;
binSize = 0.2;


MINW = 4;
noiseThresh = 0.4;
stdAway = 5;
velWindow = 0:.01:.25;
ampOverVel = {zeros(length(trials),length(velWindow)-1),zeros(length(trials),length(velWindow)-1)};
roi = {};

for trial = 1:length(trials)
    load(trials{trial});
    totalFiles = totalFiles + 1
    
    window = round(0:binSize*data.framerate:length(data.behFrame)); % 200ms
    binnedVel = zeros(1,length(window) - 1); 
    for bin = 1:length(window) - 1
        binnedVel(:,bin) = mean(abs(data.vel(:,window(bin) + 1:window(bin + 1))),2);
    end
       
    LOCS{1} = [];
    LOCS{2} = [];
    
    roi{1} = data.dF1;
    roi{2} = data.dF2;
    roiData = data;
    
    for cellType = 1:2;
        
        roi2 = zeros(size(roi{cellType}.dF));   
        % Z-scoring Cells
        for nCell = 1:size(roi{cellType}.dF,1)
            roi2(nCell,:) = smooth(roi{cellType}.dF(nCell,:),5)';
        end
                                   
        cellSpikeAmp = zeros(size(roi2,1),length(window)-1);
        spikeHist = zeros(1,length(window)-1); %cell(length(trials),2);
        for nCell = 1:size(roi2,1)
            MPP = mean(roi2(nCell,roi2(nCell,:) < noiseThresh)) + stdAway*std(roi2(nCell,roi2(nCell,:) < noiseThresh));
            MPH = MPP;
            [tempPKS, tempLOCS] = findpeaks(roi2(nCell,:),'MinPeakProminence', MPP, 'MinPeakHeight', MPH, 'MinPeakWidth', MINW);
            
            for bin = 1:length(window)-1
                cellSpikeAmp(nCell,bin) = mean(tempPKS(tempLOCS >= window(bin) & tempLOCS < window(bin+1)));
            end
            
        end
        
        for velBin = 1:length(velWindow)-1
            ampOverVel{cellType}(trial,velBin) = nanmean(cellSpikeAmp(binnedVel >= velWindow(velBin) & binnedVel < velWindow(velBin + 1)));
        end
       
    end
end

% figure;
% plot(window(2:end)/data.framerate,spikeHist{1,1});
% hold on;
% plot(window(2:end)/data.framerate,binnedVel)

%%
figure;
hold on
smoothing = 5; %was 5
for cellType = 1:2
%     window = 0:.005:.25;
    if cellType == 1
        shadedErrorBar(velWindow(1:size(ampOverVel{cellType},2)), smooth(nanmean(ampOverVel{cellType},1),smoothing)', smooth(nanstd(ampOverVel{cellType},1)./sqrt(sum(~isnan(ampOverVel{cellType}),1)),smoothing)','r',1);
    else
        shadedErrorBar(velWindow(1:size(ampOverVel{cellType},2)), smooth(nanmean(ampOverVel{cellType},1),smoothing)', smooth(nanstd(ampOverVel{cellType},1)./sqrt(sum(~isnan(ampOverVel{cellType}),1)),smoothing)','g',1);
    end
    
%     if cellType == 1
%         plot(window(1:size(spikePerFrame{cellType},2)), smooth(nanmean(spikePerFrame{cellType},1),5)','r')
%     else
%         plot(window(1:size(spikePerFrame{cellType},2)), smooth(nanmean(spikePerFrame{cellType},1),5)','g')
%     end
    title('Fraction of Total SPNs Active Over Velocity');
    xlabel('Velocity (m/s)');
    ylabel('Fraction');
%     ylim([0,.006]);
end
% [N,X] = hist(LOCS{2},window);
% hold on
% plot(X(1:length(N)),smooth(N/totalCells(2),5)','Color',[0,0.8,0])
% title('Spike Probability Distribution (Norm to # of Cells)');
% xlabel('Time After Onset (s)')
% ylabel('Spike Probability in Frame')
% legend('D1','D2','Location','NorthWest')

