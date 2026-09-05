function [ stimulus ] = defstimulus( triggerData)
%Defines the stimulus depending on the trigger Signal.
% 1.2 --> electrical, 1 --> neutral, 0.8 --> vibratory, 0.6 --> auditory

if max(triggerData) > 1.15
    stimulus = 'electrical';
elseif max(triggerData) > 0.95
    stimulus = 'neutral' ;
elseif max(triggerData) > 0.75
    stimulus = 'vibratory';
elseif max(triggerData) > 0.55
    stimulus = 'auditory';
else stimulus = 'notrigger';
end



end
