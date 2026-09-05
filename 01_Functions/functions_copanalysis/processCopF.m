function [cop_GO, f_GO ] = processCopF( sf, copData, fData, triggerdata, doplot)

copData = copData - mean(copData);
cop_filt = filterdata(copData,sf);
cop_crop = crop(triggerdata, cop_filt, sf);
cop_GO = cop_crop - repmat(mean(cop_crop),length(cop_crop),1);

fData = fData-mean(fData);
f_filt = filterdata(fData,sf);
f_crop = crop(triggerdata, abs(f_filt), sf);
f_GO = f_crop - repmat(mean(f_crop),length(f_crop),1);


%% Plot
if doplot == 1
    % CoP
    h = figure;
    title('Single-sided Power spectrum (Hertz) for CoP');
    temp_data(:,1) = copData(:,1) - mean(copData(:,1));
    raw_CoP = fft(copData(:,1)).*conj(fft(copData(:,1)));
    detrended_CoP =  fft(temp_data(:,1)).*conj(fft(temp_data(:,1)));
    N = length(raw_CoP(:,1));
    freqs=0:sf/N:(sf/2);
    figure; subplot(2,1,1)
    plot(freqs,[abs(raw_CoP(1:N/2+1)) abs(detrended_CoP(1:N/2+1))]);hold on;
    xlabel('Frequency (Hz)');ylabel('Power (dB)');legend('Raw','Detrended');
    title('Single-sided Power spectrum (Hertz) for CoP');

    % Non-filter vs filter
    Filtered_CoP = fft(detrend(cop_filt(:,1))).*conj(fft(detrend(cop_filt (:,1))));
    subplot(2,1,2)
    plot(freqs,[abs(detrended_CoP(1:N/2+1)) abs(Filtered_CoP(1:N/2+1))]);hold on;
    xlabel('Frequency (Hz)');ylabel('Power (dB)');legend('Detrended','Detrended-Filtered');

end
end
