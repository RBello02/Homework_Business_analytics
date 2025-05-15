classdef Simulation < handle

    % SIMULATION è la classe che si occupa di gestire il funzionamento di
    % una singola simulazione, andando a determinare qual è il prossimo
    % evento da processare.
    
    properties
        network
        lista_eventi_futuri
        clock % tempo attuale
        lista_entita % lista di tutti i clienti nel sistema

        attributi_entita 
        % struct del tipo nome_attr : {'val1', 'val2'} --> l'entità
        % assumerà il valore sorteggiando uniformemente 'val1' o 'val2'
    end
    
    methods

        % Costruttore
        function self = Simulation(net, attributi_entita)
            self.network = net;
            self.lista_eventi_futuri = {}; % creo una lista di celle vuote
            self.clock = 0;
            self.lista_entita = {};
            self.attributi_entita = attributi_entita;
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
        function list_entita = ottieni_entita(self)
            list_entita = self.lista_entita;
        end
        
        % Metodo per aggiungere un cliente alla lista
        function memorizzare_nuova_entita(self, ent)
            self.lista_entita{end+1} = ent;
        end

    end % end methods
end

