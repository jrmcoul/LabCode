

MPP = 4;
MPH = 3;
MINW = 6;
roi = {};

    
roi{1} = data.dF1;
roi{2} = data.dF2;

LOCS = {};
framerate = data.framerate;

for cellType = 1:2;
    
    roi2 = zeros(size(roi{cellType}.dF));
    % Z-scoring Cells
    for cellNum = 1:size(roi{cellType}.dF,1)
        roi2(cellNum,:) = zscore(roi{cellType}.dF(cellNum,:));
    end               

    if cellType == 1
        numD1 = size(roi2,1);
    end
    
    for cellNum = 1:size(roi2,1)
        warning('OFF');
        [PKS, LOCS{cellNum + numD1*(cellType - 1)}] = findpeaks(roi2(cellNum,:),'MinPeakProminence', MPP, 'MinPeakHeight', MPH, 'MinPeakWidth', MINW);
    end 
    
end

%% Comparing peaks between cells

cellEnsemb = cell(length(LOCS));

counter = 1;

for cellNum = 1:length(LOCS)
    for cellComp = 1:length(LOCS)
        
        % Comparing peaks of each OTHER cell      
        if cellComp ~= cellNum        
            for peak = 1:length(LOCS{cellNum})
                tempDiffs = LOCS{cellComp} - LOCS{cellNum}(peak);                
                cellEnsemb{cellNum, cellComp} = cat(2,cellEnsemb{cellNum, cellComp},tempDiffs(find(tempDiffs < framerate & tempDiffs > -framerate)));
            end
        end
        
    end
    counter = counter + 1;
    if cellNum == numD1
        counter = 1;
    end
end

%%
maxCorr = 0;
maxCorrPair = [0,0];
maxCorrMat = zeros(size(cellEnsemb));
maxCorrMatVal = zeros(size(cellEnsemb));
for cellNum = 1:length(cellEnsemb)
    for cellComp = 1:length(cellEnsemb)       
        peakLocs = cellEnsemb{cellNum, cellComp};
        dupRemoved = [];
        numPeaks = [];
        index = 1;
        while ~isempty(peakLocs)
            dupRemoved(index) = peakLocs(1);
            numPeaks(index) = length(find(peakLocs == peakLocs(1)));
            peakLocs = peakLocs(find(peakLocs ~= peakLocs(1)));
            index = index + 1;
        end
        corrs = numPeaks/length(LOCS{cellNum});
        if ~isempty(corrs)
            maxCorrMat(cellNum, cellComp) = max(corrs);
            maxCorrMatVal(cellNum, cellComp) = dupRemoved(min(find(numPeaks == max(numPeaks))));
        else
            maxCorrMat(cellNum, cellComp) = 0;
            maxCorrMatVal(cellNum, cellComp) = nan;
        end
        tempMaxCorr = max(corrs);
        if isempty(tempMaxCorr)
            tempMaxCorr = 0;
        end
        
        if tempMaxCorr > maxCorr && (length(LOCS{cellNum}) > 10)
            maxCorr = tempMaxCorr;
            maxCorrPair = [cellNum,cellComp];
        end
        % figure;
        % plot(dupRemoved, numPeaks/length(LOCS{cellNum}),'x');
    end
end
%%

stdMat = zeros(size(cellEnsemb));
for row = 1:size(cellEnsemb,1)
    for col = 1:size(cellEnsemb,2)
        if length(cellEnsemb{row,col}) < 5
            stdMat(row,col) = nan;
        else
            stdMat(row,col) = std(cellEnsemb{row,col});
        end
    end
end

%% Plotting

counter = 1;
figure;
hold on
for row = 1:size(cellEnsemb,1)
    for col = (row + 1):size(cellEnsemb,2)
        if row <= numD1 && col <= numD1
        plot(cellEnsemb{row,col}, counter*ones(length(cellEnsemb{row,col})), 'rx');
        else if (row <= numD1 && col > numD1) || (row > numD1 && col <= numD1)
                plot(cellEnsemb{row,col}, counter*ones(length(cellEnsemb{row,col})), 'bx');            
            else if row > numD1 && col > numD1
                    plot(cellEnsemb{row,col}, counter*ones(length(cellEnsemb{row,col})), 'gx');                  
                end
            end
        end
        counter = counter + 1;
    end
end