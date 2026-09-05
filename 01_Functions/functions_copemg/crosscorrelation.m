function Crosscorrelation = crosscorrelation(inputDataResampled, emgData, sf, inputName)
% Description: This MATLAB function calculates the cross-correlation of the resampled input data with EMG data.
% It returns the highest correlation and corresponding time shift.
%
% Inputs:
% - inputDataResampled: The resampled input data.
% - emgData: The EMG data.
% - sf: The sampling frequency.
% - inputName: The name of the input data.
%
% Output:
% - Crosscorrelation: A structure containing the cross-correlation results.
% It includes the cross-correlation coefficients (r) and lag (time shift)
% for both normalized and non-normalized cross-correlation.
% The time shift is converted to milliseconds.
% Author: YKK

% Define maximum lag in milliseconds:
maxLagMs = 512; % to match with the averaging window size of 32 taken for the coherence parameters
maxLagFrames = round((maxLagMs / 1000) * sf);

% Preallocate structure fields with 'x', 'y', 'z' or numeric indices:
notes = ['x', 'y', num2cell(4:size(inputDataResampled, 2))];

for col = 1:size(emgData, 2)
    for i = 1:size(inputDataResampled, 2)
        fieldName = [inputName, notes{i}];

        % Calculate normalized and non-normalized cross-correlation and lag.
        [ccNorm, lagsNorm] = xcorr(inputDataResampled(:, i), emgData(:, col), round(maxLagFrames), 'normalized');
        [ccNonNorm, lagsNonNorm] = xcorr(inputDataResampled(:, i), emgData(:, col), round(maxLagFrames), 'none');

        % Assign results to the structure.
        Crosscorrelation.(fieldName).r(:, col) = ccNorm;
        Crosscorrelation.(fieldName).lag(:, col) = lagsNorm;
        Crosscorrelation.(fieldName).Nonnorm_r(:, col) = ccNonNorm;
        Crosscorrelation.(fieldName).Nonnorm_lag(:, col) = lagsNonNorm;

        % Convert lags to milliseconds.
        Crosscorrelation.(fieldName).time(:, col) = (lagsNorm * maxLagMs / sf);
        Crosscorrelation.(fieldName).Nonnorm_time(:, col) = (lagsNonNorm * maxLagMs / sf);

        % Find index of maximum correlation and corresponding time shift.
        [corrMax, corrMaxIndex] = max(abs(ccNorm));
        Crosscorrelation.(fieldName).Corrmax(:, col) = corrMax;
        Crosscorrelation.(fieldName).timeDiff(:, col) = Crosscorrelation.(fieldName).time(corrMaxIndex, col);

        [nonNormCorrMax, nonNormCorrMaxIndex] = max(abs(ccNonNorm));
        Crosscorrelation.(fieldName).Nonnorm_Corrmax(:, col) = nonNormCorrMax;
        Crosscorrelation.(fieldName).Nonnorm_timeDiff(:, col) = Crosscorrelation.(fieldName).Nonnorm_time(nonNormCorrMaxIndex, col);
    end
end
end