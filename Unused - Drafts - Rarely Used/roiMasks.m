%% Calculating distance between ROIs

temp = data.dF1;
% temp = data.dF2;
% temp = data.dF3;

mask = zeros(512, 512);
for i = 1:length(temp.roiList)
    mask(temp.roiList(i).indBody(~isnan(temp.roiList(i).indBody))) = 1;
%     coordinates = [mod(original-1,512)+1, ceil(original/512)];
%     centroids(i,:) = mean(coordinates,1);
end

figure;
imagesc(mask)
% temp.centroids = centroids;
% 
% data.dF1 = temp;
% data.dF2 = temp;
% data.dF3 = temp;
% 
% distmatrix = dist([data.dF1.centroids,data.dF2.centroids,data.dF3.centroids]');

% data.distMat =
% figure; plot(coordinates(:,1),coordinates(:,2),'x', centroids(4,1),centroids(4,2),'r^')