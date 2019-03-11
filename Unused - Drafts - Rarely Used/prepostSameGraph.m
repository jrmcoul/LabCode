for postlesion = [0, 1];

if postlesion == false
%%pre-lesion
mouse = {'SW011','SW012','SW018','SW021','SW024','SW025'};
date = {'170201', '170203','170216','170221','170405','170412','170418','170420','170425','170427','170502'};
acq = {'1','2','3','4','5','6'};
else
%%post lesion
mouse = {'sw011','SW011','SW012','SW018','SW021','SW024','SW025'};
date = {'170223', '170224','170301','170427','170428','170504','170505'};
acq = {'1_Post','2_Post','3_Post','4_Post'};
end


condition = 1; % 1 = D1, 2 = D2, 3 = other
norm = false; % true if you want to normalize each trace
avg = true; % true if you want the mean signal at onset/offset instead of summed signal/ false for the sum

[time, finalOnsetsDF, finalOnsetsBeh, finalOffsetsDF, finalOffsetsBeh] = plotMeanOnsetOffset(mouse, date, acq, condition, norm, avg);

% %Optional
% finalOnsetsDF = finalOnsetsDF/max(max(finalOnsetsDF));
% finalOffsetsDF = finalOffsetsDF/max(max(finalOffsetsDF));
% finalOnsetsBeh = finalOnsetsBeh/max(max(finalOnsetsBeh));
% finalOffsetsBeh = finalOffsetsBeh/max(max(finalOffsetsBeh));


colorRed = [1 - postlesion*.5, 0, 0];
colorBlack = [postlesion*.5, postlesion*.5, postlesion*.5];

%plotting
figure(1);
h(1) = subplot(2,1,1);
shadedErrorBar(time, mean(finalOffsetsDF,1), std(finalOffsetsDF,1)/sqrt(size(finalOffsetsDF,1)), {'-','MarkerFaceColor',colorRed},1);
title('mean fluorescence at Offset')
hold on
h(2) = subplot(2,1,2);
% hold on
shadedErrorBar(time, mean(finalOffsetsBeh,1), std(finalOffsetsBeh,1)/sqrt(size(finalOffsetsBeh,1)), {'-','MarkerFaceColor',colorBlack},1);
title('mean velocity at Offset')
hold on
% hold off
linkaxes(h,'x')
xlabel('Time (s)')

figure(2); 
h(1) = subplot(2,1,1);
shadedErrorBar(time, mean(finalOnsetsDF,1), std(finalOnsetsDF,1)/sqrt(size(finalOnsetsDF,1)), {'-','MarkerFaceColor',colorRed,'MarkerEdgeColor',colorRed},1);
title('mean fluorescence at Onset')
hold on
h(2) = subplot(2,1,2);
% hold on
shadedErrorBar(time, mean(finalOnsetsBeh,1), std(finalOnsetsBeh,1)/sqrt(size(finalOnsetsBeh,1)), {'-','MarkerFaceColor',colorBlack,'MarkerEdgeColor',colorBlack},1);
title('mean velocity at Onset')
hold on
% hold off
linkaxes(h,'x')
xlabel('Time (s)')

end

