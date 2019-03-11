

%% Diff DF

samplerate = data.sampleRate; %in Hz
onsetIndex = 1;
diffDF = zeros(size(data.onsetsMatrixDF,1),1);
diffBeh = zeros(size(data.onsetsMatrixBeh,1),1);
for i = 1:length(numOnsets)
    preDF = mean(mean(data.onsetsMatrixDF(onsetIndex:onsetIndex + numOnsets(i) - 1,1:4*samplerate),2),1);
    preBeh = mean(mean(data.onsetsMatrixBeh(onsetIndex:onsetIndex + numOnsets(i) - 1,1:4*samplerate),2),1);
    postDF = mean(max(data.onsetsMatrixDF(onsetIndex:onsetIndex + numOnsets(i) - 1,4*samplerate + 1:6*samplerate + 1),[],2),1);
    postBeh = mean(max(data.onsetsMatrixBeh(onsetIndex:onsetIndex + numOnsets(i) - 1,4*samplerate + 1:6*samplerate + 1),[],2),1);
    diffDF(i) = postDF - preDF;
    diffBeh(i) = postBeh - preBeh;
    onsetIndex = onsetIndex + numOnsets(i);
end
diffDF = reshape(diffDF,length(date),length(mouse))';
diffBeh = reshape(diffBeh,length(date),length(mouse))';


%% Plotting DiffDF

figure();
for i = 1:length(mouse)
   if i <= 3
       plotString = 'bx-';
   else
       plotString = 'rx-';
   end
   plot(diffDF(i,:),plotString);
   hold on
end
hold off