function [crosscorrparameters] = convertcrosscorrmatrix(dataset, subID, sessID, trialID, stimID, musclename)

participant = cellstr(subID);
session = cellstr(sessID);
trial = cellstr(trialID);
stim = cellstr(stimID);

crosscorrx = dataset.Copx.Corrmax;
crosscorry = dataset.Copy.Corrmax;

lagx = dataset.Copx.timeDiff;
lagy = dataset.Copx.timeDiff;


crosscorrparameters = table(participant, session, trial, stim);

for jj = 1:length(musclename)
    headerN = musclename{jj};
    hdname = [headerN, 'crosscorrx'];
    commd  = ['crosscorrparameters.' hdname ...
        ' = crosscorrx(:, jj);'];
    eval(commd);
    hdname2 = [headerN, 'crosscorry'];
    commd2 = ['crosscorrparameters.' hdname2 ...
        ' = crosscorry(:, jj);'];
    eval(commd2);
    hdname3 = [headerN, 'lagx'];
    commd3 = ['crosscorrparameters.' hdname3 ...
        ' = lagx(:, jj);'];
    eval(commd3);
    hdname4 = [headerN, 'lagy'];
    commd4 = ['crosscorrparameters.' hdname4 ...
        ' = lagy(:, jj);'];
    eval(commd4);
end