classdef Simulation < handle

    % SIMULATION è la classe che si occupa di gestire il funzionamento di
    % una singola simulazione, andando a determinare qual è il prossimo
    % evento da processare.
    
    properties
        network
        eventi_futuri
        clock 
        lista_entita % lista delle entità attualmente nella network
        numero_entita % numero di entità nel sistema
        num_tot_entita % mi serve per assegnare un id univoco alle entità che genero

        attributi_entita 
        % struct del tipo nome_attr : {'val1', 'val2'} --> l'entità
        % assumerà il valore sorteggiando uniformemente 'val1' o 'val2'

        verbose % controlla solo quanto si stampa durante la simulazione

        statistics % cell array contenente tutte le statistiche della simulazione
    end
    
    methods

        % Costruttore
        function self = Simulation(net, attributi_entita)
            self.network = net;
            self.eventi_futuri = FIFOQueue();
            self.clock = 0;
            self.numero_entita = 0;
            self.lista_entita = {};
            self.verbose = false;
            self.statistics = {};
            self.num_tot_entita = 0;

            if nargin == 2 && ~isempty(attributi_entita)
                self.attributi_entita = attributi_entita;
            end
        end
       

        % Metodo che si occupa di eseguire la simulazione finché un certo
        % orizzonte temporale non è stato raggiunto (si possono aggiungere altri criteri di stop)
        function stats = run(self, TimeOrizon, verbose)

            if nargin == 3
                self.verbose = verbose;
            end

            if verbose
                figure;
            end

            % inizializzo le statistiche
            self.statistics{end+1} = AverageEntityNetworkTime();
            self.statistics{end+1} = AverageEntityQueuesTime(self.network);
            self.statistics{end+1} = AverageNumEntityIntoNetwork(self.verbose);
            self.statistics{end+1} = AverageNumEntityIntoNodes(self.network);



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
                if self.verbose
                    fprintf('\n CLOCK = %3.2f\n ', self.clock);
                end

                % 2. Processo l'evento
                evento_da_processare.process(self.clock, self);

            end


            fprintf("\n FINE SIMULAZIONE \n\n")
            
            % stampo le statistiche
            avg_ent_net_time = self.statistics{1}.return_stat();
            avg_ent_queues_time = self.statistics{2}.return_stat(self);
            avg_num_ent_net = self.statistics{3}.return_stat(self);
            avg_num_ents_nodes = self.statistics{4}.return_stat(self);

            if self.verbose
                fprintf('\n Avarage time into the network per entity  = %3.2f\n', avg_ent_net_time)
                fprintf('\n Avarage time spent in the queues per entity:\n')
                for i = 1:size(self.network.matrice_di_adiacenza,1)
                    if i~=self.network.posizione_sink
                        fprintf('\n Node %1.f: %3.2f', i, avg_ent_queues_time(i))
                    else
                        fprintf('\n Node %1.f: SINK', i)
                    end
                end
                fprintf('\n\n Avarage number of entities in the network  = %3.2f\n', avg_num_ent_net)
                fprintf('\n Avarage number of entities in the nodes of the network:\n')
                for i = 1:size(self.network.matrice_di_adiacenza,1)
                    if i~=self.network.posizione_sink
                        fprintf('\n Node %1.f: %3.2f', i, avg_num_ents_nodes(i))
                    else
                        fprintf('\n Node %1.f: SINK', i)
                    end
                end
                fprintf('\n')
            end

            stats = self.statistics;

            % Pulisco la simulazione
            clear_simulation(self);
      
        end %end run

        % Metodo per rinizializzare gli oggetti della simulazione
        function clear_simulation(sim)

            % Reinizializzazione delle proprietà
            sim.statistics = {};
            sim.numero_entita = 0;
            sim.lista_entita = {};
            sim.eventi_futuri = FIFOQueue();
            sim.clock = 0;

            % Reinizializza nodo (libera server + svuota le coda)
            for id_nodo = 1:sim.network.numero_nodi
                sim.network.nodi{id_nodo}.clear_node();
            end
        end


        

    end % end methods
end

