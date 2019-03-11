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
% edges = [0.07, 0.12, 0.17, 0.22];
warning('off');
freqVelBins = cell(1,2);


for trial = 1:length(trials);
	load(trials{trial});                               
	totalFiles = totalFiles + 1

    % Sorting velocity into bins    
    [n, edges] = histcounts(data.vel,20);
    timeDist = n/data.framerate;
    timeDist(find(timeDist < 4)) = nan;
                                
    roi{1} = data.dF1;
    roi{2} = data.dF2;

%     percActive = cell(1,2);
    framerate = data.framerate;

    for cellType = 1:2;
        
        freqVelBins{cellType} = zeros(size(roi{cellType}.dF,1),length(timeDist));

        roi2 = zeros(size(roi{cellType}.dF));
        % Z-scoring Cells
        for cellNum = 1:size(roi{cellType}.dF,1)
            roi2(cellNum,:) = zscore(roi{cellType}.dF(cellNum,:));
        end               

        for cellNum = 1:size(roi2,1)
            warning('OFF');
            peakTotal = zeros(1, length(edges) - 1);
            [PKS, LOCS] = findpeaks(roi2(cellNum,:),'MinPeakProminence', MPP, 'MinPeakHeight', MPH, 'MinPeakWidth', MINW);

            for peak = 1:length(LOCS)
                for bin = 1:length(edges) - 1
                    binTimePoints = data.vel > edges(bin) & data.vel < edges(bin + 1);
                    if binTimePoints(LOCS(peak))
                        peakTotal(bin) = peakTotal(bin) + 1;
                        break
                    end
                end
            end
            
            freqVelBins{cellType}(cellNum,:) = peakTotal./timeDist;            
        end 

        roi{cellType}.freqVelBins = freqVelBins{cellType};
%         percActive{cellType} = sum((freqVelBins{cellType} ~= 0 & ~isnan(freqVelBins{cellType}))/size(freqVelBins{cellType},1),1);
        
        figure(cellType);
        hold on
        plot(edges(1:end-1),mean(roi{cellType}.freqVelBins,1),'x-');
    end
    
end

% figure;
% plot(edges(1:end-1),timeDist)
% 
% cellType = 2;
% figure;
% for i = 1:size(roi{cellType}.freqVelBins,1)
%     plot(edges(1:end-1),roi{cellType}.freqVelBins(i,:));
%     hold on
% end
% 
% figure;
% plot(edges(1:end-1),mean(roi{cellType}.freqVelBins,1));