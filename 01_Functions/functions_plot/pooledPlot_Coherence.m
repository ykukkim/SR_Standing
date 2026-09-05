function [cohere, cl_cohere] = pooledPlot_Coherence(plf1, plv1, poolFlag, IDtocomp, muscname, cohtype, subFolder,cohere_window,destPath)

destinationfolder =  destPath;


[f,t,cl,sc]=pool_scf_out(plf1,plv1);% Plotting parameters

freq=60;
ch_max=2*max(f(:,4));
lag_tot=300;
lag_neg=150;
chi_max=0;% Will auto scale
Pooledfiles = ['Pooled analysis, ', num2str(plv1.fil_tot)];
figurenameoverall = ['Pooled Coherence', muscname];
hfig = figure('Name',figurenameoverall);
hfig.Visible = 'off';
cl.what=Pooledfiles;
psp2_pool6(f,t,cl,freq,lag_tot,lag_neg,ch_max,chi_max);
if strcmp(cohtype, 'interemg') ~= 0
    coherenceFolder = ['IntermuscularCoherence_',cohere_window];
elseif strcmp(cohtype, 'copemg') ~= 0
    coherenceFolder = 'Muscle_Sway_Coherence';
end
if strcmp(poolFlag, 'PAS') ~= 0
    filestr = 'PAS';

    filefolder = [destinationfolder, subFolder, filesep, coherenceFolder, filesep, muscname, filesep, filestr, filesep];
    filename = [filefolder, filestr, '_', num2str(plv1.fil_tot), '.pdf'];
    if ~exist(filefolder, 'dir') %#ok<EXIST>
        mkdir(filefolder)
    end
    filefolder1 = [destinationfolder, subFolder, filesep, coherenceFolder, filesep, muscname, filesep, filestr, '_Coh', filesep];
    filename1 = [filefolder1, filestr, '_', num2str(plv1.fil_tot), '_Coh.pdf'];
    if ~exist(filefolder1, 'dir') %#ok<EXIST>
        mkdir(filefolder1)
    end
elseif strcmp(poolFlag, 'PWS') ~= 0
    filestr = 'PWS';
    filefolder = [destinationfolder, subFolder, filesep, coherenceFolder, filesep, muscname, filesep, filestr, filesep];
    filename = [filefolder, IDtocomp, '_', filestr, '_', num2str(plv1.fil_tot), '.pdf'];
    if ~exist(filefolder, 'dir') %#ok<EXIST>
        mkdir(filefolder)
    end

    filefolder1 = [destinationfolder, subFolder, filesep, coherenceFolder, filesep, muscname, filesep, filestr, '_Coh', filesep];
    filename1 = [filefolder1, IDtocomp, '_', filestr, '_', num2str(plv1.fil_tot), '_Coh.pdf'];
    if ~exist(filefolder1, 'dir') %#ok<EXIST>
        mkdir(filefolder1)
    end
end

saveas(hfig, filename);
close all;

% Pooled Coherence figures
figurename = ['Pooled Coherence for Manuscript', muscname];
ch_fig = figure('Name',figurename);
ch_fig.Visible = 'off';
cl.what = Pooledfiles;

% Pooled (r) coherence, in column 4 of f.
subplot(2,1,1)
psp_ch1(f,cl,freq,ch_max);
% Chi^2 test, in column 8 of f.
subplot(2,1,2)
psp_chi1(f,cl,freq,chi_max);
saveas(ch_fig, filename1);
close all;

cohere = [f(:,1) f(:,4) f(:,8)];
f_start=f(1,1,1);
freq_pts=round((freq-f_start)/cl.df)+1;
f_max=f(freq_pts,1);
cl_cohere = [f_start, cl.ch_c95, cl.chi_c95;f_max, cl.ch_c95, cl.chi_c95];
end


% %Example: (Assuming from your description what's in the picture)
% x = 0:0.001:2*pi;
% y = sin(x);
% tr = diff([0 cumtrapz(x,y)]);
% gray_area = sum(tr(y<0));
% red_area  = sum(tr(y>0));

% Gastrocnemius and Soleus coherence with Sway


%P03, P04, P05 and so on complex doubles why?