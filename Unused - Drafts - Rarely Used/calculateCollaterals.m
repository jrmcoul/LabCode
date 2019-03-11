%% Calculating distance between ROIs

temp = data.dF1;
temp = data.dF2;
temp = data.dF3;

centroids = zeros(length(temp.roiList),2);
for i = 1:length(temp.roiList)
    original = temp.roiList(i).indBody;
    coordinates = [mod(original-1,512)+1, ceil(original/512)];
    centroids(i,:) = mean(coordinates,1);
end
temp.centroids = centroids;

data.dF1 = temp;
data.dF2 = temp;
data.dF3 = temp;

distmatrix = dist([data.dF1.centroids,data.dF2.centroids,data.dF3.centroids]');

% data.distMat =
% figure; plot(coordinates(:,1),coordinates(:,2),'x', centroids(4,1),centroids(4,2),'r^')

%% Finding Peaks + Calculating Prob. of Cell #2 Peaking After Cell #1

roi = data.normDF2.dF;
MPH = 0.4; % minimum peak height in fraction of tallest peak
MINW = 6; % minimum peak width in frames
numCells = size(roi,1);
PKS = {};
LOCS = {};
timeAfter = .09*data.framerate; % threshold for measuring spike probabilities
cellList = 1:numCells;

for cell = cellList
    [PKS{cell}, LOCS{cell}] = findpeaks(roi(cell,:), 'MinPeakHeight', MPH, 'MinPeakWidth', MINW);
end

probMatrix = zeros(numCells);
for presynaptic = cellList
    for postsynaptic = cellList
        spikeCount = 0;
        totalCount = 0;
        for peak = 1:length(LOCS{presynaptic})
            if sum(((LOCS{postsynaptic} - LOCS{presynaptic}(peak)) < timeAfter) & ((LOCS{postsynaptic} - LOCS{presynaptic}(peak)) > 0)) > 0;
                spikeCount = spikeCount + 1;
            end
            totalCount = totalCount + 1;
        end
        probMatrix(presynaptic,postsynaptic) = spikeCount/totalCount;
    end
end

% Looking at locations of all peaks relative to each peak
tempList = [];
for presynaptic = cellList
    for postsynaptic = cellList(cellList~=presynaptic)
        for peak = 1:length(LOCS{presynaptic})
            offsets = LOCS{postsynaptic} - LOCS{presynaptic}(peak);
            tempList = cat(2,tempList,offsets);
        end
    end
end
tempList = tempList;
figure;
hist(tempList,[-10:10])
xlim([-9,9])

% figure;
% for cell = 2:numCells
%     for peak = 1:length(LOCS{1})
%         plot(roi(cell,LOCS{1}(peak):LOCS{1}(peak)+ round(timeAfter)));
%     end
%     hold on
% end
% hold off
% 
% for cell = 1:4
%     figure;
%     plot(data.normDF1.dF(cell,:))
% end

%% Cross-correlation

roi = data.normDF2.dF;
MPH = 0.4; % minimum peak height in fraction of tallest peak
MINW = 6; % minimum peak width in frames
numCells = size(roi,1);
PKS = {};
LOCS = {};
timeAfter = .09*data.framerate; % threshold for measuring spike probabilities
cellList = 1:numCells;

binarizedData = zeros(size(roi));
for cell = cellList
    [PKS{cell}, LOCS{cell}] = findpeaks(roi(cell,:), 'MinPeakHeight', MPH, 'MinPeakWidth', MINW);
    for index = 1:length(LOCS{cell});
        binarizedData(cell,LOCS{cell}(index)) = 1;
    end
end

roi = binarizedData;
lagLimit = round(data.framerate);

corrMat = zeros(numCells,numCells-1,2*lagLimit+1);
lagMat = zeros(numCells,numCells-1,2*lagLimit+1);

for presynaptic = cellList
    postInd = 1;
    for postsynaptic = cellList(cellList ~= presynaptic)
        [r, lags] = xcorr(roi(presynaptic,:),roi(postsynaptic,:),lagLimit,'coeff');
        corrMat(presynaptic,postInd,:) = r(1,:);
        lagMat(presynaptic,postInd,:) = lags(1,:);
        postInd = postInd + 1;
    end
end

meanCorr = zeros(1,2*lagLimit+1);
meanLag = zeros(1,2*lagLimit+1);
meanCorr(1,:) = mean(mean(corrMat,1),2);
meanLag(1,:) = mean(mean(lagMat,1),2);

figure;
plot(meanLag,meanCorr);

%% Binarized Cross-correlation

roi = data.normDF2.dF;
numCells = size(roi,1);
cellList = 1:numCells;
lagLimit = round(.5*data.framerate);

corrMat = zeros(numCells^2 - numCells,2*lagLimit+1);
lagMat = zeros(numCells^2 - numCells,2*lagLimit+1);

roi = binarizedData;

ind = 1;
for presynaptic = cellList
    for postsynaptic = cellList(cellList ~= presynaptic)
        [r, lags] = xcorr(roi(presynaptic,:),roi(postsynaptic,:),lagLimit,'coeff');
%         subplot(numCells,numCells, numCells*(presynaptic-1)+postsynaptic);
%         plot(lags,r)
        corrMat(ind,:) = r(1,:);
        lagMat(ind,:) = lags(1,:);
        ind = ind + 1;
    end
end
figure;
surf(corrMat);
% meanCorr = zeros(1,2*lagLimit+1);
% meanLag = zeros(1,2*lagLimit+1);
% meanCorr(1,:) = mean(mean(corrMat,1),2);
% meanLag(1,:) = mean(mean(lagMat,1),2);
% 
% figure;
% plot(meanLag,meanCorr);
% 




