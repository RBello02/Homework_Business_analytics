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

        statistics % cell array contenente tutte le statistiche della simulazione
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
            self.statistics = {};
        end
       

        % Metodo che si occupa di eseguire la simulazione finché un certo
        % orizzonte temporale non è stato raggiunto (si possono aggiungere altri criteri di stop)
        function [list_ent, avg_ent_net_time, avg_ent_queues_time, avg_ent_net]  = ...
                run(self, TimeOrizon, verbose)

            if nargin == 3
                self.verbose = verbose;
            end

            % inizializzo le statistiche
            self.statistics{end+1} = AvarageEntityNetworkTime();
            self.statistics{end+1} = AvarageEntityQueuesTime(self.network);
            self.statistics{end+1} = AvarageNumEntityIntoNetwork(self.verbose);
            self.statistics{end+1} = AvarageNumEntityIntoNodes(self.network);



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
            list_ent = self.lista_entita;
            
            % stampo le statistiche
            if self.verbose
                avg_ent_net_time = self.statistics{1}.return_stat();
                fprintf('\n Avarage time into the network per entity  = %3.2f\n', avg_ent_net_time)
                avg_ent_queues_time = self.statistics{2}.return_stat(self);
                fprintf('\n Avarage time spent in the queues per entity:\n')
                for i = 1:size(self.network.matrice_di_adiacenza,1)
                    if i~=self.network.posizione_sink
                        fprintf('\n Node %1.f: %3.2f', i, avg_ent_queues_time(i))
                    else
                        fprintf('\n Node %1.f: SINK', i)
                    end
                end
                avg_ent_net = self.statistics{3}.return_stat(self);
                fprintf('\n\n Avarage time spent in the queues per entity  = %3.2f\n', avg_ent_net_time)
                avg_num_ents_nodes = self.statistics{4}.return_stat(self);
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
            
        end

        

    end % end methods
end

