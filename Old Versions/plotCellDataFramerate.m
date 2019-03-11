function [normalizedData, resampledWheelData] = plotCellDataFramerate(wheelData, cellData, numD1, framerate, cellType, varargin)

%% Getting Wheel Data

baselineAdjust = median(cellData(1:800,:));
normalizedData = 500*(cellData - repmat(baselineAdjust, size(cellData)./size(baselineAdjust)));

minPeakHeight = 3;
samplingRate = length(cellData)/length(wheelData);
frameNumber = samplingRate:samplingRate:length(cellData);

%% Plotting All Data
if strcmp(varargin, 'matrix') % In matrix form

    resampledWheelData = 300*resample(wheelData,length(normalizedData),length(wheelData));    
    cellPlusWheel = [normalizedData'; ...
        interp1(1:length(resampledWheelData), resampledWheelData, 1:length(normalizedData))];

    figure()
    imagesc(cellPlusWheel)
    title([cellType, ' Spiking Over Time']);
    ylabel('Cell #');
    xlabel('Frame #');

elseif strcmp(varargin, 'line') % In a stack of line graphs
    
    figure()
    increment = 2000;
    hold on
%     axis off
    title([cellType, ' Spiking Over Time'])
    xlabel('Time (s)')
    offset = -increment;
        period = 1/framerate;
        movieRate = period:period:period*length(normalizedData);
        wheelRate = period:period:period*length(wheelData);
        length(period);
        length(wheelData);
      plot(wheelRate, 5000*(wheelData) + offset)
      offset = offset + increment;
        for cell = 1:length(cellData(1,:))
            if cell <= numD1
                h = plot(movieRate, normalizedData(:,cell) + offset, 'r');
                set(h,'Markersize',4)
            else
                h = plot(movieRate, normalizedData(:,cell) + offset, 'g');
                set(h,'Markersize',4)
            end
            offset = offset + increment;
        end
    hold off

elseif strcmp(varargin, 'average') % With D1 cells and NonD1 Cells Averaged     
    
    resampledWheelData = 300*resample(wheelData,length(normalizedData),length(wheelData));    
    resampledWheelData = interp1(1:length(resampledWheelData), resampledWheelData, 1:length(normalizedData));
    cellRunning = zeros(size(normalizedData));
    cellNotRunning = zeros(size(normalizedData));
    for i = 1:length(resampledWheelData)
        if resampledWheelData(i) > 150
            cellRunning(i,:) = normalizedData(i,:);
            cellNotRunning(i,:) = nan;
        else
            cellRunning(i,:) = nan;
            cellNotRunning(i,:) = normalizedData(i,:);
        end
    end
    
    figure()
    hold on
    axis off
    title([cellType, ' Spiking Over Time'])
    xlabel('Frame #')
    offset = -5000;
    plot(frameNumber, 3000*(wheelData > 2) + offset)
    offset = offset + 5000;
    for cell = 1:length(cellData(1,:))
        if cell <= numD1
            h = plot([1:length(normalizedData)], cellNotRunning(:,cell) + offset, '.r');
            set(h,'Markersize',4)
            h = plot([1:length(normalizedData)], cellRunning(:,cell) + offset, '.k');
            set(h,'Markersize',4)
        else
            h = plot([1:length(normalizedData)], cellNotRunning(:,cell) + offset, '.g');
            set(h,'Markersize',4)
            h = plot([1:length(normalizedData)], cellRunning(:,cell) + offset, '.k');
            set(h,'Markersize',4)
        end
        if cell == numD1
            offset = offset + 5000;
        end
    end
    hold off   
    
elseif strcmp(varargin, 'sum') % With D1 cells and NonD1 Cells Averaged     
    
    resampledWheelData = 300*resample(wheelData,length(normalizedData),length(wheelData));    
    resampledWheelData = interp1(1:length(resampledWheelData), resampledWheelData, 1:length(normalizedData));
    cellRunning = zeros(size(normalizedData));
    cellNotRunning = zeros(size(normalizedData));
    for i = 1:length(resampledWheelData)
        if resampledWheelData(i) > 150
            cellRunning(i,:) = normalizedData(i,:);
            cellNotRunning(i,:) = nan;
        else
            cellRunning(i,:) = nan;
            cellNotRunning(i,:) = normalizedData(i,:);
        end
    end
    
    figure()
    hold on
%     axis off
    title([cellType, ' Spiking Over Time'])
    xlabel('Frame #')
    offset = -5000;
    plot(frameNumber, 3000*(wheelData > 2) + offset)
    offset = offset + 5000;    
    sumRunning = zeros(size(normalizedData(:,1)));
    sumNotRunning = zeros(size(normalizedData(:,1)));
    for cell = 1:length(cellData(1,:))
        if cell <= numD1
            sumRunning = sumRunning + cellRunning(:,cell);
            sumNotRunning = sumNotRunning + cellNotRunning(:,cell);
        end
        if cell == numD1         
            h = plot([1:length(normalizedData)], sumNotRunning + offset, '.r');
            set(h,'Markersize',4)
            h = plot([1:length(normalizedData)], sumRunning + offset, '.k');
            set(h,'Markersize',4)
            offset = offset + 5000;
            sumRunning = zeros(size(normalizedData(:,1)));
            sumNotRunning = zeros(size(normalizedData(:,1)));
        end
        if cell > numD1
            sumRunning = sumRunning + cellRunning(:,cell);
            sumNotRunning = sumNotRunning + cellNotRunning(:,cell);
        end
        if cell == length(cellData(1,:)) && cell > numD1
            h = plot([1:length(normalizedData)], sumNotRunning + offset, '.g');
            set(h,'Markersize',4)
            h = plot([1:length(normalizedData)], sumRunning + offset, '.k');
            set(h,'Markersize',4)
        end
    end
    ylim([0 1])
    hold off    
end

end
