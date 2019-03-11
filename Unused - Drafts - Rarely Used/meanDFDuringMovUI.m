function [meanDFPerFrameMat, meanSpeedPerFrameMat] = meanDFDuringMovUI(trials, condition)

meanDFPerFrameMat = [];
meanSpeedPerFrameMat = [];

for trial = 1:length(trials);
	load(trials{trial});
	if condition == 1
    	roi = data.dF1;
    end %if
	if condition == 2
    	roi = data.dF2;
    end %if
	if condition == 3
    	roi = data.dF3;
    end %if

	meanDFPerFrameMat = cat(1,meanDFPerFrameMat,[roi.meanMovDF,roi.meanRestDF,roi.meanTotDF]);
	meanSpeedPerFrameMat = cat(1,meanSpeedPerFrameMat,[roi.meanMovVel,roi.meanRestVel,roi.meanTotVel]);
end %for trial

end %function