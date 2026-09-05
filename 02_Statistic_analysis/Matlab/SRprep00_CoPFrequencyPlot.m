%% Script Name: SR_1_CoPFrequencyPlot Analysis
% Description: Exports raw frequency spectrum to excel, and plots
% analysis
% Inputs:
%   - Input1 (struct): raw mat files converted from c3d
% Outputs:
%   - copparametersbyconditions (struct): CopParameters assosicated with conditions.
% Additional Notes:
%  S01_notrigger: Eyes closed,
%  S02_notrigger: Eyes closed on compliance,
%  S03_neutral: Eyes closed on compliance + 1Hz stimulation
%  S03_vibratory: Eyes closed on compliance + 1Hz stimulation + vibratory noise
%  S03_auditory: Eyes closed on compliance + 1Hz stimulation + auditory noise
%  x -> AP, y -> ML
% Author: YKK

clc; clear all;close all;
DIR_SRdata   = 'P:\Projects\NCM\NCM_EXP\NCM_STM\NCM_STR\SR_YKK\Results\Rect\Stat_Results';

load([DIR_SRdata,filesep,'CoP_Result.mat']);
addpath(genpath('01_Functions'));
% Find indices of frequencies between 0 and 2 Hz
freq = copParametersByCondition.spectraFrequency.Copx.freqAll.Frequency(1,:);
idx = freq >= 0 & freq <= 2;

% Select the corresponding frequencies and power values
freq_subset = freq(idx);

% Extremely low sway participants
p03 = strcmp(copParametersByCondition.linear.SubID, 'P03');
p05 = strcmp(copParametersByCondition.linear.SubID, 'P05');
p12 = strcmp(copParametersByCondition.linear.SubID, 'P12');
p14 = strcmp(copParametersByCondition.linear.SubID, 'P14');
p15 = strcmp(copParametersByCondition.linear.SubID, 'P15');
p21 = strcmp(copParametersByCondition.linear.SubID, 'P21');
p22 = strcmp(copParametersByCondition.linear.SubID, 'P22');
p25 = strcmp(copParametersByCondition.linear.SubID, 'P25');
p26 = strcmp(copParametersByCondition.linear.SubID, 'P26');
p28 = strcmp(copParametersByCondition.linear.SubID, 'P28');

pCommon = p03 + p05 + p12 + p14 + p15 + p21 + p22 + p25 + p26 + p28;
conditions_name = fieldnames(copParametersByCondition);

