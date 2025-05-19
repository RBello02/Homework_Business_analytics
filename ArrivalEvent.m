classdef ArrivalEvent < Event
    % Evento di arrivo di un'entità in una coda

    properties
        queueID
    end

    methods
        % Costruttore
        function self = ArrivalEvent(clock, queueID)
            self@Event(clock);
            self.queueID = queueID;
        end

        % Meodo per il processamento dell'evento:
        %   1. creo l'entità e la incodo nel nodo in cui è stata generate
        %   2. schedulo il prossimo evento
        function process(self, clock, sim)
            ent = Entity(clock, sim.attributi_entita, self.queueID, sim.network.matrice_di_adiacenza);
            sim.network.nodi{self.queueID}.aggiunta_cliente_al_nodo(ent, sim);

            nextTime = clock + sim.network.nodi{self.queueID}.distribuzione_arrivi_esterni.sample();
            evento = ArrivalEvent(nextTime, self.queueID);
            sim.eventi_futuri.enqueue(evento, nextTime);
            
        end
    end
end
