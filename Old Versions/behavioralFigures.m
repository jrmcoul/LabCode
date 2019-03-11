% All Lesioned mice
mouse = {'F006','F008','F009','F010','F013','F014','F015','F016','F022','F023','F024', ...
    'SW011','SW012','SW018','SW021','SW024','SW025','SW026','SW027'};
date = {'170201','170203','170216','170221','170223', '170224','170301','170303', ...
    '170307','170309','170315','170316','170321','170323','170325','170330','170405', ...
    '170406','170412','170413','170414','170417','170418','170420','170421','170425', ...
    '170426','170427','170428','170502','170504','170505','170509','170510','170511', ...
    '170512','170517','170518','170524','170526','170601','170602','170603','170604'};
acq = {'1','2','3','4','1_Post','2_Post','3_Post','4_Post','1_PostPostPost','2_PostPostPost','3_PostPostPost','4_PostPostPost'};
% % 
% % All Sham Mice
% mouse = {'F007','F011','F012','F017','F018','SW017','SW023'};
% date = {'170303','170307','170309','170315','170316','170321','170323','170325', ...
%     '170330','170406','170413','170414','170417','170420','170421','170426','170427', ...
%     '170428','170502','170504','170509','170511','170512','170517','170524'};
% acq = {'1','2','3','4','5','6', '1_Post','2_Post','3_Post','4_Post','5_Post','6_Post'};
% 
% % % Lesioned SW Mice
% % mouse = {'SW011','SW012','SW018','SW021','SW024','SW025','SW026','SW027'};
% % date = {'170201','170203','170216','170221','170223', '170224','170301','170309','170316','170321','170405','170412','170413','170414','170417','170418','170420','170425','170427','170428','170502','170504','170505','170510','170511','170518','170524'};
% % acq = {'1','2','3','4','1_Post','2_Post','3_Post','4_Post'};
% 
% % % Sham SW Mice
% % mouse = {'SW017','SW023'};
% % date = {'170309','170316','170413','170414','170427','170428'};
% % acq = {'1','2','3','4','1_Post','2_Post','3_Post','4_Post'};
% 
% % % Lesioned Mice 
% % mouse = {'F006','F008','F009','F010','F013','F014','F015','F016'};
% % date = {'170303','170307','170309','170315','170321','170323','170325','170330', ... 
% %     '170406','170413','170417','170420','170421','170426','170502','170504','170509', ...
% %     '170511','170512','170517','170524','170601','170602','170603','170604'};
% % acq = {'1','2','3','4','5','6', '1_Post','2_Post','3_Post','4_Post','5_Post','6_Post'};
% 
% % % Sham Mice
% % mouse = {'F007','F011','F012','F017','F018'};
% % date = {'170303','170307','170309','170315','170321','170323','170325','170330', ...
% %     '170406','170413','170417','170420','170421','170426','170502','170504','170509', ...
% %     '170511','170512','170517','170524'};
% % acq = {'1','2','3','4','5','6', '1_Post','2_Post','3_Post','4_Post','5_Post','6_Post'};
% 
% condition = 1;
% norm = false;
% avg = false;
% 
% [mouseBoutData] = getMouseBoutData(mouse,date,acq, condition, norm, avg);
[mouseBoutData] = getMouseBoutDataEXCEL(mouse,date,acq);
%% Concatenating all bout length, mean vel, peak vel & Plotting Histogams
tempBoutDurs = [];
tempMeanVels = [];
tempPeakVels = [];
postlesion = true; % If you want to look at prelesion or postlesion data

for mouseNum = 1:length(mouseBoutData)
    for dateNum = 1:length(mouseBoutData{mouseNum})
        if ~isempty(mouseBoutData{mouseNum}{dateNum})           
            for acqNum = 1:length(mouseBoutData{mouseNum}{dateNum})
                if ~isempty(mouseBoutData{mouseNum}{dateNum}{acqNum}) && (postlesion == strcmp(mouseBoutData{mouseNum}{dateNum}{acqNum}.acq(end),'t'))
                    tempBoutDurs = cat(2,tempBoutDurs,mouseBoutData{mouseNum}{dateNum}{acqNum}.boutDurations);
                    tempMeanVels = cat(2,tempMeanVels,mouseBoutData{mouseNum}{dateNum}{acqNum}.meanVel);
                    tempPeakVels = cat(2,tempPeakVels,mouseBoutData{mouseNum}{dateNum}{acqNum}.peakVel);               
                end
            end
        end
    end
