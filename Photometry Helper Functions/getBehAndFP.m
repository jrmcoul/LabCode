function [rawData, FPArray] = getBehAndFP(firstFile, lastFile, FP)

% [rawData, FPArray] = getBehAndFP(firstFile, lastFile, FP)
%
% Summary: This function concatenates the rotary encoder and FP data and
% then normalizes rotary encoder data.
%
% Inputs:
%
% 'firstFile' - the first scanimage acquisition trace to be concatenated.
% This is the x in AD0_x.
%
% 'lastFile' - the last scanimage acquisition trace to be concatenated. This
% is the x in AD0_x. This is equal to firstFile if you want to look at just
% one acquisition.
%
% **IMPORTANT**
% 'FP' - the value of the input to the NI board for the FP data. If the
% selected input channel data doesn't exist, the code will count downward
% until it finds a value that exists. This was written to be robust to
% changing input values, assuming that the photometry signal is being
% recorded in the highest input number. This may cause a runtime error if
% there is a higher input number that is not the photometry signal. The
% function concatenates these photometry acquisitions in the same way as
% the behavior data.
%
% Outputs:
%
% 'rawData' - the normalized, concatenated rotary encoder data. Values range
% from 0-1 rotation.
%
% 'FPArray' - the concatenated FP data.
%
% Author: Jeffrey March, 2018

behArray = [];
for fileNameIndex = firstFile:lastFile
    file = getfield(open(sprintf('AD0_%d.mat',fileNameIndex)), sprintf('AD0_%d',fileNameIndex));
    behArray = cat(2,behArray,file.data);
end
rawData = behArray;
rawData = (rawData - min(rawData)); % Making minimum point = 0
rawData = rawData/max(rawData); % Max point = 1


% This portion says that if the selected input channel data doesn't exist,
% the code will count downward until it finds a value that exists. BE
% CAREFUL WITH THIS!!
while ~exist(sprintf(['AD',num2str(FP),'_%d.mat'],fileNameIndex))
    FP = FP - 1;
end

FPArray = [];
for fileNameIndex = firstFile:lastFile
    FPfile = getfield(open(sprintf(['AD',num2str(FP),'_%d.mat'],fileNameIndex)), sprintf(['AD',num2str(FP),'_%d'],fileNameIndex));
    FPArray = cat(2,FPArray,FPfile.data);
end


end

