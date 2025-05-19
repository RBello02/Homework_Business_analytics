classdef (Abstract) AbstractQueue < handle
    % Classe astratta per code (di eventi o entità)
    
    properties
        lista = {}; % cell array di struct
    end

    methods (Abstract)
        enqueue(obj, elemento, clock)
        elemento = dequeue(obj)
    end
end

