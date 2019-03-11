% mouse = {'SW011','SW012'};
% date = {'170201', '170203','170216'};
% acq = {'1','2','3'};

% mouse = {'SW011','SW012'};
% date = {'170223', '170224'};
% acq = {'1','2','3'};

mouse = {'SW011','SW012','SW018','SW021','SW024','SW025'};
date = {'170223', '170224','170301','170321','170427','170428','170504','170505'};
acq = {'1_Post','2_Post','3_Post','4_Post'};

cd('C:\Users\labadmin\Documents\MATLAB\Calcium Data\')
for mouseNum = 1:length(mouse);
    for dateNum = 1:length(date);
        for acqNum = 1:length(acq);
            filename = cat(2,mouse{mouseNum},'_',date{dateNum},'_Acq',acq{acqNum},'.mat');
            if exist(filename)
                load(filename);
                for condition = 1:3;
                    if condition == 1
                        roi = data.dF1;
                    end
                    if condition == 2
                        roi = data.dF2;
                    end
                    if condition == 3
                        roi = data.dF3;
                    end

                    speed = abs(data.vel);
                    bins = [0,0.001:0.005:1.001];
                    
                    roi.meanBinDF =[];
                    roi.meanBinVel =[];
                    % Calculate binarized data: moving or resting
                    for i = 1:length(bins)-1;
                        binNum{i} = speed < bins(i+1) & speed >= bins(i);
                        % Calculate mean DF/F when moving or resting
                        roi.meanBinDF(i) = nanmean((roi.dF*binNum{i}')/sum(binNum{i}));
                        % Calculate mean speed when moving or resting
                        roi.meanBinVel(i) = (speed*binNum{i}')/sum(binNum{i});
                    end

                    if condition == 1
                        data.dF1 = roi;
                    end
                    if condition == 2
                        data.dF2 = roi;
                    end
                    if condition == 3
                        data.dF3 = roi;
                    end
                end               
                save(filename,'data')                
            end
        end
    end
end
cd ..