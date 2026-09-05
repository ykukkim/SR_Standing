function [ emgData, copData, fData, sf, triggerData] = loaddata( filename, data_1 )
% loads emgData form channel 1-6, COP Data, Force DatatriggerData and sampling frequency from
% the mat. file.
% data_1 = load(filename);
sf = data_1.P.(genvarname(filename)).sf;
triggerData = data_1.P.(genvarname(filename)).trigger;

emgData = [data_1.P.(genvarname(filename)).ch1 data_1.P.(genvarname(filename)).ch2 ...
    data_1.P.(genvarname(filename)).ch3 ...
    data_1.P.(genvarname(filename)).ch4 ...
    data_1.P.(genvarname(filename)).ch5 ...
    data_1.P.(genvarname(filename)).ch6];

copData = [data_1.P.(genvarname(filename)).copx data_1.P.(genvarname(filename)).copy];

fData = [data_1.P.(genvarname(filename)).fx data_1.P.(genvarname(filename)).fy data_1.P.(genvarname(filename)).fz];

end
