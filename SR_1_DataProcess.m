%% Script Name: SR_1_CoPEMG_DataProcess
% Description: % This code is a processing routine for the SR study.
% It performs various analyses on EMG and CoP data files and extracts relevant parameters and features.
%
% Inputs:
%   - DIR_SRdata (string): Directory path where the raw data files are located.
%
% Outputs:
%   - MatrixTablecopParameter: Table containing COP parameters for each trial.
%   - MatrixTablecrosscorrelation: Table containing cross-correlation values between COP and EMG data for each trial.
%   - MatrixTablecoherenceIntegral: Table containing coherence integral values between COP and EMG data for each trial.
%   - MatrixTablecoherence: Table containing COP-EMG coherence values for each trial.
%   - MatrixTablespectra: Table containing COP and EMG power spectra values for each trial.
%   - MatrixTableemgcoherence: Table containing EMG-EMG coherence values for each trial.
%   - copemgcoherenceconfidencelimits: Structure containing confidence limits for COP-EMG coherence values.
%   - interemgcoherenceconfidencelimits: Structure containing confidence limits for EMG-EMG coherence values.
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

clc; clear all;close all;
tic;
DIR_SRdata   = '\\hest.nas.ethz.ch\green_groups_lmb_public\Projects\NCM\NCM_EXP\NCM_STM\NCM_STR\SR_Data\Masterarbeit_Fabienne\SR_main_experiment\Vicon\Vicon_processed\further';
DIR_destPath = '\\hest.nas.ethz.ch\green_groups_lmb_public\Projects\NCM\NCM_EXP\NCM_STM\NCM_STR\SR_YKK\Results\Hilbert_TJ0.5sec';
addpath(genpath(DIR_SRdata));
addpath(genpath(pwd));

%% start of the processing routine for the SR study
% Load the emg data file and preinitialize parameters
trialnames = dir([DIR_SRdata, filesep, '*.mat']); % *participant*session*trial*.mat
muscleType = {'SOL_L', 'TAN_L', 'GAL_L', 'SOL_R','TAN_R', 'GAL_R'};

MatrixTablecopParameter    = [];
MatrixTablecrosscorrelation = [];
MatrixTablecopspectra = struct();
MatrixTableemgspectra = struct();
MatrixTableemgcopcoherence = struct();
MatrixTableemgemgcoherence = struct();

