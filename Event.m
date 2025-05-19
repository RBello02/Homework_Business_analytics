classdef (Abstract) Event < handle
    % EVENT è la classe base astratta per gli eventi.
    % Le sottoclassi devono implementare il metodo process.
    
    properties
        timestamp % clock mi indica quando l'evento accadrà
    end
    
    methods
        % Costruttore
        function self = Event(clock)
            self.timestamp = clock;
        end
    end

    methods (Abstract)
        % Metodo astratto da implementare nelle sottoclassi
        process(self, clock, sim)
    end
end