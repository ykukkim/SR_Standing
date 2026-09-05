clc
clear all
close all

%% define input and output folders

ifMac = input('Please choose computer is being used for analysis? \n Enter 0 for Mac or 1 for Non Mac or Junk\n');
switch ifMac
    case 0
        DIR_SROutputdata = '/Volumes/green_groups_lmb_public/Projects/NCM/NCM_EXP/NCM_STM/NCM_STR/Manuscript/2019/Outputs_cl';
        %DIR_SRCOPdata = '/Volumes/green_groups_lmb_public/Projects/NCM/NCM_EXP/NCM_STM/NCM_STR/SR_FR_FINAL/MatCodes';
        destPath= '/Volumes/green_groups_lmb_public/Projects/NCM/NCM_EXP/NCM_STM/NCM_STR/Manuscript/2019/Outputs/Output_Summary'; % destination path that needs to be changed based on the folder where the results
        % need to be saved.
        pathCompSep = '/';
    case 1
        % Please check paths for the Windows computer...
        DIR_SROutputdata='\\green-lmb\green_groups_lmb_public\Projects\NCM\NCM_EXP\NCM_STM\NCM_STR\Manuscript\Ouputs_2018_cl'; % change to the relevant Windows path.
        %DIR_SRCOPdata = 'P:\Projects\NCM\NCM_EXP\NCM_STM\NCM_STR\SR_FR_FINAL\MatCodes';
        pathCompSep = '\';
        destPath= '\\green-lmb\green_groups_lmb_public\Projects\NCM\NCM_EXP\NCM_STM\NCM_STR\Manuscript\Outputs\Output_Summary';
end

addpath(genpath(DIR_SROutputdata));
%addpath(genpath(DIR_SRCOPdata));
currentfolder = pwd;
addpath(genpath(currentfolder));

%% load data as table

Coherencetype = 'copemg';
filenamecoherence = [DIR_SROutputdata, pathCompSep,  'Outputs_2018_clcoherence.csv'];

filenameconfidencelimits = [DIR_SROutputdata, pathCompSep,  'Outputs_2018_clcopemgcoherencecl.mat'];

%filedata = dlmread(filename);

copemgCoherence = readtable(filenamecoherence,...
    'Delimiter',',','ReadVariableNames',true);

load(filenameconfidencelimits);

columnNames = copemgCoherence.Properties.VariableNames;

count = 0;

pooledcopemgCoherence = struct([]);

% for cols = 7:size(copemgCoherence,2)
%     if isempty(strfind(columnNames{cols},'phase')) && ...
%             isempty(strfind(columnNames{cols},'cumden')) && ...
%             isempty(strfind(columnNames{cols},'specCoeff'))
%         count=count+1;
%         columnNamesnew{count} = ['zscores', columnNames{cols}];
%         copemgCoherence.(columnNamesnew{count}) = ...
%             atanh(copemgCoherence.(columnNames{cols}));
%     end
% end
% columnNamesAdded = copemgCoherence.Properties.VariableNames;

% Removing the conventional sway individuals...
% conventional sway group: P01, P02, P04, P06, P07, P08, P09, P10, P11,
% P13, P14, P18, P16, P17, P18, P19, P20, P21, P23, P24, P27
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

pCommon = p03 + p05 + p12 + p14 + p15 + p21 + p22 + p25 + p26 + p28;

copemgCoherence(logical(pCommon),:) = [];

fields = {'P03', 'P05', 'P12', 'P14', 'P15', 'P21', 'P22', 'P25', 'P26', 'P28'};
copemgcoherenceconfidencelimits = rmfield(copemgcoherenceconfidencelimits,fields);

