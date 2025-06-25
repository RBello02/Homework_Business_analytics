classdef AverageNumEntityIntoNodes < StatManager
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        tracker_time
        tracker_value
    end
    
    methods
        function self = AverageNumEntityIntoNodes(net)
            self.tracker_time = zeros(size(net.matrice_di_adiacenza,1),1);
            self.tracker_value = zeros(size(net.matrice_di_adiacenza,1),1);
            posizione_sink = net.posizione_sink;
            self.tracker_time(posizione_sink) = NaN;
            self.tracker_value(posizione_sink) = NaN;

            self.sums = zeros(size(net.matrice_di_adiacenza,1), 1);
        end
        
        function update_stat(self, indice_nodo, clock, num_entita_nel_nodo)
            self.sums(indice_nodo) = self.sums(indice_nodo) + (clock-self.tracker_time(indice_nodo))*self.tracker_value(indice_nodo);
            self.tracker_value(indice_nodo) = num_entita_nel_nodo;
            self.tracker_time(indice_nodo) = clock;
        end

        function stat = return_stat(self,sim)
            stat = zeros(size(sim.network.matrice_di_adiacenza,1), 1);
            self.results = NaN(size(stat));
            stat(sim.network.posizione_sink) = NaN;
            % chiudo gli ultimi rettangoli
            for i = 1:size(sim.network.matrice_di_adiacenza,1)
                self.update_stat(i,sim.clock, 0)
                if self.tracker_time(i) ~= 0 && ~isnan(self.tracker_time(i))
                    stat(i) = self.sums(i)/self.tracker_time(i);
                    self.results(i) = stat(i);
                else
                    error('Impossibile calcolare la lunghezza media di entità nel nodo')
                end
            end          
        end
    end
end

