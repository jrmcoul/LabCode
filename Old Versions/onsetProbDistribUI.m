[trials, pathname] = uigetfile('*.mat','MultiSelect','on');

if ~iscell(trials)
    tempTrials = trials;
    trials = cell(1);
    trials{1} = tempTrials;
end

cd(pathname)


isOnset = true; % For looking at Onsets
% isOnset = false; % For looking at Offsets

[LOCS, totalCells, totalBouts] = getOnsetProbDistribUIFINAL(trials,isOnset);
% [LOCS, totalCells, totalBouts] = getOnsetProbDistribUI(trials,isOnset);
% [LOCS, totalCells, totalBouts] = getOnToOffProbDistribUI(trials);

%% Histograms For Onset or Offset

window = [-4:1/data.framerate:4];
[N,X] = histcounts(LOCS{1},window);
figure();
plot(X(1:length(N)),smooth(N/totalCells(1),5)','Color',[0.8,0,0])

[N,X] = hist(LOCS{2},window);
hold on
plot(X(1:length(N)),smooth(N/totalCells(2),5)','Color',[0,0.8,0])
title('Spike Probability Distribution (Norm to # of Cells)');
xlabel('Time After Onset (s)')
ylabel('Spike Probability in Frame')
legend('D1','D2','Location','NorthWest')

% [N,X] = hist(LOCS{1},29*8);
% figure(2);
% subplot(2,1,1)
% bar(X,N/totalBouts)
% title('D1 Cells Probability Distribution (Norm to # of Bouts)');
% xlabel('Time After Onset (s)')
% 
% [N,X] = hist(LOCS{2},29*8);
% figure(2);
% subplot(2,1,2)
% bar(X,N/totalBouts)
% title('D2 Cells Probability Distribution (Norm to # of Bouts)');
% xlabel('Time After Onset (s)')

% figure;
% histogram(LOCS{1},100,'Normalization','pdf');
% title('D1 Cells Probability Distribution');
% xlabel('Time After Onset (s)')
% 
% figure;
% histogram(LOCS{2},100,'Normalization','pdf');
% title('D2 Cells Probability Distribution');
% xlabel('Time After Onset (s)')

%% For Full Bout

window = 29*6;
[N,X] = histcounts(LOCS{1},window);
figure();
plot(X(1:length(N)),smooth(N/totalCells(1),5)','Color',[0.8,0,0])

[N,X] = hist(LOCS{2},window);
hold on
plot(X(1:length(N)),smooth(N/totalCells(2),5)','Color',[0,0.8,0])
title('Spike Probability Distribution (Norm to # of Cells)');
xlabel('Seconds (s)')
ylabel('Spike Probability')
legend('D1','D2','Location','NorthWest')

% [N,X] = hist(LOCS{1},100);
% figure;
% bar(X,N/totalCells(1))
% title('D1 Cells Probability Distribution (Norm to # of Cells)');
% xlabel('Percent Through Bout (%)')
% 
% [N,X] = hist(LOCS{2},100);
% figure;
% bar(X,N/totalCells(2))
% title('D2 Cells Probability Distribution (Norm to # of Cells)');
% xlabel('Percent Through Bout (%)')
% 
% [N,X] = hist(LOCS{1},100);
% figure;
% bar(X,N/totalBouts)
% title('D1 Cells Probability Distribution (Norm to # of Bouts)');
% xlabel('Percent Through Bout (%)')
% 
% [N,X] = hist(LOCS{2},100);
% figure;
% bar(X,N/totalBouts)
% title('D2 Cells Probability Distribution (Norm to # of Bouts)');
% xlabel('Percent Through Bout (%)')