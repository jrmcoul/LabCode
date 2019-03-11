%% Plotting Velocity with Onsets and Offsets
figure();
title('Velocity with Onsets and Offsets')
ylabel('Velocity(m/s)')
xlabel('Time (s)')
hold on
plot(data.frameTime, data.vel);
stem(data.indOnsetsRest/data.framerate,.05*ones(length(data.indOnsetsRest),1))
stem(data.indOffsetsRest/data.framerate,.05*ones(length(data.indOffsetsRest),1))
hold off