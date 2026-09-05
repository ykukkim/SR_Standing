function [ inputData_rs, sf_aftermovav ] = resampletoemgLength( inputData, emg_data, desiredLength )
%this code resamples the Input data to the same length as the emgData and
%calculates the new sampling frequency.

p = length(inputData);
q = length(emg_data);
inputData_rs = resample(inputData, q, p);
sf_aftermovav = length(emg_data)/desiredLength;
end
