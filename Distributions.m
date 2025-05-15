classdef (Abstract) Distributions < handle
    %DISTRIBUTIONS Summary of this class goes here
    %   Detailed explanation goes here
    
    methods(Abstract)
        sample(obj, numero_campioni)
    end
end


