function [peakmag, peakx, peaky] = peakvelocity(x, y, sampling_rate)

delta_t = 1 / sampling_rate; % time period (seconds)

n = length(x);
vel = zeros(n, 2);

% central difference method to calculate velocity
for i = 2:n-1
    vel(i,:) = [(x(i+1) - x(i-1)) / (2 * delta_t), (y(i+1) - y(i-1)) / (2 * delta_t)];
end

vel_mag = sqrt(vel(:,1).^2 + vel(:,2).^2);   % magnitude of velocity sqrt(x^2 + y^2)

% Maximum velocity (x-dir, y-dir, total velocity)
peakx = max(vel(2:end-1, 1));    % peak velocity in x-direction
peaky = max(vel(2:end-1, 2));    % peak velocity in y-direction
peakmag = max(vel_mag(2:end-1)); % peak magnitude of velocity
