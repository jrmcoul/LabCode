cd('C:\MATLAB\Calcium Data\')
[trials] = uigetfile('*.mat','MultiSelect','on');

totalFiles = 0;

roi = {};
statsMats = {[],[]};

for trial = 1:length(trials);
	load(trials{trial});                               
	totalFiles = totalFiles + 1
    
    roi{1} = data.dF1;
    roi{2} = data.dF2;
      
    for cellType = 1:2;
        statsMats{cellType} = cat(1,statsMats{cellType},[roi{cellType}.peakHeights, roi{cellType}.riseTimes, roi{cellType}.decayTimes]);
    end
                    
end

for stat = 1:3
    figure(stat);
    for cellType = 1:2
        for cell = 1:length(statsMats{cellType})
            plot(cellType,statsMats{cellType}(cell,stat),'kx');
            hold on
        end
        plot(cellType,nanmean(statsMats{cellType}(:,stat),1),'rx');
    end
    
    switch stat
        case 1
            title('Peak Heights');
            ylabel('Fluorescence (DF/F)')
        case 2
            title ('Peak Rise Times');
            ylabel('Seconds (s)');
        case 3
            title ('Peak Decay Times');
            ylabel('Seconds (s)');
    end
    
    set(gca,'XLim',[.5,2.5],'XTick',[1,2],'XTickLabel',{'D1','D2'});
    hold off
end