function [ emgData_noise_mean, emgData_noise_std, emgData_referenceContract] = getnoise(filename)
%UNTITLED Summary of this function goes here
if mod(filename(3),2) ~= 0 %ungerade
    % Simply as the presentation order of the conditions were
    % counterbalanced during data collection
    filename_1 = [filename(1:3), '_S01_T02'];
    filename_2 = [filename(1:3), '_S01_T03'];
else filename_1 = [filename(1:3), '_S02_T02'];
    filename_2 = [filename(1:3), '_S02_T03'];
end
% process noise data
data_1 = load(filename_1);
data_2 = load(filename_2);
if isfield(data_1, 'P') && isfield(data_2, 'P')
    [noise.(filename_1).mean, noise.(filename_1).std, reflevel_1]  = processnoise(filename_1);
    [noise.(filename_2).mean, noise.(filename_2).std, reflevel_2]  = processnoise(filename_2);
elseif  ~(isfield(data_1, 'P')) && isfield(data_2, 'P')
    filename_1 = [filename(1:3), '_S01_T04'];
    [noise.(filename_1).mean, noise.(filename_1).std, reflevel_1]  = processnoise(filename_1);
    [noise.(filename_2).mean, noise.(filename_2).std, reflevel_2]  = processnoise(filename_2);
elseif isfield(data_1, 'P') && ~(isfield(data_2, 'P'))
    filename_2 = [filename(1:3), '_S01_T04'];
    [noise.(filename_1).mean, noise.(filename_1).std, reflevel_1]  = processnoise(filename_1);
    [noise.(filename_2).mean, noise.(filename_2).std, reflevel_2]  = processnoise(filename_2);
else
    filename_2 = [filename(1:3), '_S01_T04'];
    data_2 = load(filename_2);
    if isfield(data_2,'P')

        [noise.(filename_2).mean, noise.(filename_2).std, reflevel_2]  = processnoise(filename_2);
    else
        filename_2 = [filename(1:3), '_S01_T05'];
        data_2 = load(filename_2);
        [noise.(filename_2).mean, noise.(filename_2).std, reflevel_2]  = processnoise(filename_2);
    end
    filename_1 = [filename(1:3), '_S01_T01'];
    [noise.(filename_1).mean, noise.(filename_1).std, reflevel_1]  = processnoise(filename_1);
end
% mean and std of the two trials
emgData_noise_mean = mean([noise.(filename_1).mean; noise.(filename_2).mean]);
emgData_noise_std = max([noise.(filename_1).std, noise.(filename_2).std]);

emgData_referenceContract = mean([reflevel_1; reflevel_2]);
end
