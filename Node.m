classdef Node < handle
    % NODE è la classe che gestisce le code locali, l'arrivo dei clienti e l'assegnazione
    % ai server. Ad ogni nodo è associato una coda e un gruppo di server.
    
    properties
        id
        coda
        policy_coda
        servers
        numero_servers
        distribuzione_arrivi % distribuzione probabilistica degli arrivi esterni dal sistema
        distribuzione_servizi % questo sarà un vettore (eventualmente con tutte le componenti uguali)
    end
    
    methods

        % Costruttore
        function self = Node(id, pol_coda , distr_arrivi, distr_servizi)
            self.id = id;
            self.policy_coda = pol_coda;
            self.distribuzione_arrivi = distr_arrivi;
            self.distribuzione_servizi = distr_servizi;
            self.coda = [];
            self.numero_servers = size(distr_servizi,2);
            self.servers = cell(1, self.numero_servers);

            for i = 1:self.numero_servers
                self.servers{i} = Server();
            end
        end
        
        % Metodo per la schedulazione degli eventi iniziali
        function schedulazione_arrivo_iniziale(self, sim)
            pass % bisogna campionare il primo evento di arrivo
        end
        
        % Metodo per l'aggiunta di un cliente in coda
        function aggiunta_cliente_al_nodo(self, cliente, sim)
            pass % se ho un server libero lo servo subito, sennò lo incodo
        end
    
        % Metodo per gestire la fine di un servizio
        function fine_servizio(self, cliente, sim, server)
            pass 
        end

    end %end methods
end

