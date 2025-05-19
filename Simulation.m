classdef Simulation < handle

    % SIMULATION è la classe che si occupa di gestire il funzionamento di
    % una singola simulazione, andando a determinare qual è il prossimo
    % evento da processare.
    
    properties
        network
        eventi_futuri
        clock 

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
        end
       

        % Metodo che si occupa di eseguire la simulazione finché un certo
        % orizzonte temporale non è stato raggiunto (si possono aggiungere altri criteri di stop)
        function run(self, TimeOrizon)
            
            while self.clock < TimeOrizon

                % 1. Determino il prossimo evento da processare e porto
                % avanti il clock
                evento_da_processare = self.eventi_futuri.dequeue();
                self.clock = self.clock + evento_da_processare.timestamp_coda;

                % 2. Processo l'evento
                evento_da_processare.process(self.clock, self);

                print('clock = ', self.clock)
                print('evento da processarr = ', evento_da_processare)
            end
            
            % stampo qualcosa
        end

        

    end % end methods
end

