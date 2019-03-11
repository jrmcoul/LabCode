function [mouseBoutData] = getMouseBoutData(mouse,date,acq, condition, norm, avg)

totalFiles = 0;
mouseBoutData = {};

for mouseNum = 1:length(mouse)
    for dateNum = 1:length(date)
%         if ~((strcmp(mouse{mouseNum},'F007') || strcmp(mouse{mouseNum},'F007')) && strcmp(date{dateNum},'170406'));
        for acqNum = 1:length(acq)
            filename = cat(2,mouse{mouseNum},'_',date{dateNum},'_Acq',acq{acqNum},'.mat');            
            if exist(filename)
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
                mouseBoutData{mouseNum}{dateNum}{acqNum}.mouse = mouse{mouseNum};
                mouseBoutData{mouseNum}{dateNum}{acqNum}.date = date{dateNum};
                mouseBoutData{mouseNum}{dateNum}{acqNum}.acq = acq{acqNum};
                
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
                mouseBoutData{mouseNum}{dateNum}{acqNum}.boutDurations = boutDurations;
                mouseBoutData{mouseNum}{dateNum}{acqNum}.meanVel = meanVels;
                mouseBoutData{mouseNum}{dateNum}{acqNum}.peakVel = peakVels;

            end
        end
%         end
    end
end

end

