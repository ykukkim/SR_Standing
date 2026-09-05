function [cropped_data, desiredlength] = crop_emg(data_input_processed, data_input)
% first cuts the signal to trigger length and then to a desired length of
% 50 sec. With a starting point after 5 sec.

triggerData = data_input.triggerData;
sf          = data_input.sf;

% crop to trigger length
frameOut = 1;
for frame = 1:length(triggerData)
    if triggerData(frame) > 0.5
        emgData_toTriggerLength(frameOut,:)      = data_input_processed(frame,:);
        frameOut = frameOut + 1;
    end
end

if ~any(triggerData > 0.5)
        emgData_toTriggerLength      = data_input_processed;
end

%crops to desired length [sec]
start             = 6000; %in frames
desiredlength     = 50; % in Sec
cropped_data       = emgData_toTriggerLength(start: start+(sf*desiredlength),:);

end
