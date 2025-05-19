classdef EndProcessEvent < Event
    % EndProcessEvent rappresenta la fine del servizio di un cliente in una coda

    properties
        nodoID
        serverID  
    end

    methods
        % Costruttore
        function self = EndProcessEvent(clock, nodoID, serverID)
            self@Event(clock);      % Chiama il costruttore della superclasse
            self.nodoID = nodoID;
            self.serverID = serverID;
        end

        % Implementazione del metodo astratto process
        function process(self, clock, sim)
            % Richiama entita
            ent = sim.network.nodi{self.nodoID}.servers{self.serverID}.entita;
            sim.network.nodi{self.nodoID}.servers{self.serverID}.occupato = false;
           
            % Routing: decidi dove va l'entità dopo il servizio
            prox_nodo = find(ent.matrice_del_percorso(self.nodoID, :) == 1);

            if prox_nodo == sim.network.posizione_sink
                pass
            else
                aggiunta_cliente_al_nodo(self, ent, sim)
            end

            % Se ci sono altri clienti in coda attuale, schedula nuovo servizio
            bool = try_servizio(entita, sim);
        end
    end
end