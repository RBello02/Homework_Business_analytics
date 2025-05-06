classdef Event < handle
    % EVENT è la classe che definisce gli eventi.
    % Questa classe è la base di alcune sottoclassi.
    
    properties
        timestamp % clock mi indica quando l'evento accadrà
    end
    
    methods

        % Costruttore
        function self = Event(clock)
            self.timestamp = clock;
        end
  
        % Metodo per il processamento di un evento, questo verrà definito
        % nelle sottoclassi di Event
        function process(self, clock, sim)
            pass
        end

    end %end methods
end

