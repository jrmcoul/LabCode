function [mouseBoutData] = getMouseBoutDataEXCEL(mouse,date,acq)

totalFiles = 0;
mouseBoutData = {};
boutNum = 1;
prevMouse = '';
prevDate = '';

for mouseNum = 1:length(mouse)
        
    for dateNum = 1:length(date)
                
        for acqNum = 1:length(acq)
            filename = cat(2,mouse{mouseNum},'_',date{dateNum},'_Acq',acq{acqNum},'.mat');            
            if exist(filename)
                
                if ~(strcmp(mouse{mouseNum},prevMouse))
                    mouseBoutData{boutNum,1} = mouse{mouseNum};
                end 
                
                if  ~(strcmp(date{dateNum},prevDate))    
                    mouseBoutData{boutNum,2} = date{dateNum};
                end
                
                mouseBoutData{boutNum,3} = acq{acqNum};
                
                load(filename);
                totalFiles = totalFiles + 1
                if strcmp(filename(1),'F')
                    roi = data;
                end
                if strcmp(filename(1),'S')
                    roi = data;
                    roi.sampleRate = data.framerate;
                    roi.FP = data.dF1.dF;
                    roi.onsetToOffsetBeh = data.dF1.onsetToOffsetBeh;
                    roi.onsetToOffsetTime = data.dF1.onsetToOffsetTime;
                end
                
                boutDurations = [];
                meanVels = [];
                peakVels = [];
 
                fRatio = size(roi.FP,2)/length(roi.vel);
                timeBefore = 4*roi.sampleRate; % Time before onset/offset (coeff is in seconds)
                timeAfter = 4*roi.sampleRate; % Time after onset/offset (coeff is in seconds)
                for bout= 1:length(roi.onsetToOffsetTime)
                    boutDurations(bout) = roi.onsetToOffsetTime{bout}(end) - 4; % 4 seconds is time after offset recorded
                    meanVels(bout) = mean(abs(roi.onsetToOffsetBeh{bout}(round((timeBefore + 1)*fRatio:end - round((timeBefore + 1)*fRatio)))));
                    peakVels(bout) = max(abs(roi.onsetToOffsetBeh{bout}(round((timeBefore + 1)*fRatio:end - round((timeBefore + 1)*fRatio)))));
                end
                
                for bout = 1:length(boutDurations)
                    mouseBoutData{boutNum + bout - 1, 4} = boutDurations(bout);
                    mouseBoutData{boutNum + bout - 1, 5} = meanVels(bout);
                    mouseBoutData{boutNum + bout - 1, 6} = peakVels(bout);
                end
                
                boutNum = boutNum + length(boutDurations);               
                
                prevMouse = mouse{mouseNum};
                prevDate = date{dateNum};
            end
        end
    end
end

end