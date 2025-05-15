classdef Discrete < Distributions
    % DISCRETE --> si occupa di gestire la distribuzione discreta
    
    properties
        categorie        
        probabilita      
        reinserimento     % Booleano: true se il campionamento è con reinserimento
    end

    methods

        % Costruttore della classe
        function self = Discrete(categorie, probabilita, reinserimento)

            % Controllo che categorie e probabilità abbiano la stessa lunghezza
            if length(categorie) ~= length(probabilita)
                error('Il numero di categorie deve coincidere con il numero di probabilità.');
            end

            % Controllo che la somma delle probabilità sia 1 (con tolleranza numerica)
            if abs(sum(probabilita) - 1) > 1e-6
                error('Le probabilità devono sommare a 1.');
            end

            % Inizializzazione delle proprietà
            self.categorie = categorie;
            self.probabilita = probabilita(:)';  % Forza riga
            self.reinserimento = reinserimento;
        end

        % Metodo per l'estrazione di numero_campioni elementi
        function samples = sample(self, numero_campioni)

            if self.reinserimento == 0 && numero_campioni > length(self.categorie)
                error('Il numero di campioni da estrarre deve essere minore o uguale al numero di categorie senza reinserimento.');
            end

            n = length(self.categorie);
            indici_estratti = randsample(n, numero_campioni, self.reinserimento, self.probabilita);

            % Rimappa gli indici nelle categorie (Randsample() estrae
            % valori da 1 a n)
            samples = self.categorie(indici_estratti);
        end
    end
end
