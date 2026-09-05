function [meanfreq] = meanfrequency(data,sampling_rate) % mean power frequency


Nfft = 2^nextpow2(length(data));
% fast fourier transform
amp = fft(data, Nfft);
amp(1) = 0;	% 1st component of y is sum of data and is removed
m = Nfft/2;
pwr = abs(amp(1:m)).^2;	% calculates power spectrum array
nyquist = 1/2;
freq = ((0:m-1)/m)*nyquist*sampling_rate;     % calculates array of frequencies

% plots data in frequency domain
%figure(1),plot(freq,pwr),xlabel('frequency(Hz)'),ylabel('power'),axis([min(freq) 10 min(pwr) max(pwr)]);

meanfreq = sum(pwr.*freq')/sum(pwr);
