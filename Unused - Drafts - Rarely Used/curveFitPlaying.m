

cellType = 1;
[dist, distSortOrder] = sort(finalMat{cellType}(1,:));
cellNum = finalMat{cellType}(2,distSortOrder);

figure;
plot(dist,cellNum,'x')



k = lsqcurvefit(@logistic,3,dist,cellNum)


fitLine = logistic(k, dist);

hold on
plot(dist,fitLine)

error = cellNum - fitLine;
meanError = mean(error);
stdError = std(error);
figure;
histogram(error,20)



figure;
plot(