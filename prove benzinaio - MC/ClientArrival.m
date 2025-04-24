classdef ClientArrival < EventoFuturo
% This class is used to describe how to process this specific future event.

methods 
    % Processing the event 
    function ProcessingEvent(obj, SimManager, clock)
        SimManager.myQueueGS.EnqueueingClient(obj.ClockTime)

        % Updating the value
        obj.ClockTime = clock + exprnd(SimManager.rate_arrivals);
    end
end
end