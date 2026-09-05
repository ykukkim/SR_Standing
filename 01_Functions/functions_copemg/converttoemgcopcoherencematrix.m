function [coherenceparameters,spectra,confidencelimitsparameters] = converttoemgcopcoherencematrix(dataset, subID, sessID, trialID, stimID, musclename)

participant_old = cellstr(subID);
session_old = cellstr(sessID);
trial_old = cellstr(trialID);
stim_old = cellstr(stimID);

directions = fieldnames(dataset);
nameoffield_cop = fieldnames(dataset.(directions{1}));

for n_index = 1:length(nameoffield_cop)
    frequencies = dataset.(directions{1}).(nameoffield_cop{n_index}).analysisfreq(:,1);
    lengthofvector = size(frequencies, 1);
    bin = (1:1:lengthofvector)';

    participant = repmat(participant_old(~cellfun(@isempty,participant_old)), lengthofvector, 1);
    session = repmat(session_old(~cellfun(@isempty,session_old)), lengthofvector, 1);
    trial = repmat(trial_old(~cellfun(@isempty,trial_old)), lengthofvector, 1);
    stim = repmat(stim_old(~cellfun(@isempty,stim_old)), lengthofvector, 1);

    copspectra_x = dataset.(directions{1}).(nameoffield_cop{n_index}).analysisspectra;
    emgcopcohere_x = dataset.(directions{1}).(nameoffield_cop{n_index}).analysiscoherence;
    emgcopspecCoeff1_x = dataset.(directions{1}).(nameoffield_cop{n_index}).analysisspecCoeff1;
    emgcopspecCoeff2_x = dataset.(directions{1}).(nameoffield_cop{n_index}).analysisspecCoeff2;
    emgcopspecCoeff3_x = dataset.(directions{1}).(nameoffield_cop{n_index}).analysisspecCoeff3;

    copspectra_y = dataset.(directions{2}).(nameoffield_cop{n_index}).analysisspectra;
    emgcopcohere_y = dataset.(directions{2}).(nameoffield_cop{n_index}).analysiscoherence;
    emgcopspecCoeff1_y = dataset.(directions{2}).(nameoffield_cop{n_index}).analysisspecCoeff1;
    emgcopspecCoeff2_y = dataset.(directions{2}).(nameoffield_cop{n_index}).analysisspecCoeff2;
    emgcopspecCoeff3_y = dataset.(directions{2}).(nameoffield_cop{n_index}).analysisspecCoeff3;

    coherenceparameters.(nameoffield_cop{n_index}) = table(participant, session, trial, stim, bin, frequencies);
    spectra.(nameoffield_cop{n_index}) = table(participant, session, trial, stim, bin, frequencies,copspectra_x, copspectra_y);

    for jj = 1:length(musclename)
        headerN = musclename{jj};

        coherenceparameters.(nameoffield_cop{n_index}).([headerN, '_emgcopcohere_x']) = emgcopcohere_x(:, jj);
        coherenceparameters.(nameoffield_cop{n_index}).([headerN, '_emgcopspecCoeff1_x']) = emgcopspecCoeff1_x(:, jj);
        coherenceparameters.(nameoffield_cop{n_index}).([headerN, '_emgcopspecCoeff2_x']) = emgcopspecCoeff2_x(:, jj);
        coherenceparameters.(nameoffield_cop{n_index}).([headerN, '_emgcopspecCoeff3_x']) = emgcopspecCoeff3_x(:, jj);

        coherenceparameters.(nameoffield_cop{n_index}).([headerN, '_emgcopcohere_y']) = emgcopcohere_y(:, jj);
        coherenceparameters.(nameoffield_cop{n_index}).([headerN, '_emgcopspecCoeff1_y']) = emgcopspecCoeff1_y(:, jj);
        coherenceparameters.(nameoffield_cop{n_index}).([headerN, '_emgcopspecCoeff2_y']) = emgcopspecCoeff2_y(:, jj);
        coherenceparameters.(nameoffield_cop{n_index}).([headerN, '_emgcopspecCoeff3_y']) = emgcopspecCoeff3_y(:, jj);

        confidencelimitsparameters.(nameoffield_cop{n_index}).([headerN, '_x']) = ...
            dataset.(directions{1}).(nameoffield_cop{n_index}).analysiscl(jj);
        confidencelimitsparameters.(nameoffield_cop{n_index}).([headerN, '_y']) = ...
            dataset.(directions{2}).(nameoffield_cop{n_index}).analysiscl(jj);
    end

end
