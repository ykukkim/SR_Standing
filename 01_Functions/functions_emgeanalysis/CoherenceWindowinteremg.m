function [emgcoherence] = CoherenceWindowinteremg(emgData,samplingRate)
%
% Description: This MATLAB function calculates the coherence and power spectral density between muscles.
% Various analysis techniques:
% - magnitude-squared coherence,
%       cross power spectral density
%       power spectral density estimates
% -neurospec coherence analysis.

% Inputs:
% - emgData: Electromyography (EMG) data.
% - samplingRate: Sampling rate of the data.
% - inputName: Name of the input data.
%
% Output:
% - coherence: A structure containing the coherence analysis results.
%   - crpwrAll: Cross power spectral density estimates.
%   - cfreqAll: Frequency values for cross power spectral density.
%   - pwrcopAll: Power spectral density estimates for COP data.
%   - pwremgAll: Power spectral density estimates for EMG data.
%   - cohereAll: Coherence values calculated without using mscohere for validation.
%   - phaseAll: Phase spectrum values.
%   - cohereneurospec: Coherence values from neurospec coherence analysis.
%   - phaseneurospec: Phase values from neurospec coherence analysis.
%   - cumdenneurospec: Cumulant density values from neurospec coherence analysis.
%   - specCoeff1neurospec, specCoeff2neurospec, specCoeff3neurospec: Spectral coefficients from neurospec coherence analysis.
%   - clneurospec: Confidence level from neurospec coherence analysis.
%
% Nested Function:
% - coherenceneurospec: A function that performs the neurospec coherence analysis. It calculates coherence, phase, cumulant density, spectral coefficients, and confidence level.

% Define coherence analysis parameters
segment_size = samplingRate*2; % data segment size to be deteremined by seconds

% Initialize results storage
emgcoherence = struct();
countcol = 0;

window_names = {'None','Hanning', 'Tukeywin', 'Dpss'};
window_args = {'N','H', 'W2', 'M3'};

% Loop through each pair of channels to calculate coherence
for channel = 1:size(emgData, 2)
    if channel <= 5
        for columnnew = channel + 1:size(emgData, 2)
            % Preprocess data for both channels
            temp_emg1 = (emgData(:, channel) - mean(emgData(:, channel))) / std(emgData(:, channel));
            temp_emg2 = (emgData(:, columnnew) - mean(emgData(:, columnnew))) / std(emgData(:, columnnew));
            countcol = countcol + 1;

            % Compute coherence for each window type
            for w = 1:length(window_names)
                win_name = window_names{w};
                win_arg = window_args{w};

                % Calculate coherence and other parameters
                [emgcohere, emgspectra,emgspectra2,...
                    emgfreq, emgphasen, emgautospec1, emgautospec2, emgcrossspec12, emgcl] = ...
                    coherenceneurospec(temp_emg1, temp_emg2, samplingRate, segment_size, win_name, win_arg);
                coherence_fieldname = ['cohere_', win_name];

                emgcoherence.(coherence_fieldname).emgcohere(:, countcol) = emgcohere;
                emgcoherence.(coherence_fieldname).emgspectra(:, channel) = emgspectra;
                emgcoherence.(coherence_fieldname).emgfreq(:, countcol) = emgfreq;
                emgcoherence.(coherence_fieldname).emgphasen(:, countcol) = emgphasen;
                emgcoherence.(coherence_fieldname).emgautospec1(:, countcol) = emgautospec1;
                emgcoherence.(coherence_fieldname).emgautospec2(:, countcol) = emgautospec2;
                emgcoherence.(coherence_fieldname).emgcrossspec12(:, countcol) = emgcrossspec12;
                emgcoherence.(coherence_fieldname).emgcl(countcol) = emgcl;

                if channel == 5 && columnnew == 6
                 emgcoherence.(coherence_fieldname).emgspectra(:, columnnew) = emgspectra2;
                end

            end
        end
    else
        continue;
    end
end
end

function [coherence, spectra,spectra2, freq, phase, specCoeff1, specCoeff2, ...
    specCoeff3, cl] = coherenceneurospec(channel1,channel2, samplingrate,segment_size,win_name,opt_str)
seg_pwr = nextpow2(segment_size);
[f,~,cl, sc]=sp2a2_R2_mt(channel1,channel2,samplingrate,seg_pwr,win_name,opt_str);
freq = [0; f(:,1)];
spectra = [0; f(:,6)];
spectra2 = [0; f(:,7)];
coherence = [0; f(:,4)];
phase = [0; f(:,5)];
specCoeff1 = [0; sc(2:end,1)]; % f11
specCoeff2 = [0; sc(2:end,2)]; % f22
specCoeff3 = [0; sc(2:end,3)]; % f21
end