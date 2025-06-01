classdef (Abstract) Event < handle
    % Classe base astratta per gli eventi

    properties
        timestamp_coda % Quando l'evento deve essere processato
    end

    methods
        function self = Event(clock)
            self.timestamp_coda = clock;
        end
    end

    methods (Abstract)
        process(self, clock, sim)
    end
end
