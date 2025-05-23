classdef ArrivalEvent < Event
    % Evento di arrivo di un'entità in una coda

    properties
        nodoID
    end

    methods
        % Costruttore
        function self = ArrivalEvent(clock, queueID)
            self@Event(clock);
            self.nodoID = queueID;
        end

        % Meodo per il processamento dell'evento:
        %   1. creo l'entità e la incodo nel nodo in cui è stata generate
        %   2. schedulo il prossimo evento
        function process(self, clock, sim)
            ent = Entity(clock, sim.attributi_entita, self.nodoID, sim);
            if sim.verbose
                fprintf("L'entità %d è stata generata al nodo %d. \n ", ent.id, self.nodoID)
            end
            sim.network.nodi{self.nodoID}.aggiunta_cliente_al_nodo(ent, sim);

            nextTime = clock + sim.network.nodi{self.nodoID}.distribuzione_arrivi_esterni.sample(1);
            evento = ArrivalEvent(nextTime, self.nodoID);
            sim.eventi_futuri.enqueue(evento, nextTime);
            
        end
    end
end
