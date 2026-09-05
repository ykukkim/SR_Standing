function [ emgData_noise_mean, emgData_noise_std, IntEMGref] = processnoise( filenameforNoise )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

data_1 = load(filenameforNoise);
    sf = data_1.P.(genvarname(filenameforNoise)).sf;



emgData = [data_1.P.(genvarname(filenameforNoise)).ch1 data_1.P.(genvarname(filenameforNoise)).ch2 ...
    data_1.P.(genvarname(filenameforNoise)).ch3 ...
    data_1.P.(genvarname(filenameforNoise)).ch4 ...
    data_1.P.(genvarname(filenameforNoise)).ch5 ...
    data_1.P.(genvarname(filenameforNoise)).ch6];

%% A band pass butterworth filter
emgData_bandpassFilt= emgbandpass( sf, emgData);

%% Moving average filter
emgData_movavFilt = movingaveragefilter( emgData_bandpassFilt, sf, 'nooverlap');
lengthfornoise = ceil(0.5*size(emgData_movavFilt,1));
% approx. first 10 sec of data.
IntEMGref = trapz(emgData_movavFilt, 1);

%% Mean and Std
emgData_noise_mean = mean(emgData_movavFilt(1:lengthfornoise, :));
emgData_noise_std = std(emgData_movavFilt(1:lengthfornoise, :));
end
