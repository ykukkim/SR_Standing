function [distance distx disty] = rmsdistance(x,y)


RD = sqrt((x.^2 + y.^2));  % array of resultant distances

% RMS distances
distance = norm(RD) / sqrt(length(RD));
distx = norm(x) / sqrt(length(x));
disty = norm(y) / sqrt(length(y));