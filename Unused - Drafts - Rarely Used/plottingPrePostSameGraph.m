for postlesion = [0,1]

prelesion = ~postlesion;

if prelesion
    mouse = {'F011'};
    date = {'170406','170413','170417'};
    acq = {'1','2','3'};
end

if postlesion
    mouse = {'F011'};
    date = {'170420','170421'};
    acq = {'1','2','3'};
end




% if prelesion
%     mouse = {'F012'};
%     date = {'170406','170413','170417'};
%     acq = {'1_left','2_left','3_left','4','5','6'};
% end
% 
% if postlesion
%     mouse = {'F012'};
%     date = {'170420','170421'};
%     acq = {'1_left','2_left','3_left','4','5','6'};
% end





condition = 0;
norm = false;
avg = false;

[time, finalOnsetsDF, finalOnsetsBeh, finalOffsetsDF, finalOffsetsBeh] = plotMeanOnsetOffset(mouse, date, acq, condition, norm, avg);


if prelesion
    timeTemp = time;
    finalOnsetsDFTemp = finalOnsetsDF;
    finalOnsetsBehTemp = finalOnsetsBeh;
    finalOffsetsDFTemp = finalOffsetsDF;
    finalOffsetsBehTemp = finalOffsetsBeh;
end

end

%plotting downsampled data
% figure;
% h(1) = subplot(2,1,1);
% hold on
% shadedErrorBar(downsample(timeTemp,100), downsample(mean(finalOffsetsDFTemp,1),100), downsample(std(finalOffsetsDFTemp,1)/sqrt(size(finalOffsetsDFTemp,1)),100), 'g',1);
% shadedErrorBar(downsample(time,100), downsample(mean(finalOffsetsDF,1),100), downsample(std(finalOffsetsDF,1)/sqrt(size(finalOffsetsDF,1)),100), 'r',1);
% hold off
% title('mean fluorescence at Offset')
% h(2) = subplot(2,1,2);
% hold on
% shadedErrorBar(downsample(timeTemp,100), downsample(mean(finalOffsetsBehTemp,1),100), downsample(std(finalOffsetsBehTemp,1)/sqrt(size(finalOffsetsBehTemp,1)),100), 'g',1);
% shadedErrorBar(downsample(time,100), downsample(mean(finalOffsetsBeh,1),100), downsample(std(finalOffsetsBeh,1)/sqrt(size(finalOffsetsBeh,1)),100), 'r',1);
% hold off
% title('mean velocity at Offset')
% linkaxes(h,'x')
% xlabel('Time (s)')

figure;
h(1) = subplot(2,1,1);
hold on
shadedErrorBar(downsample(timeTemp,100), downsample(mean(finalOnsetsDFTemp,1),100), downsample(std(finalOnsetsDFTemp,1)/sqrt(size(finalOnsetsDFTemp,1)),100), 'g',1);
shadedErrorBar(downsample(time,100), downsample(mean(finalOnsetsDF,1),100), downsample(std(finalOnsetsDF,1)/sqrt(size(finalOnsetsDF,1)),100), 'r',1);
hold off
title('mean fluorescence at Onset')
h(2) = subplot(2,1,2);
hold on
shadedErrorBar(downsample(timeTemp,100), downsample(mean(finalOnsetsBehTemp,1),100), downsample(std(finalOnsetsBehTemp,1)/sqrt(size(finalOnsetsBehTemp,1)),100), 'g',1);
shadedErrorBar(downsample(time,100), downsample(mean(finalOnsetsBeh,1),100), downsample(std(finalOnsetsBeh,1)/sqrt(size(finalOnsetsBeh,1)),100), 'r',1);
hold off
title('mean velocity at Onset')
linkaxes(h,'x')
xlabel('Time (s)')

% 
% % Plotting all DF/F and Velocity Traces for ONSET
% figure();
% subplot(2,1,1)
% title('DF Traces at Onset')
% hold on
% for trace = 1:size(finalOnsetsDF,1)
%     plot(time, finalOnsetsDF(trace,:));  
% end
% hold off
% subplot(2,1,2)
% title('Velocity Traces at Onset')
% hold on
% for trace = 1:size(finalOnsetsBeh,1)
%     plot(time, finalOnsetsBeh(trace,:));  
% end
% xlabel('Time (s)')
% hold off
% 
% % Plotting all DF and Velocity Traces for OFFSET
% figure();
% subplot(2,1,1);
% title('DF Traces at Offset')
% hold on
% for trace = 1:size(finalOffsetsDF,1)
%     plot(time, finalOffsetsDF(trace,:));  
% end
% hold off
% subplot(2,1,2);
% title('Velocity Traces at Offset')
% hold on
% for trace = 1:size(finalOffsetsBeh,1)
%     plot(time, finalOffsetsBeh(trace,:));  
% end
% xlabel('Time (s)')
% hold off