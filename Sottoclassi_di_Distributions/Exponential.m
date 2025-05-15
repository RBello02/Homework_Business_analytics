classdef Exponential < Distributions
    % EXPONENTIAL --> si occupa di gestire la distribuzione esponenziale
    
    properties
        rate % λ della distribuzione esponenziale
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
            samples = exprnd(1 / self.rate, numero_campioni, 1);  % nota: MATLAB usa 1/λ
        end
    end

end