for trial = 1:length(trialnames)

    filename = [trialnames(trial).name(1:end-4)]; % remove the file extensions
    specialcases = {'P02_S01_T02', 'P02_S01_T03', ...
        'P02_S03_T03', ...
        'P05_S01_T02', 'P05_S01_T03', ...
        'P12_S01_T02', 'P12_S01_T03', ...
        'P15_S02_T04', 'P15_S02_T05', ...
        'P24_S01_T02', 'P24_S01_T03'};  % Issues on loading these files...

    if ismember(filename, specialcases)
        data_1 = load([DIR_SRdata, filesep, filename]);
    else
        data_1 = load(filename);
    end

    if isfield(data_1, 'P')
        [emgData.raw, copData.raw, fData.raw, emgData.sf, emgData.triggerData] = loaddata(filename, data_1);
    else
        disp(filename);
        disp('hasnt been correctly converted to the MAT format');
        continue;
    end

    %% define stimulustype
    subID = filename(1:3);
    sessionID = filename(5:7);
    trialID = filename(9:11);

    emgData.stimulus = defstimulus(emgData.triggerData);

    if strcmp(emgData.stimulus, 'electrical')
        continue;
    elseif strcmp(emgData.stimulus, 'vibratory')
        stimulationID = 'S03_vibratory';
    elseif strcmp(emgData.stimulus, 'auditory')
        stimulationID = 'S03_auditory';
    elseif strcmp(emgData.stimulus, 'neutral')
        stimulationID = 'S03_neutral';
    elseif strcmp(emgData.stimulus, 'notrigger')
        if strcmp(sessionID, 'S01')
            stimulationID = 'S01_notrigger';
        elseif strcmp(sessionID, 'S02')
            stimulationID = 'S02_notrigger';
        elseif strcmp(sessionID, 'S04')
            stimulationID = 'S04_notrigger';
        elseif strcmp(sessionID, 'S03')
            stimulationID = 'S03_neutral';
        end
    end

    if length(emgData.triggerData) > 72000
        emgData.raw = emgData.raw(1:72000,:);
        emgData.triggerData = emgData.triggerData(1:72000,:);
    elseif length(emgData.triggerData) < 72000 && rem(length(emgData.triggerData),1200) ~= 0
        len_diff = 72000 - length(emgData.triggerData);
        rem_diff = rem(length(emgData.triggerData),1200);
        len = 72000 - len_diff - rem_diff;
        emgData.raw = emgData.raw(1:len,:);
        emgData.triggerData = emgData.triggerData(1:len,:);
    end

    %% process cop and force data
    [copData.processed, fData.processed] = processCopF(emgData.sf, copData.raw, fData.raw, emgData.triggerData,0);

    %% COP parameters
    copParameters = calculateCopParameters(copData,emgData.sf);

    %% cut EMG to Triggerlength and to 50 sec
    [emgData_processed] = emgbandpass(emgData.sf, emgData);
    [emgData_cropped,desiredLengthinSec] = crop_emg(emgData_processed,emgData);

    % %% cross-correlation COP with Interference EMG data -- Not Used
    % crosscorrelationCopEMG = crosscorrelation(copData.processed, emgData_cropped, emgData.sf, 'Cop');

    % %% coherence COP with EMG
    [windowedCopEmgCoherence] = CoherenceWindowcopemg(copData.processed, emgData_cropped, emgData.sf, 'Cop');

    % %% EMG-EMG Coherence
    % [windowedEmgEmgCoherence] = CoherenceWindowinteremg(emgData_cropped, emgData.sf);

    %% Extract Features
    windowedCopEmgCoherence = extractFrequencyDomainFeatures(windowedCopEmgCoherence, 'emgcopcohere');
    % windowedEmgEmgCoherence = extractFrequencyDomainFeatures(windowedEmgEmgCoherence, 'emgcohere');

    %% Saving info

    copAnalysisMatrix                  = converttocopmatrix(copParameters, subID, sessionID, trialID, stimulationID);
    % copemgcrosscorrelationMatrix       = convertcrosscorrmatrix(crosscorrelationCopEMG, subID, sessionID, trialID, stimulationID, muscleType);
    [copemgcoherenceMatrix, copemgspectra, emgcopcoherenceconfidencelimitsStruct] = converttoemgcopcoherencematrix(windowedCopEmgCoherence, subID, sessionID, trialID, stimulationID, muscleType);
    % [emgemgcoherenceMatrix, emgemgspectra, emgemgcoherenceconfidencelimitsStruct] = converttoemgemgcoherencematrix(windowedEmgEmgCoherence, subID, sessionID, trialID, stimulationID, muscleType);
    % copemgcoherenceIntegralMatrix      = converttocoherenceIntegralmatrix(windowedCopEmgCoherence, windowedInterEmgCoherence, subID, sessionID, trialID, stimulationID, muscleType);

    % emgcopcoherenceconfidencelimits.(subID).(sessionID).(trialID).(stimulationID) = emgcopcoherenceconfidencelimitsStruct;
    % emgemgcoherenceconfidencelimits.(subID).(sessionID).(trialID).(stimulationID) = emgemgcoherenceconfidencelimitsStruct;

    MatrixTablecopParameter      = [MatrixTablecopParameter; copAnalysisMatrix];
    % MatrixTablecrosscorrelation  = [MatrixTablecrosscorrelation; copemgcrosscorrelationMatrix];
    window_index = fieldnames(copemgcoherenceMatrix);
    % Append data to each field
    for i = 1:length(window_index)
        field = window_index{i};

        if ~isfield(MatrixTablecopspectra, field)
            MatrixTablecopspectra.(field) = [];
        end
        % if ~isfield(MatrixTableemgspectra, field)
        %     MatrixTableemgspectra.(field) = [];
        % end
        % if ~isfield(MatrixTableemgcopcoherence, field)
        %     MatrixTableemgcopcoherence.(field) = [];
        % end
        % if ~isfield(MatrixTableemgemgcoherence, field)
        %     MatrixTableemgemgcoherence.(field) = [];
        % end

        MatrixTablecopspectra.(field) = [MatrixTablecopspectra.(field); copemgspectra.(field)];
        % MatrixTableemgspectra.(field) = [MatrixTableemgspectra.(field); emgemgspectra.(field)];
        % MatrixTableemgcopcoherence.(field) = [MatrixTableemgcopcoherence.(field); copemgcoherenceMatrix.(field)];
        % MatrixTableemgemgcoherence.(field) = [MatrixTableemgemgcoherence.(field); emgemgcoherenceMatrix.(field)];
    end
    % MatrixTablecoherenceIntegral(trial, :)       = copemgcoherenceIntegralMatrix;

    disp(filename);

    clearvars -except ifMac DIR_destPath DIR_SRdata trialnames muscleType currentfolder nooffiles trial ...
        MatrixTablecopParameter  MatrixTablecrosscorrelation MatrixTablecopspectra MatrixTableemgspectra ...
        MatrixTableemgcopcoherence MatrixTableemgemgcoherence MatrixTablecoherenceIntegral...
        copemgcoherenceconfidencelimits emgemgcoherenceconfidencelimits ...
        close all;

