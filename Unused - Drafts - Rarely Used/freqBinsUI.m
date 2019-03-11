[trials, pathname] = uigetfile('*.mat','MultiSelect','on');

cd(pathname)

% Counting peaks in bins
totalFiles = 0;
MPP = 4;
MPH = 3;
MINW = 6;
roi = {};
numSpikesCell = {};
freqCell = {};
bins = [0.07, 0.12, 0.17, 0.22];
warning('off');
freqVelBins = cell(1,2);

for trial = 1:length(trials);
	load(trials{trial});                               
	totalFiles = totalFiles + 1

    % Sorting velocity into bins
                                
    roi{1} = data.dF1;
    roi{2} = data.dF2;

    LOCS = {};
    framerate = data.framerate;

    totTime = zeros(1, length(bins) - 1);
    for bin = 1:length(bins) - 1
        totTime(bin) = sum(data.vel > bins(bin) & data.vel < bins(bin + 1))/data.framerate;
    end
    totTime(find(totTime == 0)) = nan;

    for cellType = 1:2;
        
        freqVelBins{cellType} = zeros(size(roi{cellType}.dF,1),3);

        roi2 = zeros(size(roi{cellType}.dF));
        % Z-scoring Cells
        for cellNum = 1:size(roi{cellType}.dF,1)
            roi2(cellNum,:) = zscore(roi{cellType}.dF(cellNum,:));
        end               

        for cellNum = 1:size(roi2,1)
            warning('OFF');
            peakTotal = zeros(1, length(bins) - 1);
            [PKS, LOCS] = findpeaks(roi2(cellNum,:),'MinPeakProminence', MPP, 'MinPeakHeight', MPH, 'MinPeakWidth', MINW);

            for peak = 1:length(LOCS)
                for bin = 1:length(bins) - 1
                    binTimePoints = data.vel > bins(bin) & data.vel < bins(bin + 1);
                    if binTimePoints(LOCS(peak))
                        peakTotal(bin) = peakTotal(bin) + 1;
                    end
                end
            end
            
            freqVelBins{cellType}(cellNum,:) = peakTotal./totTime;            
        end 

        roi{cellType}.freqVelBins = freqVelBins{cellType};
    end
                    
end