% %% extracting variable names from the cop parameters matrix
% copVariablenames = copAnalysisMatrix.Properties.VariableNames;
% MatrixTablecopParameter.Properties.VariableNames = copVariablenames;
%
% for colnames = 5:length(copVariablenames)
%     MatrixTablecopParameter.(copVariablenames{colnames}) = ...
%         str2double(MatrixTablecopParameter.(copVariablenames{colnames}));
% end
%
% %% coherence paramters
% coherenceVariablenames = copemgcoherenceMatrix.Properties.VariableNames;
% MatrixTablecoherence.Properties.VariableNames = coherenceVariablenames;
%
% for colnames = 5:length(coherenceVariablenames)
%     MatrixTablecoherence.(coherenceVariablenames{colnames}) = ...
%         str2double(MatrixTablecoherence.(coherenceVariablenames{colnames}));
% end

% %% spectral parameters
% spectraVariablenames = copemgpowerspectraMatrix.Properties.VariableNames;
% MatrixTablespectra.Properties.VariableNames = spectraVariablenames;
%
% for colnames = 5:length(spectraVariablenames)
%     MatrixTablespectra.(spectraVariablenames{colnames}) = ...
%         str2double(MatrixTablespectra.(spectraVariablenames{colnames}));
% end
%
% %% cross correlation
%
% crosscorrVariablenames = copemgcrosscorrelationMatrix.Properties.VariableNames;
% MatrixTablecrosscorrelation.Properties.VariableNames = crosscorrVariablenames;
%
% for colnames = 5:length(crosscorrVariablenames)
%     MatrixTablecrosscorrelation.(crosscorrVariablenames{colnames}) = ...
%         str2double(MatrixTablecrosscorrelation.(crosscorrVariablenames{colnames}));
% end

%% intermuscular emg
emgcohereVariableNames = interemgcoherenceMatrix.Properties.VariableNames;
MatrixTableemgcoherence.Properties.VariableNames = emgcohereVariableNames;

for colnames = 5:length(emgcohereVariableNames)
    MatrixTableemgcoherence.(emgcohereVariableNames{colnames}) = ...
        str2double(MatrixTableemgcoherence.(emgcohereVariableNames{colnames}));
end
%
% %% coherence Integral
% coherenceIntegralNames = copemgcoherenceIntegralMatrix.Properties.VariableNames;
% MatrixTablecoherenceIntegral.Properties.VariableNames = coherenceIntegralNames;
%
% for colnames = 5:length(coherenceIntegralNames)
%     MatrixTablecoherenceIntegral.(coherenceIntegralNames{colnames}) = ...
%         str2double(MatrixTablecoherenceIntegral.(coherenceIntegralNames{colnames}));
% end
%
