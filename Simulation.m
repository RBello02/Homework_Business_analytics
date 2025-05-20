classdef Simulation < handle

    % SIMULATION è la classe che si occupa di gestire il funzionamento di
    % una singola simulazione, andando a determinare qual è il prossimo
    % evento da processare.
    
    properties
        network
        eventi_futuri
        clock 
        lista_entita % lista delle entità attualmente nella network
        numero_entita % numero di entità che sono passate

        attributi_entita 
        % struct del tipo nome_attr : {'val1', 'val2'} --> l'entità
        % assumerà il valore sorteggiando uniformemente 'val1' o 'val2'
    end
    
    methods

        % Costruttore
        function self = Simulation(net, attributi_entita)
            self.network = net;
            self.eventi_futuri = FIFOQueue();
            self.clock = 0;
            self.attributi_entita = attributi_entita;
            self.numero_entita = 0;
            self.lista_entita = {};
        end
       

        % Metodo che si occupa di eseguire la simulazione finché un certo
        % orizzonte temporale non è stato raggiunto (si possono aggiungere altri criteri di stop)
        function list_ent = run(self, TimeOrizon)
            disp('*****************************************')
            disp('Inizio simulazione: ')

            % Schedulo un primo evento di arrivo per ciascun nodo
            for id_nodo = 1:self.network.numero_nodi
                nodo = self.network.nodi{id_nodo};
                nodo.schedulazione_evento_iniziale(self); % self = sim
            end
            
            
            while self.clock < TimeOrizon
               
                % 1. Determino il prossimo evento da processare e porto
                % avanti il clock
                evento_da_processare = self.eventi_futuri.dequeue();
                self.clock = self.clock + evento_da_processare.timestamp_coda;
                fprintf('clock = %d\n', self.clock);
                fprintf('Classe evento: %s\n', class(evento_da_processare));


                % 2. Processo l'evento
                evento_da_processare.process(self.clock, self);

            end

            list_ent = self.lista_entita;
            
            % stampo qualcosa
        end

        

    end % end methods
end

