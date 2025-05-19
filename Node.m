classdef Node < handle
    % NODE è la classe che gestisce le code locali, l'arrivo dei clienti e l'assegnazione
    % ai server. Ad ogni nodo è associato una coda e un gruppo di server.
    
    properties
        id
        coda
        policy_coda
        servers
        numero_servers
        distribuzione_arrivi_esterni % distribuzione probabilistica degli arrivi esterni dal sistema
        distribuzione_servizi % questo sarà un vettore (eventualmente con tutte le componenti uguali)
    end
    
    methods

        % Costruttore
        function self = Node(id, policy_coda, distr_servizi, distr_arrivi_esterni)
            self.id = id;
            self.policy_coda = policy_coda;

            if nargin == 4
                self.distribuzione_arrivi_esterni = distr_arrivi_esterni; % l'atributo si riferisce agli arrivi esterni dal sistema, il campo può restare vuoto
            else
                self.distribuzione_arrivi_esterni = -1; %valore per dire che non ci sono arivi esterni
            end
                
            self.coda = [];
            self.numero_servers = size(distr_servizi,2);
            self.servers = cell(1, self.numero_servers);

            for i = 1:self.numero_servers
                self.servers{i} = Server(distr_servizi(i));
            end
        end
        
        % Metodo per la schedulazione degli eventi iniziali (saranno arrivi dall'esterno)
        function schedulazione_evento_iniziale(self, sim)
            if   ~(isnumeric(self.distribuzione_arrivi_esterni) && self.distribuzione_arrivi_esterni == -1)
                clock = self.distribuzione_arrivi_esterni.sample(); % + sim.clock = 0
                sim.lista_eventi_futuri{end+1} = ArrivalEvent(clock); 
            end

        end
        
        % Metodo per l'aggiunta di un cliente in coda
        function aggiunta_cliente_al_nodo(self, entita, sim)
            
            ho_processato_il_cliente = self.try_servizio(entita, sim);
            if  ~ho_processato_il_cliente 
                % incodo l'entità
                self.coda{end+1} = entita;
            end %end if

        end %end metodo
    
        % Metodo per gestire la fine di un servizio
        function fine_servizio(self, cliente, sim, server)
            pass 
        end

        % Tentativo di servizio
        function bool = try_servizio(entita, sim)

            % Se un server è libero processo direttamente il cliente
            id_srv_libero = -1;
            for id_srv = 1:self.numero_servers
                if  ~self.servers{id_srv}.occupato 
                    id_srv_libero = id_srv;
                end

                if id_srv_libero >= 0
                    % l'entità viene direttamente servita
                    bool = true;
                    clock_fine_servizio = self.servers{id_srv_libero}.inizio_servizio(entita, sim.clock);
                    sim.lista_eventi_futuri{end+1} = EndProcessEvent(clock_fine_servizio, self.id, id_srv_libero);
                else
                    bool = false;
                end
            end %end for sui server
        end 
        


    end %end methods
end

