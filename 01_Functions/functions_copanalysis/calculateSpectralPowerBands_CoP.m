function [pwr, n_pwr, freq, pwr_sum,  ...
    abspowerBelow0_5Hz, abspower0_5to2Hz, abspowerAbove2Hz] ...
    = calculateSpectralPowerBands_CoP(data, samplingRate,freq_resoltuion) % Power spectrum calculation
% Description: The function applies (FFT), then calculates and normalizes the power spectrum.
% Inputs:
% - data: The raw CoP data.
% - samplingRate: The frequency at which the data was sampled.
% - average_factor: The factor used in averaging the power spectrum.
%
% Outputs:
% - pwr: Power spectrum calculation.
% - n_pwr: Normalized power spectrum.
% - freq: Frequency array.
% - pwr_sum: Sum of power spectrum.
% - npwr_sum: Sum of normalized power spectrum.
% - freq_sum: Sum of frequency array.
% - abspowerLongLatency: Absolute power in long latency band (<= 3 Hz).
% - abspowerMediumLatency: Absolute power in medium latency band (> 3 and <= 10 Hz).
% - abspowerShortLatency: Absolute power in short latency band (> 10 and <= 30 Hz).
% Author: YKK

Nfft = 2^(nextpow2(samplingRate / freq_resoltuion)-1);
data = data - mean(data);
amp = fft(data, Nfft);
amp(1) = 0;

half_Nfft = Nfft / 2 +1; % Half index for mirroring in FFT
pwr = abs(amp(1:half_Nfft)).^2; % Power spectrum calculation.

% Frequency array creation
freq = (0:(half_Nfft-1))' * (samplingRate / Nfft); % Column vector
pwr_sum = sum(pwr);
n_pwr = pwr / pwr_sum; % Normalized power spectrum

% Define latency bands
bandBelow0_5HzID = freq <= 0.5;           % Energy below 0.5 Hz
band0_5to2HzID = (freq > 0.5) & (freq <= 2);   % Energy between 0.5 and 2 Hz
bandAbove2HzID = freq > 2;               % Energy above 2 Hz

% Absolute power in latency bands
abspowerBelow0_5Hz = sum(n_pwr(bandBelow0_5HzID));
abspower0_5to2Hz = sum(n_pwr(band0_5to2HzID));
abspowerAbove2Hz = sum(n_pwr(bandAbove2HzID));

end
