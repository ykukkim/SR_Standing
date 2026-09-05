function [pwr, n_pwr, pwr_sum, freq] = calculateSpectralPowerBands_EmG(data,Nfft, segement_size,sampling_rate)
% Description: The function applies Welch's method using pwelch to calculate and normalize the power spectrum.
% Inputs:
% - data: The raw EMG data.
% - freq_resolution: Desired frequency resolution in Hz.
% - sampling_rate: The frequency at which the data was sampled.
%
% Outputs:
% - pwr: Power spectrum calculation.
% - n_pwr: Normalized power spectrum.
% - pwr_sum: Sum of power spectrum.
% - freq: Frequency array.

data = data - mean(data);
amp = fft(data, Nfft);
amp(1) = 0;

half_Nfft = Nfft / 2 + 1; % Half index for mirroring in FFT
pwr = abs(amp(1:half_Nfft)).^2; % Power spectrum calculation.

% Frequency array creation
freq = (0:(half_Nfft-1))' * (sampling_rate / Nfft); % Column vector
pwr_sum = sum(pwr);
n_pwr = pwr / pwr_sum; % Normalized power spectrum

end