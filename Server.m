classdef Server < handle
    % SERVER è la classe che definisce un singolo server.
    
    properties
        occupato % flag per indicare se il servere è busy
        cliente % cliente in lavorazione
    end
    
    methods

        % Costruttore
        function self = Server()
            self.occupato = false;
            self.cliente = [];
        end
        
        % Metodo per gestire l'inizio di un servizio presso il server
        function inizio_servizio(self, cliente, sim, nodo)
            pass % il server risulterà ora occupato + caclolo del tempo di servizio + schedulazione evento di fine servizio
        end
        
        % Metodo per modificare l'attributo del server affinché risulti non
        % occupato
        function libera_server(self)
            pass % il server risulterà ora libero
        end

    end %end methods
end

