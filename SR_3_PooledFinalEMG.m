%% Stochastic resonance study
% Pools interemg coherence across all the trials, sessions and partcipants.
% Conditions  S01_notrigger: Eyes closed,
%             S02_notrigger: Eyes closed on compliance,
%             S03_neutral: Eyes closed on compliance + 1Hz stimulation
%             S03_vibratory: Eyes closed on compliance + 1Hz stimulation +
%             vibratory noise
%             S03_auditory: Eyes closed on compliance + 1Hz stimulation +
%             auditory noise
clc; clear all;close all;

% define input and output folders
DIR_SROutputdata = '\\hest.nas.ethz.ch\green_groups_lmb_public\Projects\NCM\NCM_EXP\NCM_STM\NCM_STR\SR_YKK\Results\Hilbert_TJ0.5sec\Pooled_Hilbert';
addpath(genpath(DIR_SROutputdata));
addpath(genpath(pwd));

%% Data Load
filename_interemg_pooledCoherence = [DIR_SROutputdata, filesep,  'pooledinteremgCoherence_All.mat'];
filename_interemg_pooledCoherence_cl = [DIR_SROutputdata, filesep,  'pooledinteremgCoherence_All_clValue.mat'];

pooledCoherence_interemg = load(filename_interemg_pooledCoherence);
pooledCoherence_interemg_cl = load(filename_interemg_pooledCoherence_cl);

%% colors and initialization for plotting

coloroption = 2;

if coloroption == 1
    colorID ={[0 1 0], [1 0 0], [0.75 0.75 0.75], [1 1 0], [0 0.25 0.75]};
    %          green         red      gray         yellow    dark blue
    LinestyleID = {'-', '-', '-', '-', '-', '-'};

elseif coloroption == 2
    colorID ={[0.75 0.75 0.75], [1 0 0], [0.5 0.5 0.5], [0 0.75 0.25]};
    %          gray         red      black         yellow     green
    LinestyleID = {'-', '-', '-', '-', '-', '-'};

elseif coloroption == 3
    colorID ={[0 0.25 0.75], [1 0 0], [0.75 0.75 0.75], [1 1 0], [0 1 0]};
    %          green         red      gray         yellow     green
    LinestyleID = {'--', '-', '-', '-', '-', '-'};
end

muscleID_cop = {'SoleusLeft', 'TibialisLeft', 'GastrocLeft', 'SoleusRight', 'TibialisRight', 'GastrocRight'};
muscleID_interemg = {'SOL_L', 'TAN_L', 'GAL_L', 'SOL_R', 'TAN_R', 'GAL_R'};

sessionID1 = {'$EC_{Hard}$', '$EC_{Foam}$', '$EC_{Foam+1Hz+WN}$','$EC_{Foam+1Hz}$'};

frequency = 0:1.1719:60.9375; % 0.5 sec
% frequency = 0:0.5859:60.3516; % 1 sec
% frequency = 0:0.2930:60.0586; % 2 sec

interemgCoherence = struct();
sheetNames = fieldnames(pooledCoherence_interemg_cl.sig1_withSess);

for i = 1:length(sheetNames)

    for caseno = [1]

        if caseno == 1
            sessRun = 1:4;
            colcount = 1:4;
            sesscompNameString = 'overall';
            compstringName = 'Overall';
        elseif caseno == 2
            sessRun = [1 2];
            compstringName = 'woStim';
            sesscompNameString = 'sess_1_2';
        elseif caseno == 3
            sessRun = [3 5];
            colcount = [1 2];

            compstringName = 'withSR';
            sesscompNameString = 'sess_3_5';
        elseif caseno == 4
            sessRun = [3 4];
            colcount = [1 2];

            compstringName = 'withSR';
            sesscompNameString = 'sess_3_4';
        elseif caseno == 5
            sessRun = [2 5];
            colcount = [1 2];

            compstringName = 'compSR';
            sesscompNameString = 'sess_2_5';
        elseif caseno == 6
            sessRun = [2 3];
            colcount = [1 2];
            compstringName = 'withStim';
            sesscompNameString = 'sess_2_3';
        end

        %% Compare each muscle to all other muscles and make one plot for each comparison
        for musc = 1:(size(muscleID_interemg, 2) - 1)
            for  musc1 = musc+1:size(muscleID_interemg, 2)
                sigsinv = [muscleID_interemg{musc}, '_', muscleID_interemg{musc1}];
                plot_title = [compstringName,' - ' ,muscleID_interemg{musc}, '-', muscleID_interemg{musc1},'-',sheetNames{i}];
                figm= figure('Name', sigsinv,'Visible','off');
                title(plot_title);
                hold on;

                %% Loop through all conditions each participant had to do and plot them in the same figure
                for sess = 1:length(sessRun)

                    colormap winter
                    sizetoplot = (1:length(frequency));
                    Pooledcohere_temp = mean(pooledCoherence_interemg.withSess.(sheetNames{i}).(sesscompNameString).(sigsinv)(sizetoplot, :, colcount(sess)),2);
                    plot(frequency, Pooledcohere_temp, 'Color', colorID{sess}, 'LineWidth', 1.3, 'linestyle', LinestyleID{sess});

                end

                hAll1 = legend(sessionID1, 'Interpreter', 'latex');
                ax1 = gca;
                % ax1.YLim=[0 0.16];
                yticks('auto')
                ax.XAxis.TickValues = [0, 20, 40, 60];
                ax1.TickLength = [0 0];

                filename = [DIR_SROutputdata,filesep,'Interemg', compstringName, sigsinv,'_',(sheetNames{i})];

                %% Save file as pdf
                if ~exist(DIR_SROutputdata, 'dir')
                    mkdir(DIR_SROutputdata)
                end

                print(figm, filename, '-dpdf', '-r1200');
                close(figm);
                clear sigCoh_low sigCoh_high
            end
        end
    end
end