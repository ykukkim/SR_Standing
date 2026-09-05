%% Script Name: SR_1_CoPFrequency Analysis
% Description: Extracts all the relevant CoP parameters and frequency
% analysis
%
% Inputs:
%   - Input1 (struct): raw mat files converted from c3d
%
%
% Additional Notes:
% x -> AP, y -> ML
% S01_notrigger: Eyes closed,
% S02_notrigger: Eyes closed on compliance,
% S03_neutral: Eyes closed on compliance + 1Hz metronome
% S03_vibratory: Eyes closed on compliance + 1Hz metronome + vibratory noise
% S03_auditory: Eyes closed on compliance + 1Hz metronome + auditory noise
% Corresponding muscles to EMG; (1-3) right, (4-6) left
% 1,4 Soleus
% 2,5 Tibialis anterior
% 3,6 Gastrocnemius lateralis
% Author: YKK
%
clc; clear all; close all;

% define input and output folders
DIR_SROutputdata = '\\hest.nas.ethz.ch\green_groups_lmb_public\Projects\NCM\NCM_EXP\NCM_STM\NCM_STR\SR_YKK\Results\Hilbert_TJ2sec\';
addpath(genpath(DIR_SROutputdata));
addpath(genpath(pwd));
%  Define your parameters (example: length of bin)
sessionID = {'S01_notrigger', 'S02_notrigger',  'S03_auditory', 'S03_neutral', 'S03_vibratory','S04_notrigger'};
sessionID2 = {'ECHard', 'ECFoam', 'ECFoamVib','ECFoam1Hz', 'ECFoam1HzWN'};
muscleID = {'SOL_L', 'TAN_L', 'GAL_L', 'SOL_R', 'TAN_R', 'GAL_R'};

% Define the frequency ranges for different oscillatory bands
bands = {'delta', 'theta', 'alpha', 'beta', 'gamma'};
band_ranges = {
    [0 4],     % Delta band
    [4 8],     % Theta band
    [8 12],    % Alpha band
    [12 30],   % Beta band
    [30 61]    % Gamma band
    };

sessRun = 1:5;
sesscompNameString = 'overall';
columnsfixed = 1:6;
columnsshift = 1;
columnformuscen = 6;
count_sess = 1;
count = 1;

