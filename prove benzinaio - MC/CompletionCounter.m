classdef CompletionCounter < EventoFuturo
% This class is used to describe how to process this specific future event.

methods
    % Processing the event
    function ProcessingEvent(obj, SimManager, clock)
        client = SimManager.myQueueC.DequeueingClient();
        % con questo time potrei calcolare delle statistiche

        % Now the counter and the gas station are no longer busy
        SimManager.myCounter.isBusy = 0;
        SimManager.myGasStation.isBusy(client.id_GasStation) = 0;

        % Updating the value
        obj.ClockTime = Inf;
    end
end
end