for i = 1:length(conditions_name)-1

    p03 = strcmp(copParametersByCondition.linear.SubID, 'P03');
    p05 = strcmp(copParametersByCondition.linear.SubID, 'P05');
    p12 = strcmp(copParametersByCondition.linear.SubID, 'P12');
    p14 = strcmp(copParametersByCondition.linear.SubID, 'P14');
    p15 = strcmp(copParametersByCondition.linear.SubID, 'P15');
    p21 = strcmp(copParametersByCondition.linear.SubID, 'P21');
    p22 = strcmp(copParametersByCondition.linear.SubID, 'P22');
    p25 = strcmp(copParametersByCondition.linear.SubID, 'P25');
    p26 = strcmp(copParametersByCondition.linear.SubID, 'P26');
    p28 = strcmp(copParametersByCondition.linear.SubID, 'P28');

    pCommon = p03 + p05 + p12 + p14 + p15 + p21 + p22 + p25 + p26 + p28;

    CoP_All.linear = copParametersByCondition.linear;
    CoP_All.frequency = copParametersByCondition.frequency;
    CoP_All_freq.Copy.spectraAll = copParametersByCondition.spectraFrequency.Copy.spectraAll;
    CoP_All_freq.Copx.spectraAll = copParametersByCondition.spectraFrequency.Copx.spectraAll;
    CoP_All_freq.Copy.freqAll = copParametersByCondition.spectraFrequency.Copy.freqAll;
    CoP_All_freq.Copx.freqAll = copParametersByCondition.spectraFrequency.Copx.freqAll;

    CoP_Normal.linear = copParametersByCondition.linear(~logical(pCommon),:);
    CoP_Normal.frequency = copParametersByCondition.frequency(~logical(pCommon),:);
    CoP_Normal_freq.Copy.spectraAll = copParametersByCondition.spectraFrequency.Copy.spectraAll(~logical(pCommon),:);
    CoP_Normal_freq.Copx.spectraAll = copParametersByCondition.spectraFrequency.Copx.spectraAll(~logical(pCommon),:);
    CoP_Normal_freq.Copy.freqAll = copParametersByCondition.spectraFrequency.Copy.freqAll(~logical(pCommon),:);
    CoP_Normal_freq.Copx.freqAll = copParametersByCondition.spectraFrequency.Copx.freqAll(~logical(pCommon),:);

    CoP_Extreme.linear = copParametersByCondition.linear(logical(pCommon),:);
    CoP_Extreme.frequency = copParametersByCondition.frequency(logical(pCommon),:);
    CoP_Extreme_freq.Copy.spectraAll = copParametersByCondition.spectraFrequency.Copy.spectraAll(logical(pCommon),:);
    CoP_Extreme_freq.Copx.spectraAll = copParametersByCondition.spectraFrequency.Copx.spectraAll(logical(pCommon),:);
    CoP_Extreme_freq.Copy.freqAll = copParametersByCondition.spectraFrequency.Copy.freqAll(logical(pCommon),:);
    CoP_Extreme_freq.Copx.freqAll = copParametersByCondition.spectraFrequency.Copx.freqAll(logical(pCommon),:);

end

% Initialize cell arrays to store the filtered tables
All_COP = [];
Normal_COP = [];
Extreme_COP = [];

% Define stimulation IDs of interest
stimulationIDs = {'S01_notrigger', 'S02_notrigger', 'S03_neutral', 'S03_auditory'};
filename = fullfile(DIR_SRdata, 'CoP_Parameters_Processed.xlsx');

% Loop through each stimulation ID to filter and concatenate tables
for i = 1:length(stimulationIDs)
    % Filter for All_COP
    logicalIndex = ismember(CoP_All.linear.StimulationID, stimulationIDs{i});
    All_COP = [All_COP;  CoP_All.linear(logicalIndex, :);];

    % Filter and concatenate for Normal_COP - adjust this part according to your indexing scheme
    normalIndex = ismember(CoP_Normal.linear.StimulationID, stimulationIDs{i});
    Normal_COP = [Normal_COP; CoP_Normal.linear(normalIndex,:);];

    % Filter and concatenate for Extreme_COP - similarly, adjust for your indexing scheme
    extremeIndex = ismember(CoP_Extreme.linear.StimulationID, stimulationIDs{i});
    Extreme_COP = [Extreme_COP; CoP_Extreme.linear(extremeIndex,:);];
end

% Write tables to different sheets in the same Excel file
writetable(All_COP, filename, 'Sheet', 'All');
writetable(Normal_COP, filename, 'Sheet', 'Normal');
writetable(Extreme_COP, filename, 'Sheet', 'Extreme');

filename = fullfile(DIR_SRdata, 'CoP_Parameters_Frequency_rawspectra.xlsx');
writetable(CoP_All_freq.Copx.spectraAll  , filename, 'Sheet', 'All_x');
writetable(CoP_All_freq.Copy.spectraAll  , filename, 'Sheet', 'All_y');
writetable(CoP_All_freq.Copy.freqAll  , filename, 'Sheet', 'AllFreq');
writetable(CoP_Normal_freq.Copx.spectraAll  , filename, 'Sheet', 'Normal_x');
writetable(CoP_Normal_freq.Copy.spectraAll  , filename, 'Sheet', 'Normal_y');
writetable(CoP_Normal_freq.Copy.freqAll  , filename, 'Sheet', 'NormalAllFreq');
writetable(CoP_Extreme_freq.Copx.spectraAll  , filename, 'Sheet', 'Extreme_x');
writetable(CoP_Extreme_freq.Copy.spectraAll  , filename, 'Sheet', 'Extreme_y');
writetable(CoP_Extreme_freq.Copy.freqAll  , filename, 'Sheet', 'ExtremeAllFreq');

