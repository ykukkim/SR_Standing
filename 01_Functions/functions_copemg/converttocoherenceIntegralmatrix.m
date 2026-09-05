function [coherenceIntegralparameters] = converttocoherenceIntegralmatrix(dataseta, datasetb, subID, sessID, trialID, stimID, musclename)

participant = cellstr(subID);
session = cellstr(sessID);
trial = cellstr(trialID);
stim = cellstr(stimID);

parametercopemgcoherenceIntegralx = array2table(dataseta.Copx.analysiscoherenceIntegral);
parametercopemgcoherenceIntegraly = array2table(dataseta.Copy.analysiscoherenceIntegral);


parametercopemgcoherenceIntegralx_neurospec = array2table(dataseta.Copx.analysiscoherenceIntegral_neurospec);
parametercopemgcoherenceIntegraly_neurospec = array2table(dataseta.Copy.analysiscoherenceIntegral_neurospec);


parameterinteremgcoherenceIntegral = array2table(datasetb.analysiscoherenceIntegral);
parameterinteremgcoherenceIntegral_neurospec = array2table(datasetb.analysiscoherenceIntegral_neurospec);

coherenceIntegralparameterscells = table(participant, session, trial, stim);
coherenceIntegralparameters = [coherenceIntegralparameterscells parametercopemgcoherenceIntegralx];

coherenceIntegralVariablenames = coherenceIntegralparameters.Properties.VariableNames;

colnames = 5;

for jj = 1:length(musclename)
    headerN = musclename{jj};

    hdname = [headerN, '_emgcohereIntegralx'];
    coherenceIntegralVariablenames{colnames} = hdname;
    colnames = colnames + 1;
end

coherenceIntegralparameters.Properties.VariableNames = coherenceIntegralVariablenames;

coherenceIntegralparameters = [coherenceIntegralparameters parametercopemgcoherenceIntegraly];
coherenceIntegralVariablenames = coherenceIntegralparameters.Properties.VariableNames;

for jj = 1:length(musclename)
    headerN = musclename{jj};

    hdname = [headerN, '_emgcohereIntegraly'];
    coherenceIntegralVariablenames{colnames} = hdname;
    colnames = colnames + 1;
end
coherenceIntegralparameters.Properties.VariableNames = coherenceIntegralVariablenames;

coherenceIntegralparameters = [coherenceIntegralparameters parametercopemgcoherenceIntegralx_neurospec];

coherenceIntegralVariablenames = coherenceIntegralparameters.Properties.VariableNames;


for jj = 1:length(musclename)
    headerN = musclename{jj};

    hdname = [headerN, '_emgcohereIntegralx_neurospec'];
    coherenceIntegralVariablenames{colnames} = hdname;
    colnames = colnames + 1;
end

coherenceIntegralparameters.Properties.VariableNames = coherenceIntegralVariablenames;

coherenceIntegralparameters = [coherenceIntegralparameters parametercopemgcoherenceIntegraly_neurospec];
coherenceIntegralVariablenames = coherenceIntegralparameters.Properties.VariableNames;


for jj = 1:length(musclename)
    headerN = musclename{jj};

    hdname = [headerN, '_emgcohereIntegraly_neurospec'];
    coherenceIntegralVariablenames{colnames} = hdname;
    colnames = colnames + 1;
end
coherenceIntegralparameters.Properties.VariableNames = coherenceIntegralVariablenames;


coherenceIntegralparameters = [coherenceIntegralparameters parameterinteremgcoherenceIntegral];
coherenceIntegralVariablenames = coherenceIntegralparameters.Properties.VariableNames;

countcol = 0;

for ll = 1:length(musclename)
    if ll>5
        continue;
    else
        for kk = ll+1:length(musclename)
            countcol = countcol +1;
            headerN = [musclename{ll}, '_',musclename{kk}];
            hdname = [headerN, '_interemgcohereIntegral'];
            coherenceIntegralVariablenames{colnames} = hdname;
            colnames = colnames + 1;
        end
    end
end
coherenceIntegralparameters.Properties.VariableNames = coherenceIntegralVariablenames;

coherenceIntegralparameters = [coherenceIntegralparameters parameterinteremgcoherenceIntegral_neurospec];
coherenceIntegralVariablenames = coherenceIntegralparameters.Properties.VariableNames;

countcol = 0;

for ll = 1:length(musclename)
    if ll>5
        continue;
    else
        for kk = ll+1:length(musclename)
            countcol = countcol +1;
            headerN = [musclename{ll}, '_',musclename{kk}];
            hdname = [headerN, '_interemgcohereIntegral_neurospec'];
            coherenceIntegralVariablenames{colnames} = hdname;
            colnames = colnames + 1;
        end
    end
end

coherenceIntegralparameters.Properties.VariableNames = coherenceIntegralVariablenames;
