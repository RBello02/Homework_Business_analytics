classdef AverageNumEntityIntoNetwork < StatManager
    % AVARAGENUMENTITYINTONETWORK Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        tracker_time
        tracker_value
        x_plot
        y_plot 
        h
        verbose = false; %valore di default
    end
    
    methods
        function self = AverageNumEntityIntoNetwork(verbose)
            self.tracker_time = 0;
            self.tracker_value = 0;
            self.sums = 0;
            self.x_plot = [];
            self.y_plot = [];

            
            if nargin >= 1
                self.verbose = verbose;
            end
            if verbose
                self.h = plot(NaN, NaN, 'b.-');  % inizializza il grafico
            end
        end
        
        function update_stat(self, clock, num_entita)


            % self.tracker_value è l'altezza del rettangolo da chiudere
            % num_entita è l'altezza del rettangolo che stiamo iniziando
            % (clock-self.tracker_time) è la base del rettangolo da chiudere

            self.sums = self.sums + (clock-self.tracker_time)*self.tracker_value;
            y_middle = self.tracker_value;  % serve per il plot dei rettangoli
            self.tracker_value = num_entita;
            x_before = self.tracker_time;    % serve per il plot
            self.tracker_time = clock;
            x_after = self.tracker_time;   % serve per il plot


            if self.verbose    % faccio i plot
                self.x_plot(end+1) = x_before;
                self.y_plot(end+1) = y_middle;
                set(self.h, 'XData', self.x_plot, 'YData', self.y_plot);
                title(sprintf('Numero di entità nella rete - clock %.2f', self.x_plot(end)));
                xlabel('Tempo (clock)');  % <-- Etichetta asse x
                ylabel('Numero di entità');  % <-- Etichetta asse y
                drawnow;
                self.x_plot(end+1) = x_after;
                self.y_plot(end+1) = y_middle;
                set(self.h, 'XData', self.x_plot, 'YData', self.y_plot);
                title(sprintf('Numero di entità nella rete - clock %.2f', self.x_plot(end)));
                xlabel('Tempo (clock)');  % <-- Etichetta asse x
                ylabel('Numero di entità');  % <-- Etichetta asse y
                drawnow;
            end
        end

        function stat = return_stat(self, sim)

            % Chiudo l'ultimo rettangolo
            self.update_stat(sim.clock, 0)
            
            if self.tracker_time ~= 0
                stat = self.sums/self.tracker_time;
                self.results = stat;
            else
                error('Impossibile calcolare la lunghezza media di entità nel network')
            end
        end
    end
end

