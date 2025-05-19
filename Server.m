classdef Server < handle
    % SERVER è la classe che definisce un singolo server.
    
    properties
        occupato % flag per indicare se il servere è busy
        entita % cliente in lavorazione
        distribuzione_servizio
    end
    
    methods

        % Costruttore
        function self = Server(distr)
            self.occupato = false;
            self.entita = [];
            self.distribuzione_servizio = distr;
        end
        
        % Metodo per gestire l'inizio di un servizio presso il server
        function clock_fine_servizio = inizio_servizio(self, entita, clock_inizio_servizio)
            % Il server risulterà ora occupato e deve schedulare un evento
            % di fine servizio
            self.occupato = true;
            self.entita{end+1} = entita;

            clock_fine_servizio = self.distribuzione_servizio.sample() + clock_inizio_servizio;
            
        end
        

    end %end methods
end

