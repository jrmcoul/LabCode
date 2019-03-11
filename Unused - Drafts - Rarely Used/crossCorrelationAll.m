clear all;
[trials, path] = uigetfile('*.mat','MultiSelect','on');
cd(path)

if ~iscell(trials)
    tempTrials = trials;
    trials = cell(1);
    trials{1} = tempTrials;
end

totalFiles = 0;
roi = {};

for trial = 1:length(trials)
    load(trials{trial});
    totalFiles = totalFiles + 1
    
    roi{1} = data.dF1.dF;
    roi{2} = data.dF2.dF;
    
    for cellType = 1:2
        
        for nCell1 = 1:size(roi{cellType},1)-1
            for nCell2 = nCell1+1:size(roi{cellType},1)
                check = xcorr(roi{cellType}(nCell1,:),roi{cellType}(nCell2,:),'coeff');
                if max(check) > .75
                    display([trials{trial},' D',num2str(cellType),' Cell 1: ', num2str(nCell1), ' Cell 2: ', num2str(nCell2)])
                end
            end

        end
        
        
    end


end

%%
figure;
hold on
plot(data.dF1.dF(2,:));
plot(data.dF1.dF(3,:));

% figure;
% plot(data.dF1.dF(64,:) - data.dF1.dF(67,:))


%%
figure;
hold on
plot(data.dF2.dF(4,:));
plot(data.dF2.dF(9,:));

% figure;
% plot(data.dF2.dF(35,:) - data.dF2.dF(57,:))