classdef Uniform < Distributions
    % UNIFORM --> Gestisce una distribuzione uniforme continua tra lb e ub

    properties
        lowerBound   
        upperBound   
        interi       % true se voglio valori interi (uniforme discreta)
    end

    methods

        % Costruttore
        function self = Uniform(lb, ub, int)

            if nargin < 3 
                self.interi = false;  % default: distribuzione continua
            end

            if lb >= ub
                error('Il valore inferiore deve essere strettamente minore di quello superiore.');
            end

            % Se l'uniforme è negli interi, forzo lb e ub ad essere interi
            if interi
                lb = ceil(lb);
                ub = floor(ub);
            end

            self.lowerBound = lb;
            self.upperBound = ub;
            self.interi = int;
        end

        % Metodo di campionamento
        function samples = sample(self, numero_campioni)
            if self.interi
                samples = randi([self.lowerBound, self.upperBound], numero_campioni, 1);
            else
                intervallo = self.upperBound - self.lowerBound;
                samples = self.lowerBound + rand(numero_campioni, 1) * intervallo;
            end
        end
    end
end