end

finalBoutDurs = tempBoutDurs;
finalMeanVels = tempMeanVels;
finalPeakVels = tempPeakVels;

meanBoutDur = mean(finalBoutDurs);
medianBoutDur = median(finalBoutDurs);
stdBoutDur = std(finalBoutDurs);

meanMeanVel = mean(finalMeanVels);
medianMeanVel = median(finalMeanVels);
stdMeanVel = std(finalMeanVels);

meanPeakVel = mean(finalPeakVels);
medianPeakVel = median(finalPeakVels);
stdPeakVel = std(finalPeakVels);

% Bout Duration All Mice Histogram
figure;
histogram(finalBoutDurs,100)
title('Bout Duration Across All Mice')
xlabel('Bout Duration (s)')
ylabel('# of Occurrences')
hold on
stem(meanBoutDur,20)
hold off

% Mean Bout Velocity All Mice Histogram
figure;
histogram(finalMeanVels,100)
title('Mean Bout Velocity Across All Mice')
xlabel('Mean Bout Velocity (m/s)')
ylabel('# of Occurrences')
hold on
stem(meanMeanVel,17)
hold off

% Peak Bout Velocity All Mice Histogram
figure;
histogram(finalPeakVels,100)
title('Peak Bout Velocity Across All Mice')
xlabel('Peak Bout Velocity (m/s)')
ylabel('# of Occurrences')
hold on
stem(meanPeakVel,12)
hold off

clearvars -except mouseBoutData
%% Graphing Means for each Mouse

finalBoutDursMouse = {};
finalMeanVelsMouse = {};
finalPeakVelsMouse = {};

postlesion = false; % If you want to look at prelesion or postlesion data

for mouseNum = 1:length(mouseBoutData)
    tempBoutDursMouse{1,mouseNum} = [];
    tempMeanVelsMouse{1,mouseNum} = [];
    tempPeakVelsMouse{1,mouseNum} = [];
    for dateNum = 1:length(mouseBoutData{mouseNum})
        if ~isempty(mouseBoutData{mouseNum}{dateNum})
            for acqNum = 1:length(mouseBoutData{mouseNum}{dateNum})
                if ~isempty(mouseBoutData{mouseNum}{dateNum}{acqNum}) && (postlesion == strcmp(mouseBoutData{mouseNum}{dateNum}{acqNum}.acq(end),'t'))
                    tempBoutDursMouse{1,mouseNum} = cat(2,tempBoutDursMouse{1,mouseNum},mouseBoutData{mouseNum}{dateNum}{acqNum}.boutDurations);
                    tempMeanVelsMouse{1,mouseNum} = cat(2,tempMeanVelsMouse{1,mouseNum},mouseBoutData{mouseNum}{dateNum}{acqNum}.meanVel);
                    tempPeakVelsMouse{1,mouseNum} = cat(2,tempPeakVelsMouse{1,mouseNum},mouseBoutData{mouseNum}{dateNum}{acqNum}.peakVel);
                    tempBoutDursMouse{2,mouseNum} = mouseBoutData{mouseNum}{dateNum}{acqNum}.mouse;
                    tempMeanVelsMouse{2,mouseNum} = mouseBoutData{mouseNum}{dateNum}{acqNum}.mouse;
                    tempPeakVelsMouse{2,mouseNum} = mouseBoutData{mouseNum}{dateNum}{acqNum}.mouse;
                end
            end
        end
    end
end

finalBoutDursMouse = tempBoutDursMouse;
finalMeanVelsMouse = tempMeanVelsMouse;
finalPeakVelsMouse = tempPeakVelsMouse;

for i = 1:size(finalBoutDursMouse,2)
    finalBoutDursMouse{3,i} = mean(finalBoutDursMouse{1,i});
    finalBoutDursMouse{4,i} = median(finalBoutDursMouse{1,i});
    finalBoutDursMouse{5,i} = std(finalBoutDursMouse{1,i});

    finalMeanVelsMouse{3,i} = mean(finalMeanVelsMouse{1,i});
    finalMeanVelsMouse{4,i} = median(finalMeanVelsMouse{1,i});
    finalMeanVelsMouse{5,i} = std(finalMeanVelsMouse{1,i});

    finalPeakVelsMouse{3,i} = mean(finalPeakVelsMouse{1,i});
    finalPeakVelsMouse{4,i} = median(finalPeakVelsMouse{1,i});
    finalPeakVelsMouse{5,i} = std(finalPeakVelsMouse{1,i});
