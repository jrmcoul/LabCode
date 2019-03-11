% % Pre-Lesion SW Mice
% mouse = {'SW011','SW012','SW018','SW021','SW024','SW025'};
% date = {'170201','170203','170216','170221','170223', '170224','170301','170309',...
%     '170316','170321','170405','170412','170413','170414','170417','170418','170420', ...
%     '170425','170427','170428','170502','170504','170505','170510','170511','170518', ...
%     '170524','170526','170601'};
% acq = {'1','2','3','4'};
% 
% % 24-48Hrs Post-Lesion SW Mice
% mouse = {'SW011','SW012','SW018','SW021','SW024','SW025'};
% date = {'170201','170203','170216','170221','170223', '170224','170301','170309', ...
%     '170316','170321','170405','170412','170413','170414','170417','170418','170420', ...
%     '170425','170427','170428','170502','170504','170505','170510','170511','170518', ...
%     '170524','170526','170601'};
% acq = {'1_Post','2_Post','3_Post','4_Post'};

% 1 Month Post-Lesion SW Mice
mouse = {'SW011','SW012','SW018','SW021','SW024','SW025'};
date = {'170201','170203','170216','170221','170223', '170224','170301','170309', ...
    '170316','170321','170405','170412','170413','170414','170417','170418','170420', ...
    '170425','170427','170428','170502','170504','170505','170510','170511','170518', ...
    '170524','170526','170601'};
acq = {'1_PostPostPost','2_PostPostPost','3_PostPostPost','4_PostPostPost'};


isOnset = true; % For looking at Onsets
% isOnset = false; % For looking at Offsets

[LOCS, totalCells, totalBouts] = getOnsetProbDistrib(mouse,date,acq,isOnset);
% [LOCS, totalCells, totalBouts] = getOnToOffProbDistrib(mouse,date,acq);


%% Histograms For Onset or Offset

[N,X] = hist(LOCS{1},100);
figure(1);
subplot(2,1,1)
bar(X,N/totalCells(1))
title('D1 Cells Probability Distribution (Norm to # of Cells)');
xlabel('Time After Onset (s)')

[N,X] = hist(LOCS{2},100);
figure(1);
subplot(2,1,2)
bar(X,N/totalCells(2))
title('D2 Cells Probability Distribution (Norm to # of Cells)');
xlabel('Time After Onset (s)')

[N,X] = hist(LOCS{1},100);
figure(2);
subplot(2,1,1)
bar(X,N/totalBouts)
title('D1 Cells Probability Distribution (Norm to # of Bouts)');
xlabel('Time After Onset (s)')

[N,X] = hist(LOCS{2},100);
figure(2);
subplot(2,1,2)
bar(X,N/totalBouts)
title('D2 Cells Probability Distribution (Norm to # of Bouts)');
xlabel('Time After Onset (s)')

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

[N,X] = hist(LOCS{1},100);
figure;
bar(X,N/totalCells(1))
title('D1 Cells Probability Distribution (Norm to # of Cells)');
xlabel('Percent Through Bout (%)')

[N,X] = hist(LOCS{2},100);
figure;
bar(X,N/totalCells(2))
title('D2 Cells Probability Distribution (Norm to # of Cells)');
xlabel('Percent Through Bout (%)')

[N,X] = hist(LOCS{1},100);
figure;
bar(X,N/totalBouts)
title('D1 Cells Probability Distribution (Norm to # of Bouts)');
xlabel('Percent Through Bout (%)')

[N,X] = hist(LOCS{2},100);
figure;
bar(X,N/totalBouts)
title('D2 Cells Probability Distribution (Norm to # of Bouts)');
xlabel('Percent Through Bout (%)')