classdef AverageEntityNetworkTime < StatManager
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here

    properties
       Num_entita_uscenti
    end
    
    methods
        function self = AverageEntityNetworkTime()
            self.sums = 0;    % in questo caso non è una lista ma un intero
            self.Num_entita_uscenti = 0;
        end
        
        function update_stat(self, tempo_di_arrivo, tempo_di_rilascio)
            self.Num_entita_uscenti = self.Num_entita_uscenti + 1;
            self.sums = self.sums + (tempo_di_rilascio-tempo_di_arrivo);
        end

        function stat = return_stat(self)
            if self.Num_entita_uscenti ~= 0
                stat = self.sums/self.Num_entita_uscenti;
                self.results = stat;
            else
                error('Nessun entità ha lasciato la rete')
            end
        end
    end
end

