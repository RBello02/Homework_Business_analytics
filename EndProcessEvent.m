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

            % 2. Determino dove andrà l'entità estraendo il nodo di
            % destinazione
            nextNode = randsample(1:size(ent.matrice_del_percorso, 2), 1, true, ent.matrice_del_percorso(self.nodoID, :));
            ent.nodo_attuale = nextNode;
            if sim.verbose
                fprintf("L'entità %d ha terminato il servizio al nodo %d ed è passata al nodo %d. \n ", ent.id, nodo.id, nextNode)
            end

            if nextNode ~= sim.network.posizione_sink
                sim.network.nodi{nextNode}.aggiunta_cliente_al_nodo(ent, sim);
            end

            if nextNode == sim.network.posizione_sink

                 % tolgo un'entità
                sim.numero_entita = sim.numero_entita - 1;

                % ciclo per trovare la statistica: tempo medio nella network
                for i = 1:numel(sim.statistics)
                    if isa(sim.statistics{i}, 'AvarageEntityNetworkTime')
                       sim.statistics{i}.update_stat(ent.istante_di_arrivo_glob, clock)
                    elseif isa(sim.statistics{i}, 'AvarageNumEntityIntoNetwork')
                       sim.statistics{i}.update_stat(sim.clock, sim.numero_entita)
                    elseif isa(sim.statistics{i}, 'AvarageNumEntityIntoNodes')
                       sim.statistics{i}.update_stat(self.nodoID, sim.clock, length(sim.network.nodi{self.nodoID}.coda)) %non va messo qua correggi
                    end
                end

            end



            % 3. Tento di avviare il processo per altri utenti
            sim.network.nodi{self.nodoID}.try_servizio(sim);

            
        end
    end
end
