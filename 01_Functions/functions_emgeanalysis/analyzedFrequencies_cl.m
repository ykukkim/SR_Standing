function [dataset] = analyzedFrequencies_cl(dataset, inputname)

if strcmp(inputname, 'spectra')
    nameoffield = fieldnames(dataset);
    nameoffield = nameoffield(2);
elseif strcmp(inputname, 'emgcohere')
    nameoffield = fieldnames(dataset);
    nameoffield = nameoffield(9);
else
    nameoffield = fieldnames(dataset);
end

if strcmp(inputname, 'copspectra')
    parameter = 'spectratotal';
elseif strcmp(inputname, 'emgcohere')
    parameter = 'coheretotal';
    neurospecparameter = [inputname, 'neurospec'];
elseif strcmp(inputname, 'spectra')
    parameter = [inputname, 'total'];
else
    parameter = [inputname, 'total'];
    neurospecparameter = [inputname, 'neurospec'];
end
outputparameter = ['analysis', inputname];

for i = 1:size(nameoffield, 1)
    if strcmp(inputname, 'cohere') || strcmp(inputname, 'copspectra')
        dir=char(nameoffield(i));
        frequencies = dataset.(dir).freqtotal;
        magnitude = dataset.(dir).(parameter);
        if ~strcmp(inputname, 'copspectra')
            magnitudeneurospec = dataset.(dir).(neurospecparameter);
            phaseneurospec = dataset.(dir).phaseneurospec;
            cumdenneurospec = dataset.(dir).cumdenneurospec;
            clneurospec = dataset.(dir).clneurospec;
            specCoeff1neurospec = dataset.(dir).specCoeff1neurospec;
            specCoeff2neurospec = dataset.(dir).specCoeff2neurospec;
            specCoeff3neurospec = dataset.(dir).specCoeff3neurospec;

        end
    else
        frequencies = dataset.freqtotal;
        magnitude = dataset.(parameter);
        if ~strcmp(inputname, 'spectra')
            magnitudeneurospec = dataset.(neurospecparameter);
            phaseneurospec = dataset.emgphaseneurospec;
            cumdenneurospec = dataset.emgcumdenneurospec;
            clneurospec = dataset.emgclneurospec;
            specCoeff1neurospec = dataset.emgspecCoeff1neurospec;
            specCoeff2neurospec = dataset.emgspecCoeff2neurospec;
            specCoeff3neurospec = dataset.emgspecCoeff3neurospec;
        end
    end

    frequency_ind = frequencies<=600;

    coherenceAnalmagnitude = magnitude(frequency_ind(:,1)', frequency_ind(1,:));
    coherenceAnalfrequency =  frequencies(frequency_ind(:,1)', frequency_ind(1,:));

    frequency_indII = frequencies<=11;
    coherenceAnalIntegral = trapz(magnitude(frequency_indII(:,1)', frequency_indII(1,:)));

    if ~strcmp(inputname, 'spectra') && ~strcmp(inputname,'copspectra')
        coherenceAnalmagnitude_neurospec = magnitudeneurospec(frequency_ind(:,1)', frequency_ind(1,:));
        phaseAnal_neurospec = phaseneurospec(frequency_ind(:,1)', frequency_ind(1,:));
        cumdenAnal_neurospec = cumdenneurospec(frequency_ind(:,1)', frequency_ind(1,:));
        clAnal_neurospec = clneurospec;
        specCoeff1Anal_neurospec = specCoeff1neurospec(frequency_ind(:,1)', frequency_ind(1,:));
        specCoeff2Anal_neurospec = specCoeff2neurospec(frequency_ind(:,1)', frequency_ind(1,:));
        specCoeff3Anal_neurospec = specCoeff3neurospec(frequency_ind(:,1)', frequency_ind(1,:));
        coherenceAnalIntegral_neurospec = trapz(magnitudeneurospec(frequency_indII(:,1)', frequency_indII(1,:)));
    end

    if strcmp(inputname, 'cohere') || strcmp(inputname, 'copspectra')
        dataset.(dir).(outputparameter) = coherenceAnalmagnitude;
        dataset.(dir).analysisfreq = coherenceAnalfrequency;
        if strcmp(inputname, 'cohere')
            phase = dataset.(dir).phasetotal;
            coherenceAnalphase = phase(frequency_ind(:,1)', frequency_ind(1,:));
            dataset.(dir).analysisphase = coherenceAnalphase;
            dataset.(dir).analysiscoherenceIntegral = coherenceAnalIntegral;

            dataset.(dir).analysiscoherence_neurospec = coherenceAnalmagnitude_neurospec;
            dataset.(dir).analysiscoherenceIntegral_neurospec = coherenceAnalIntegral_neurospec;
            dataset.(dir).analysisphase_neurospec = phaseAnal_neurospec;
            dataset.(dir).analysiscumden_neurospec = cumdenAnal_neurospec;
            dataset.(dir).analysiscl_neurospec = clAnal_neurospec;
            dataset.(dir).analysisspecCoeff1_neurospec = specCoeff1Anal_neurospec;
            dataset.(dir).analysisspecCoeff2_neurospec = specCoeff2Anal_neurospec;
            dataset.(dir).analysisspecCoeff3_neurospec = specCoeff3Anal_neurospec;
        end
    elseif strcmp(inputname, 'emgcohere')
        phase = dataset.phasetotal;
        dataset.(outputparameter) = coherenceAnalmagnitude;
        dataset.analysiscoherenceIntegral = coherenceAnalIntegral;
        dataset.analysisfreq = coherenceAnalfrequency;
        coherenceAnalphase = phase(frequency_ind(:,1)', frequency_ind(1,:));
        dataset.analysisphase = coherenceAnalphase;

        dataset.analysiscoherence_neurospec = coherenceAnalmagnitude_neurospec;
        dataset.analysiscoherenceIntegral_neurospec = coherenceAnalIntegral_neurospec;
        dataset.analysisphase_neurospec = phaseAnal_neurospec;
        dataset.analysiscumden_neurospec = cumdenAnal_neurospec;
        dataset.analysiscl_neurospec = clAnal_neurospec;
        dataset.analysisspecCoeff1_neurospec = specCoeff1Anal_neurospec;
        dataset.analysisspecCoeff2_neurospec = specCoeff2Anal_neurospec;
        dataset.analysisspecCoeff3_neurospec = specCoeff3Anal_neurospec;

    else
        dataset.(outputparameter) = coherenceAnalmagnitude;
        dataset.analysisfreq = coherenceAnalfrequency;
    end
end