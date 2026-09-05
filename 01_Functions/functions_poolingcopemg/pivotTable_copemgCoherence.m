clc
clear all
close all

%% define input and output folders

ifMac = input('Please choose computer is being used for analysis? \n Enter 0 for Mac or 1 for Non Mac or Junk\n');
switch ifMac
    case 0
        DIR_SROutputdata = '/Volumes/green_groups_lmb_public/Projects/NCM/NCM_EXP/NCM_STM/NCM_STR/Manuscript/Outputs_2017';
        %DIR_SRCOPdata = '/Volumes/green_groups_lmb_public/Projects/NCM/NCM_EXP/NCM_STM/NCM_STR/SR_FR_FINAL/MatCodes';
        destPath= '/Volumes/green_groups_lmb_public/Projects/NCM/NCM_EXP/NCM_STM/NCM_STR/Manuscript/Outputs/Output_Summary'; % destination path that needs to be changed based on the folder where the results
        % need to be saved.
        pathCompSep = '/';
    case 1
        % Please check paths for the Windows computer...
        DIR_SROutputdata='P:\Projects\NCM\NCM_EXP\NCM_STM\NCM_STR\Manuscript\Outputs_2017'; % change to the relevant Windows path.
        %DIR_SRCOPdata = 'P:\Projects\NCM\NCM_EXP\NCM_STM\NCM_STR\SR_FR_FINAL\MatCodes';
        pathCompSep = '\';
        destPath= 'P:\Projects\NCM\NCM_EXP\NCM_STM\NCM_STR\Manuscript\Outputs\Output_Summary';
end

addpath(genpath(DIR_SROutputdata));
%addpath(genpath(DIR_SRCOPdata));
currentfolder = pwd;
addpath(genpath(currentfolder));

%% load data as table

filename = [DIR_SROutputdata, pathCompSep,  'Outputs_2017coherence.csv'];

%filedata = dlmread(filename);

copemgCoherence = readtable(filename,...
    'Delimiter',',','ReadVariableNames',true);

columnNames = copemgCoherence.Properties.VariableNames;

count = 0;
for cols = 7:size(copemgCoherence,2)
    if isempty(strfind(columnNames{cols},'phase')) && ...
            isempty(strfind(columnNames{cols},'cumden'))
        count=count+1;
        columnNamesnew{count} = ['zscores', columnNames{cols}];
        copemgCoherence.(columnNamesnew{count}) = ...
            atanh(copemgCoherence.(columnNames{cols}));
    end
end
columnNamesAdded = copemgCoherence.Properties.VariableNames;

p06 = strcmp(copemgCoherence.participant, 'P06');
p23 = strcmp(copemgCoherence.participant, 'P23');
p25 = strcmp(copemgCoherence.participant, 'P25');
p28 = strcmp(copemgCoherence.participant, 'P28');

pCommon = p06 + p23 + p25 + p28;

copemgCoherence(logical(pCommon),:) = [];

for i = 7:size(copemgCoherence,2)
    colName = columnNamesAdded{i};
    paramName = ['mean', colName];
    commd = [paramName ...
        '= unstack(copemgCoherence,', '''', colName, '''', ',''stim'', ''GroupingVariables'', {''participant'', ''frequencies''}, ''AggregationFunction'', @mean);'];
    eval(commd);
    commd1 = ['nocols = size(', paramName, ', 2);'];
    eval(commd1);
    commd2 = ['varnames = ', paramName, '.Properties.VariableNames;'];
    eval(commd2);


    commd6 = ['check = isempty(strfind(', '''', paramName, '''',', ''phase''));'];
    eval(commd6);
    commd7 = ['check1 = isempty(strfind(', '''', paramName, '''', ', ''cumden''));'];
    eval(commd7);
    commd9 = ['check2 = ~isempty(strfind(', '''', paramName, '''', ', ''zscores''));'];
    eval(commd9);

    if i == 7
        pG = meanSOL_L_coherex(:, 'participant');
        noofparts = union(meanSOL_L_coherex.participant, pG.participant);
    end

    if check && check1 && check2

        nofigs = 0;
        for pno = 1:size(noofparts,1)

            commd5 = ['p = strcmp(', paramName, '.participant, noofparts(pno));'];
            eval(commd5);
            commd8 = [paramName, '_', num2str(pno), ' = ', paramName, '(p,:);'];
            eval(commd8)
            if strcmp(noofparts(pno), 'P01') || strcmp(noofparts(pno), 'P05') ...
                    || strcmp(noofparts(pno), 'P13')
                nofigs = nofigs + 1;
                commdF = ['f', num2str(nofigs), '= figure;'];
                eval(commdF);
                commdA = ['ax', num2str(nofigs), '= axes(', '''', 'Parent', '''', ', f', num2str(nofigs), ',', '''', 'Fontsize', '''',',', '12, ', '''', 'FontName', '''', ', ', '''', 'Arial', '''', ');'];
                eval(commdA)
                count = 0;
                for j = 3:nocols
                    if j == 6 || j == 8
                        continue;
                    else
                        count = count + 1;

                        commd3 = ['plot(',paramName, '_', num2str(pno), '.frequencies, ', paramName, '_', num2str(pno), '.', varnames{j},');'];
                        eval(commd3);
                        commd4 = ['legendinfo{count} = [', '''', varnames{j}, '''', '];'];
                        eval(commd4);
                        hold on;
                    end
                end
                legend(legendinfo, 'interpreter', 'none');
                if pno < 11
                    commdT = ['title(ax',num2str(nofigs), ',', '''', 'P0', num2str(pno), ' - ', colName, '''', ',', '''', 'interpreter', '''', ',', '''', 'none', '''', ');'];
                else
                    commdT = ['title(ax',num2str(nofigs), ',', '''', 'P', num2str(pno), ' - ', colName, '''', ',', '''', 'interpreter', '''', ',', '''', 'none', '''', ');'];
                end
                eval(commdT);
                hold off;
            end
        end
    end
end
