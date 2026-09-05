function [ ] = plotcopyy( copData, firingData, Muscle, COP)
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

if strcmp(COP, 'copx')
    C = 1;
elseif strcmp(COP, 'copy')
    C = 2;
else
end


p = length(copData);
q = length(firingData);
copData_rs = resample(copData, q, p);


yyaxis left
plot(copData_rs(:,C));
yyaxis right
plot(firingData(:,M));
ylim([0, 1.1]);
legend(COP, Muscle);
end
