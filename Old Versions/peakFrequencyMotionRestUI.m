[trials] = uigetfile('*.mat','MultiSelect','on');

[LOCS, totalTimeCells, totalTime, freqCell] = getPeakFreqUI(trials);

% D1FreqPerCell = length(LOCS{1})/totalTimeCells(1);
% D2FreqPerCell = length(LOCS{2})/totalTimeCells(2);
% D1FreqPerPop = length(LOCS{1})/totalTime;
% D2FreqPerPop = length(LOCS{2})/totalTime;