classdef Exponential < Distributions

    % Distribuzione esponenziale 

    properties
        rate
    end

    methods
        % Costruttore
        function self = Exponential(rate) 
            self.rate = rate;
        end
        
        function samples = sample(self, numero_campioni)
            samples = exprnd(self.rate, numero_campioni, 1);
        end
    end

end