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
clc;clear all;close all
%
% define input and output folders
DIR_SROutputdata = '\\hest.nas.ethz.ch\green_groups_lmb_public\Projects\NCM\NCM_EXP\NCM_STM\NCM_STR\SR_YKK\Results\Hilbert_TJ1sec\';
addpath(genpath(DIR_SROutputdata));
addpath(genpath(pwd));

%% load data -- Loop through each sheet and read its data
participantsToRemove = {};% {'P02', 'P03', 'P05', 'P12', 'P14', 'P15', 'P21', 'P22', 'P25', 'P26', 'P28'};
fieldsToRemove = participantsToRemove; % Fields to remove from interemgcoherenceconfidencelimits

[~, sheetNames] = xlsfinfo([DIR_SROutputdata, 'copspectra.xlsx']);
Coherencetype = 'interemg';
interemgCoherence = struct();

for i = 1:length(sheetNames)

    interemgCoherence.(sheetNames{i}) = load([DIR_SROutputdata,  ['emgemgcoherence',(sheetNames{i}),'.mat']]);

    rowsToRemove = ismember(interemgCoherence.(sheetNames{i}).emgemgcoherenceTable.participant, participantsToRemove);

    interemgCoherence.(sheetNames{i}).emgemgcoherenceTable(rowsToRemove, :) = [];
end

filenameconfidencelimits  = [DIR_SROutputdata,  'emgemgcoherencecl.mat'];
load(filenameconfidencelimits);
emgemgcoherenceconfidencelimits = rmfield(emgemgcoherenceconfidencelimits,fieldsToRemove);

muscleID = {'SOL_L', 'TAN_L', 'GAL_L', 'SOL_R', 'TAN_R', 'GAL_R'};
sessionID = {'S01_notrigger', 'S02_notrigger',  'S03_auditory', 'S03_neutral', 'S03_vibratory','S04_notrigger'};

