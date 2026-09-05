function [meanvel, meanvelx, meanvely] = ...
    meanvelocity(x,y, period)

% calculate distance between each recorded CoP
dist    = sqrt((x(2:end) - x(1:end-1)).^2 + (y(2:end) - y(1:end-1)).^2);
distx   = abs(x(2:end) - x(1:end-1));
disty   = abs(y(2:end) - y(1:end-1));


% sum distances to equal total pathlength
meanvel     = sum(dist)     / period;
meanvelx    = sum(distx)    / period;
meanvely    = sum(disty)    / period;


% figure;
% plot(dist);