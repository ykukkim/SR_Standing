function [fa] = factoranalysis( Zdata_emgmov, data_emgmov )
% factor analysis:

% [coeff,score,latent,tsquared,explained,mu] = pca(Zdata_emgmov); % PCA method

% stats_emg.p = 0;
noOfFactors = 3;

while noOfFactors <= 0.5*size(Zdata_emgmov,2)
    NOFstring = ['N', num2str(noOfFactors)];
[fa.loadings_emg.(genvarname(NOFstring)),fa.specVar_emg.(genvarname(NOFstring)), ...
    fa.T_emg.(genvarname(NOFstring)), fa.stats_emg.(genvarname(NOFstring)), fa.preds_emg.(genvarname(NOFstring))] = ...
    factoran(data_emgmov, noOfFactors, 'scores', 'regression', 'rotate','none');

[fa.loadings_emg_rot.(genvarname(NOFstring)),fa.specVar_emg_rot.(genvarname(NOFstring)), ...
    fa.T_emg_rot.(genvarname(NOFstring)), fa.stats_emg_rot.(genvarname(NOFstring)), fa.preds_emg_rot.(genvarname(NOFstring))] = ...
    factoran(data_emgmov, noOfFactors, 'scores', 'regression', 'rotate','varimax');

noOfFactors = noOfFactors + 1;
end

end
