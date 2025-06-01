classdef AvarageNumEntityIntoNodes < StatManager
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        tracker_time
        tracker_value
    end
    
    methods
        function self = AvarageNumEntityIntoNodes(net)
            self.tracker_time = zeros(size(net.matrice_di_adiacenza,1),1);
            self.tracker_value = zeros(size(net.matrice_di_adiacenza,1),1);
            posizione_sink = net.posizione_sink;
            self.tracker_time(posizione_sink) = NaN;
            self.tracker_value(posizione_sink) = NaN;

            self.lista = cell(size(net.matrice_di_adiacenza,1), 1);
            for i = 1:length(self.lista)
                self.lista{i} = 0;
            end
        end
        
        function update_stat(self, indice_nodo, clock, num_entita_nel_nodo)
            self.lista{indice_nodo} = self.lista{indice_nodo} + (clock-self.tracker_time(indice_nodo))*self.tracker_value(indice_nodo);
            self.tracker_value(indice_nodo) = num_entita_nel_nodo;
            self.tracker_time(indice_nodo) = clock;
        end

        function stat = return_stat(self,sim)
            stat = zeros(size(sim.network.matrice_di_adiacenza,1), 1);
            stat(sim.network.posizione_sink) = NaN;
            % chiudo gli ultimi rettangoli
            for i = 1:size(sim.network.matrice_di_adiacenza,1)
                self.update_stat(i,sim.clock, 0)
                if self.tracker_time(i) ~= 0 && ~isnan(self.tracker_time(i))
                    stat(i) = self.lista{i}/self.tracker_time(i);
                else
                    error('Impossibile calcolare la lunghezza media di entità nel nodo')
                end
            end
            
        end
    end
end

