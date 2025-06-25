classdef Entity < handle
    % ENTITY rappresenta un'entità nel sistema, con attributi e percorso personalizzato.
    
    properties
        id
        matrice_del_percorso     % Matrice di transizione personalizzata (stocastica)
        nodo_di_partenza         % Nodo di partenza (indice)
        istante_di_arrivo_glob   % Tempo di arrivo globale nel sistema
        nodo_attuale             % id del nodo in cui si trova attualmente
        timestamp_coda           % Timestamp per statistiche locali nel nodo (aggiornato per ogni nodo)
        proprieta                % Struct con attributi personalizzati dell'entità
    end
    
    methods
        % Costruttore
        function self = Entity(clock, attr, nodo_generaz, sim)
            % clock: tempo di generazione/arrivo
            % attr: struct con attributi possibili (cell array o vettori)
            % nodo_generaz: nodo di partenza (indice)
            % matr: matrice di adiacenza (cell array con numeri o function handle)
            
            % Inizializzo le proprietà base
            self.istante_di_arrivo_glob = clock;
            self.nodo_di_partenza = nodo_generaz;
            self.nodo_attuale = nodo_generaz;

            matr_adiac_net = sim.network.matrice_di_adiacenza;
            sim.numero_entita = sim.numero_entita +1;
            sim.num_tot_entita = sim.num_tot_entita +1;
            id_ent = sim.num_tot_entita;
            self.id = id_ent;
            sim.lista_entita{end+1} = self;
            
            % Inizializzo la struct proprietà dell'entità
            if ~isempty(attr)
                self.proprieta = struct();
                campi = fieldnames(attr);
                for i = 1:length(campi)
                    campo = campi{i};
                    valori_possibili = attr.(campo);
                    
                    % Se è cell array, scelgo casualmente un valore
                    if iscell(valori_possibili)
                        idx = randi(length(valori_possibili));
                        self.proprieta.(campo) = valori_possibili{idx};
                    
                    % Se è vettore numerico o stringa, scelgo casualmente un elemento
                    elseif isnumeric(valori_possibili) || isstring(valori_possibili) || ischar(valori_possibili)
                        idx = randi(length(valori_possibili));
                        self.proprieta.(campo) = valori_possibili(idx);
                    
                    % Altrimenti assegno direttamente il valore singolo
                    else
                        self.proprieta.(campo) = valori_possibili;
                    end
                end
            end

            % Personalizzo la matrice di transizione in base agli attributi
            self.matrice_del_percorso = self.PersonalizzaRoute(matr_adiac_net);
            
            % --- Controlli di consistenza ---

            % 1. Controllo che la matrice personalizzata sia una matrice (numeric)
            if ~ismatrix(self.matrice_del_percorso)
                disp('Matrice del Percorso: ')
                disp(self.matrice_del_percorso);
                error('La matrice di adiacenza personalizzata non è una matrice valida.');
            end
            
            % 2. Verifico che il nodo di partenza sia valido
            if self.nodo_di_partenza > size(matr_adiac_net,1) || self.nodo_di_partenza < 1
                disp('Matrice del Percorso: ')
                disp(self.matrice_del_percorso);
                error('Il nodo di partenza non è valido per la matrice di adiacenza.');
            end
            
            % 3. Verifico che il sink coincida con il sink dalla network
            sink_glob = sim.network.posizione_sink;
            sink_personale = sim.network.Trova_sink(self.matrice_del_percorso);

            if ~sink_personale == sink_glob
                disp('Matrice del Percorso: ')
                disp(self.matrice_del_percorso);
                error("'La matrice del percorso per l'entità non ha sink coincidente con il sink globale.");
            end
            
            
            % 4. Verifico che la matrice sia stocastica (righe sommano a 1)
            if Verifica_matrice_stocastica(self.matrice_del_percorso) == 0
                disp('Matrice del Percorso: ')
                disp(self.matrice_del_percorso);
                error('La matrice di adiacenza personalizzata non è stocastica.');
            end
            
            % 5. Verifico che esista un percorso dal nodo di partenza a uno dei nodi di arrivo
            nodi_visitabili = BreadthFirstSearch(self.matrice_del_percorso, self.nodo_di_partenza);
            % Verifica se almeno uno dei nodi di arrivo è raggiungibile (nodo di arrivo = sink)
            if ~any(nodi_visitabili(sink_personale))
                disp('Matrice del Percorso: ')
                disp(self.matrice_del_percorso);
                error('Non è possibile raggiungere nessuno dei nodi di arrivo partendo dal nodo di partenza.');
            end
            
        end
        
        
        % Metodo per personalizzare la matrice di transizione in base agli attributi
        function matr_stocastica = PersonalizzaRoute(self, matr)
            % matr: cell array (con numeri o function handle)
            % self.proprieta: attributi dell'entità
            % OUTPUT: matrice binaria con un solo 1 per riga (prossimo nodo scelto)
        
            prop_entita = self.proprieta;
            [num_righe, num_colonne] = size(matr);
            matr_stocastica = zeros(num_righe, num_colonne);  % inizializza matrice finale
        
            for id_riga = 1:num_righe
                prob_riga = zeros(1, num_colonne);  % riga di probabilità
        
                for id_col = 1:num_colonne
                    elem = matr{id_riga, id_col};
        
                    if isa(elem, 'function_handle')
                        try
                            val = double(elem(prop_entita));
                            if ~isscalar(val) || val < 0 || val > 1
                                error('Valore da function handle non valido.');
                            end
                            prob_riga(id_col) = val;
                        catch ME
                            error(['Errore in funzione alla posizione (' num2str(id_riga) ',' num2str(id_col) '): ' ME.message]);
                        end
        
                    elseif isnumeric(elem)
                        if ~isscalar(elem) || elem < 0 || elem > 1
                            error(['Valore numerico non valido in (' num2str(id_riga) ',' num2str(id_col) ')']);
                        end
                        prob_riga(id_col) = elem;
        
                    else
                        error(['Elemento non riconosciuto in (' num2str(id_riga) ',' num2str(id_col) ')']);
                    end %end case elem is a funcion handle
                end %end loop sulle colonne
        
                % Normalizzazione
                somma = sum(prob_riga);
                matr_stocastica(id_riga, :) = prob_riga / somma;
     
            end %end for sulle righe
        end

        
        
        % Qui puoi aggiungere altri metodi per la gestione delle statistiche o altro...
        
    end
end
