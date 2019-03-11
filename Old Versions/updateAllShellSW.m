% mouse = {'SW011','SW012'};
% date = {'170201', '170203','170216'};
% acq = {'1','2','3'};

% mouse = {'SW011','SW012'};
% date = {'170223', '170224'};
% acq = {'1','2','3'};

% mouse = {'SW011','SW012'};
% date = {'170301'};
% acq = {'1','2','3','4'};

mouse = {'SW011','SW012','SW017','SW018','SW021','SW023','SW024','SW025','SW026','SW027'};
date = {'170201','170203','170216','170221','170223', '170224','170301','170309','170316','170321','170405','170412','170413','170414','170417','170418','170420','170425','170427','170428','170502','170504','170505','170510','170511','170518','170524'};
acq = {'1','2','3','4','1_Post','2_Post','3_Post','4_Post'};


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
                    threshold = .001;

                    % Calculate binarized data: moving or resting
                    moving = speed >= threshold;
                    resting = speed < threshold;

                    % Calculate mean DF/F when moving or resting
                    roi.meanMovDF = mean((roi.dF*moving')/sum(moving));
                    roi.meanRestDF = mean((roi.dF*resting')/sum(resting));
                    roi.meanTotDF = mean(mean(roi.dF));

                    % Calculate mean speed when moving or resting
                    roi.meanMovVel = (speed*moving')/sum(moving);
                    roi.meanRestVel = (speed*resting')/sum(resting);
                    roi.meanTotVel = mean(speed);
                    
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