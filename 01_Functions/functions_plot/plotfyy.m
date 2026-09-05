function [ ] = plotfyy( fData, firingData, Muscle, Force )
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

if strcmp(Force, 'fx')
    F = 1;
elseif strcmp(Force, 'fy')
    F = 2;
elseif strcmp(Force, 'fx')
    F = 3;
else
end

p = length(fData);
q = length(firingData);
f_rs = resample(fData, q, p);


yyaxis left
plot(f_rs(:,F));
yyaxis right
plot(firingData(:,M));
ylim([0, 1.1]);
legend(Force, Muscle);
end
