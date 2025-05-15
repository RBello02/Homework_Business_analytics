classdef Uniform < Distributions
    %UNIFORM Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        LowerBound
        UpperBound
    end
    
    methods
        % Costruttore
        function self = Uniform(lb,ub)
            self.LowerBound = lb;
            self.UpperBound = ub;
        end
        
        function samples = sample(self, numero_campioni)
            samples = self.LowerBound + rand(numero_campioni) * (self.UpperBound-self.LowerBound);
        end
    end
end

