%% Script Name: SR_1_CoPFrequency Analysis
% Description: Extracts all the relevant CoP parameters and frequency
% analysis
% Inputs:
%   - Input1 (struct): raw mat files converted from c3d
% Outputs:
%   - emgbyconditions (struct): emg assosicated with conditions.
% Additional Notes:
%  S01_notrigger: Eyes closed,
%  S02_notrigger: Eyes closed on compliance,
%  S03_neutral: Eyes closed on compliance + 1Hz stimulation
%  S03_vibratory: Eyes closed on compliance + 1Hz stimulation + vibratory noise
%  S03_auditory: Eyes closed on compliance + 1Hz stimulation + auditory noise
%  x -> AP, y -> ML
% Author: YKK

clc; clear all;close all;
tic;
DIR_SRdata = 'P:\Projects\NCM\NCM_EXP\NCM_STM\NCM_STR\SR_YKK\Results';
destPath         = '\\hest.nas.ethz.ch\green_groups_lmb_public\Projects\NCM\NCM_EXP\NCM_STM\NCM_STR\SR_YKK\Results\PooledFinalPlots';

addpath(genpath(DIR_SRdata));
addpath(genpath(pwd));

%% Load the emg data file and preinitialize parameters
load([DIR_SRdata, filesep, 'AggregatedwaveletCoherence.mat']); % Specify filename based on the format /*participant*session*trial*.mat
load([DIR_SRdata, filesep, 'msCoherence.mat']); % Specify filename based on the format /*participant*session*trial*.mat

conditions = fieldnames(aggregatedCoherenceResults);
muscleType = fieldnames(aggregatedCoherenceResults.S01_notrigger);

% Initialize structure to hold aggregated results
% aggregatedCoherenceResults = struct();

% Loop through each condition and muscle pair
for conditionIdx = 1:length(conditions)-1
    try
        for muscleIdx = 1:length(muscleType)

            %  % % --- Wavelet Coherence Calculation ---
            %
            % wtc = aggregatedCoherenceResults.(conditions{conditionIdx}).(muscleType{muscleIdx}).averageCoherence;
            % f = aggregatedCoherenceResults.(conditions{conditionIdx}).(muscleType{muscleIdx}).frequencies;
            % x = size(wtc,2);
            % time = (0:size(wtc,2)-1) / 1200;
            %
            % figure;
            % pcolor(time,f,wtc); % Use pcolor to create the coherence plot
            % shading interp;
            % title('Wavelet Coherence');
            % xlabel('Time');
            % ylabel('Frequency (Hz)');
            % colorbar;
            % hold on;
            muscleString = muscleType{muscleIdx};  % Example: 'SOL_L_TAN_L'
            conditionString = (conditions{conditionIdx});

            % --- FFT-based Coherence Calculation ---
            Cxy_matrix = aggregatedCoherenceResults.(conditionString).(muscleString).averageCxy;

            % Frequecncy
            F = 0:601;
            T= 0:3.1250:50;
            freq_idx = F <= 60;

            % Plotting the time-frequency coherence
            figm= figure('Name', muscleString);
            imagesc(T, F(freq_idx), Cxy_matrix(freq_idx,:));
            axis xy;
            colorbar;
            xlabel('Time (s)');
            ylabel('Frequency (Hz)');

            title([(strrep(conditionString, '_', '\_')),' - ' ,( strrep(muscleString, '_', '\_'))]);

            filename = [destPath,filesep,'tv_coherence', (strrep(conditionString, '_', '-')) (strrep(muscleString, '_', '-'))];

            %% Save file as pdf
            if ~exist(destPath, 'dir')
                mkdir(destPath)
            end

            print(figm, filename, '-dpdf', '-r1200');
            close(figm);
        end

    catch ME
        disp(['Condition: ', (conditions{conditionIdx}(5:end)), ' does not exist for muscle pair ', muscleString, '. Skipping...']);
        continue;
    end
end
