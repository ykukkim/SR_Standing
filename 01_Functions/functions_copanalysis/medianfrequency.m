function [ medianfreq ] = medianfrequency(data,sampling_rate)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

Nfft = 2^nextpow2(length(data));
% fast fourier transform
amp = fft(data, Nfft);
amp(1) = 0;	% 1st component of y is sum of data and is removed
m = Nfft/2;
pwr = abs(amp(1:m)).^2;	% calculates power spectrum array
nyquist = 1/2;
freq = ((0:m-1)/m)*nyquist*sampling_rate;     % calculates array of frequencies
pwr_disp = cumsum(pwr); %NOT quiet sure if the cumulative sum is requiered!

% idea from: http://www.mathworks.com/matlabcentral/answers/14375-median-frequency
topHalf = find(pwr_disp>=pwr_disp(end)/2,1,'first'); %finds the first bin where power is biggern than 1/2 of cumulative power
bottomHalf = find(pwr_disp<=pwr_disp(end)/2,1,'last'); %finds the last bin where power is smaller than 1/2 of cumulative power
medianfreq = (freq(topHalf)+freq(bottomHalf))/2; %returns mean of both frequencies corresponding to the bins

% plots data in frequency domain
%figure(1),plot(freq,pwr),xlabel('frequency(Hz)'),ylabel('power'),axis([min(freq) 10 min(pwr) max(pwr)]);



end
