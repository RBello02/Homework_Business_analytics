classdef Events < handle
    %EVENTS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        timestamp % clock mi indica quando l'evento accadrà
    end
    
    methods
        function obj = Events(clock)
            %EVENTS Construct an instance of this class
            %   Detailed explanation goes here
            obj.timestamp = clock;
        end
  
        function process(clock, sim)
            pass
            % come si processa un evento verrà descritto nelle sottoclassi
        end
    end
end

