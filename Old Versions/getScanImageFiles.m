dataArray = [];
firstFile = 1;
lastFile = 109;
warning off

for fileNameIndex = firstFile:lastFile
    file = getfield(open(sprintf('AD0_%d.mat',fileNameIndex)), sprintf('AD0_%d',fileNameIndex));
    dataArray(fileNameIndex,:) = file.data;
end

ampMatrix = max(dataArray')';
medianMatrix = median(dataArray')';
diffMatrix = ampMatrix - medianMatrix;
time = 0:.5:.5*(length(diffMatrix) - 1);
figure();
plot(time, diffMatrix);
title('Amplitude of Photodetector over Time');
xlabel('Time (min)');
ylabel('Amplitude');


