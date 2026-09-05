clc;clear all;close all
% Pools cop-emg coherence across all the trials, sessions and partcipants.
% Conditions  S01_notrigger: Eyes closed,
%             S02_notrigger: Eyes closed on compliance,
%             S03_neutral: Eyes closed on compliance + 1Hz stimulation
%             S03_vibratory: Eyes closed on compliance + 1Hz stimulation +
%             vibratory noise
%             S03_auditory: Eyes closed on compliance + 1Hz stimulation +
%             auditory noise

% define input and output folders
DIR_SROutputdata = '\\hest.nas.ethz.ch\green_groups_lmb_public\Projects\NCM\NCM_EXP\NCM_STM\NCM_STR\SR_YKK\Results_3\Norect';
destPath         = '\\hest.nas.ethz.ch\green_groups_lmb_public\Projects\NCM\NCM_EXP\NCM_STM\NCM_STR\SR_YKK\Results_3\Norect\';
addpath(genpath(DIR_SROutputdata));
addpath(genpath(pwd));

%% load data as table
Coherencetype = 'copemg';
filenamecoherence = [DIR_SROutputdata, filesep,  'coherence.csv'];
filenameconfidencelimits = [DIR_SROutputdata, filesep,  'copemgcoherencecl.mat'];

copemgCoherence = readtable(filenamecoherence,'Delimiter',',','ReadVariableNames',true);
load(filenameconfidencelimits);

columnNames = copemgCoherence.Properties.VariableNames;

pooledcopemgCoherence = struct([]);
%% On the side: Looking at Cop Parameters
filename = [DIR_SROutputdata, filesep,  'copParameters.csv'];
copparams = readtable(filename, 'Delimiter',',','ReadVariableNames',true);

% Removing extreme value of coeff
p02 = strcmp(copemgCoherence.participant, 'P02');

% Removing the extremely low sway individuals...
p03 = strcmp(copemgCoherence.participant, 'P03');
p05 = strcmp(copemgCoherence.participant, 'P05');
p12 = strcmp(copemgCoherence.participant, 'P12');
p14 = strcmp(copemgCoherence.participant, 'P14');
p15 = strcmp(copemgCoherence.participant, 'P15');
p21 = strcmp(copemgCoherence.participant, 'P21');
p22 = strcmp(copemgCoherence.participant, 'P22');
p25 = strcmp(copemgCoherence.participant, 'P25');
p26 = strcmp(copemgCoherence.participant, 'P26');
p28 = strcmp(copemgCoherence.participant, 'P28');

pCommon = p02 + p03 + p05 + p12 + p14 + p15 + p21 + p22 + p25 + p26 + p28;

copemgCoherence(logical(pCommon),:) = [];
fields = {'P02','P03', 'P05', 'P12', 'P14', 'P15', 'P21', 'P22', 'P25', 'P26', 'P28'};
copemgcoherenceconfidencelimits= rmfield(copemgcoherenceconfidencelimits,fields);

% ivar = {'participant', 'stim'};
% specCoeffUnstack = unstack(copemgCoherence, 'SOL_R_cohereneurospecx', ivar);
% Necessary columns for further processing for all muscldes

muscleID = {'SoleusLeft', 'TibialisLeft', 'GastrocLeft', 'SoleusRight', 'TibialisRight', 'GastrocRight'};
muscleType = {'SOL_L', 'TAN_L', 'GAL_L', 'SOL_R','TAN_R', 'GAL_R'};
sessionID = {'S01_notrigger', 'S02_notrigger', 'S03_neutral', 'S03_vibratory', 'S03_auditory'};
columnsforMusc = [[1:6, 11:22]; [1:6, 27:38]; [1:6, 43:54]; [1:6, 59:70]; [1:6, 75:86]; [1:6, 91:102]];

count = 1;
count_sess = 1;
colCount = 1;

