%% Testing various coherence technqiues

% Define sampling rate
samplingRate = emgData.sf; % in Hz
emgData_temp = emgData_cropped;

% Define segment size (1-second window)
segment_size = samplingRate * 1; % 1 second window size (in samples)

% Define different Nfft values for comparison
Nfft1 = 2^(nextpow2(segment_size) - 1); % Lower Nfft for coarser frequency resolution
Nfft2 = 2^(nextpow2(segment_size));     % Higher Nfft for finer frequency resolution

% Define overlap (50% of segment size)
noverlap = segment_size / 2;

% Initialize variables to store coherence results for each window type
window_types = {'hanning', 'tukey', 'dpss', 'rectwin'};
coherenceResults = cell(length(window_types), 2);
frequency = cell(length(window_types), 2);

% Loop through different window types
for w = 1:length(window_types)
    % Define the window based on the current type
    switch window_types{w}
        case 'hanning'
            window = hanning(segment_size);
        case 'tukey'
            window = tukeywin(segment_size, 0.2); % 20% taper
        case 'dpss'
            [window, ~] = dpss(segment_size, 3, 1); % DPSS with time-half bandwidth of 3, single taper
        case 'rectwin'
            window = rectwin(segment_size);
    end

    countcol = 0;
    for channel = 1%:size(emgData_temp, 2) % Soleus
        if channel <= 5
            for columnnew = channel+1%:size(emgData_temp,2)
                temp_temp_emg1 = emgData_temp(:, channel) - mean(emgData_temp(:, channel));
                temp_temp_emg2 = emgData_temp(:, columnnew) - mean(emgData_temp(:, columnnew));
                temp_emg1 = (temp_temp_emg1 - mean(temp_temp_emg1)) / std(temp_temp_emg1);
                temp_emg2 = (temp_temp_emg2 - mean(temp_temp_emg2)) / std(temp_temp_emg2);
                countcol = countcol + 1;

                %% Magnitude-squared coherence calculation -coherence at zero frequency assumed zero
                % Coarse Frequency Resolution Coherence (Nfft1)
                [Cpsd1, Fcpsd1] = cpsd(temp_emg1, temp_emg2, window, noverlap, Nfft1, samplingRate);
                [Pxx1, ~] = pwelch(temp_emg1, window, noverlap, Nfft1, samplingRate);
                [Pyy1, ~] = pwelch(temp_emg2, window, noverlap, Nfft1, samplingRate);
                coherence1 = abs(Cpsd1).^2 ./ (Pxx1 .* Pyy1);

                % Store coherence results for coarse resolution
                coherenceResults{w, 1}(:, countcol) = coherence1;
                frequency{w, 1} = Fcpsd1; % Only need to store once

                % Fine Frequency Resolution Coherence (Nfft2)
                [Cpsd2, Fcpsd2] = cpsd(temp_emg1, temp_emg2, window, noverlap, Nfft2, samplingRate);
                [Pxx2, ~] = pwelch(temp_emg1, window, noverlap, Nfft2, samplingRate);
                [Pyy2, ~] = pwelch(temp_emg2, window, noverlap, Nfft2, samplingRate);
                coherence2 = abs(Cpsd2).^2 ./ (Pxx2 .* Pyy2);

                % Store coherence results for fine resolution
                coherenceResults{w, 2}(:, countcol) = coherence2;
                frequency{w, 2} = Fcpsd2; % Only need to store once

            end
        else
            continue;
        end
    end
end

% Calculate frequency resolutions
freq_res1 = samplingRate / Nfft1; % Coarse frequency resolution
freq_res2 = samplingRate / Nfft2; % Fine frequency resolution

% Plotting the results for each window type
figure;
for w = 1:length(window_types)
    subplot(length(window_types), 2, (w-1)*2+1);
    plot(frequency{w, 1}, coherenceResults{w, 1}(:, 1), 'b-', 'LineWidth', 1.5);
    title(['Coherence with ', window_types{w}, ' Window (Coarse Resolution: ', num2str(freq_res1, '%.2f'), ' Hz)']);
    xlabel('Frequency (Hz)');
    ylabel('Coherence');
    xlim([0 60]); % Limit the x-axis to 0-60 Hz
    ylim([0 1]);
    grid on;

    subplot(length(window_types), 2, (w-1)*2+2);
    plot(frequency{w, 2}, coherenceResults{w, 2}(:, 1), 'r-', 'LineWidth', 1.5);
    title(['Coherence with ', window_types{w}, ' Window (Fine Resolution: ', num2str(freq_res2, '%.2f'), ' Hz)']);
    xlabel('Frequency (Hz)');
    ylabel('Coherence');
    xlim([0 60]); % Limit the x-axis to 0-60 Hz
    ylim([0 1]);
    grid on;
end

% Adjust figure
sgtitle('Comparison of Coherence with Different Windowing Functions and Frequency Resolutions');

function [coherence, phase, cumulantdensity, specCoeff1, specCoeff2, ...
    specCoeff3, cl] = coherenceneurospec(cop, emg, samplingrate,segment_size)
seg_pwr = nextpow2(segment_size);
seglength = nextpow2(size(cop,1));
addlength = seglength - size(emg,1);
emgAdd = (mean(emg, 1).' * ones([addlength, 1]).').';
copAdd = (mean(cop, 1).' * ones([addlength, 1]).').';
emgneurospec = [emg; emgAdd];
copneurospec = [cop; copAdd];
[f,t,cl, sc]=sp2a2_R2_mt(copneurospec,emgneurospec,samplingrate,seg_pwr,'M');
coherence = [0; f(:,4)];
phase = [0; f(:,5)];
cumulantdensity = [0; t(:,2)];
specCoeff1 = sc(:,1); % f11
specCoeff2 = sc(:,2); % f22
specCoeff3 = sc(:,3); % f21
end