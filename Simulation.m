classdef Simulation < handle
    %SIMULATION Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        network
        lista_eventi_futuri
        clock % tempo attuale
        clienti % lista di tutti i clienti nel sistema
    end
    
    methods
        function obj = Simulation(net)
            %SIMULATION Construct an instance of this class
            %   Detailed explanation goes here
            obj.network = net;
            obj.lista_eventi_futuri = {}; % creo una lista di celle vuote
            obj.clock = 0;
            obj.clienti = {};
        end
        
        function outputArg = method1(obj,inputArg)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            outputArg = obj.Property1 + inputArg;
        end
    end
end

