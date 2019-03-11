figure(42);
hold on
title('Avg F and Velocity at Onset')
yyaxis right
plot(data.frameTime,smooth(mean(data.dF3.dF,1),100)','r');
ylabel('Fluorescence (dF/F)')
yyaxis left
% shadedErrorBar(data.timeDF, mean(roi.onsetsMatrixBeh,1), std(roi.onsetsMatrixBeh,1), 'k');
plot(data.frameTime,data.vel,'k');
ylabel('Velocity (m/s)')
hold off