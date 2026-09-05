function [ ] = plotcoherence( coherenceData, Muscle )
%UNTITLED Summary of this function goes here
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

if strcmp(Muscle, 'Factor1')
    M = 1;
elseif strcmp(Muscle, 'Factor2')
    M = 2;
elseif strcmp(Muscle, 'Factor3')
    M = 3;
else
end

plot(coherenceData(:,M)); hold on;
legend(Muscle)
end
