classdef EventoFuturo < handle
    % class to manage the single future event

properties 
    ClockTime % clock of when the future event will happen 
end

methods
    % Constructor
    function obj = EventoFuturo()
        obj.ClockTime = NaN;
    end
end

methods (Abstract)
    ProcessingEvent(obj, SimManager, clock)
end
end 