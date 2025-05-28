classdef Node < handle
    % NODE gestisce le code locali, gli arrivi dei clienti e l'assegnazione ai server.
    % Ogni nodo ha una coda e un gruppo di server.
    
    properties
        id
        coda
        servers
        numero_servers
        distribuzione_arrivi_esterni % distribuzione degli arrivi esterni
    end
    
    methods
        
        % Costruttore
        function self = Node(id, policy_coda, distr_servizi, distr_arrivi_esterni)
            self.id = id;
            
            % Gestione distribuzione arrivi esterni
            if nargin == 4
                self.distribuzione_arrivi_esterni = distr_arrivi_esterni;
            else
                self.distribuzione_arrivi_esterni = -1; % Nessun arrivo esterno
            end
            
            % Numero di server e loro inizializzazione
            self.numero_servers = length(distr_servizi);
            self.servers = cell(1, self.numero_servers);
            for i = 1:self.numero_servers
                self.servers{i} = Server(distr_servizi(i));
            end
            
            % Controllo della policy della coda
            valid_policies = {'FIFO', 'LIFO'};
            if ~ismember(policy_coda, valid_policies)
                error("Policy coda non valida: deve essere 'FIFO' o 'LIFO'.");
            end
            
            % Creazione della coda in base alla policy scelta
            switch policy_coda
                case 'FIFO'
                    self.coda = FIFOQueue();
                case 'LIFO'
                    self.coda = LIFOQueue();
            end

        end
        
        % Schedulazione evento iniziale (arrivi esterni)
        function schedulazione_evento_iniziale(self, sim)
            if ~(isnumeric(self.distribuzione_arrivi_esterni) && self.distribuzione_arrivi_esterni == -1)
                next_arrival_time = self.distribuzione_arrivi_esterni.sample(1); % tempo prossimo arrivo
                sim.eventi_futuri.enqueue(ArrivalEvent(next_arrival_time, self.id), next_arrival_time);
            end
        end
        
        % Aggiunta di un cliente in coda e tentativo di servizio
        function aggiunta_cliente_al_nodo(self, entita, sim)
            self.coda.enqueue(entita, sim.clock);  % metto in coda l'entità
            self.try_servizio(sim);                % provo a servire l'entità
        end
        
        
        % Tentativo di servizio: prendo un cliente dalla coda e lo assegno a un server libero
        function success = try_servizio(self, sim)
            success = false;
            
            % 1. Provo a prelevare un'entità dalla coda (se c'è)
            if ~isempty(self.coda.lista)
                entita_da_servire = self.coda.dequeue();
            else
                return;
            end
            
            % 2. Cerco un server libero
            id_srv_libero = -1;
            for i = 1:self.numero_servers
                if ~self.servers{i}.occupato
                    id_srv_libero = i;
                    break; % esco appena trovo un server libero
                end
            end
            
            if id_srv_libero == -1
                % Nessun server libero: rimetto l'entità in coda
                self.coda.enqueue(entita_da_servire, entita_da_servire.timestamp_coda); 
                success = false;
                return;
            end
            
            % 3. Assegno il cliente al server libero
            success = true;
            clock_fine_servizio = self.servers{id_srv_libero}.inizio_servizio(entita_da_servire, sim.clock);

            % Aggiorno le statistiche del nodo:

            % ciclo per trovare la statistica: tempo medio nella network
            for i = 1:numel(sim.statistics)
                if isa(sim.statistics{i}, 'AvarageEntityQueuesTime')
                   sim.statistics{i}.update_stat(self.id, entita_da_servire.timestamp_coda,sim.clock)
                end
            end
            
            % 4. Programmo l'evento di fine servizio
            evento = EndProcessEvent(clock_fine_servizio, self.id, id_srv_libero);
            sim.eventi_futuri.enqueue(evento, clock_fine_servizio);

            if sim.verbose
                fprintf("L'entità %d ha iniziato il servizio presso il server %d del nodo %d. \n ", entita_da_servire.id, id_srv_libero, self.id)
            end

        end
        
    end
end