%% Plot one by one with SPM All- X and Y
figure; hold on;
subplot(3,1,1);spm1d.plot.plot_meanSD(CoP_All_freq.Copx.S02_notrigger.spectraAll(idx,:),freq_subset);
xlabel('Frequency (Hz)'); ylabel('Power'); legend('mean','std');title('Eyes closed on Comp  - X-axis');
subplot(3,1,2);spm1d.plot.plot_meanSD(CoP_All_freq.Copx.S03_neutral.spectraAll(idx,:),freq_subset);
xlabel('Frequency (Hz)'); ylabel('Power'); legend('mean','std'); title('Eyes closed on Comp + 1Hz');
subplot(3,1,3);spm1d.plot.plot_meanSD(CoP_All_freq.Copx.S03_auditory.spectraAll(idx,:),freq_subset);
xlabel('Frequency (Hz)'); ylabel('Power'); legend('mean','std'); title('Eyes closed on Comp + 1Hz + WN');
saveas(gcf,[DIR_SRdata,'AllSPMX.jpg']); close;

figure; hold on;
subplot(3,1,1);spm1d.plot.plot_meanSD(CoP_All_freq.Copy.S02_notrigger.spectraAll(idx,:),freq_subset);
xlabel('Frequency (Hz)'); ylabel('Power'); legend('mean','std');title('Eyes closed on Comp  - Y-axis');
subplot(3,1,2);spm1d.plot.plot_meanSD(CoP_All_freq.Copy.S03_neutral.spectraAll(idx,:),freq_subset);
xlabel('Frequency (Hz)'); ylabel('Power'); legend('mean','std'); title('Eyes closed on Comp + 1Hz');
subplot(3,1,3);spm1d.plot.plot_meanSD(CoP_All_freq.Copy.S03_auditory.spectraAll(idx,:),freq_subset);
xlabel('Frequency (Hz)'); ylabel('Power'); legend('mean','std'); title('Eyes closed on Comp + 1Hz + WN');
saveas(gcf,[DIR_SRdata,'AllSPMY.jpg']); close;

