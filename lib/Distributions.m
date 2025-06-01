classdef (Abstract) Distributions < handle
    % DISTRIBUTIONS è una classe astratta che generalizza il comportamento
    % delle distribuzioni che definiremo.
    
    methods(Abstract)
        sample(obj, numero_campioni)
    end
end