% ivar = {'participant', 'stim'};
% specCoeffUnstack = unstack(copemgCoherence, 'SOL_R_cohereneurospecx', ivar);
muscleID = {'SoleusLeft', 'TibialisLeft', 'GastrocLeft', 'SoleusRight', 'TibialisRight', 'GastrocRight'};
columnsforMusc = [[1:6, 11:21]; [1:6, 26:36]; [1:6, 41:51]; [1:6, 56:66]; [1:6, 71:81]; [1:6, 86:96]];
sessionID = {'S01_notrigger', 'S02_notrigger', 'S03_neutral', 'S03_vibratory', 'S03_auditory'};
count = 1;
count_sess = 1;
colCount = 1;

for caseno = [2, 3, 5, 6]
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
        if musc == 1
            mstructdef = 'SOL_L';
        elseif musc == 2
            mstructdef = 'TAN_L';
        elseif musc == 3
            mstructdef = 'GAL_L';
        elseif musc == 4
            mstructdef = 'SOL_R';
        elseif musc == 5
            mstructdef = 'TAN_R';
        elseif musc == 6
            mstructdef = 'GAL_R';
        end

        sigsinv = ['cop', muscleID{musc}];
        muscname = [muscleID{musc}, 'Coherence'];
        musccoln = columnsforMusc(musc,:);
        mcommd = [muscname '= copemgCoherence(:, [musccoln]);'];
        eval(mcommd);

        partcommd = ['participants = unique(', muscname, '.participant);'];
        eval(partcommd);
        for side = 1%:2
            if side == 1
                direction = 'x';
                structdef = 'Copx_';
            elseif side == 2
                direction = 'y';
                structdef = 'Copy_';
            end
            for sess = sessRun
                part_count = 1;
                IDtocompare = sessionID{sess};
                sesscl = char(IDtocompare(1:3));
                dirParam = [sesscompNameString, 'cop', direction, muscleID{musc}, 'SpecCoeff', IDtocompare];
                scommd = [dirParam '=', muscname, '(strcmp(', muscname, '.stim, IDtocompare), [1, 3, 5, 6, 13, 15, 17]);'];
                eval(scommd);

                for parts = 1:length(participants)

                    pooledcopemgCoherenceScript_HCPC_2019;

                end


                count_sess =  1;

            end
            filefolder = [DIR_SROutputdata, pathCompSep, 'Latest'];
            if ~exist([filefolder, 'dir'])
                mkdir(filefolder)
            end

            varnamecopemgCoherence = ['Pooled_f_withSess', sesscompNameString, sigsinv];

            varnamecopemgCoherence_clValue = ['Pooled_cl_sig_withSess', sesscompNameString, sigsinv];

            varnamecopemgCoherence_chisqSig = ['Pooled_cl_sig1_withSess', sesscompNameString, sigsinv];

            varnamecopemgCoherence_chisqValue = ['Pooled_f_chisq_withSess', sesscompNameString, sigsinv];

            filename = [filefolder, pathCompSep, 'pooledcopemgCoherence.mat'];
            if exist(filename) == 2
                save(filename, varnamecopemgCoherence, '-append');
            else
                save(filename, varnamecopemgCoherence);
            end

            filename1 = [filefolder, pathCompSep, 'pooledcopemgCoherence_clValue.mat'];
            if exist(filename1) == 2
                save(filename1, varnamecopemgCoherence_clValue, '-append');
            else
                save(filename1, varnamecopemgCoherence_clValue);
            end

            filename2 = [filefolder, pathCompSep, 'pooledcopemgCoherence_chisqSig.mat'];
            if exist(filename2) == 2
                save(filename2, varnamecopemgCoherence_chisqSig, '-append');
            else
                save(filename2, varnamecopemgCoherence_chisqSig);
            end

            filename3 = [filefolder, pathCompSep, 'pooledcopemgCoherence_chisqValue.mat'];
            if exist(filename3) == 2
                save(filename3, varnamecopemgCoherence_chisqValue, '-append');
            else
                save(filename3, varnamecopemgCoherence_chisqValue);
            end

            count = 1;
        end
    end
end







%save('2019September27_copemg')
