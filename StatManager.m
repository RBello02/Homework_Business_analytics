classdef (Abstract) StatManager < handle
    % StatManager è una classe astratta che gestisce le statistic e
    
    properties
        lista     % cell array di lunghezza variabile
    end
    
    methods (Abstract)
        update_stat
    end
end

