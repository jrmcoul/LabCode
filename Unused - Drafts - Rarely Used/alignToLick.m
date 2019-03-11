% This aligns to lick onset after time point 0
timeBefore = 1000;
timeAfter = 1000;
timeArray = -timeBefore:timeAfter;
tempMatrix = {};
for condition = 1:2
    row = 1;
    tempMatrix{condition} = [];
    for trial = 1:length(data(condition).licks)
        index = find(data(condition).licks{trial} > 0, 1);
        if index 
            if find(data(condition).photo{trial}(:,1) >= data(condition).licks{trial}(index) + timeAfter)           
                index2 = find(data(condition).photo{trial}(:,1) == data(condition).licks{trial}(index));
                tempMatrix{condition}(row,:) = data(condition).photo{trial}(index2 - timeBefore:index2 + timeAfter,2);
                row = row + 1;
            end
        end
    end
end


for condition = 1:2
    figure(condition+10)
    for trial = 1:size(tempMatrix{condition},1)
        plot(timeArray,tempMatrix{condition}(trial,:));
        hold on;
    end
    hold off
end

for condition = 1:2
    figure(condition + 12);
    plot(timeArray,mean(tempMatrix{condition},1));
end