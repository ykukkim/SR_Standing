function copParameters = calculateCopParameters(copData, samplingfrequency,freq_res)
% Description: This MATLAB function computes various parameters from Center of Pressure (CoP) data.
% These include both linear parameters and frequency parameters.
%
% Inputs:
% - copData: The processed CoP data in X and Y directions.
% - samplingfrequency: Sampling frequency
% - averagingFactor: The factor used for averaging the power spectrum.
%
% Output:
% - copParameters: A structured array containing all the calculated parameters.
% Linear parameters:
% absolute and relative sway area, 95% confidence interval elliptical area, RMS distance, mean distance,
% mean velocity, and peak velocity in radial, x, and y directions respectively.
% Frequency parameters:
% mean and median frequency in x and y directions respectively, and absolute power in long, medium, and short
% latency bands in x and y directions respectively.
% The output also includes spectral power bands for both x and y directions of CoP data.
%
% Additional Notes:
% Author: YKK

%% Initialize copParameters structure
copParameters = struct();

%% COP linear parameters
% Length of each trial
copData.trialLength = length(copData.processed(:,1))/samplingfrequency; % After cropping

% Extracting base COP data for X and Y directions
baseDataCopx = copData.processed(:,1) - mean(copData.processed(:,1));
baseDataCopy = copData.processed(:,2) - mean(copData.processed(:,2));

% Absolute sway area (mm)
copParameters.linear.swayArea_abs = swayarea(baseDataCopx, baseDataCopy);

% Relative sway area normalised to time of trial (mm2/s)
copParameters.linear.swayArea_rel = swayareaRel(baseDataCopx, baseDataCopy, copData.trialLength);

% 95% CI elliptical area (mm2)
copParameters.linear.ellipseArea = ellipse(baseDataCopx, baseDataCopy);

%% Calculate relative parameters: RMS distance, mean distance, mean velocity, peak velocity

% Path Length (mm)
for mm = 2:length(baseDataCopx)
    tmp_COP_Path_Length(mm) = sqrt((baseDataCopx(mm) - baseDataCopx(mm-1))^2 +...
        (baseDataCopy(mm) - baseDataCopy(mm-1))^2);
end
copParameters.linear.pathlength = sum(tmp_COP_Path_Length);

% RMS distance (mm)
[copParameters.linear.rmsDist_r, copParameters.linear.rmsDist_x, ...
    copParameters.linear.rmsDist_y] = rmsdistance(baseDataCopx, baseDataCopy);

% Mean distance (mm)
[copParameters.linear.meanDist_r, copParameters.linear.meanDist_x, ...
    copParameters.linear.meanDist_y] = mdistance(baseDataCopx, baseDataCopy);

% Mean velocity (mm/s)
[copParameters.linear.meanVel_r, copParameters.linear.meanVel_x, ...
    copParameters.linear.meanVel_y] = meanvelocity(baseDataCopx, baseDataCopy, copData.trialLength);

% Peak velocity (mm/s)
[copParameters.linear.peakVel_r, copParameters.linear.peakVel_x, ...
    copParameters.linear.peakVel_y] = peakvelocity(baseDataCopx, baseDataCopy, samplingfrequency);

%% Frequency parameters
directions = {'x', 'y'};
copdir     = {'Copx', 'Copy'};

% Mean/Median frequency (Hz) and spectral power bands
for k = 1:length(directions)
    % Mean and median frequency
    copParameters.frequency.(['meanFreq_', directions{k}]) = ...
        meanfrequency(copData.processed(:,k), samplingfrequency);
    copParameters.frequency.(['medianFreq_', directions{k}]) = ...
        medianfrequency(copData.processed(:,k), samplingfrequency);

    % Spectral power bands
    [copParameters.spectraFrequency.(copdir{k}).spectraAll, ...
        copParameters.spectraFrequency.(copdir{k}).normalizedSpectraAll, ...
        copParameters.spectraFrequency.(copdir{k}).freqAll, ...
        copParameters.spectraFrequency.(copdir{k}).spectraTotal, ...
        copParameters.frequency.(['absPwrLongLatency_', directions{k}]), ...
        copParameters.frequency.(['absPwrMediumLatency_', directions{k}]), ...
        copParameters.frequency.(['absPwrShortLatency_', directions{k}])] = ...
        calculateSpectralPowerBands_CoP(copData.processed(:,k), samplingfrequency,freq_res);

end
