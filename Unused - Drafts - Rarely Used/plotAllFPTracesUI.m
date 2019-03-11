[trials, pathname] = uigetfile('*.mat','MultiSelect','on');

cd(pathname)
totalFiles = 0;

MPP = 4;
MPH = 3;
MINW = 6;
roi = {};

for trial = 1:length(trials);
	load(trials{trial});                               
	totalFiles = totalFiles + 1
    
    if mod(totalFiles,2) == 1
    figure;
    plot(abs(data.FPNorm));
    hold on
    else
        plot(abs(data.FPNorm));
        hold off
    end
                    
end

a = abs(fourierFilt(data.FP,5,data.sampleRate,'low'));
window = ceil(20*data.sampleRate);
for i = 1:length(a) - window
    b(i) = min(a(i:i+window));
end
figure;
plot(b);
    
    
