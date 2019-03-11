[trials, pathname] = uigetfile('*.mat','MultiSelect','on');

if ~iscell(trials)
    tempTrials = trials;
    trials = cell(1);
    trials{1} = tempTrials;
end

cd(pathname)


totalFiles = 0;
TP = [];
FP = [];
velThresh = .004; % in m/s

for trial = 1:length(trials)
    
    roi = {};
    totalCells = zeros(1,2);
    totalBouts = 0;
    
    load(trials{trial});
    totalFiles = totalFiles + 1
    
    roiData = data;
           
    meanDF = mean(cat(1,data.dF1.dF,data.dF2.dF),1);

    counter = 1;
    for thresh = 0:.001:1
        TP(trial, counter) = sum(meanDF(data.vel >= velThresh) > thresh);
        FP(trial, counter) = sum(meanDF(data.timeDF < velThresh) > thresh);
        counter = counter + 1;
    end
end

figure();
hold on;
for trial = 1:length(trials)
        plot(FP(trial,:)/FP(trial,1),TP(trial,:)/TP(trial,1),'o-','Color',[0.8,0.8,0]);
end
plot(0:.1:1,0:.1:1,'k:')


%%

figure;
hold on
for trial = 1:length(trials)
    fpData(trial,:) = FP(trial,:)/FP(trial,1);
    tpData(trial,:) = TP(trial,:)/TP(trial,1);
end
fpData(isnan(fpData)) = 0;
tpData(isnan(tpData)) = 0;


k = lsqcurvefit(@logistic,3,fpData,tpData)
x = 0:.01:1;
fitLine = logistic(k, x);
plot(x,fitLine,'Color',[0.8,0.8,0]);
plot(x,x,'k:')

%%
areaUnder = [];
for region = 1:size(FP,1)
    if FP(region,1) == 0 && TP(region,1) ~= 0
        areaUnder(region) = .5;
        continue
    end
    if FP(region,1) ~= 0 && TP(region,1) == 0
        areaUnder(region) = .5;
        continue
    end
    if FP(region,1) == 0 && TP(region,1) == 0
        areaUnder(region) = nan;
        continue
    end

    coords = [];
    counter = 1;
    for thresh = 1:size(FP,2)
        if counter == 1
            coords(counter,:) = [FP(region,thresh)/FP(region,1), TP(region,thresh)/TP(region,1)];
        else if sum([FP(region,thresh)/FP(region,1), TP(region,thresh)/TP(region,1)] - coords(counter - 1,:)) == 0
                continue
            else
                coords(counter,:) = [FP(region,thresh)/FP(region,1), TP(region,thresh)/TP(region,1)];
            end
        end
        counter = counter + 1;
    end
    coords = flipud(coords);
    areaUnder(region) = integrateROC(coords) + .5;
end

%%
figure;
plot(ones(size(areaUnder)),areaUnder,'kx');
hold on;
plot(1,nanmean(areaUnder),'rx');
errorbar(1,nanmean(areaUnder),nanstd(areaUnder),'.r');
ylim([0,1])