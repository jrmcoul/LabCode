Fs = data.sampleRate;            % Sampling frequency                    
T = 1/Fs;             % Sampling period       
L = length(data.FP);             % Length of signal
t = (0:L-1)*T;        % Time vector
Fc = 5; % Cutoff Frequency in Hz
condition = 'low';

if strcmp(condition, 'high')
    X = data.FP;
    Y = fft(X);
    Y(1:Fc*L/Fs) = 0;
    Y(L-Fc*L/Fs:end) = 0;
    X = ifft(Y);
end
if strcmp(condition, 'low')
    X = data.FP;
    Y = fft(X);
    Y(Fc*L/Fs:L - Fc*L/Fs) = 0;
    X = ifft(Y);
end


figure;
h(1) = subplot(2,1,1);
plot(t,X)
title('Signal Corrupted with Zero-Mean Random Noise')
xlabel('t (milliseconds)')
ylabel('X(t)')
h(2) = subplot(2,1,2);
plot(t,data.FP);
linkaxes(h,'x')

P2 = abs(Y/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);

f = Fs*(0:(L/2))/L;

figure;
plot(f,P1) 
title('Single-Sided Amplitude Spectrum of X(t)')
xlabel('f (Hz)')
ylabel('|P1(f)|')
