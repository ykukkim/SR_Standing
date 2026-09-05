function [  ] = plotemgyy( emgData, emgData_2, Muscle, threshold)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
if strcmp(Muscle, 'SOL L')
    M = 1;
elseif strcmp(Muscle, 'TAN L')
    M = 2;
elseif strcmp(Muscle, 'GAL L')
    M = 3;
elseif strcmp(Muscle, 'SOL R')
    M = 4;
elseif strcmp(Muscle, 'TAN R')
    M = 5;
elseif strcmp(Muscle, 'GAL R')
    M = 6;
else
end


yyaxis left
plot(emgData(:,M)); hold on;
plot(repmat(threshold(:,M),length(emgData),M));
yyaxis right
plot(emgData_2(:,M));
ylim([0, 1.1]);
legend(Muscle, 'threshold');
end
