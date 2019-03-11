[trials, pathname] = uigetfile('*.mat','MultiSelect','on');

cd(pathname)
totalFiles = 0;
avgCell = {};
roi = {};
minLength = inf;

for trial = 1:length(trials);
	load(trials{trial});                               
	totalFiles = totalFiles + 1
    
    roi{1} = data.dF1;
    roi{2} = data.dF2;
      
    for cellType = 1:2;
        avgCell{totalFiles,cellType} = mean(roi{cellType}.dF,1);
        minLength = min([minLength,length(avgCell{totalFiles,cellType})]);      
    end
    avgCell{totalFiles,3} = data.vel;
                  
end

avgMatD1 = [];
avgMatD2 = [];
avgMatWheel = [];
for i = 1:size(avgCell,1)
    avgMatD1(i,:) = avgCell{i,1}(1:minLength);
    avgMatD2(i,:) = avgCell{i,2}(1:minLength);
    avgMatWheel(i,:) = avgCell{i,3}(1:minLength);
end

figure;
subplot(3,1,1);
plot(mean(avgMatWheel,1));
subplot(3,1,2);
plot(smooth(mean(avgMatD1,1),data.framerate)','r');
subplot(3,1,3);
plot(smooth(mean(avgMatD2,1),data.framerate)','g');