end

Labels = {};
for labelInd = 1:length(tempBoutDursMouse)
    Labels{labelInd} = tempBoutDursMouse{2,labelInd};
end

% Bout Duration Across Mice
figure;
for xticks = 1:size(finalBoutDursMouse,2)
    plot(xticks*ones(size(finalBoutDursMouse{1,xticks})),finalBoutDursMouse{1,xticks},'kx',xticks*ones(size(finalBoutDursMouse{3,xticks})),finalBoutDursMouse{3,xticks},'ro')
    hold on
end
title('Bout Duration Across Mice')
ylabel('Bout Duration (s)')
set(gca, 'XTick', 1:size(finalBoutDursMouse,2), 'XTickLabel', Labels);
axis([0.5, size(finalBoutDursMouse,2) + 0.5, 0, 150])
hold off

% Mean Bout Velocity Across Mice
figure;
for xticks = 1:size(finalMeanVelsMouse,2)
    plot(xticks*ones(size(finalMeanVelsMouse{1,xticks})),finalMeanVelsMouse{1,xticks},'kx',xticks*ones(size(finalMeanVelsMouse{3,xticks})),finalMeanVelsMouse{3,xticks},'ro')
    hold on
end
title('Mean Bout Velocity Across Mice')
ylabel('Mean Bout Velocity (m/s)')
set(gca, 'XTick', 1:size(finalMeanVelsMouse,2), 'XTickLabel', Labels);
axis([0.5, size(finalMeanVelsMouse,2) + 0.5, 0, 0.15])
hold off

% Peak Bout Velocity Across Mice
figure;
for xticks = 1:size(finalPeakVelsMouse,2)
    plot(xticks*ones(size(finalPeakVelsMouse{1,xticks})),finalPeakVelsMouse{1,xticks},'kx',xticks*ones(size(finalPeakVelsMouse{3,xticks})),finalPeakVelsMouse{3,xticks},'ro')
    hold on
end
title('Peak Bout Velocity Across Mice')
ylabel('Peak Bout Velocity (m/s)')
set(gca, 'XTick', 1:size(finalPeakVelsMouse,2), 'XTickLabel', Labels);
axis([0.5, size(finalPeakVelsMouse,2) + 0.5, 0, 0.25])
hold off

clearvars -except mouseBoutData
%% Graphing for each Mouse Across Days

finalBoutDursMouse = {};
finalMeanVelsMouse = {};
finalPeakVelsMouse = {};

for postlesion = [0,1]; % If you want to look at prelesion or postlesion data

    tempBoutDursMouse = {};
    tempMeanVelsMouse = {};
    tempPeakVelsMouse = {};

