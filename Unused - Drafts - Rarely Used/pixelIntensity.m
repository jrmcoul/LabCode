filename = 'example2'; %Name this whatever is the final name, minus the '.avi'

vidObj = VideoReader([filename,'.avi']);
vidHeight = vidObj.Height;
vidWidth = vidObj.Width;
s = struct('cdata',zeros(vidHeight,vidWidth,'uint16'));
k = 1;
while hasFrame(vidObj)
    s(k).cdata = readFrame(vidObj);
    k = k+1;
    if mod(k,1000) == 0
        k
    end
end

%%
diffs = size(s(1).cdata);
avgs = zeros(1,length(s));
maxes = zeros(1,length(s));
for frame = 2:length(s)
    diffs = abs(s(frame).cdata - s(frame-1).cdata);
%     figure(10);
%     imagesc(diffs,[0,100]);
%     pause(.01);
    maxes(frame) = max(max(diffs));
    avgs(frame) = mean(mean(diffs));
%     figure(11);
%     hold on
%     plot(frame, avgs(frame),'-rx')
%     xlim([0,frame]);
end

figure;
h(1) = subplot(3,1,1);
plot(smooth(avgs,5));
h(2) = subplot(3,1,2);
plot(maxes);
h(3) = subplot(3,1,3);
plot(data.vel);
linkaxes(h, 'x');
% plot(avgs > 2.8);
% plot(maxes > 30);
% hold on;
% plot(5*abs(data.vel));
% plot(avgs > 8);
% figure;
% plot((maxes > 7) - (avgs > 8))
% for i = 1:10000
%     figure(10);
%     imagesc(s(i).cdata);
%     pause(.01);
%     i
% end

figure;
plot(smooth(avgs,5));
hold on
plot(100*data.vel);