classdef AvarageEntityQueuesTime < StatManager
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Num_entita_per_coda; % è un array, di lunghezza = numero di nodi, contenente il numero di entità che sono passate per la coda
    end
    
    methods
        function self = AvarageEntityQueuesTime(net)
            % net è un oggetto network
            posizione_sink = net.posizione_sink;
            Num_entita_per_coda = zeros(size(net.matrice_adiacenza,1));
            Num_entita_per_coda(posizione_sink) = NaN; % non aggiorniamo mai questo valore => questo valore sarà NaN
            self.Num_entita_per_coda = Num_entita_per_coda;
           
        end
        
        function update(self, indice_nodo, tempo_di_arrivo, tempo_di_uscita)
            self.Num_entita_per_coda(indice_nodo) = self.Num_entita_per_coda + 1;
            self.lista{indice_nodo} = self.lista{indice_nodo} + tempo_di_uscita-tempo_di_arrivo;
        end

        function stat = return_stat(self)
            stat = self.Num_entita_per_coda;
            for i=1:length(self.lista)
                if self.Num_entita_per_coda ~= 0 && ~isnan(self.Num_entita_per_coda)
                    stat(i) = self.lista{i}/self.Num_entita_uscenti(i);
                else
                    error('Nessuna entità è uscita dal nodo')
                end
            end 
        end 
    end
end

