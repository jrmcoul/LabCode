function [peaksPerSecond, numPeaksMatrix, numFramesMatrix] = countPeaks(signal, onsets, offsets, timeLag, framerate, MPH, MINW)
% This function will count the peaks in a 


%   Detailed explanation goes here
    numCells = size(signal,1);
    numBouts = length(onsets);
    numPeaksMatrix = zeros(numCells,numBouts); %initializing
    numFramesMatrix = zeros(numCells,numBouts); %initializing
    frameLag = round(timeLag*framerate);
    
    for cell = 1:numCells
        % search the signal for each bout. one second after onset to one second
        % before offset.
        for bout = 1:numBouts
            % find peaks in that range, put total peaks in numPeaksMatrix with the
            % index corresponding to (cell#, bout#)
            [PKS, LOCS] = findpeaks(signal(cell, onsets(bout) + frameLag:offsets(bout) - frameLag), ...
                'MinPeakHeight', MPH, 'MinPeakWidth', MINW);
            numPeaksMatrix(cell,bout) = length(PKS); % number of peaks in a given bout
            numFramesMatrix(cell,bout) = (offsets(bout)-frameLag) - (onsets(bout) + frameLag); % number of frames in a given bout
        end
    end
    peaksPerFrame = sum(sum(numPeaksMatrix))/sum(sum(numFramesMatrix));
    peaksPerSecond = framerate*peaksPerFrame;
end