for mouseNum = 1:length(mouseBoutData)
    tempBoutDursMouse{1,mouseNum} = {};
    tempMeanVelsMouse{1,mouseNum} = {};
    tempPeakVelsMouse{1,mouseNum} = {};
    tempNumBoutsMouse{1,mouseNum} = {};
    
    for dateNum = 1:length(mouseBoutData{mouseNum})
        if ~isempty(mouseBoutData{mouseNum}{dateNum})
            tempBoutDursMouse{1,mouseNum}{1,dateNum} = [];
            tempMeanVelsMouse{1,mouseNum}{1,dateNum} = [];
            tempPeakVelsMouse{1,mouseNum}{1,dateNum} = [];
            tempNumBoutsMouse{1,mouseNum}{1,dateNum} = [];
            
            tempBoutDursMouse{1,mouseNum}{2,dateNum} = '';
            tempMeanVelsMouse{1,mouseNum}{2,dateNum} = '';
            tempPeakVelsMouse{1,mouseNum}{2,dateNum} = '';
            tempNumBoutsMouse{1,mouseNum}{2,dateNum} = '';
            
            for acqNum = 1:length(mouseBoutData{mouseNum}{dateNum})
                if ~isempty(mouseBoutData{mouseNum}{dateNum}{acqNum}) && (postlesion == strcmp(mouseBoutData{mouseNum}{dateNum}{acqNum}.acq(end),'t'))
                    tempBoutDursMouse{1,mouseNum}{1,dateNum} = cat(2,tempBoutDursMouse{1,mouseNum}{1,dateNum},mouseBoutData{mouseNum}{dateNum}{acqNum}.boutDurations);
                    tempMeanVelsMouse{1,mouseNum}{1,dateNum} = cat(2,tempMeanVelsMouse{1,mouseNum}{1,dateNum},mouseBoutData{mouseNum}{dateNum}{acqNum}.meanVel);
                    tempPeakVelsMouse{1,mouseNum}{1,dateNum} = cat(2,tempPeakVelsMouse{1,mouseNum}{1,dateNum},mouseBoutData{mouseNum}{dateNum}{acqNum}.peakVel);
                    tempNumBoutsMouse{1,mouseNum}{1,dateNum} = cat(2,tempNumBoutsMouse{1,mouseNum}{1,dateNum},length(mouseBoutData{mouseNum}{dateNum}{acqNum}.peakVel));
                    
                    tempBoutDursMouse{1,mouseNum}{2,dateNum} = mouseBoutData{mouseNum}{dateNum}{acqNum}.date;
                    tempMeanVelsMouse{1,mouseNum}{2,dateNum} = mouseBoutData{mouseNum}{dateNum}{acqNum}.date;
                    tempPeakVelsMouse{1,mouseNum}{2,dateNum} = mouseBoutData{mouseNum}{dateNum}{acqNum}.date;
                    tempNumBoutsMouse{1,mouseNum}{2,dateNum} = mouseBoutData{mouseNum}{dateNum}{acqNum}.date;
                    
                    tempBoutDursMouse{2,mouseNum} = mouseBoutData{mouseNum}{dateNum}{acqNum}.mouse;
                    tempMeanVelsMouse{2,mouseNum} = mouseBoutData{mouseNum}{dateNum}{acqNum}.mouse;
                    tempPeakVelsMouse{2,mouseNum} = mouseBoutData{mouseNum}{dateNum}{acqNum}.mouse;
                    tempNumBoutsMouse{2,mouseNum} = mouseBoutData{mouseNum}{dateNum}{acqNum}.mouse;
                end
            end
            
            if ~isempty(tempBoutDursMouse{1,mouseNum}{1,dateNum})
                tempBoutDursMouse{1,mouseNum}{3,dateNum} = mean(tempBoutDursMouse{1,mouseNum}{1,dateNum});
                tempBoutDursMouse{1,mouseNum}{4,dateNum} = median(tempBoutDursMouse{1,mouseNum}{1,dateNum});
                tempBoutDursMouse{1,mouseNum}{5,dateNum} = std(tempBoutDursMouse{1,mouseNum}{1,dateNum});
                
                tempMeanVelsMouse{1,mouseNum}{3,dateNum} = mean(tempMeanVelsMouse{1,mouseNum}{1,dateNum});
                tempMeanVelsMouse{1,mouseNum}{4,dateNum} = median(tempMeanVelsMouse{1,mouseNum}{1,dateNum});
                tempMeanVelsMouse{1,mouseNum}{5,dateNum} = std(tempMeanVelsMouse{1,mouseNum}{1,dateNum});
                
                tempPeakVelsMouse{1,mouseNum}{3,dateNum} = mean(tempPeakVelsMouse{1,mouseNum}{1,dateNum});
                tempPeakVelsMouse{1,mouseNum}{4,dateNum} = median(tempPeakVelsMouse{1,mouseNum}{1,dateNum});
                tempPeakVelsMouse{1,mouseNum}{5,dateNum} = std(tempPeakVelsMouse{1,mouseNum}{1,dateNum});
                
                tempNumBoutsMouse{1,mouseNum}{3,dateNum} = mean(tempNumBoutsMouse{1,mouseNum}{1,dateNum});
                tempNumBoutsMouse{1,mouseNum}{4,dateNum} = median(tempNumBoutsMouse{1,mouseNum}{1,dateNum});
                tempNumBoutsMouse{1,mouseNum}{5,dateNum} = std(tempNumBoutsMouse{1,mouseNum}{1,dateNum});
            end
        end
    end
end

finalBoutDursMouse{postlesion + 1} = tempBoutDursMouse;
finalMeanVelsMouse{postlesion + 1} = tempMeanVelsMouse;
finalPeakVelsMouse{postlesion + 1} = tempPeakVelsMouse;
finalNumBoutsMouse{postlesion + 1} = tempNumBoutsMouse;

end

