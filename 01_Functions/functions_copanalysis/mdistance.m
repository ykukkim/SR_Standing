function [mdist mdistx mdisty] = mdistance(x,y)


RD = sqrt((x.^2 + y.^2));  % array of resultant distances
abs_x = abs(x);
abs_y = abs(y);

% Mean distances
mdist = mean(RD, 1);
mdistx = mean(abs_x, 1);
mdisty = mean(abs_y, 1);