%% Loop through muscles, COPx and COPy, sessions and participants
for caseno = [1,3,5,6]
    if caseno == 1
        sessRun = [1:3, 5];
        sesscompNameString = 'overall';
        filesubFolder = 'Outputs_Visualisation_woST';
    elseif caseno == 2
        sessRun = [1 2];
        sesscompNameString = 'sess_1_2';
        filesubFolder = 'Outputs_Visualisation_woST_sess1_2';
    elseif caseno == 3
        sessRun = [3 5];
        sesscompNameString = 'sess_3_5';
        filesubFolder = 'Outputs_Visualisation_woST_sess3_5';
    elseif caseno == 4
        sessRun = [3 4];
        sesscompNameString = 'sess_3_4';
        filesubFolder = 'Outputs_Visualisation_woST_sess3_4';
    elseif caseno == 5
        sessRun = [2 5];
        sesscompNameString = 'sess_2_5';
        filesubFolder = 'Outputs_Visualisation_woST_sess2_5';
    elseif caseno == 6
        sessRun = [2 3];
        sesscompNameString = 'sess_2_3';
        filesubFolder = 'Outputs_Visualisation_woST_sess2_3';
    end

    for musc = 1:size(muscleID, 2)
        mstructdef=muscleType{1, musc}; % e.g. SOL_R
        muscname = [muscleID{musc}, 'Coherence']; % e.g. SoleusRightCoherence
        musccoln = columnsforMusc(musc,:); % columns of copemgCoherence used for corresponding muscle

        MuscleCoherence.(muscname) = copemgCoherence(:, musccoln); % Save columns in struct

        participants = unique(MuscleCoherence.(muscname).participant); % List of all participants
        participants = participants(~cellfun('isempty', participants));

        % Convert columns from double into cells for further processing
        for cols = 5:18
            MuscleCoherence.(muscname).(cols) = num2cell(MuscleCoherence.(muscname).(cols));
        end
        % Pooling later done for coherence of each muscle with COPx and COPy
        for side = 1:2
            if side == 1
                direction = 'x';
                structdef = 'Copx';
            elseif side == 2
                direction = 'y';
                structdef = 'Copy';
            end

            % Loop through all four conditions
            for sess = sessRun
                IDtocompare = sessionID{sess}; % E.g. S01_FP_EC
                sesscl = char(IDtocompare(1:3));
                checkIDs = strcmp(MuscleCoherence.(muscname).stim, IDtocompare);

                if side == 1 % Copx vs muscle

                    % Save only measurements for Spectra coefficients in x direction for the condition we are looking at
                    SpecCoeff.(sesscompNameString).(structdef).(muscleID{musc}).(IDtocompare(5:end)) = [MuscleCoherence.(muscname){checkIDs, [1,3,5,6]}, num2cell(MuscleCoherence.(muscname){checkIDs, [13,15,17]})];
                    SpecCoeff.(sesscompNameString).(structdef).(muscleID{musc}).(IDtocompare(5:end)) = cell2table(SpecCoeff.(sesscompNameString).(structdef).(muscleID{musc}).(IDtocompare(5:end)), "VariableNames", ["participant" "trial" "bin" "frequencies" "specCoeff1neurospecx" "specCoeff2neurospecx" "specCoeff3neurospecx"]);

                    % Loop through all participants for COPx-Muscle coherence
                    for parts = 1:length(participants)

                        parttocompare = participants{parts};

                        % Save only measurements for current participant in struct
                        partCheck = strcmp(SpecCoeff.(sesscompNameString).(structdef).(muscleID{musc}).(IDtocompare(5:end)){:,1}, parttocompare);
                        SpecCoeff_parts.(sesscompNameString).(structdef).(muscleID{musc}).(parttocompare).(IDtocompare(5:end)) = cell2table([SpecCoeff.(sesscompNameString).(structdef).(muscleID{musc}).(IDtocompare(5:end)){partCheck,1:2}, num2cell(SpecCoeff.(sesscompNameString).(structdef).(muscleID{musc}).(IDtocompare(5:end)){partCheck,3:4}), num2cell(SpecCoeff.(sesscompNameString).(structdef).(muscleID{musc}).(IDtocompare(5:end)){partCheck,5:7})],...
                            "VariableNames", ["participant", "trial", "bin", "frequencies", "specCoeff1neurospecx", "specCoeff2neurospecx", "specCoeff3neurospecx"]);

                        % Check that length of dataframe is right
                        lengthoftable_participant = size(SpecCoeff_parts.(sesscompNameString).(structdef).(muscleID{musc}).(parttocompare).(IDtocompare(5:end)), 1);
                        if lengthoftable_participant >= 1000
                            pooledcopemgCoherenceScript_HCPC_YKK; % Pooling
                        else
                            disp('this trial is too short')
                        end
                    end

                    disp(['Done with: ', mstructdef, ', ', structdef, ', ', IDtocompare])
                    count_sess = 1;

                elseif side == 2 % Copy vs muscle

                    % Save only measurements for Spectra coefficients in y direction for the condition we are looking at
                    % (still for all participants)
                    SpecCoeff.(sesscompNameString).(structdef).(muscleID{musc}).(IDtocompare(5:end)) = [MuscleCoherence.(muscname){checkIDs, [1,3,5,6]}, num2cell(MuscleCoherence.(muscname){checkIDs, [14,16,18]})];
                    SpecCoeff.(sesscompNameString).(structdef).(muscleID{musc}).(IDtocompare(5:end)) = cell2table(SpecCoeff.(sesscompNameString).(structdef).(muscleID{musc}).(IDtocompare(5:end)), "VariableNames", ["participant" "trial" "bin" "frequencies" "specCoeff1neurospecy" "specCoeff2neurospecy" "specCoeff3neurospecy"]);

                    % Loop through all participants for COPy-Muscle coherence
                    for parts = 2:length(participants)

                        parttocompare = participants{parts};
                        partCheck = strcmp(SpecCoeff.(sesscompNameString).(structdef).(muscleID{musc}).(IDtocompare(5:end)){:,1}, parttocompare);

                        % Save only measurements for current participant in struct
                        SpecCoeff_parts.(sesscompNameString).(structdef).(muscleID{musc}).(parttocompare).(IDtocompare(5:end)) = cell2table([SpecCoeff.(sesscompNameString).(structdef).(muscleID{musc}).(IDtocompare(5:end)){partCheck,1:2}, num2cell(SpecCoeff.(sesscompNameString).(structdef).(muscleID{musc}).(IDtocompare(5:end)){partCheck,3:4}), num2cell(SpecCoeff.(sesscompNameString).(structdef).(muscleID{musc}).(IDtocompare(5:end)){partCheck,5:7})],...
                            "VariableNames", ["participant", "trial", "bin", "frequencies", "specCoeff1neurospecy", "specCoeff2neurospecy", "specCoeff3neurospecy"]);

                        % Check that length of dataframe is right
                        lengthoftable_participant = size(SpecCoeff_parts.(sesscompNameString).(structdef).(muscleID{musc}).(parttocompare).(IDtocompare(5:end)), 1);
                        if lengthoftable_participant >= 4097
                            pooledcopemgCoherenceScript_HCPC_YKK; % Pooling
                        else
                            disp('this trial is too short')
                        end
                    end
                    disp(['Done with: ', mstructdef, ', ', structdef, ', ', IDtocompare])
                    count_sess = 1;
                end
            end
            count = 1;
        end
    end
end

%% Save results of pooled COP-EMG coherence
filefolder = [destPath, filesep, 'Latest'];
if ~exist(filefolder, 'dir')
    mkdir(filefolder)
end

filename = [filefolder, filesep, 'pooledcopemgCoherence.mat'];
save(filename, '-struct', 'Pooled_f_concat')
filename1 = [filefolder, filesep, 'pooledcopemgCoherence_clValue.mat'];
save(filename1, '-struct', 'Pooled_cl_concat')