end
toc;
%% save file
if ~exist(DIR_destPath, 'dir')
    mkdir(DIR_destPath)
end

MatrixTablecopParameter=MatrixTablecopParameter(~any(ismissing(MatrixTablecopParameter),2),:);
% MatrixTablecrosscorrelation=MatrixTablecrosscorrelation(~any(ismissing(MatrixTablecrosscorrelation),2),:);
% MatrixTablecoherenceIntegral = MatrixTablecoherenceIntegral(~any(ismissing(MatrixTablecoherenceIntegral),2),:);

filenamecop = [DIR_destPath, filesep, 'copParameters.xlsx'];
% filenamecrosscorr = [DIR_destPath, filesep, 'crosscorrelation.csv'];
% filenamecoherenceIntegral = [DIR_destPath, filesep, 'coherenceIntegral.csv'];

writetable(MatrixTablecopParameter,filenamecop);
% writetable(MatrixTablecrosscorrelation,filenamecrosscorr);
% writetable(MatrixTablecoherenceIntegral,filenamecoherenceIntegral);

window_index = fieldnames(MatrixTableemgspectra);
% Loop through each field to write to the corresponding sheet
for i = 1:length(window_index)
    field = window_index{i};

    % % Clean data by removing rows with missing values
    MatrixTablecopspectra.(field) = MatrixTablecopspectra.(field)(~any(ismissing(MatrixTablecopspectra.(field)), 2), :);
    % MatrixTableemgspectra.(field) = MatrixTableemgspectra.(field)(~any(ismissing(MatrixTableemgspectra.(field)), 2), :);
    % MatrixTableemgcopcoherence.(field) = MatrixTableemgcopcoherence.(field)(~any(ismissing(MatrixTableemgcopcoherence.(field)), 2), :);
    % MatrixTableemgemgcoherence.(field) = MatrixTableemgemgcoherence.(field)(~any(ismissing(MatrixTableemgemgcoherence.(field)), 2), :);

    % Assign tables to variables
    copspectraTable = MatrixTablecopspectra.(field);
    % emgspectraTable = MatrixTableemgspectra.(field);
    % emgcopcoherenceTable = MatrixTableemgcopcoherence.(field);
    % emgemgcoherenceTable = MatrixTableemgemgcoherence.(field);

    % Save the variables to .mat files
    save([DIR_destPath, ['copspectra',(field),'.mat']], 'copspectraTable');
    % save([DIR_destPath, ['emgspectra',(field),'.mat']], 'emgspectraTable');
    % save([DIR_destPath, ['emgcopcoherence',(field),'.mat']], 'emgcopcoherenceTable');
    % save([DIR_destPath, ['emgemgcoherence',(field),'.mat']], 'emgemgcoherenceTable');
end

% filenameemgemgcl = [DIR_destPath, 'emgemgcoherencecl.mat'];
% filenameemgcopcl = [DIR_destPath, 'emgcopcoherencecl.mat'];

% save(filenameemgemgcl, 'emgemgcoherenceconfidencelimits');
% save(filenameemgcopcl, 'emgcopcoherenceconfidencelimits');