legendStrings = {};
for legendInd = 1:size(finalBoutDursMouse{1},2)
    legendStrings{legendInd} = finalBoutDursMouse{1}{2,legendInd};
end

averagingMeanBoutDurDay = {};
averagingMeanMeanVelDay = {};
averagingMeanPeakVelDay = {};
averagingMeanNumBoutsDay = {};

for mouseNum = 1:size(finalBoutDursMouse{1},2)
    
    meanBoutDurDay = [];
    meanMeanVelDay = [];
    meanPeakVelDay = [];
    medianBoutDurDay = [];
    medianMeanVelDay = [];
    medianPeakVelDay = [];
    stdBoutDurDay = [];
    stdMeanVelDay = [];
    stdPeakVelDay = [];
    meanNumBoutsDay = [];
    medianNumBoutsDay = [];
    stdNumBoutsDay = [];
    labelInd = 0;
    
    for postOrPre = 1:2;
        for dateNum = 1:size(finalBoutDursMouse{postOrPre}{1,mouseNum},2)
            if ~isempty(finalBoutDursMouse{postOrPre}{1,mouseNum}{1,dateNum})
                labelInd = labelInd + 1;
                meanBoutDurDay(labelInd) = finalBoutDursMouse{postOrPre}{1,mouseNum}{3,dateNum};
                meanMeanVelDay(labelInd) = finalMeanVelsMouse{postOrPre}{1,mouseNum}{3,dateNum};
                meanPeakVelDay(labelInd) = finalPeakVelsMouse{postOrPre}{1,mouseNum}{3,dateNum};
                meanNumBoutsDay(labelInd) = finalNumBoutsMouse{postOrPre}{1,mouseNum}{3,dateNum};
                
                medianBoutDurDay(labelInd) = finalBoutDursMouse{postOrPre}{1,mouseNum}{4,dateNum};
                medianMeanVelDay(labelInd) = finalMeanVelsMouse{postOrPre}{1,mouseNum}{4,dateNum};
                medianPeakVelDay(labelInd) = finalPeakVelsMouse{postOrPre}{1,mouseNum}{4,dateNum};
                medianNumBoutsDay(labelInd) = finalNumBoutsMouse{postOrPre}{1,mouseNum}{4,dateNum};

                stdBoutDurDay(labelInd) = finalBoutDursMouse{postOrPre}{1,mouseNum}{5,dateNum};
                stdMeanVelDay(labelInd) = finalMeanVelsMouse{postOrPre}{1,mouseNum}{5,dateNum};
                stdPeakVelDay(labelInd) = finalPeakVelsMouse{postOrPre}{1,mouseNum}{5,dateNum};
                stdNumBoutsDay(labelInd) = finalNumBoutsMouse{postOrPre}{1,mouseNum}{5,dateNum};
                
            end
        end
        if postOrPre == 1 
            numPrelesion = labelInd;
        end
    end
    figure(40);
    x = [-numPrelesion:-1, 1:labelInd - numPrelesion];
    plot(x, meanBoutDurDay,'-^');
    hold on
    title('Mean Bout Duration Across Mice & Trials')
    ylabel('Bout Duration (s)')
    xlabel('Trials After Lesion')
    legend(legendStrings)
    
    figure(41);
    x = [-numPrelesion:-1, 1:labelInd - numPrelesion];
    plot(x, meanMeanVelDay,'-^');
    hold on
    title('Mean Mean Bout Velocity Across Mice & Trials')
    ylabel('Mean Bout Velocity (m/s)')
    xlabel('Trials After Lesion')
    legend(legendStrings)
    
    figure(42);
    x = [-numPrelesion:-1, 1:labelInd - numPrelesion];
    plot(x, meanPeakVelDay,'-^');
    hold on
    title('Mean Peak Bout Velocity Across Mice & Trials')
    ylabel('Peak Bout Velocity (m/s)')
    xlabel('Trials After Lesion')
    legend(legendStrings)
    
    figure(43);
    x = [-numPrelesion:-1, 1:labelInd - numPrelesion];
    plot(x, meanNumBoutsDay,'-^');
    hold on
    title('Mean Number of Bouts Across Mice & Trials')
    ylabel('Number of Bouts')
    xlabel('Trials After Lesion')
    legend(legendStrings)
    
    averagingMeanBoutDurDay{1,mouseNum} = x;
    averagingMeanBoutDurDay{2,mouseNum} = meanBoutDurDay;
    averagingMeanMeanVelDay{1,mouseNum} = x;
    averagingMeanMeanVelDay{2,mouseNum} = meanMeanVelDay;
    averagingMeanPeakVelDay{1,mouseNum} = x;
    averagingMeanPeakVelDay{2,mouseNum} = meanPeakVelDay;
    averagingMeanNumBoutsDay{1,mouseNum} = x;
    averagingMeanNumBoutsDay{2,mouseNum} = meanNumBoutsDay;
    
