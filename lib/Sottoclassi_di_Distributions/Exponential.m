classdef Exponential < Distributions
    % EXPONENTIAL --> si occupa di gestire la distribuzione esponenziale
    
    properties
        rate % il rate corrisponde con la media della distribuzione esponenziale
    end

    methods

        % Costruttore
        function self = Exponential(rate)
            % Controllo che rate sia un numero positivo
            if ~isscalar(rate) || rate <= 0
                error('Il parametro "rate" deve essere uno scalare positivo.');
            end
            self.rate = rate;
        end
        
        % Metodo per la generazione di campioni
        function samples = sample(self, numero_campioni)
            samples = exprnd(self.rate, numero_campioni, 1);  
        end
    end

end