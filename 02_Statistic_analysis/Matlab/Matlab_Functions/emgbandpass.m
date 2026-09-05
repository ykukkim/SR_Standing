function [data_input] = emgbandpass(sf, data_input,doplot)
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
data_input.Power_removed = ft_preproc_dftfilter(data_input.raw,sf,50)';

%% Filter
% Online BP @ 20 - 450 sampled at x by Delsys

%% Rectification
% data_input.rectifiedEMG = abs(hilbert(data_input.Power_removed));
data_input.rectifiedEMG = data_input.raw;

%% Plot of frquency spectrum
if doplot == 1
    % FFT
    N = length(data_input.raw(:,1));
    freqs=0:sf/N:(sf/2);
    BP_filtered        = fft(data_input.Power_removed_detrended(:,1)).*conj(fft(data_input.Power_removed_detrended(:,1)));

    BP_filtered_rect   = fft((data_input.HP(:,1))).*conj(fft(data_input.HP(:,1)));

    h = figure;title('Single-sided Power spectrum (Hertz) for EMG');
    subplot(4,1,1);
    plot(freqs,[abs(raw_detrended(1:N/2+1)) abs(raw_detrended_rect(1:N/2+1))]);hold on;
    xlabel('Frequency (Hz)'); ylabel('Power (dB)');legend('Non-Rect','Rect');
    subplot(4,1,2);
    plot(freqs,[abs(raw_detrended(1:N/2+1)) abs(Power_removed(1:N/2+1))]);hold on;
    xlabel('Frequency (Hz)'); ylabel('Power (dB)');legend('Non-Rect','Non-Rect Power Removed');
    subplot(4,1,3);
    plot(freqs,[abs(Power_removed(1:N/2+1)) abs(Power_removed_rect(1:N/2+1))]);hold on;
    xlabel('Frequency (Hz)');ylabel('Power (dB)');legend('Non-Rect-Power-removed','Rect-Power-removed');
    subplot(4,1,4)
    plot(freqs,abs(BP_filtered(1:N/2+1)));hold on;
    plot(freqs,abs(BP_filtered_rect(1:N/2+1)));hold on;

    xlabel('Frequency (Hz)');ylabel('Power (dB)');legend('BP-filtered','BP-filtered-Rect');
end
