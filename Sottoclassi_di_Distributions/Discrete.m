classdef Discrete < Distributions
    %DISCRETE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        numero_nodi     
        prob        % rappresenta il vettore riga della matrice di adiacenza
        reinserimento
    end
    
    methods
        %Costruttore
        function self = Discrete(tipo,prob,ripetizione)
            self.tipo
            self.prob
            self.reinserimento
        end

        function samples = sample(self, numero_campioni)
            samples = randsample(self.numero_nodinumero_campioni, self.reinserimento, self.prob);
        end
    end
end

