figure;
plot(data.vel);
hold on;
stem(data.indOnsets,.1*ones(size(data.indOnsets)));
stem(data.indOffsets,.1*ones(size(data.indOnsets)));