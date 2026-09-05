function [coherenceparameters,spectra, confidencelimitsparameters] = converttoemgemgcoherencematrix(dataset, subID, sessID, trialID, stimID, musclename)

participant_old = cellstr(subID);
session_old = cellstr(sessID);
trial_old = cellstr(trialID);
stim_old = cellstr(stimID);

nameoffield = fieldnames(dataset); % Get all field names in the dataset

for n_index = 1:size(nameoffield, 1)
    frequencies = dataset.(nameoffield{n_index}).analysisfreq(:,1);
    lengthofvector = size(frequencies, 1);
    bin = (1:1:lengthofvector)';

    participant = repmat(participant_old(~cellfun(@isempty,participant_old)), lengthofvector, 1);
    session = repmat(session_old(~cellfun(@isempty,session_old)), lengthofvector, 1);
    trial = repmat(trial_old(~cellfun(@isempty,trial_old)), lengthofvector, 1);
    stim = repmat(stim_old(~cellfun(@isempty,stim_old)), lengthofvector, 1);

    emgspectra = dataset.(nameoffield{n_index}).analysisspectra;
    emgcohere = dataset.(nameoffield{n_index}).analysiscoherence;
    emgspecCoeff1 = dataset.(nameoffield{n_index}).analysisspecCoeff1;
    emgspecCoeff2 = dataset.(nameoffield{n_index}).analysisspecCoeff2;
    emgspecCoeff3 = dataset.(nameoffield{n_index}).analysisspecCoeff3;

    % Initialize table with basic fields
    coherenceparameters.(nameoffield{n_index}) = table(participant, session, trial, stim, bin, frequencies);
    spectra.(nameoffield{n_index}) = table(participant, session, trial, stim, bin, frequencies);

    countcol = 0;
    for jj = 1:length(musclename)
        if jj <= 5
            for kk = jj+1:length(musclename)
                countcol = countcol + 1;
                headerN = [musclename{jj}, '_', musclename{kk}];

                % Assign data directly to table fields

                if jj == 5 && kk == 6
                    spectra.(nameoffield{n_index}).([musclename{kk}, '_emgspectra']) = emgspectra(:,kk);
                end
                spectra.(nameoffield{n_index}).([musclename{jj}, '_emgspectra']) = emgspectra(:,jj);
                coherenceparameters.(nameoffield{n_index}).([headerN, '_emgcohere']) = emgcohere(:, countcol);
                coherenceparameters.(nameoffield{n_index}).([headerN, '_specCoeff1']) = emgspecCoeff1(:, countcol);
                coherenceparameters.(nameoffield{n_index}).([headerN, '_specCoeff2']) = emgspecCoeff2(:, countcol);
                coherenceparameters.(nameoffield{n_index}).([headerN, '_specCoeff3']) = emgspecCoeff3(:, countcol);
                confidencelimitsparameters.(nameoffield{n_index}).(headerN) = ...
                    dataset.(nameoffield{n_index}).analysiscl(countcol);

            end
        else
            continue;
        end
    end
end
end
