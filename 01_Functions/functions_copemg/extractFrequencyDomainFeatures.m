function [dataset] = extractFrequencyDomainFeatures(dataset, inputname)

% Adjust parameters based on specific input names
switch inputname
    case 'emgcopcohere'
        directions = fieldnames(dataset);
        nameoffield = fieldnames(dataset.(directions{1}));
    case 'emgcohere'
        nameoffield = fieldnames(dataset);

end

if strcmp(inputname, 'emgcopcohere')
    for cop_idx = 1:length(directions)
        for n_index = 1:length(nameoffield)
            frequencies = dataset.(directions{cop_idx}).(nameoffield{n_index}).emgcopfreq;
            copspectra = dataset.(directions{cop_idx}).(nameoffield{n_index}).copspectra;
            magnitude = dataset.(directions{cop_idx}).(nameoffield{n_index}).emgcopcohere;
            phase = dataset.(directions{cop_idx}).(nameoffield{n_index}).emgcopphasen;
            cl = dataset.(directions{cop_idx}).(nameoffield{n_index}).emgcopcl;
            specCoeff1 = dataset.(directions{cop_idx}).(nameoffield{n_index}).emgcopcrossspec12;
            specCoeff2 = dataset.(directions{cop_idx}).(nameoffield{n_index}).emgcopautospec1;
            specCoeff3 = dataset.(directions{cop_idx}).(nameoffield{n_index}).emgcopautospec2;

            dataset.(directions{cop_idx}).(nameoffield{n_index}).analysisfreq = frequencies;
            dataset.(directions{cop_idx}).(nameoffield{n_index}).analysisspectra = copspectra;

            dataset.(directions{cop_idx}).(nameoffield{n_index}).analysiscoherence = magnitude;
            dataset.(directions{cop_idx}).(nameoffield{n_index}).analysisphase = phase;

            dataset.(directions{cop_idx}).(nameoffield{n_index}).analysisspecCoeff1 = specCoeff1;
            dataset.(directions{cop_idx}).(nameoffield{n_index}).analysisspecCoeff2 = specCoeff2;
            dataset.(directions{cop_idx}).(nameoffield{n_index}).analysisspecCoeff3 = specCoeff3;
            dataset.(directions{cop_idx}).(nameoffield{n_index}).analysiscl = cl;

        end
    end
elseif strcmp(inputname, 'emgcohere')
    for i = 1:size(nameoffield, 1)

        for n_index = 1:length(nameoffield)
            frequencies = dataset.(nameoffield{n_index}).emgfreq;
            emgspectra = dataset.(nameoffield{n_index}).emgspectra;

            magnitude = dataset.(nameoffield{n_index}).emgcohere;
            phase = dataset.(nameoffield{n_index}).emgphasen;
            cl = dataset.(nameoffield{n_index}).emgcl;
            specCoeff1 = dataset.(nameoffield{n_index}).emgautospec1;
            specCoeff2 = dataset.(nameoffield{n_index}).emgautospec2;
            specCoeff3 = dataset.(nameoffield{n_index}).emgcrossspec12;

            dataset.(nameoffield{n_index}).analysisspectra = emgspectra;
            dataset.(nameoffield{n_index}).analysisfreq = frequencies;

            dataset.(nameoffield{n_index}).analysiscoherence = magnitude;
            dataset.(nameoffield{n_index}).analysisphase = phase;
            dataset.(nameoffield{n_index}).analysiscl = cl;
            dataset.(nameoffield{n_index}).analysisspecCoeff1 = specCoeff1;
            dataset.(nameoffield{n_index}).analysisspecCoeff2 = specCoeff2;
            dataset.(nameoffield{n_index}).analysisspecCoeff3 = specCoeff3;
        end
    end
end
end