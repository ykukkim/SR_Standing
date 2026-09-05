function [dataf] = filterdata(data, samprate)
%% Filter

% Bandpass filter design parameters
low_cutoff = 0.5;
high_cutoff = 30;
[b, a] = butter(2, [low_cutoff high_cutoff]/(samprate/2), 'bandpass'); % 2nd-order Butterworth bandpass filter

% Apply the high-pass Butterworth filter with zero phase-lag
% using filtfilt to avoid phase shift
dataf = filtfilt(b, a, data);
