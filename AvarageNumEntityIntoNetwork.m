classdef AvarageNumEntityIntoNetwork < StatManager
    % AVARAGENUMENTITYINTONETWORK Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        integrale 
        tracker_time
        tracker_value
    end
    
    methods
        function self = AvarageNumEntityIntoNetwork()
            self.tracker_time = 0;
            self.tracker_value = 0;
            self.integrale = 0;
        end
        
        function update_stat(self, clock, num_entita)

            % self.tracker_value è l'altezza del rettangolo da chiudere
            % num_entita è l'altezza del rettangolo che stiamo iniziando
            % (clock-self.tracker_time) è la base del triangolo da chiudere

            self.integrale = self.integrale + (clock-self.tracker_time)*self.tracker_value;
            self.tracker_value = num_entita;
            self.tracker_time = clock;
        end

        function stat = return_stat(self)
            
            if self.tracker_time ~= 0
                stat = self.integrale/self.tracker_time;
            else
                error('Impossibile calcolare la lunghezza media di entità nel network')
            end
        end
    end
end

