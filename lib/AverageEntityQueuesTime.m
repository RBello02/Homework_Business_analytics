classdef AverageEntityQueuesTime < StatManager
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Num_entita_per_coda; % è un array, di lunghezza = numero di nodi, contenente il numero di entità che sono passate per la coda
    end
    
    methods
        function self = AverageEntityQueuesTime(net)
            % net è un oggetto network
            posizione_sink = net.posizione_sink;
            Num_entita_per_coda = zeros(size(net.matrice_di_adiacenza,1),1);
            Num_entita_per_coda(posizione_sink) = NaN; % non aggiorniamo mai questo valore => questo valore sarà NaN
            self.Num_entita_per_coda = Num_entita_per_coda;

            self.lista = cell(size(net.matrice_di_adiacenza,1), 1);
            for i = 1:length(self.lista)
                self.lista{i} = 0;
            end
           
        end
        
        function update_stat(self, indice_nodo, tempo_di_arrivo, tempo_di_uscita)
            self.Num_entita_per_coda(indice_nodo) = self.Num_entita_per_coda(indice_nodo) + 1;
            self.lista{indice_nodo} = self.lista{indice_nodo} + tempo_di_uscita-tempo_di_arrivo;
        end

        function stat = return_stat(self, sim)
            stat = self.Num_entita_per_coda;

            for idx_nodo =1:length(self.lista)
                    if self.Num_entita_per_coda(idx_nodo) ~= 0 && ~isnan(self.Num_entita_per_coda(idx_nodo))

                        % Devo guardare se ho ancora della gente in coda
                        gente_ancora_in_coda = sim.network.nodi{idx_nodo}.coda.lista;
                        for g = 1:length(gente_ancora_in_coda)
                            ent = gente_ancora_in_coda{g};
                            self.lista{idx_nodo} = self.lista{idx_nodo} + ent.timestamp_coda;
                            self.Num_entita_per_coda(idx_nodo) = self.Num_entita_per_coda(idx_nodo) + 1;
                        end

                        stat(idx_nodo) = self.lista{idx_nodo}/self.Num_entita_per_coda(idx_nodo);
                    else
                        continue
                    end
            end 
        end 
    end
end

