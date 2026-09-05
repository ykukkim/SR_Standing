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

% clc; clear all;close all;
% tic;
% DIR_SRdata = 'P:\Projects\NCM\NCM_EXP\NCM_STM\NCM_STR\SR_YKK\Results';
% addpath(genpath(DIR_SRdata));
% addpath(genpath(pwd));
%
%% Load the emg data file and preinitialize parameters
% load([DIR_SRdata, filesep, 'EMG_Raw_Result.mat']); % Specify filename based on the format /*participant*session*trial*.mat

samplingRate = 1200;
desired_freq_resoltuion = 1;
window_size = samplingRate * 3;
Nfft = samplingRate/desired_freq_resoltuion;
overlap = 0; % No overlap
step = window_size - overlap;   % Step size for sliding window
seg_tot=fix(60000/window_size); % Number of complete segments (L).

% Frequency axis
frequencies = (0:seg_size/2) * (samplingRate / seg_size);

% Define maximum frequency to display
max_freq = 60; % Maximum frequency to display
freq_idx = frequencies <= max_freq; % Indices of frequencies up to 60 Hz
filtered_frequencies = frequencies(freq_idx); % Frequencies up to 60 Hz

numparticipants = fieldnames(emgByCondition);
muscleType = {'SOL_L', 'TAN_L', 'GAL_L', 'SOL_R', 'TAN_R', 'GAL_R'};
conditions = {'S01_notrigger', 'S02_notrigger', 'S03_neutral', 'S03_auditory'};


% Initialize structure to hold aggregated results
aggregatedCoherenceResults = struct();

% Loop through each condition and muscle pair
for conditionIdx = 1:length(conditions)
    conditionName = conditions{conditionIdx};
    try
        for muscleIdx = 1:length(muscleType)
            muscle1 = muscleType{muscleIdx};

            for columnIdx = muscleIdx+1:length(muscleType)
                muscle2 = muscleType{columnIdx};
                pair_name = sprintf('%s_%s', muscle1, muscle2);

                % Initialize sum matrices for coherence and frequency
                coherenceSum = [];
                CxySum = zeros(Nfft/2+1, seg_tot); % Ensure CxySum is initialized with the correct size
                frequency = [];

                for parts = 1:length(numparticipants)
                    participant = numparticipants{parts};

                    % Check if the participant data exists
                    if ~isfield(emgByCondition.(participant), conditionName)
                        continue;
                    end
                    channel1 = mean(emgByCondition.(participant).(conditionName).(muscle1), 2);
                    channel2 = mean(emgByCondition.(participant).(conditionName).(muscle2), 2);

                    % % --- Wavelet Coherence Calculation ---
                    % % Compute wavelet coherence
                    % [wcoh, ~, f] = wcoherence(channel1, channel2, samplingRate);
                    %
                    % % Limit to max frequency
                    % freq_idx = f <= max_freq;
                    %
                    % % Initialize coherenceSum, CxySum, and frequency on the first participant
                    % if isempty(coherenceSum)
                    %     coherenceSum = zeros(sum(freq_idx), size(wcoh, 2));
                    %     CxySum = zeros(nfft/2+1, size(wcoh, 2)); % Initialize CxySum
                    %     frequency = f(freq_idx);
                    % end
                    %
                    % % Sum wavelet coherence values across participants
                    % coherenceSum = coherenceSum + wcoh(freq_idx, :);

                    % --- FFT-based Coherence Calculation ---
                    % Initialize Cxy_matrix for storing the results for this participant
                    Cxy_matrix = zeros(Nfft/2+1, seg_tot);

                    for i = 1:seg_tot
                        % Determine the segment indices based on window size and overlap
                        start_idx = (i-1) * (window_size - overlap) + 1;
                        end_idx = start_idx + window_size - 1;

                        % Ensure the segment does not exceed the signal length
                        if end_idx > length(channel1)
                            break;
                        end

                        % Extract segments for coherence calculation
                        segment1 = channel1(start_idx:end_idx);
                        segment2 = channel2(start_idx:end_idx);

                        % Calculate coherence for the segment without a window
                        [Cxy, ~] = mscohere(segment1, segment2, [], [], Nfft, Fs);
                        Cxy_matrix(:, i) = Cxy;
                    end

                    % Sum FFT-based coherence matrices across participants
                    CxySum = CxySum + Cxy_matrix;

                end

                % % Compute average wavelet coherence across participants
                % if ~isempty(coherenceSum)
                %     averageCoherence = coherenceSum / length(numparticipants);
                %
                %     % Store the aggregated wavelet coherence results
                %     aggregatedCoherenceResults.(conditionName).(pair_name).averageCoherence = averageCoherence;
                %     aggregatedCoherenceResults.(conditionName).(pair_name).frequencies = frequency;
                % end

                % Compute average FFT-based coherence across participants
                if ~isempty(CxySum)
                    averageCxy = CxySum / length(numparticipants);

                    % Store the aggregated FFT-based coherence results
                    aggregatedCoherenceResults.(conditionName).(pair_name).averageCxy = averageCxy;
                end
            end
        end
    catch ME
        disp(['Participant ', participant, ' does not exist for condition ', conditionName, '. Skipping...']);
        continue;
    end
end
aggregatedCoherenceResults.saving_timestamp=datestr(now,datestr(now,'yyyy_mm_dd-HH:MM:SS'));

if isfolder(DIR_destPath) ~= 1
    mkdir(DIR_destPath);
end

disp('--Saving results:');
disp('Directory:');
disp(aggregatedCoherenceResults);
save([DIR_destPath,filesep,'msCoherence'],'aggregatedCoherenceResults','-v7.3');
disp('Saving done');
