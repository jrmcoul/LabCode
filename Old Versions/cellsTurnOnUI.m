totalDistances = cell(1,4);

% Iterating through each condition
for conditions = 1:3
    conditionStrings = {'Pre','Acute','Chronic','L-dopa'};
        
    [trials, pathname] = uigetfile('*.mat','MultiSelect','on');
    
    % In case you want to look at one acquisition
    if ~iscell(trials)
        tempTrials = trials;
        trials = cell(1);
        trials{1} = tempTrials;
    end
    
    cd(pathname)
    
    % Initializing values
    totalFiles = 0;
    npeaks = 1;
    MPP = 4;
    MPH = 3;
    MINW = 6;
    roi = cell(1,2);
    warning('off');
    finalMat = cell(1,2);
    
       
    for trial = 1:length(trials);
        load(trials{trial});
        totalFiles = totalFiles + 1
        
        roi{1} = data.dF1;
        roi{2} = data.dF2;
        
        for cellType = 1:2;
            LOCS = zeros(1,size(roi{cellType}.dF,1));
            PKS = zeros(1,size(roi{cellType}.dF,1));
            
            roi2 = zeros(size(roi{cellType}.dF));
            % Z-scoring Cells
            for cellNum = 1:size(roi{cellType}.dF,1)
                roi2(cellNum,:) = zscore(roi{cellType}.dF(cellNum,:));
            end
            
            for cellNum = 1:size(roi2,1)
                if ~isempty(findpeaks(roi2(cellNum,:),'MinPeakProminence', MPP, 'MinPeakHeight', MPH, 'MinPeakWidth', MINW,'NPeaks',npeaks))
                    [PKS(cellNum), LOCS(cellNum)] = findpeaks(roi2(cellNum,:),'MinPeakProminence', MPP, 'MinPeakHeight', MPH, 'MinPeakWidth', MINW,'NPeaks',npeaks);
                end
            end
            
            LOCS = LOCS(find(LOCS ~= 0));
            
            distForCell = zeros(2,length(LOCS));
            distForCell(2,:) = (1:length(LOCS)); %/length(LOCS); %add /length(LOCS) to make y axis "fraction of active cells"
            cumDist = cumsum(abs(data.vel))/data.framerate;
            distForCell(1,:) = sort(cumDist(LOCS)); %/cumDist(end); %add /cumDist(end) to make x axis "fraction of total distance"
            
            finalMat{cellType} = cat(2,finalMat{cellType},distForCell);
        end
        
        if data.totalDistance > 50
            display([trials{trial},' ',num2str(data.totalDistance)]);
        end
        
        totalDistances{conditions} = [totalDistances{conditions}, data.totalDistance];
        cutOffs = .5:.5:20;
        
    end
    
    %Run this for all conditions, one after the other, to get full picture
    for cellType = 1:2
        figure(cellType + 5);
        plot(finalMat{cellType}(1,:),finalMat{cellType}(2,:),'x')
        title(['Fraction of Active D',num2str(cellType),' Cells Activated vs. Distance Traveled']);
        xlabel('Distance Traveled (m)');
        ylabel('Fraction of Active Cells Activated');
        legend(conditionStrings{1},conditionStrings{2},conditionStrings{3},conditionStrings{4});
        %     xlim([0,1]);
%         ylim([0,1]);
        hold on
        
    end
    
%     for cellType = 1:2
%         [dist, distSortOrder] = sort(finalMat{cellType}(1,:));
%         cellNum = finalMat{cellType}(2,distSortOrder);
%         
%         k = lsqcurvefit(@logistic,3,dist,cellNum)
%         
%         fitLine = logistic(k, dist);
%         
%         figure(cellType + 10);
%         hold on
%         plot(dist,fitLine);
%         title(['Fraction of Active D',num2str(cellType),' Cells Activated vs. Distance Traveled (Fit)']);
%         xlabel('Distance Traveled (m)');
%         ylabel('Fraction of Active Cells Activated');
% %         ylim([0,1]);
%         legend(conditionStrings{1},conditionStrings{2},conditionStrings{3},conditionStrings{4});
%     end
end
