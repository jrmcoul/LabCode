[movNames, movPath] = uigetfile('*.tif','MultiSelect','on');
movNames = sort(movNames);

cd(movPath)
movies = {};
movRegistered = {};
tform = {};
for movie = 1:length(movNames)
    tempMov = tiffRead(movNames{movie});
    movies{movie} = tempMov(:,:,2);
end

[optimizer, metric] = imregconfig('multimodal');
transformType = 'rigid';

tform{1} = [];
movieRegStack = movies{1};
for regNum = 2:length(movNames)
    tform{regNum} = imregtform(movies{regNum},movies{1},'rigid',optimizer,metric);
    movieRegStack = cat(3,movieRegStack,imwarp(movies{regNum},tform{regNum},'OutputView',imref2d(size(movies{1}))));
end
disp('Registration Complete!')

newImg = maskRegistered{1} > 0;
figure(1);
imshow(imfuse(movieRegStack(:,:,1),newImg,'Scaling','none'),[min(min(movies{1})),max(max(movies{1}))]);
for i = 1:size(centroids{2},1);
    t = text(round(centroids{2}(i,1)),round(centroids{2}(i,2)), num2str(i), 'FontSize', 10, 'Color', [1, 1, 1]);
end

% imshow3D(movieRegStack,[min(min(movies{1})),max(max(movies{1}))],centroids) 
% t = text(250,250, 'helloooo', 'FontSize', 10, 'Color', [1, 0, 0]);


% tform{2} = imregtform(moving{2},fixed,'rigid',optimizer,metric);
% movingRegistered{2} = imwarp(moving{2},tform{2},'OutputView',imref2d(size(fixed)));

% figure; 
% subplot(1,2,1);
% imshow(fixed,[min(min(fixed)),max(max(fixed))])
% % subplot(1,3,2);
% % imshow(moving_reg,[32000,34000])
% subplot(1,2,2);
% imshow(movingRegistered,[32000,34000])
% c = cat(3,fixed,movingRegistered{1},movingRegistered{2});
% figure; imshow3D(c,[min(min(fixed)),max(max(fixed))])
% 
%    fileFolder = 'C:\Users\labadmin\Documents\MATLAB\Registration Testing\';
%    dirOutput = dir(fullfile(fileFolder,'*.jpg'));
%    fileNames = {dirOutput.name};
%    montage(fileNames);
%% Calculating distance between ROIs

cd('C:\Users\labadmin\Documents\MATLAB\Calcium Data\');
centroids = {};
maskRegistered = {};
for dataset = 1:length(movNames)
    datafile = [movNames{dataset}(1:end-3),'mat'];
    load(datafile);
    
    for cellType = 1:1
        if cellType == 1
            temp = data.dF1;
        else if cellType == 2
                temp = data.dF2;
            else if cellType == 3
                    temp = data.dF3;
                end
            end
        end

        
        mask = zeros(512, 512);
        for i = 1:length(temp.roiList)
            tempROI = temp.roiList(i).indBody(~isnan(temp.roiList(i).indBody));
            mask(tempROI) = i;
%     coordinates = [ceil(tempROI/512), mod(tempROI-1,512)+1];
%     centroids(i,:) = mean(coordinates,1);
%     mask = insertText(mask,centroids(i,:),i);
        end

        if dataset > 1
            maskRegistered{dataset} = imwarp(mask,tform{dataset},'OutputView',imref2d(size(movies{1})));
        else
            maskRegistered{dataset} = mask;
        end
            
            
        for i = 1:1:length(temp.roiList)
            tempROI = find(maskRegistered{dataset} == i);
            coordinates = [ceil(tempROI/512), mod(tempROI-1,512)+1];
            centroids{dataset}(i,:) = mean(coordinates,1);
        end

        figure(dataset+1);
%         subplot(1,3,cellType)
        imshow(maskRegistered{dataset})
%         for i = 1:size(centroids,1);
%             t = text(round(centroids(i,1)),round(centroids(i,2)), num2str(i), 'FontSize', 10, 'Color', [1, 0, 0]);
%         end
    end
end

% imagesc(maskRegistered)