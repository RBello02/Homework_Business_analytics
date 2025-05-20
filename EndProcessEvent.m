classdef EndProcessEvent < Event
    % Evento che rappresenta la fine del servizio per un cliente

    properties
        nodoID
        serverID
    end

    methods
        % Costruttore
        function self = EndProcessEvent(clock, nodoID, serverID)
            self@Event(clock);
            self.nodoID = nodoID;
            self.serverID = serverID;
        end

        % Metodo per il processamento dell'evento
        function process(self, clock, sim)
            nodo = sim.network.nodi{self.nodoID};
            server = nodo.servers{self.serverID};
            ent = server.entita{1};

            % 1. Libero il server
            server.occupato = false;
            server.entita = [];

            % 2. Determino dove andrà l'entità
            nextNode = find(abs(ent.matrice_del_percorso(self.nodoID, :) - 1) < 1e-12);
            ent.nodo_attuale = nextNode;

            if nextNode ~= sim.network.posizione_sink
                sim.network.nodi{nextNode}.aggiunta_cliente_al_nodo(ent, sim);
            end

            % 3. Tento di avviare il processo per altri utenti
            sim.network.nodi{self.nodoID}.try_servizio(sim);
            
        end
    end
end
