function [data_input_processed] = emgbandpass(sf, data_input)
% Description: This MATLAB function carries out signal processing for EMG
% 1. Power hum removal
% 2. Band Pass filter, most of them are carried out by the measurement
% devices
% 3. Rectification using Hilbert transform
% Inputs:
% - data_input: The processed EMG data
% - sf: Sampling frequency
%
% Output:
% - data_input: signal processed EMG data
%
% Additional Notes:
% Author : YKK

temp = data_input.raw - mean(data_input.raw);
data_input.raw = temp;

%% Power hum removal - @50Hz
% Remove 50Hz powerline interference (hum)
data_input_filtered = ft_preproc_dftfilter(data_input.raw, sf, 50)';

cutoff = 200;  % Adjust this cut-off based on  specific application
[b_hp, a_hp] = butter(2, cutoff / (sf / 2), 'high');
data_input_processed = filtfilt(b_hp, a_hp, data_input_filtered);
%% Hilbert Transform - Rectification
% Perform the Hilbert transform to get the analytic signal
analytic_signal = hilbert(data_input_processed);

% Extract the envelope (magnitude of the analytic signal)
data_input_processed  = abs(analytic_signal);
