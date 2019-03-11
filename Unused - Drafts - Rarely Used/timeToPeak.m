close all;

condition = 3; % defines condition to look at
timeWindow = [0,1000]; % defines window to plot
maxes = [];
maxInd = [];
mins = [];
minInd = [];
isMax = [];
threshWindow = [10,400]; % defines window in which to search peak
peakTime = [];
peakAmp = [];
peakDF = [];
peakAmpThresh = .0075; % defines threshold for peak prominence

for trial = 1:length(data(condition).photo) % looping through all trials
    
    % Taking a specific window to look for peak, defined by timeWindow
    indices = find(data(condition).photo{trial}(:,1) >= timeWindow(1) & data(condition).photo{trial}(:,1) <= timeWindow(2))';
    
    % Only looking at trials where desired time points exist
    if length(indices) == 1001
        photo = smooth(data(condition).photo{trial}(indices,2),30)'; % creating window of DF data
        
        maxes(trial) = max(photo(threshWindow(1):threshWindow(2))); % absolute max in smaller threshWindow
        maxInd(trial) = find(photo == max(photo(threshWindow(1):threshWindow(2))),1); % index of max
        mins(trial) = min(photo(threshWindow(1):threshWindow(2))); % absolute min in smaller threshWindow
        minInd(trial) = find(photo == min(photo(threshWindow(1):threshWindow(2))),1); % index of min

        window = [threshWindow(1):threshWindow(2)]; % x data points for fitting function
        p = polyfit(window, photo(threshWindow(1):threshWindow(2)),2); % creating polynomial fit function
        
        isMax(trial) = p(1) < 0; % is polynomial - or + (is signal a max or min, respectively)
        
        % Determining if max or min should be used, based on isMax
        if isMax(trial)
            peakTime(trial) = maxInd(trial);
        else
            peakTime(trial) = minInd(trial);
        end
        
        % If peak of parabola is outside window, DF peak doesn't exist
        if -p(2)/(2*p(1)) > threshWindow(2) || -p(2)/(2*p(1)) < threshWindow(1)
            peakTime(trial) = nan;
        end
        
        % If peak of parabola is inside window, but max is still near
        % threshWindow edge, define DF peak as left of parabola peak
        if peakTime(trial) > threshWindow(2) - 15 && isMax(trial)
            peakTime(trial) = find(photo == max(photo(1:floor(-p(2)/(2*p(1))))),1);
        end
        if peakTime(trial) > threshWindow(2) - 15 && ~isMax(trial)
            peakTime(trial) = find(photo == min(photo(1:floor(-p(2)/(2*p(1))))),1);
        end
        
        % Calculating relative peak amplitude, and absolute peakDF
        if ~isnan(peakTime(trial)) && isMax(trial)
            peakAmp(trial) = photo(peakTime(trial)) - min(photo(1:peakTime(trial)));
            peakDF(trial) = photo(peakTime(trial));
        else if ~isnan(peakTime(trial)) && ~isMax(trial)
            peakAmp(trial) = photo(peakTime(trial)) - max(photo(1:peakTime(trial)));
            peakDF(trial) = photo(peakTime(trial));
            else
            peakAmp(trial) = nan;
            peakDF(trial) = nan;
            end
        end
        
        % Throwing out peaks that are below threshold
        if abs(peakAmp(trial)) < peakAmpThresh
            peakTime(trial) = nan;
            peakDF(trial) = nan;
        end
        
        % Plotting every 10 trials
        if mod(trial+3,10) == 0
            figure;
            plot(photo);
            hold on
            plot(window , p(1)*window.^2 + p(2)*window + p(3));
            title(num2str(peakAmp(trial)))
            if ~isnan(peakTime(trial))
                stem(peakTime(trial),peakDF(trial));
            end
        end
    end
end

% figure;
% plot(maxes);
% figure;
% plot(maxMinusMin);
% figure;
% plot(mins);
%  for trial = 1:10
%      plot(N366A6(3).photo{trial}(:,1), smooth(N366A6(3).photo{trial}(:,2),100));
%      hold on
%  end