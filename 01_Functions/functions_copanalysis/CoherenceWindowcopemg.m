function [emgcopcoherence] = CoherenceWindowcopemg(copData, emgData, samplingRate, inputName)
%
% Description: This MATLAB function calculates the coherence and power spectral density between COP and EMG data.
% Various analysis techniques:
% - magnitude-squared coherence,
%       cross power spectral density
%       power spectral density estimates
% -neurospec coherence analysis.
%
% Inputs:
% - copData: Center of pressure (COP) data.
% - emgData: Electromyography (EMG) data.
% - averaging_factor: Window averaging factor.
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
% Define coherence analysis parameters
segment_size = samplingRate*0.5; % data segment size to be deteremined by seconds
emgcopcoherence = struct();
notes = {'x','y'};
window_names = {'None','Hanning', 'Tukeywin', 'Dpss'};
window_args = {'N','H', 'W2', 'M3'};

% Loop through each channel
for channel = 1:size(emgData, 2)
    for axis = 1:size(copData, 2)

        % Select axis note
        fieldName = [inputName, notes{axis}];

        temp_cop = (copData(:, axis) - mean(copData(:, axis))) / std(copData(:, axis));
        temp_emg = (emgData(:, channel) - mean(emgData(:, channel))) / std(emgData(:, channel));

        % Compute coherence for each window type
        for w = 1:length(window_names)
            win_name = window_names{w};

            % Calculate coherence
            coherence_fieldname = ['cohere_', win_name];

            %% Neurospec coherence analysis
            [emgcopcoherence.(fieldName).(coherence_fieldname).emgcopcohere(:, channel), ...
                emgcopcoherence.(fieldName).(coherence_fieldname).copspectra(:, 1), ...
                emgcopcoherence.(fieldName).(coherence_fieldname).emgcopfreq(:, channel), ...
                emgcopcoherence.(fieldName).(coherence_fieldname).emgcopphasen(:, channel), ...
                emgcopcoherence.(fieldName).(coherence_fieldname).emgcopcrossspec12(:, channel), ...
                emgcopcoherence.(fieldName).(coherence_fieldname).emgcopautospec1(:, channel), ...
                emgcopcoherence.(fieldName).(coherence_fieldname).emgcopautospec2(:, channel), ...
                emgcopcoherence.(fieldName).(coherence_fieldname).emgcopcl(channel)] = ...
                    coherenceneurospec(temp_cop, temp_emg, samplingRate, segment_size,win_name,window_args{w});
        end
    end
end
end

% Neurospec coherence analysis function
function [coherence, spectra, freq, phase, specCoeff1, specCoeff2, ...
    specCoeff3, cl] = coherenceneurospec(cop,emg, samplingrate,segment_size,win_name,opt_str)

seg_pwr = nextpow2(segment_size);
seglength = nextpow2(size(cop,1));
addlength = seglength - size(emg,1);
emgAdd = (mean(emg, 1).' * ones([addlength, 1]).').';
copAdd = (mean(cop, 1).' * ones([addlength, 1]).').';
emgneurospec = [emg; emgAdd]; % padding
copneurospec = [cop; copAdd]; % padding
[f,~,cl, sc]=sp2a2_R2_mt(copneurospec,emgneurospec,samplingrate,seg_pwr,win_name,opt_str);
freq = [0; f(:,1)];
spectra = [0; f(:,6)];
coherence = [0; f(:,4)];
phase = [0; f(:,5)];
specCoeff1 = [0; sc(2:end,1)]; % f11
specCoeff2 = [0; sc(2:end,2)]; % f22
specCoeff3 = [0; sc(2:end,3)]; % f21
end
