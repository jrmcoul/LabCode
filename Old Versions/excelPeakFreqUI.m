cd('C:\MATLAB\Calcium Data\')
[trials] = uigetfile('*.mat','MultiSelect','on');

totalFiles = 0;

roi = {};
freqMats = {[],[]};

for trial = 1:length(trials);
	load(trials{trial});                               
	totalFiles = totalFiles + 1
    
    roi{1} = data.dF1;
    roi{2} = data.dF2;   
      
    for cellType = 1:2;       
        freqMats{cellType} = cat(1,freqMats{cellType},roi{cellType}.peakFreqRestMot);
    end
                    
end

for cellType = 1:2
    figure(cellType);
    for cell = 1:length(freqMats{cellType})
        plot([1,2],freqMats{cellType}(cell,:),'k.-','LineWidth',.25);
        hold on
    end
    plot([1,2],mean(freqMats{cellType},1),'rx-');
    hold off
end