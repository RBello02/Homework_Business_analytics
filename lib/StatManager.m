classdef (Abstract) StatManager < handle
    % StatManager è una classe astratta che gestisce le statistic e
    
    properties
        sums     % cell array di lunghezza variabile
        results
    end
    
    methods (Abstract)
        update_stat
        return_stat
    end
end

