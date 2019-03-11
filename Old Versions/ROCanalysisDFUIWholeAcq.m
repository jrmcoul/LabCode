[trials, pathname] = uigetfile('*.mat','MultiSelect','on');

if ~iscell(trials)
    tempTrials = trials;
    trials = cell(1);
    trials{1} = tempTrials;
end

cd(pathname)


totalFiles = 0;
TP = {[],[]};
FP = {[],[]};
velThresh = .004; % in m/s

for trial = 1:length(trials)
    
    roi = {};
    totalCells = zeros(1,2);
    totalBouts = 0;

    N = {[],[]};
    X = {[],[]};
    
    load(trials{trial});
    totalFiles = totalFiles + 1
    
    roi{1} = data.dF1;
    roi{2} = data.dF2;
    roiData = data;
    
    for cellType = 1:2;
        
        meanDF = [];
        meanDF = mean(roi{cellType}.dF,1);
        
        counter = 1;
        for thresh = 0:.001:1
            TP{cellType}(trial, counter) = sum(meanDF(data.vel >= velThresh) > thresh);
            FP{cellType}(trial, counter) = sum(meanDF(data.timeDF < velThresh) > thresh);
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
        areaUnder{cellType}(region) = integrateROC(coords) + .5;
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
ylim([0,1])