for i = 1:length(sheetNames)
    columnsfixed = 1:6;
    columnsshift = 1;
    columnformuscen = 6;
    count_sess = 1;
    count = 1;
    for caseno = 1
        if caseno == 1
            sessRun = 1:4;
            colcount = 1:4;
            sesscompNameString = 'overall';
            filesubFolder = 'Outputs_Visualisation_woST';
        elseif caseno == 2
            sessRun = [1 2];
            colcount = [1 2];
            sesscompNameString = 'sess_1_2';
            filesubFolder = 'Outputs_Visualisation_woST_sess1_2';
        elseif caseno == 3
            sessRun = [3 5];
            colcount = [1 2];
            sesscompNameString = 'sess_3_5';
            filesubFolder = 'Outputs_Visualisation_woST_sess3_5';
        elseif caseno == 4
            sessRun = [3 4];
            sesscompNameString = 'sess_3_4';
            filesubFolder = 'Outputs_Visualisation_woST_sess3_4';
        elseif caseno == 5
            sessRun = [2 5];
            colcount = [1 2];
            sesscompNameString = 'sess_2_5';
            filesubFolder = 'Outputs_Visualisation_woST_sess2_5';
        elseif caseno == 6
            sessRun = [2 3];
            colcount = [1 2];
            sesscompNameString = 'sess_2_3';
            filesubFolder = 'Outputs_Visualisation_woST_sess2_3';
        end

        %% Compare each muscle with each other muscle (120 comparisons total)
        for musc = 1:(size(muscleID, 2) - 1)
            for musc1 = musc+1:size(muscleID, 2)
                sigsinv = [muscleID{musc}, '_', muscleID{musc1}]; % e.g. SOL_R-TAN_R
                musclePairName = ['interemg_', sigsinv, '_Coherence'];

                % Get necessary columns for comparison of two current muscles
                muscle_pair_idx = find(contains(interemgCoherence.(sheetNames{i}).emgemgcoherenceTable.Properties.VariableNames,sigsinv),1);
                musccoln = [columnsfixed, (muscle_pair_idx+1):(muscle_pair_idx + 3)];

                Coherence_interemg.(sigsinv) = interemgCoherence.(sheetNames{i}).emgemgcoherenceTable(:, musccoln); % save columns in struct

                for cols = 5:9
                    Coherence_interemg.(sigsinv).(cols) = num2cell(Coherence_interemg.(sigsinv).(cols));
                end

                participants = unique(Coherence_interemg.(sigsinv).participant(~cellfun('isempty', Coherence_interemg.(sigsinv).participant)));
                for sessIdx = 1:length(sessRun)
                    sess = sessRun(sessIdx);
                    sessionID_temp = sessionID{sess};
                    sessionIDShort = sessionID_temp(5:end);
                    sess_ID = char(sessionID_temp(1:3));
                    checkIDs = strcmp(Coherence_interemg.(sigsinv).stim, sessionID_temp);
                    fprintf(sessionID_temp)

                    %% Extracting all coeffcients of the muscle pairs across all pariticiapnts and trails in the selection session
                    % neusropecoeff 1 = autosepctra 1
                    % neurosepcoeff 2 = autosepctra 2
                    % neurosepcoeff 3 = croess spectra 1 & 2
                    SpecCoeff_interemg.(sesscompNameString).(sigsinv).(sessionIDShort) = cell2table(...
                        num2cell(Coherence_interemg.(sigsinv){checkIDs, [1, 3, 5, 6, 7, 8, 9]}), ...
                        "VariableNames", ["participant", "trial", "bin", "frequencies", "specCoeff1neurospec", "specCoeff2neurospec", "specCoeff3neurospec"]);

                    % Loop through all participants
                    for partIdx = 1:length(participants)

                        pariticipantID = participants{partIdx};
                        partCheck = strcmp(SpecCoeff_interemg.(sesscompNameString).(sigsinv).(sessionIDShort){:, 1}, pariticipantID);

                        SpecCoeff_participant.(sesscompNameString).(sigsinv).(pariticipantID).(sessionIDShort) = cell2table(...
                            num2cell(SpecCoeff_interemg.(sesscompNameString).(sigsinv).(sessionIDShort){partCheck, :}), ...
                            "VariableNames", ["participant", "trial", "bin", "frequencies", "specCoeff1neurospec", "specCoeff2neurospec", "specCoeff3neurospec"]);

                        % Loop through all trials within the participant

                        trIDtocompare = unique(SpecCoeff_participant.(sesscompNameString).(sigsinv).(pariticipantID).(sessionID_temp(5:end)).trial);
                        for trial = 1:size(trIDtocompare, 1)

                            trialCheck = strcmp(SpecCoeff_participant.(sesscompNameString).(sigsinv).(pariticipantID).(sessionID_temp(5:end)){:, 2}, trIDtocompare{trial});

                            % Save participant data for current trial in struct
                            temp_Coeff = cell2mat(SpecCoeff_participant.(sesscompNameString).(sigsinv).(pariticipantID).(sessionID_temp(5:end)){trialCheck,5:7});
                            temp_Cl = emgemgcoherenceconfidencelimits.(pariticipantID).(sess_ID).(trIDtocompare{trial}).(sessionID_temp).(sheetNames{i}).(sigsinv);

                            % Pooling all trials for selected intermuscular coherence
                            if count == 1
                                [plf1.(sheetNames{i}).(sesscompNameString), plv1.(sheetNames{i}).(sesscompNameString)] = pool_scf(temp_Coeff, temp_Cl);
                            else % Pool together for all trials
                                [plf1.(sheetNames{i}).(sesscompNameString), plv1.(sheetNames{i}).(sesscompNameString)] = pool_scf(temp_Coeff, temp_Cl, plf1.(sheetNames{i}).(sesscompNameString), plv1.(sheetNames{i}).(sesscompNameString));
                            end

                            if count_sess == 1 % Start with first participant
                                [plf1_sess.(sheetNames{i}).(sesscompNameString).(sessionID_temp(5:end)), plv1_sess.(sheetNames{i}).(sesscompNameString).(sessionID_temp(5:end))] = pool_scf(temp_Coeff, temp_Cl);
                            else % Pool together for all following participants
                                [plf1_sess.(sheetNames{i}).(sesscompNameString).(sessionID_temp(5:end)), plv1_sess.(sheetNames{i}).(sesscompNameString).(sessionID_temp(5:end))] = pool_scf(temp_Coeff, temp_Cl, plf1_sess.(sheetNames{i}).(sesscompNameString).(sessionID_temp(5:end)), plv1_sess.(sheetNames{i}).(sesscompNameString).(sessionID_temp(5:end)));
                            end
                            count = count + 1;
                            count_sess = count_sess + 1;
                        end
                        disp(['Done with all the ', sessionID_temp, ' trials: ', sigsinv, ', ', pariticipantID])

                        colCount = colcount(sessIdx);

                        % Pool and plot muscle-muscle coherences
                        % whole pool_scf function needs to be run at least 2 times (once with all the inputs) that the following functions work
                        if count >= 2 && count_sess >= 2

                            [Pooled_f.accSess.(sheetNames{i}).(sesscompNameString).(pariticipantID).(sigsinv), Pooled_cl.accSess.(sheetNames{i}).(sesscompNameString).(pariticipantID).(sigsinv)] = pooledPlot_Coherence(plf1.(sheetNames{i}).(sesscompNameString), plv1.(sheetNames{i}).(sesscompNameString), 'PAS', trIDtocompare, musclePairName, Coherencetype, filesubFolder, (sheetNames{i}), DIR_SROutputdata);

                            [Pooled_f.withSess.(sheetNames{i}).(sesscompNameString).(pariticipantID).(sessionID_temp(5:end)).(sigsinv), Pooled_cl.withSess.(sheetNames{i}).(sesscompNameString).(pariticipantID).(sessionID_temp(5:end)).(sigsinv)] = ...
                                pooledPlot_Coherence(plf1_sess.(sheetNames{i}).(sesscompNameString).(sessionID_temp(5:end)), plv1_sess.(sheetNames{i}).(sesscompNameString).(sessionID_temp(5:end)), 'PWS', sessionID_temp, musclePairName, Coherencetype, filesubFolder, (sheetNames{i}), DIR_SROutputdata);

                            Pooled_f_concat.withSess.(sheetNames{i}).(sesscompNameString).(sigsinv)(:, partIdx, colCount)       = Pooled_f.withSess.(sheetNames{i}).(sesscompNameString).(pariticipantID).(sessionID_temp(5:end)).(sigsinv)(:,2);  % Pooled coherence (calculated from pooled coherency),
                            Pooled_cl_concat.sig_withSess.(sheetNames{i}).(sesscompNameString).(sigsinv)(:, partIdx, colCount)  = Pooled_cl.withSess.(sheetNames{i}).(sesscompNameString).(pariticipantID).(sessionID_temp(5:end)).(sigsinv)(:,2); % 95% confidence limit for coherence.
                            Pooled_cl_concat.sig1_withSess.(sheetNames{i}).(sesscompNameString).(sigsinv)(:, partIdx, colCount) = Pooled_cl.withSess.(sheetNames{i}).(sesscompNameString).(pariticipantID).(sessionID_temp(5:end)).(sigsinv)(:,3); % 95% confidence limit for Chi^2 test, JNM (2.9)
                            Pooled_f_concat.chisq_withSess.(sheetNames{i}).(sesscompNameString).(sigsinv)(:, partIdx, colCount) = Pooled_f.withSess.(sheetNames{i}).(sesscompNameString).(pariticipantID).(sessionID_temp(5:end)).(sigsinv)(:,3);  % Chi-squared difference of coherence test.
                        end
                    end
                    disp(['Done with all the ', sessionID_temp, ' trials: ', sigsinv, ' Window: ', (sheetNames{i})]);
                    count_sess = 1;
                end
                count = 1;
            end
        end
    end
end
%% Save results of pooled EMG-EMG coherence
filefolder = [DIR_SROutputdata, filesep, 'Pooled_Hilbert'];
if ~exist(filefolder, 'dir')
    mkdir(filefolder)
end

filename = [filefolder, filesep, 'pooledinteremgCoherence_All.mat'];
save(filename, '-struct', 'Pooled_f_concat')
filename1 = [filefolder, filesep, 'pooledinteremgCoherence_All_clValue.mat'];
save(filename1, '-struct', 'Pooled_cl_concat')
