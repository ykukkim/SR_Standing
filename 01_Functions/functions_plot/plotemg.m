function [  ] = plotemg( emgData )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

newColorSet = [0 0 1; 0 1 0; 1 0 0; 0 1 1; 1 0 1; 1 1 0];

% Apply the new default colors to the current axes.

set(gca, 'ColorOrder', newColorSet, 'NextPlot', 'replacechildren');
hold on;
plot(emgData);
legend('SOL L', 'TAN L', 'GAL L', 'SOL R','TAN R', 'GAL R');

end
