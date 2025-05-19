classdef ArrivalEvent < Event
    % ARRIVALEVENT rappresenta un evento di arrivo di un cliente
    
    properties
        queueID  % ID della coda in cui arriva il cliente
    end
    
    methods

        % Costruttore
        function self = ArrivalEvent(clock, queueID)
            self@Event(clock);      % Chiama il costruttore della superclasse
            self.queueID = queueID; % Assegna la coda
        end

        % Implementazione del metodo process 
        function process(self, clock, sim)

            % Genero entità
            ent = Entity(clock, sim.attributi_entita, self.queueID);

            %  Aggiungi un cliente al nodo
            sim.network.nodi{self.queueID}.aggiunta_cliente_al_nodo(ent)

            % Schedula un nuovo arrivo esterno (per continuare la simulazione)
            nextArrivalTime = clock + sim.network.nodi{self.queueID}.distribuzione_arrivi_esterni.sample();
            sim.scheduleEvent(ArrivalEvent(nextArrivalTime, self.queueID));
        end
    end
end