[~, sheetNames] = xlsfinfo([DIR_SROutputdata, 'copspectra.xlsx']);
interemgCoherence = struct();
for i = 1:length(sheetNames)

    interemgCoherence.(sheetNames{i}) = load([DIR_SROutputdata,  ['emgemgcoherence',(sheetNames{i}),'.mat']]);
    results.(sheetNames{i}) = struct();
    %% Compare each muscle with each other muscle (120 comparisons total)
    for musc = 1:(size(muscleID, 2) - 1)
        for musc1 = musc + 1:size(muscleID, 2)
            sigsinv = [muscleID{musc}, '_', muscleID{musc1}]; % e.g. SOL_R-TAN_R
            musclePairName = ['interemg_', sigsinv, '_Coherence'];

            % Get necessary columns for comparison of two current muscles
            muscle_pair_idx = find(contains(interemgCoherence.(sheetNames{i}).emgemgcoherenceTable.Properties.VariableNames,sigsinv),1);
            musccoln = [columnsfixed, (muscle_pair_idx):(muscle_pair_idx + 3)];

            Coherence_interemg.(sigsinv) = interemgCoherence.(sheetNames{i}).emgemgcoherenceTable(:, musccoln); % save columns in struct

            for cols = 5:9
                Coherence_interemg.(sigsinv).(cols) = num2cell(Coherence_interemg.(sigsinv).(cols)); % format conversion
            end

            participants = unique(Coherence_interemg.(sigsinv).participant(~cellfun('isempty', Coherence_interemg.(sigsinv).participant)));

            for sessIdx = 1:length(sessRun)

                sess = sessRun(sessIdx);
                sessionID_temp = sessionID{sess};
                sessionIDShort = sessionID_temp(5:end);
                sess_ID = char(sessionID_temp(1:3));
                sess_ID2 = sessionID2{sessIdx};
                checkIDs = strcmp(Coherence_interemg.(sigsinv).stim, sessionID_temp);

                %% Extracting all coeffcients of the muscle pairs across all pariticiapnts and trails in the selection session
                % neusropecoeff 1 = autosepctra 1
                % neurosepcoeff 2 = autosepctra 2
                % neurosepcoeff 3 = croess spectra 1 & 2
                SpecCoeff_interemg.(sesscompNameString).(sigsinv).(sessionIDShort) = cell2table(...
                    num2cell(Coherence_interemg.(sigsinv){checkIDs, [1, 3, 5, 6, 7]}), ...
                    "VariableNames", ["participant", "trial", "bin", "frequencies", "emgcohere"]);

                band_tables = struct();
                for band_idx = 1:length(bands)
                    band_tables.(bands{band_idx}).coherencevalue = [];
                    band_tables.(bands{band_idx}).variability = [];
                end

                % Loop through all participants
                for partIdx = 1:length(participants)
                    try

                        pariticipantID = participants{partIdx};
                        partCheck = strcmp(SpecCoeff_interemg.(sesscompNameString).(sigsinv).(sessionIDShort){:, 1}, pariticipantID);

                        % Save only measurements for current participant in struct
                        participant_data = SpecCoeff_interemg.(sesscompNameString).(sigsinv).(sessionIDShort){partCheck, :};

                        % Loop through all trials
                        trials =  unique(SpecCoeff_interemg.(sesscompNameString).(sigsinv).(sessionIDShort){partCheck, 2});

                        % Initialize mean_coherence_data structure
                        mean_coherence_data = struct();
                        for band_idx = 1:length(bands)
                            mean_coherence_data.(bands{band_idx}) = [];
                        end

                        for trial = 1:length(trials)
                            trial_data = participant_data(strcmp(participant_data(:, 2), trials(trial)), :);

                            cohere = [cell2mat(trial_data(:,4)) cell2mat(trial_data(:, 5))]; % Adjust based on your data structure

                            for band_idx = 1:length(bands)
                                band = bands{band_idx};
                                band_range = band_ranges{band_idx};
                                freq_indices = find(cohere(:,1) >= band_range(1) & cohere(:,1) <= band_range(2));
                                temp = [{trials{trial}} mean(cohere(freq_indices, 2))];
                                mean_coherence_data.(band) = [mean_coherence_data.(band); temp];
                            end
                        end

                        for band_idx = 1:length(bands)
                            band = bands{band_idx};
                            coherence_values = mean_coherence_data.(band);

                            for val_idx = 1:length(coherence_values)
                                new_row =[{pariticipantID} coherence_values(val_idx,:)];
                                band_tables.(band).coherencevalue = [band_tables.(band).coherencevalue; new_row];
                            end

                            std_val = [{pariticipantID} std(cell2mat(mean_coherence_data.(band)(:, 2)))];
                            band_tables.(band).variability = [band_tables.(band).variability; std_val];

                        end
                    catch
                        continue;
                    end
                end

                % Store band tables in the results structure
                if ~isfield(results.(sheetNames{i}), sigsinv)
                    results.(sheetNames{i}).(sigsinv) = struct();
                end
                if ~isfield(results.(sheetNames{i}).(sigsinv), sess_ID2)
                    results.(sheetNames{i}).(sigsinv).(sess_ID2) = struct();
                end
                for band_idx = 1:length(bands)
                    band = bands{band_idx};
                    results.(sheetNames{i}).(sigsinv).(sess_ID2).(band) = band_tables.(band);
                end
                disp(['Done with: ', sigsinv, ', ', sessionID_temp])
            end
        end
    end
    disp(['Done with: ', sheetNames{i}])
end

destPath = [DIR_SROutputdata,filesep,'Stat_Results',filesep,'RawData'];

if ~exist(destPath, 'dir')
    mkdir(destPath)
end

% Save the results to a .mat file for later use
save(fullfile(destPath, 'coherence_band_results_mean.mat'), 'results','-v7');
disp('Coherence results have been calculated and stored successfully.');