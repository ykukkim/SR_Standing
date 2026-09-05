% Conditions  S01_notrigger: Eyes closed,
%             S02_notrigger: Eyes closed on compliance,
%             S03_neutral: Eyes closed on compliance + 1Hz stimulation
%             S03_vibratory: Eyes closed on compliance + 1Hz stimulation +
%             vibratory noise
%             S03_auditory: Eyes closed on compliance + 1Hz stimulation +
%             auditory noise
clc; clear all;close all;

% define input and output folders
DIR_SROutputdata = '\\hest.nas.ethz.ch\green_groups_lmb_public\Projects\NCM\NCM_EXP\NCM_STM\NCM_STR\SR_YKK\Results\YK_Excluded';
destPath         = '\\hest.nas.ethz.ch\green_groups_lmb_public\Projects\NCM\NCM_EXP\NCM_STM\NCM_STR\SR_YKK\Results\YK_Excluded\Pooled';
addpath(genpath(DIR_SROutputdata));
addpath(genpath(pwd));

%% colors and initialization for plotting

coloroption = 2;

if coloroption == 1
    colorID ={[0 1 0], [1 0 0], [0.75 0.75 0.75], [1 1 0], [0 0.25 0.75]};
    %          green         red      gray         yellow    dark blue
    LinestyleID = {'-', '-', '-', '-', '-', '-'};

elseif coloroption == 2
    colorID ={[0.75 0.75 0.75], [1 0 0], [0.5 0.5 0.5], [1 1 0], [0 0.75 0.25]};
    %          gray         red      black         yellow     green
    LinestyleID = {'-', '-', '-', '-', '-', '-'};

elseif coloroption == 3
    colorID ={[0 0.25 0.75], [1 0 0], [0.75 0.75 0.75], [1 1 0], [0 1 0]};
    %          green         red      gray         yellow     green
    LinestyleID = {'--', '-', '-', '-', '-', '-'};
end

muscleID_cop = {'SoleusLeft', 'TibialisLeft', 'GastrocLeft', 'SoleusRight', 'TibialisRight', 'GastrocRight'};
muscleID_interemg = {'SOL_L', 'TAN_L', 'GAL_L', 'SOL_R', 'TAN_R', 'GAL_R'};
sessionID = {'S01_notrigger', 'S02_notrigger', 'S03_neutral', 'S03_vibratory', 'S03_auditory'};

%% Muscle to sway coherence
% Load Data
filename_copemg_pooledCoherence = [DIR_SROutputdata, filesep, 'Latest', filesep,  'pooledcopemgCoherence.mat'];
filename_copemg_pooledCoherence_cl = [DIR_SROutputdata, filesep, 'Latest', filesep,  'pooledcopemgCoherence_clValue.mat'];
pooledCoherence_copemg = load(filename_copemg_pooledCoherence);
pooledCoherence_copemg_cl = load(filename_copemg_pooledCoherence_cl);

frequency = (0:0.5859:49).';
colCount = 1;

for caseno = [1,3,5,6]

    if caseno == 1
        sessRun = [1:3, 5];
        sesscompNameString = 'overall';
        compstringName = 'Overall';
    elseif caseno == 2
        sessRun = [1 2];
        compstringName = 'woStim';
        sesscompNameString = 'sess_1_2';
    elseif caseno == 3
        sessRun = [3 5];
        compstringName = 'withSR';
        sesscompNameString = 'sess_3_5';
    elseif caseno == 4
        sessRun = [3 4];
        compstringName = 'withSR';
        sesscompNameString = 'sess_3_4';
    elseif caseno == 5
        sessRun = [2 5];
        compstringName = 'compSR';
        sesscompNameString = 'sess_2_5';
    elseif caseno == 6
        sessRun = [2 3];
        compstringName = 'withStim';
        sesscompNameString = 'sess_2_3';
    end

    %% Loop through all muscles and COPx and COPy and make one plot for each comparison
    for musc =1:size(muscleID_cop, 2)
        for side = 1:2
            if side == 1
                sigsinv = ['Copx_', muscleID_cop{musc}];
                structdef = 'Copx';
                filename = [destPath,filesep,compstringName,'_',sigsinv];
                plot_title = [compstringName,'-','Copx-', muscleID_cop{musc}];
            else
                sigsinv = ['Copy_', muscleID_cop{musc}];
                structdef = 'Copy';
                filename = [destPath,filesep,compstringName,'',sigsinv];
                plot_title = [compstringName,'-','Copy-', muscleID_cop{musc}];
            end

            fig=figure('Name', sigsinv);
            title(plot_title);

            %% Loop through all conditions each participant had to do and plot them in the same figure
            for sess = sessRun

                % Adjustments based on specific case and session conditions
                if caseno == 1
                    if any(sess == [1, 2, 3])
                        colCount = sess;
                    elseif sess == 5
                        colCount = 5-1;
                    end
                elseif caseno == 2
                    colCount = sess;
                elseif caseno == 3 && any(sess == [3, 5])
                    colCount = sess - 2;
                elseif caseno == 5 && any(sess == [2, 5])
                    if sess == 2
                        colCount = sess - 1;
                    elseif sess == 5
                        colCount = 5-3;
                    end
                elseif caseno == 6 && any(sess == [2, 3])
                    colCount = sess - 1;
                end

                hold on
                colormap winter
                sizetoplot = (1:size(frequency, 1));
                col_no = size(pooledCoherence_copemg.withSess.(sesscompNameString).(structdef).(muscleID_cop{musc}), 2);

                Pooledcohere_temp = mean(pooledCoherence_copemg.withSess.(sesscompNameString).(structdef).(muscleID_cop{musc})(sizetoplot, 1:col_no, colCount),2);
                Pooledcohere_cl_temp = mean(pooledCoherence_copemg_cl.sig_withSess.(sesscompNameString).(structdef).(muscleID_cop{musc})(1, 1:col_no, colCount),2);
                %                 paramName = mean(pooledCoherence_copemg.withSess.(sesscompNameString).(sigsinv)(sizetoplot, 1:col_no, colCount));
                %                 paramName_cl = pooledCoherence_copemg_cl.sig_withSess.(sesscompNameString).(sigsinv)(1, col_no, colCount);

                sigCoh(musc, sess) = Pooledcohere_cl_temp;
                plot(frequency, Pooledcohere_temp, 'Color', colorID{sess}, 'LineWidth', 2, 'linestyle', LinestyleID{sess});

            end
            sigCoh_low = min(sigCoh(musc, :), [], 2)*ones(size(frequency));

            hAll = legend(sessionID{sessRun}, 'Interpreter', 'latex');
            h1 = plot(frequency, sigCoh_low, '--k', 'LineWidth', 1.5);
            sigCoh_high = max(sigCoh(musc, :), [], 2)*ones(size(frequency));
            h2 = plot(frequency, sigCoh_high, '--k', 'LineWidth', 1.5);

            set(get(get(h1,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
            set(get(get(h2,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');

            ax1.YLim = [0 max(Pooledcohere_temp)];
            yticks('auto')
            ax = gca;
            ax.YLim = [0 0.2];
            ax.XAxis.TickValues = [0, 10, 20, 30, 40, 50, 60];
            ax.TickLength = [0 0];

            %% Save file as pdf
            if ~exist(destPath, 'dir')
                mkdir(destPath)
            end
            print(fig, filename, '-dpdf', '-r1200');
            close(fig);

            clear sigCoh_low sigCoh_high
        end
    end
end
