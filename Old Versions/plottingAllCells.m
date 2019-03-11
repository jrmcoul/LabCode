%% Plotting all Cells Calcium w/Wheel + imagesc
dist = 4;
offset = -5;
scale = 20;
figure;
hold on;
% totalCells = cat(1,scale*data.vel,scale*smooth(mean(data.dF1.dF,1),2*data.framerate)',scale*smooth(mean(data.dF2.dF,1),2*data.framerate)',data.dF1.dF,data.dF2.dF);
totalCells = cat(1,scale*data.vel,data.dF1.dF,data.dF2.dF(1:end-4,:)); %end - 4 is because of this acquisition
% totalCells = cat(1,scale*data.vel,data.dF1.dF,data.dF2.dF);
numD1 = size(data.dF1.dF,1);
threshold = .002;
mov = abs(data.vel) > threshold;
for i = 1:size(totalCells,1)
%     inMot = NaN(1,length(totalCells));
%     atRest = NaN(1,length(totalCells));
%     inMot(find(mov)) = totalCells(i,find(mov));
%     atRest(find(~mov)) = totalCells(i,find(~mov));
    
    if i == 1
        plot(data.frameTime,scale*data.vel - 8);
    else if i <= numD1
            plot(data.frameTime,offset + totalCells(i,:),'Color',[0.8,0,0]);
%         plot(data.frameTime,offset + atRest,'r.','MarkerSize',0.5);
%         plot(data.frameTime,offset + inMot,'k.','MarkerSize',0.5);
        else
            plot(data.frameTime,offset + totalCells(i,:),'Color',[0,0.8,0]);
%         plot(data.frameTime,offset + atRest,'g.','MarkerSize',0.5);
%         plot(data.frameTime,offset + inMot,'k.','MarkerSize',0.5);
        end
    end
    offset = offset + dist;
end
a = area(data.frameTime,dist*size(totalCells,1)*mov,'FaceColor','k','EdgeColor','none');
a.FaceAlpha = 0.1;


figure;
colormap(bone)
smoothedCells = zeros(size(totalCells));
for i = 1:size(totalCells,1)
%     smoothedCells(i,:) = totalCells(i,:)/max(totalCells(i,:));
    smoothedCells(i,:) = smooth(totalCells(i,:),round(10*data.framerate))';
end
% imagesc(smoothedCells,[0,.5]);
imagesc(totalCells,[.25,.7]);

%% Plotting Raster

MPP = 4;
MPH = 3;
MINW = 6;
roi{1} = data.dF1;
roi{2} = data.dF2;
counter = 0;
figure;
title('Calcium Spikes, Raster Plot')
ylabel('Cell #')
xlabel('Time (s)')
hold on
threshold = .002;
shift = 0;
mov = abs(data.vel) > threshold;
for iShift = 1:shift
    mov = [mov(1+shift:end),zeros(1,shift)] | mov | [zeros(1,shift),mov(1:end-shift)];
end

for cellType = 1:2;
    
    roi{cellType}.peakFreqRestMot = zeros(size(roi{cellType}.dF,1),2);
    numSpikesCell = zeros(size(roi{cellType}.dF,1),2);
    
    roiData = data;
    
    roi2 = zeros(size(roi{cellType}.dF));
    % Z-scoring Cells
    for cellROI = 1:size(roi{cellType}.dF,1)
        roi2(cellROI,:) = zscore(roi{cellType}.dF(cellROI,:));
    end
    
    for cellROI = 1:size(roi2,1)
        inMot = NaN(1,size(roi2,2));
        atRest = NaN(1,size(roi2,2));
        raster = NaN(1,size(roi2,2));
        warning('OFF');
        [tempPKS, tempLOCS] = findpeaks(roi2(cellROI,:),'MinPeakProminence', MPP, 'MinPeakHeight', MPH, 'MinPeakWidth', MINW);
        inMot(tempLOCS(find(mov(tempLOCS)))) = counter;
        atRest(tempLOCS(find(~mov(tempLOCS)))) = counter;
        raster(tempLOCS) = counter;
        if cellType == 1
            plot(data.frameTime,atRest,'k.')
            plot(data.frameTime,inMot,'r.')
        else
            plot(data.frameTime,atRest,'k.')
            plot(data.frameTime,inMot,'g.')
        end
 
        counter = counter + 1;
    end

end

a = area(data.frameTime,counter*mov,'FaceColor','k','EdgeColor','none');
a.FaceAlpha = 0.1;

%% Plotting Vel and Mean DF
figure;
subplot(2,1,1);
plot(data.frameTime,smooth(data.vel,2*data.framerate)');
subplot(2,1,2);
hold on
plot(data.frameTime,smooth(mean(data.dF1.dF,1),2*data.framerate)','r');
plot(data.frameTime,smooth(mean(data.dF2.dF(1:end-4,:),1),2*data.framerate)','g');
mov = abs(data.vel) > threshold;
a = area(data.frameTime,.16*mov,'FaceColor','k','EdgeColor','none');
a.FaceAlpha = 0.1;
