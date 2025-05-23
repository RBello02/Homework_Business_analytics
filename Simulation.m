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

        verbose % controlla solo quanto si stampa durante la simulazione
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
            self.verbose = false;
        end
       

        % Metodo che si occupa di eseguire la simulazione finché un certo
        % orizzonte temporale non è stato raggiunto (si possono aggiungere altri criteri di stop)
        function list_ent = run(self, TimeOrizon, verbose)
            if nargin == 3
                self.verbose = verbose;
            end

            fprintf("\n *********************************" + ...
                " \n INIZIO SIMULAZIONE ...  ")

            % Schedulo un primo evento di arrivo per ciascun nodo
            for id_nodo = 1:self.network.numero_nodi
                nodo = self.network.nodi{id_nodo};
                nodo.schedulazione_evento_iniziale(self); % self = sim
            end
            
            
            while self.clock < TimeOrizon
               
                % 1. Determino il prossimo evento da processare e porto
                % avanti il clock
                evento_da_processare = self.eventi_futuri.dequeue();
                self.clock = evento_da_processare.timestamp_coda;
                if verbose
                    fprintf('\n CLOCK = %3.2f\n ', self.clock);
                end

                % 2. Processo l'evento
                evento_da_processare.process(self.clock, self);

            end


            fprintf("\n FINE SIMULAZIONE \n\n")
            list_ent = self.lista_entita;
            
            % stampo qualcosa
        end

        

    end % end methods
end

