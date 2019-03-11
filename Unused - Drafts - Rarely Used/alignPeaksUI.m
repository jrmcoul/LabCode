function [onsetsMatrix totalPeaks tempWindow] = alignPeaksUI(trials)

MPP = 4; % minimum peak prominence
MPH = 3; % minimum peak height
MINW = 6; % minimum peak width in frames
roi = {};
totalFiles = 0;
totalPeaks = {0,0};


timeBefore = 2*30; % Estimate of framerate = 30
timeAfter = 5*30; % Estimate of framerate = 30
onsetsMatrix = {zeros(1,timeBefore+timeAfter+1),zeros(1,timeBefore+timeAfter+1)};

% onsetsMatrix = {zeros(1,timeBefore + timeAfter + 1),zeros(1,timeBefore + timeAfter + 1)};

for trial = 1:length(trials)
    load(trials{trial});
    totalFiles = totalFiles + 1
                
    roi{1} = data.dF1.dF;
    roi{2} = data.dF2.dF;
    roiData = data;
                
    for cellType = 1:2;
        roi2 = zeros(size(roi{cellType}));
                % Z-scoring Cells
        for cell = 1:size(roi{cellType},1)
            roi2(cell,:) = zscore(roi{cellType}(cell,:));
        end %for cell
                
        for cell = 1:size(roi2,1)
            onsetThresh = 1;
            [PKS, LOCS] = findpeaks(roi2(cell,:), 'MinPeakProminence', MPP, 'MinPeakHeight', MPH, 'MinPeakWidth', MINW);
            PKS = roi{cellType}(cell,LOCS);
            if ~isempty(PKS)
                peakOnsets = iterToMin(roi2(cell,:),LOCS,onsetThresh,true);
                for onset = 1:length(peakOnsets)
                    if (peakOnsets(onset) > timeBefore) && peakOnsets(onset) < (size(roi{cellType},2) - timeAfter) && (LOCS(onset) - peakOnsets(onset) < 30)
                        tempWindow = roi{cellType}(cell,(peakOnsets(onset) - timeBefore):(peakOnsets(onset) + timeAfter));
                        onsetsMatrix{cellType} = onsetsMatrix{cellType} + tempWindow;
                        totalPeaks{cellType} = totalPeaks{cellType} + 1;
                    end %if
                end %for onset
            end %if
        end %for cell
                
                
    end %for cellType

end %for trial

for cellType = 1:2
    onsetsMatrix{cellType} = onsetsMatrix{cellType}/totalPeaks{cellType};
end

end %function