function [copparameters] = converttocopmatrix(dataset, subID, sessID, trialID, stimID)

participant = cellstr(subID);
session = cellstr(sessID);
trial = cellstr(trialID);
stim = cellstr(stimID);

parameterlinear = struct2table(dataset.linear);

copparameters = table(participant, session, trial, stim);

for params = 1:size(parameterlinear,2)
    copparameters = [copparameters parameterlinear(1,params)];
end
