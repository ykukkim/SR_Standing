function [  ] = plotcrosscorr( lag_corr, r_corr, Inputname )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

if strcmp(Inputname, 'Muscles');
    newColorSet = [0 0 1; 0 1 0; 1 0 0; 0 1 1; 1 0 1; 1 1 0];
    set(gca, 'ColorOrder', newColorSet, 'NextPlot', 'replacechildren');
    hold on;
    plot(lag_corr, r_corr);
    xlabel('lag [ms]');
    ylabel('r');
    legend('SOL L', 'TAN L', 'GAL L', 'SOL R','TAN R', 'GAL R');
elseif strcmp(Inputname, 'FA');
    plot(lag_corr, r_corr);
    xlabel('lag [ms]');
    ylabel('r');
    legend('Factor1', 'Factor2', 'Factor3');
else
end

end
