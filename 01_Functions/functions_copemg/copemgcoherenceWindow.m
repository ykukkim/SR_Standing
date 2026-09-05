function [coherence, emgSpectra] = copemgcoherenceWindow(copData, emgData, samplingrate_fp, Inputname)
%% Power spectral Density
Nfft = 2^nextpow2(size(copData,1));
lengthofData = size(copData,1);

% for column = 1:size(inputData_rs,2)
%     [coherence.freqtotal(:,column), coherence.pwrtotal(:,column)] = frequencyanal(inputData_rs,samplingrate_fp,Nfft);   % Mean Power frequency in ML
% end
% coherence.freqtotal = coherence.freqtotal.';

%% Coherence and Cross power spectral density
for column = 1:size(emgData,2)
    for i = 1:size(copData, 2)
        if i == 1
            note= 'x';
        elseif i ==2
            note = 'y';
        end

        % provides a resolution of <0.3Hz, with higher averages the
        % resolution gets coarser. E.g. at na = 32 is about 0.5 Hz and at
        % 64 of 1.2 Hz.(length of data/window length)
        na = 16;
        win = hanning(floor(Nfft/na));
        Fieldname = [Inputname, note];

        % Magnitude-squared coherence: These values indicate how well x corresponds to y at each frequency.
        [coherence.(Fieldname).mscoheretotal(:,column), coherence.(Fieldname).freqtotal(:,column)] = ...
            mscohere(copData(:,i), emgData(:,column), win, 0, [], samplingrate_fp);
        coherence.(Fieldname).mscoheretotal(1,column) = 0;
        %coherence.(Fieldname).mscoheretotal(2,column) = 0;

        % Cross Power spectral Density: it displays the distribution of power for a pair of signals across a frequency spectrum at any time
        [coherence.(Fieldname).crpwrtotal(:,column), coherence.(Fieldname).cfreqtotal(:,column)] = ...
            cpsd(copData(:,i), emgData(:,column), win, 0, [], samplingrate_fp);
        coherence.(Fieldname).crpwrtotal(1,column) = 0;
        %coherence.(Fieldname).crpwrtotal(2,column) = 0;

        % Power spectral density estimate: PSD of each individual signal
        [coherence.(Fieldname).pwrcoptotal(:,column), coherence.(Fieldname).pcopfreqtotal(:,column)] = ...
            pwelch(copData(:,i), win, 0, [], samplingrate_fp);
        coherence.(Fieldname).pwrcoptotal(1,column) = 0;
        %coherence.(Fieldname).pwrcoptotal(2,column) = 0;

        [coherence.(Fieldname).pwremgtotal(:,column), coherence.(Fieldname).pemgfreqtotal(:,column)] = ...
            pwelch(emgData(:,column), win, 0, [], samplingrate_fp);

        coherence.(Fieldname).pwremgtotal(1,column) = 0;
        %coherence.(Fieldname).pwremgtotal(2,column) = 0;

        coherence.(Fieldname).coheretotal(:, column) = (abs((coherence.(Fieldname).crpwrtotal(:,column))).^2)...
            ./(abs((coherence.(Fieldname).pwrcoptotal(:,column))).*(abs(coherence.(Fieldname).pwremgtotal(:,column))));
        coherence.(Fieldname).coheretotal(1, column) = 0;
        %coherence.(Fieldname).coheretotal(2, column) = 0;

        coherence.(Fieldname).phasetotal(:,column) = (-angle(coherence.(Fieldname).crpwrtotal(:,column))/pi)*(180);

        [coherence.(Fieldname).cohereneurospec(:,column), ...
            coherence.(Fieldname).phaseneurospec(:,column), ...
            coherence.(Fieldname).cumdenneurospec(:,column), ...
            coherence.(Fieldname).specCoeff1neurospec(:, column), ...
            coherence.(Fieldname).specCoeff2neurospec(:, column), ...
            coherence.(Fieldname).specCoeff3neurospec(:, column), ...
            coherence.(Fieldname).clneurospec(column)] = ...
            coherenceneurospec(copData(:,i), emgData(:,column), samplingrate_fp, length(win));

        %coherence.(Fieldname).normcoherence(:,column) = atanh(coherence.(Fieldname).coheretotal(:,column));
    end
    [emgSpectra.freqtotal(:,column), emgSpectra.spectratotal(:,column)] = frequencyanal(emgData(:,column),samplingrate_fp,Nfft);   % Mean Power frequency in ML

end
end

% %% Cophase
%
% [cophasetotal] = atand(imag(crpwrtotal)./ real(crpwrtotal));
%
% % coheretotal1 = (crpwrtotal)^2./((MLpwr).*(APpwr));
% % % [MLAPcohere1] = [MLAPcohere1 coheretotal1];

function [coherence, phase, cumulantdensity, specCoeff1, specCoeff2,...
    specCoeff3, cl] = coherenceneurospec(cop, emg, samplingrate, windowsize)
seg_pwr = nextpow2(windowsize);
seglength = nextpow2(size(cop,1));
addlength = seglength - size(emg,1);
emgAdd = (mean(emg, 1).' * ones([addlength, 1]).').';
copAdd = (mean(cop, 1).' * ones([addlength, 1]).').';
emgneurospec = [emg; emgAdd]; % padding
copneurospec = [cop; copAdd]; % padding
[f,t,cl, sc]=sp2a2_R2_mt(copneurospec,emgneurospec,samplingrate,seg_pwr);
coherence = [0; f(:,4)];
phase = [0; f(:,5)];
cumulantdensity = [0; t(:,2)];
specCoeff1 = sc(:,1);
specCoeff2 = sc(:,2);
specCoeff3 = sc(:,3);
end