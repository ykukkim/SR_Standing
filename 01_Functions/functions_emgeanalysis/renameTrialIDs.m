
clc;
clear all;
close all;
%%
ifMac = input('Please choose computer is being used for analysis? \n Enter 0 for Mac or 1 for Non Mac or Junk\n');
switch ifMac
    case 0

        destPath= '/Volumes/green_groups_lmb_public/Student/Brockmann/Fabienne/test'; % destination path that needs to be changed based on the folder where the results
        % need to be saved.
        pathCompSep = '/';
    case 1
        % Please check paths for the Windows computer...

        pathCompSep = '\';
        destPath= 'P:\Student\Brockmann\Fabienne\test\';
end

currentfolder = pwd;
addpath(genpath(destPath));
addpath(genpath(currentfolder));

%%

fileSpectra = [destPath, 'spectra.csv'];
dataset_spectra = readtable(fileSpectra);

%%
dataset_spectra.trialMod = dataset_spectra.trial;

for i = 1:30
    if i < 10
        totalParticipant{i} = ['P0',num2str(i)];
    else
        totalParticipant{i} = ['P',num2str(i)];
    end
end

for i = 1:length(dataset_spectra.trialMod)
    participID = dataset_spectra.participant{i};
    if

end
