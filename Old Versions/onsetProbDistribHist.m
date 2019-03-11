% function [LOCS, totalCells, totalBouts] = getOnsetProbDistribUI(trials,isOnset)

totalFiles = 0;
LOCS = {};
MPP = 4;
MPH = 3;
MINW = 6;
LOCS{1} = [];
LOCS{2} = [];
roi = {};
totalCells = zeros(1,2);
totalBouts = 0;
    
    roi{1} = data.dF1.dF;
    roi{2} = data.dF2.dF;
    roiData = data;
    
    totalBouts = totalBouts + length(roiData.indOnsets); %number of bouts
    totalCells(1) = totalCells(1) + length(roiData.indOnsets)*size(roi{1},1); %number of d1 cells*bouts
    totalCells(2) = totalCells(2) + length(roiData.indOnsets)*size(roi{2},1); %number of d2 cells*bouts
    
    for cellType = 1:2;
        
        roi2 = zeros(size(roi{cellType}));
        % Z-scoring Cells
        for cell = 1:size(roi{cellType},1)
            roi2(cell,:) = zscore(roi{cellType}(cell,:));
        end
        
        timeBefore = ceil(4*roiData.framerate);
        timeAfter = timeBefore;
        onsetMat = [];
        
        for cell = 1:size(roi2,1)
            warning('OFF');
            [tempPKS, tempLOCS] = findpeaks(roi2(cell,:),'MinPeakProminence', MPP, 'MinPeakHeight', MPH, 'MinPeakWidth', MINW);
            LOCS{cellType} = cat(2,LOCS{cellType},(tempLOCS - timeBefore)/roiData.framerate);
        end
        
    end

% end

window = [0:600];
[N,X] = histcounts(LOCS{1},window);
figure();
plot(X(1:length(N)),N/size(roi{1},1),'Color',[0.8,0,0])
[N,X] = hist(LOCS{2},window);

hold on
plot(X(1:length(N)),N/size(roi{2},1),'Color',[0,0.8,0])
title('Spike Probability Distribution (Norm to # of Cells)');
xlabel('Time After Onset (s)')
ylabel('Spike Probability in Frame')
legend('D1','D2','Location','NorthWest')

windowVel = zeros(1,length(window) - 1);
for i = 1:length(window) - 1
    windowVel(i) = mean(abs(data.vel(data.frameTime > window(i) & data.frameTime <= window(i + 1))));
end
plot(windowVel,'k')