end

finalMin = inf;
finalMax = -inf;
for i = 1:size(averagingMeanBoutDurDay,2)
    tempMin = min(averagingMeanBoutDurDay{1,i});
    tempMax = max(averagingMeanBoutDurDay{1,i});
    if finalMin > tempMin
        finalMin = tempMin;
    end
    if finalMax < tempMax
        finalMax = tempMax;
    end
end

averagingMeanBoutDurDayMatrix = zeros(mouseNum,finalMax - finalMin);
averagingMeanMeanVelDayMatrix = zeros(mouseNum,finalMax - finalMin);
averagingMeanPeakVelDayMatrix = zeros(mouseNum,finalMax - finalMin);
averagingMeanNumBoutsDayMatrix = zeros(mouseNum,finalMax - finalMin);

for mouseNum = 1:size(averagingMeanBoutDurDay,2)
    for trialNum = 1:length(averagingMeanBoutDurDay{2,mouseNum})
        averagingMeanBoutDurDayMatrix(mouseNum, averagingMeanBoutDurDay{1,mouseNum}(trialNum) - finalMin + 1*(averagingMeanBoutDurDay{1,mouseNum}(trialNum) < 0)) = averagingMeanBoutDurDay{2,mouseNum}(trialNum);
        averagingMeanMeanVelDayMatrix(mouseNum, averagingMeanMeanVelDay{1,mouseNum}(trialNum) - finalMin + 1*(averagingMeanMeanVelDay{1,mouseNum}(trialNum) < 0)) = averagingMeanMeanVelDay{2,mouseNum}(trialNum);
        averagingMeanPeakVelDayMatrix(mouseNum, averagingMeanPeakVelDay{1,mouseNum}(trialNum) - finalMin + 1*(averagingMeanPeakVelDay{1,mouseNum}(trialNum) < 0)) = averagingMeanPeakVelDay{2,mouseNum}(trialNum);
        averagingMeanNumBoutsDayMatrix(mouseNum, averagingMeanNumBoutsDay{1,mouseNum}(trialNum) - finalMin + 1*(averagingMeanNumBoutsDay{1,mouseNum}(trialNum) < 0)) = averagingMeanNumBoutsDay{2,mouseNum}(trialNum);
    end
end

figure();
trialPrePostLesion = [finalMin:-1, 1:finalMax];
plot(trialPrePostLesion, sum(averagingMeanBoutDurDayMatrix,1)./sum(averagingMeanBoutDurDayMatrix~=0,1),'-^');
hold on
title('Mean Mean Duration of Bouts Across Mice & Trials')
ylabel('Bout Duration (s)')
xlabel('Trials After Lesion')

figure();
trialPrePostLesion = [finalMin:-1, 1:finalMax];
plot(trialPrePostLesion, sum(averagingMeanMeanVelDayMatrix,1)./sum(averagingMeanMeanVelDayMatrix~=0,1),'-^');
hold on
title('Mean Mean Mean Velocity of Bouts Across Mice & Trials')
ylabel('Mean Bout Velocity (m/s)')
xlabel('Trials After Lesion')

figure();
trialPrePostLesion = [finalMin:-1, 1:finalMax];
plot(trialPrePostLesion, sum(averagingMeanPeakVelDayMatrix,1)./sum(averagingMeanPeakVelDayMatrix~=0,1),'-^');
hold on
title('Mean Mean Peak Velocity of Bouts Across Mice & Trials')
ylabel('Peak Bout Velocity (m/s)')
xlabel('Trials After Lesion')

figure();
trialPrePostLesion = [finalMin:-1, 1:finalMax];
plot(trialPrePostLesion, sum(averagingMeanNumBoutsDayMatrix,1)./sum(averagingMeanNumBoutsDayMatrix~=0,1),'-^');
hold on
title('Mean Mean Number of Bouts Across Mice & Trials')
ylabel('Number of Bouts')
xlabel('Trials After Lesion')