%% Plot one by one with SPM Normal- X and Y
figure; hold on;
subplot(3,1,1);spm1d.plot.plot_meanSD(CoP_Normal.S02_notrigger.spectraFrequency.Copx.spectraAll(:,idx)',freq_subset);
xlabel('Frequency (Hz)'); ylabel('Power'); legend('mean','std');title('Eyes closed on Comp  - x-axis');
subplot(3,1,2);spm1d.plot.plot_meanSD(CoP_Normal.S03_neutral.spectraFrequency.Copx.spectraAll(:,idx)',freq_subset);
xlabel('Frequency (Hz)'); ylabel('Power'); legend('mean','std'); title('Eyes closed on Comp + 1Hz');
subplot(3,1,3);spm1d.plot.plot_meanSD(CoP_Normal.S03_auditory.spectraFrequency.Copx.spectraAll(:,idx)',freq_subset);
xlabel('Frequency (Hz)'); ylabel('Power'); legend('mean','std'); title('Eyes closed on Comp + 1Hz + WN');
saveas(gcf,[DIR_SRdata,'NormalSPMX.jpg']); close;

figure; hold on;
subplot(3,1,1);spm1d.plot.plot_meanSD(CoP_Normal.S02_notrigger.spectraFrequency.Copy.spectraAll(:,idx)',freq_subset);
xlabel('Frequency (Hz)'); ylabel('Power'); legend('mean','std');title('Eyes closed on Comp  - y-axis');
subplot(3,1,2);spm1d.plot.plot_meanSD(CoP_Normal.S03_neutral.spectraFrequency.Copy.spectraAll(:,idx)',freq_subset);
xlabel('Frequency (Hz)'); ylabel('Power'); legend('mean','std'); title('Eyes closed on Comp + 1Hz');
subplot(3,1,3);spm1d.plot.plot_meanSD(CoP_Normal.S03_auditory.spectraFrequency.Copy.spectraAll(:,idx)',freq_subset);
xlabel('Frequency (Hz)'); ylabel('Power'); legend('mean','std'); title('Eyes closed on Comp + 1Hz + WN');
saveas(gcf,[DIR_SRdata,'NormalSPMY.jpg']); close;

%% Plot one by one with SPM Extreme- X and Y
figure; hold on;
subplot(3,1,1);spm1d.plot.plot_meanSD(CoP_Extreme.S02_notrigger.spectraFrequency.Copx.spectraAll(:,idx)',freq_subset);
xlabel('Frequency (Hz)'); ylabel('Power'); legend('mean','std');title('Eyes closed on Comp - x-axis');
subplot(3,1,2);spm1d.plot.plot_meanSD(CoP_Extreme.S03_neutral.spectraFrequency.Copx.spectraAll(:,idx)',freq_subset);
xlabel('Frequency (Hz)'); ylabel('Power'); legend('mean','std'); title('Eyes closed on Comp + 1Hz');
subplot(3,1,3);spm1d.plot.plot_meanSD(CoP_Extreme.S03_auditory.spectraFrequency.Copx.spectraAll(:,idx)',freq_subset);
xlabel('Frequency (Hz)'); ylabel('Power'); legend('mean','std'); title('Eyes closed on Comp + 1Hz + WN');
saveas(gcf,[DIR_SRdata,'ExtremeSPMX.jpg']); close;

figure; hold on;
subplot(3,1,1);spm1d.plot.plot_meanSD(CoP_Extreme.S02_notrigger.spectraFrequency.Copy.spectraAll(:,idx)',freq_subset);
xlabel('Frequency (Hz)'); ylabel('Power'); legend('mean','std');title('Eyes closed on Comp  - y-axis');
subplot(3,1,2);spm1d.plot.plot_meanSD(CoP_Extreme.S03_neutral.spectraFrequency.Copy.spectraAll(:,idx)',freq_subset);
xlabel('Frequency (Hz)'); ylabel('Power'); legend('mean','std'); title('Eyes closed on Comp + 1Hz');
subplot(3,1,3);spm1d.plot.plot_meanSD(CoP_Extreme.S03_auditory.spectraFrequency.Copy.spectraAll(:,idx)',freq_subset);
xlabel('Frequency (Hz)'); ylabel('Power'); legend('mean','std'); title('Eyes closed on Comp + 1Hz + WN');
saveas(gcf,[DIR_SRdata,'ExtremeSPMY.jpg']); close;


%% Plot all conditions for All, Normal, and Extreme
figure; subplot(3,1,1); hold on;
plot(freq_subset,mean(CoP_All.S02_notrigger.spectraFrequency.Copx.spectraAll(:,idx)));
plot(freq_subset,mean(CoP_All.S03_neutral.spectraFrequency.Copx.spectraAll(:,idx)));
plot(freq_subset,mean(CoP_All.S03_auditory.spectraFrequency.Copx.spectraAll(:,idx)));
xlabel('Frequency (Hz)'); ylabel('Power'); legend('Eyes Closed on Comp','Eyes closed on Comp + 1Hz', 'Eyes closed on Comp + 1Hz + WN');
title('Power Spectrum of All - X-axis');
xlim([0 2]); % Set the x-axis limits to focus on 0 - 2 Hz

subplot(3,1,2); hold on;
plot(freq_subset,mean(CoP_Normal.S02_notrigger.spectraFrequency.Copx.spectraAll(:,idx)));
plot(freq_subset,mean(CoP_Normal.S03_neutral.spectraFrequency.Copx.spectraAll(:,idx)));
plot(freq_subset,mean(CoP_Normal.S03_auditory.spectraFrequency.Copx.spectraAll(:,idx)));
xlabel('Frequency (Hz)'); ylabel('Power'); legend('Eyes Closed on Comp','Eyes closed on Comp + 1Hz', 'Eyes closed on Comp + 1Hz + WN');
title('Power Spectrum of Normal - X-axis');
xlim([0 2]); % Set the x-axis limits to focus on 0 - 2 Hz

subplot(3,1,3); hold on;
plot(freq_subset,mean(CoP_Extreme.S02_notrigger.spectraFrequency.Copx.spectraAll(:,idx)));
plot(freq_subset,mean(CoP_Extreme.S03_neutral.spectraFrequency.Copx.spectraAll(:,idx)));
plot(freq_subset,mean(CoP_Extreme.S03_auditory.spectraFrequency.Copx.spectraAll(:,idx)));
xlabel('Frequency (Hz)'); ylabel('Power'); legend('Eyes Closed on Comp','Eyes closed on Comp + 1Hz', 'Eyes closed on Comp + 1Hz + WN');
title('Power Spectrum of Extreme - X-axis');
xlim([0 2]); % Set the x-axis limits to focus on 0 - 2 Hz
saveas(gcf,[DIR_SRdata,'AllExtremeandNormalX.jpg']); close;

figure; subplot(3,1,1); hold on;
plot(freq_subset,mean(CoP_All.S02_notrigger.spectraFrequency.Copy.spectraAll(:,idx)));
plot(freq_subset,mean(CoP_All.S03_neutral.spectraFrequency.Copy.spectraAll(:,idx)));
plot(freq_subset,mean(CoP_All.S03_auditory.spectraFrequency.Copy.spectraAll(:,idx)));
xlabel('Frequency (Hz)'); ylabel('Power'); legend('Eyes Closed on Comp','Eyes closed on Comp + 1Hz', 'Eyes closed on Comp + 1Hz + WN');
title('Power Spectrum of All - Y-axis');
xlim([0 2]); % Set the x-axis limits to focus on 0 - 2 Hz

subplot(3,1,2); hold on;
plot(freq_subset,mean(CoP_Normal.S02_notrigger.spectraFrequency.Copy.spectraAll(:,idx)));
plot(freq_subset,mean(CoP_Normal.S03_neutral.spectraFrequency.Copy.spectraAll(:,idx)));
plot(freq_subset,mean(CoP_Normal.S03_auditory.spectraFrequency.Copy.spectraAll(:,idx)));
xlabel('Frequency (Hz)'); ylabel('Power'); legend('Eyes Closed on Comp','Eyes closed on Comp + 1Hz', 'Eyes closed on Comp + 1Hz + WN');
title('Power Spectrum of Extreme - Y-axis');
xlim([0 2]); % Set the x-axis limits to focus on 0 - 2 Hz

subplot(3,1,3); hold on;
plot(freq_subset,mean(CoP_Extreme.S02_notrigger.spectraFrequency.Copy.spectraAll(:,idx)));
plot(freq_subset,mean(CoP_Extreme.S03_neutral.spectraFrequency.Copy.spectraAll(:,idx)));
plot(freq_subset,mean(CoP_Extreme.S03_auditory.spectraFrequency.Copy.spectraAll(:,idx)));
xlabel('Frequency (Hz)'); ylabel('Power'); legend('Eyes Closed on Comp','Eyes closed on Comp + 1Hz', 'Eyes closed on Comp + 1Hz + WN');
title('Power Spectrum of Extreme - Y-axis');
xlim([0 2]); % Set the x-axis limits to focus on 0 - 2 Hz
saveas(gcf,[DIR_SRdata,'AllExtremeandNormalY.jpg']); close;


%% Plot each condition for extreme and normal
% X- axis
figure; subplot(3,1,1); hold on;
plot(freq_subset,mean(CoP_All.S02_notrigger.spectraFrequency.Copx.spectraAll(:,idx)));
plot(freq_subset,mean(CoP_Normal.S02_notrigger.spectraFrequency.Copx.spectraAll(:,idx)));
plot(freq_subset,mean(CoP_Extreme.S02_notrigger.spectraFrequency.Copx.spectraAll(:,idx)));
xlabel('Frequency (Hz)'); ylabel('Power'); legend('Normal','Extreme');
title('Power Spectrum of All, Normal and Extreme - EC on Comp (x-axis)');
subplot(3,1,2); hold on;
plot(freq_subset,mean(CoP_All.S03_neutral.spectraFrequency.Copx.spectraAll(:,idx)));
plot(freq_subset,mean(CoP_Normal.S03_neutral.spectraFrequency.Copx.spectraAll(:,idx)));
plot(freq_subset,mean(CoP_Extreme.S03_neutral.spectraFrequency.Copx.spectraAll(:,idx)));
xlabel('Frequency (Hz)'); ylabel('Power'); legend('Normal','Extreme');
title('Power Spectrum of All, Normal and Extreme - EC on Comp + 1Hz (x-axis)');
subplot(3,1,3); hold on;
plot(freq_subset,mean(CoP_All.S03_auditory.spectraFrequency.Copx.spectraAll(:,idx)));
plot(freq_subset,mean(CoP_Normal.S03_auditory.spectraFrequency.Copx.spectraAll(:,idx)));
plot(freq_subset,mean(CoP_Extreme.S03_auditory.spectraFrequency.Copx.spectraAll(:,idx)));
xlabel('Frequency (Hz)'); ylabel('Power'); legend('Normal','Extreme');
title('Power Spectrum of  All, Normal and Extreme - EC on Comp + 1Hz + WN (x-axis)');
saveas(gcf,[DIR_SRdata,'VSAllExtremeNormalX.jpg']); close;

% Y-axis
figure; subplot(3,1,1); hold on;
plot(freq_subset,mean(CoP_All.S02_notrigger.spectraFrequency.Copy.spectraAll(:,idx)));
plot(freq_subset,mean(CoP_Normal.S02_notrigger.spectraFrequency.Copy.spectraAll(:,idx)));
plot(freq_subset,mean(CoP_Extreme.S02_notrigger.spectraFrequency.Copy.spectraAll(:,idx)));
xlabel('Frequency (Hz)'); ylabel('Power'); legend('Normal','Extreme');
title('Power Spectrum of Extreme and Normal - EC on Comp (y-axis)');
subplot(3,1,2); hold on;
plot(freq_subset,mean(CoP_All.S03_neutral.spectraFrequency.Copy.spectraAll(:,idx)));
plot(freq_subset,mean(CoP_Normal.S03_neutral.spectraFrequency.Copy.spectraAll(:,idx)));
plot(freq_subset,mean(CoP_Extreme.S03_neutral.spectraFrequency.Copy.spectraAll(:,idx)));
xlabel('Frequency (Hz)'); ylabel('Power'); legend('Normal','Extreme');
title('Power Spectrum of Extreme and Normal - EC on Comp + 1Hz (y-axis)');
subplot(3,1,3); hold on;
plot(freq_subset,mean(CoP_All.S03_auditory.spectraFrequency.Copy.spectraAll(:,idx)));
plot(freq_subset,mean(CoP_Normal.S03_auditory.spectraFrequency.Copy.spectraAll(:,idx)));
plot(freq_subset,mean(CoP_Extreme.S03_auditory.spectraFrequency.Copy.spectraAll(:,idx)));
xlabel('Frequency (Hz)'); ylabel('Power'); legend('Normal','Extreme');
title('Power Spectrum of Extreme and Normal - EC on Comp + 1Hz + WN (y-axis)');
saveas(gcf,[DIR_SRdata,'VSAllExtremeNormalY.jpg']); close;
