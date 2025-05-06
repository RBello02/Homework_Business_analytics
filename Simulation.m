classdef Simulation < handle

    % SIMULATION è la classe che si occupa di gestire il funzionamento di
    % una singola simulazione, andando a determinare qual è il prossimo
    % evento da processare.
    
    properties
        network
        lista_eventi_futuri
        clock % tempo attuale
        clienti % lista di tutti i clienti nel sistema
    end
    
    methods

        % Costruttore
        function self = Simulation(net)
            self.network = net;
            self.lista_eventi_futuri = {}; % creo una lista di celle vuote
            self.clock = 0;
            self.clienti = {};
        end
        
        % Metodo per l'aggiunta di un evento nella lista degli eventi
        % futuri (evento sarà un'istanza della classe Event)
        function schedula_evento(self, evento)
            self.lista_eventi_futuri{end+1} = evento;
        end

        % Metodo che si occupa di eseguire la simulazione finché un certo
        % orizzonte temporale non è stato raggiunto (si possono aggiungere altri criteri di stop)
        function run(self, TimeOrizon)
            pass
        end

        % Metodo per ottenere la lista dei clienti
        function lista_clienti = ottieni_clienti(self)
            lista_clienti = self.clienti;
        end
        
        % Metodo per aggiungere un cliente alla lista
        function memorizzare_nuovo_cliente(self, cliente)
            self.clienti{end+1} = cliente;
        end

    end % end methods
end

