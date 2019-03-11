[trials, pathname] = uigetfile('*.mat','MultiSelect','on');

if ~iscell(trials)
    tempTrials = trials;
    trials = cell(1);
    trials{1} = tempTrials;
end

cd(pathname)


isOnset = true;
totalFiles = 0;
TP = {[],[]};
FP = {[],[]};

for trial = 1:length(trials)
    
    LOCS = {};
    MPP = 4;
    MPH = 3;
    MINW = 6;
    LOCS{1} = [];
    LOCS{2} = [];
    roi = {};
    totalCells = zeros(1,2);
    totalBouts = 0;

    N = {[],[]};
    X = {[],[]};
    
    load(trials{trial});
    totalFiles = totalFiles + 1
    
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
        
        if isOnset
            for onset = 1:length(roiData.indOnsets)
                onsetMat = cat(1,onsetMat,roi2(:,roiData.indOnsets(onset) - timeBefore:roiData.indOnsets(onset) + timeAfter));
            end
        else
            for onset = 1:length(roiData.indOnsets)
                onsetMat = cat(1,onsetMat,roi2(:,roiData.indOffsets(onset) - timeBefore:roiData.indOffsets(onset) + timeAfter));
            end
        end
        for cell = 1:size(onsetMat,1)
            warning('OFF');
            [tempPKS, tempLOCS] = findpeaks(onsetMat(cell,:),'MinPeakProminence', MPP, 'MinPeakHeight', MPH, 'MinPeakWidth', MINW);
            LOCS{cellType} = cat(2,LOCS{cellType},(tempLOCS - timeBefore)/roiData.framerate);
        end
        
        window = [-4:1/data.framerate:4];
        [N{cellType},X{cellType}] = histcounts(LOCS{cellType},window);
        N{cellType} = N{cellType}/totalCells(cellType);
        N{cellType} = smooth(N{cellType},15)';
        
        counter = 1;
        for thresh = 0:.0001:.01
            TP{cellType}(trial, counter) = sum(N{cellType}(X{cellType}(1:length(N{cellType})) >= 0 & X{cellType}(1:length(N{cellType})) < 2) > thresh);
            FP{cellType}(trial, counter) = sum(N{cellType}(X{cellType}(1:length(N{cellType})) < 0 & X{cellType}(1:length(N{cellType})) > -2) > thresh);
            counter = counter + 1;
        end
        
    end


end

figure();
hold on;
for cellType = 1:2
    for trial = 1:length(trials)
        if cellType == 1
            plot(FP{cellType}(trial,:)/FP{cellType}(trial,1),TP{cellType}(trial,:)/TP{cellType}(trial,1),'o-','Color',[0.8,0,0]);
        else
            plot(FP{cellType}(trial,:)/FP{cellType}(trial,1),TP{cellType}(trial,:)/TP{cellType}(trial,1),'^-','Color',[0,0.8,0])
        end
    end
end
plot(0:.1:1,0:.1:1,'k:')


%%
fpData = {[],[]};
tpData = {[],[]};
figure;
hold on
for cellType = 1:2
    for trial = 1:length(trials)
        fpData{cellType}(trial,:) = FP{cellType}(trial,:)/FP{cellType}(trial,1);
        tpData{cellType}(trial,:) = TP{cellType}(trial,:)/TP{cellType}(trial,1);
    end
    fpData{cellType}(isnan(fpData{cellType})) = 0;
    tpData{cellType}(isnan(tpData{cellType})) = 0;


    k = lsqcurvefit(@logistic,3,fpData{cellType},tpData{cellType})
    x = 0:.01:1;
    fitLine = logistic(k, x);
    if cellType == 1
        plot(x,fitLine,'Color',[0.8,0,0]);
    else
        plot(x,fitLine,'Color',[0,0.8,0])
    end
    plot(x,x,'k:')
end

%%
areaUnder = {[],[]};
for cellType = 1:2
    for region = 1:size(FP{cellType},1)
        if FP{cellType}(region,1) == 0 && TP{cellType}(region,1) ~= 0
            areaUnder{cellType}(region) = .5;
            continue
        end
        if FP{cellType}(region,1) ~= 0 && TP{cellType}(region,1) == 0
            areaUnder{cellType}(region) = .5;
            continue
        end
        if FP{cellType}(region,1) == 0 && TP{cellType}(region,1) == 0
            areaUnder{cellType}(region) = nan;
            continue
        end
        
        coords = [];
        counter = 1;
        for thresh = 1:size(FP{cellType},2)
            if counter == 1
                coords(counter,:) = [FP{cellType}(region,thresh)/FP{cellType}(region,1), TP{cellType}(region,thresh)/TP{cellType}(region,1)];
            else if sum([FP{cellType}(region,thresh)/FP{cellType}(region,1), TP{cellType}(region,thresh)/TP{cellType}(region,1)] - coords(counter - 1,:)) == 0
                    continue
                else
                    coords(counter,:) = [FP{cellType}(region,thresh)/FP{cellType}(region,1), TP{cellType}(region,thresh)/TP{cellType}(region,1)];
                end
            end
            counter = counter + 1;
        end
        coords = flipud(coords);
        areaUnder{cellType}(region) = integrateROC(coords);
    end
end

%%
figure;
plot(ones(size(areaUnder{1})),areaUnder{1},'kx');
hold on;
plot(2*ones(size(areaUnder{2})),areaUnder{2},'ko');
plot(1,nanmean(areaUnder{1}),'rx');
errorbar(1,nanmean(areaUnder{1}),nanstd(areaUnder{1}),'.r');
plot(2,nanmean(areaUnder{2}),'ro');
errorbar(2,nanmean(areaUnder{2}),nanstd(areaUnder{2}),'.r');
ylim([-.5,.5])