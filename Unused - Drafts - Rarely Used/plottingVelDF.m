for postlesion = [0, 1];

if postlesion == false
% %%pre-lesion (D1)
% mouse = {'F014','F016'};
% date = {'170502','170504','170509'};
% acq = {'1','2','3'};
% else
% %%post lesion
% mouse = {'F014','F016'};
% date = {'170511','170512','170517','170524'};
% acq = {'1','2','3'};
% end

%%pre-lesion (A2A)
mouse = {'F007','F009','F010'};
date = {'170303','170307','170309','170315','170321','170406','170413','170417'};
acq = {'1','2','3','4','5','6'};
else
%%post lesion
mouse = {'F007','F009','F010'};
date = {'170323','170325','170330','170406','170420','170421','170426'};
acq = {'1','2','3'};
end


condition = 0; % 1 = D1, 2 = D2, 3 = other
norm = false; % true if you want to normalize each trace
avg = true; % true if you want the mean signal at onset/offset instead of summed signal/ false for the sum

[time, finalOnsetsDF, finalOnsetsBeh, finalOffsetsDF, finalOffsetsBeh] = plotMeanOnsetOffset(mouse, date, acq, condition, norm, avg);

figure();
for bout = 1:size(finalOnsetsDF,1)
%plotting
plot(finalOnsetsBeh(bout,:),finalOnsetsDF(bout,:));
title('Fluorescence vs. Velocity')
xlabel('Velocity (m/s)')
ylabel('Fluorescence (DF/F)')
hold on
end
hold off

figure(); 
plot(mean(finalOnsetsBeh,1), mean(real(finalOnsetsDF),1));

end

