% https://www.youtube.com/watch?v=pD7f6X9-_Kg
% How discontinuity distorts the spectrum analysis

fs = 1000; % Sampling frequency
t = 0:1/fs:1-1/fs; % Time vector
f = 50.5; % Frequency not fitting exactly into the FFT frequency bins
x = cos(2*pi*f*t); % Signal

% Apply different windows
rectWindow = rectwin(length(x));
hannWindow = hann(length(x));
xRect = x .* rectWindow';
xHann = x .* hannWindow';

% Perform FFT
nfft = 1024; % Number of FFT points
XRect = fft(xRect, nfft);
XHann = fft(xHann, nfft);
fVect = (0:nfft-1)*fs/nfft; % Frequency vector

% Plot original signal
figure;
subplot(3,1,1);
plot(t, x);
title('Original Time-Domain Signal');
xlabel('Time (s)');
ylabel('Amplitude');

% Plot spectrum with rectangular window
subplot(3,1,2);
plot(fVect, 20*log10(abs(XRect)));
title('Spectrum with Rectangular Window');
xlabel('Frequency (Hz)');
ylabel('Magnitude (dB)');
xlim([0 fs/2]);

% Plot spectrum with Hann window
subplot(3,1,3);
plot(fVect, 20*log10(abs(XHann)));
title('Spectrum with Hann Window');
xlabel('Frequency (Hz)');
ylabel('Magnitude (dB)');
xlim([0 fs/2]);
