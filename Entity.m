classdef Entity < handle
    % ENTITY rappresenta un'entità nel sistema, con attributi e percorso personalizzato.
    
    properties
        matrice_del_percorso     % Matrice di transizione personalizzata (stocastica)
        nodo_di_partenza         % Nodo di partenza (indice)
        nodi_di_arrivo           % Vettore dei nodi di arrivo possibili
        istante_di_arrivo_glob   % Tempo di arrivo globale nel sistema
        timestamp_coda           % Timestamp per statistiche locali nel nodo (aggiornato per ogni nodo)
        proprieta                % Struct con attributi personalizzati dell'entità
    end
    
    methods
        % Costruttore
        function self = Entity(clock, attr, nodo_generaz, matr)
            % clock: tempo di generazione/arrivo
            % attr: struct con attributi possibili (cell array o vettori)
            % nodo_generaz: nodo di partenza (indice)
            % nodi_arrivo: vettore di nodi di arrivo
            % matr: matrice di adiacenza (cell array con numeri o function handle)
            
            % Inizializzo le proprietà base
            self.istante_di_arrivo_glob = clock;
            self.nodo_di_partenza = nodo_generaz;
            self.nodi_di_arrivo = nodi_arrivo;
            
            % Inizializzo la struct proprietà dell'entità
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
            
            % Personalizzo la matrice di transizione in base agli attributi
            self.matrice_del_percorso = self.PersonalizzaRoute(matr, self.proprieta);
            
            % --- Controlli di consistenza ---
            
            % 1. Verifico che il nodo di partenza sia valido
            if self.nodo_di_partenza > size(matr,1) || self.nodo_di_partenza < 1
                error('Il nodo di partenza non è valido per la matrice di adiacenza.');
            end
            
            % 2. Verifico che tutti i nodi di arrivo siano validi
            for i = 1:length(self.nodi_di_arrivo)
                if self.nodi_di_arrivo(i) > size(self.matrice_del_percorso,1) || self.nodi_di_arrivo(i) < 1
                    error('Uno dei nodi di arrivo non è valido per la matrice di adiacenza.');
                end
            end
            
            % 3. Controllo che la matrice personalizzata sia una matrice (numeric)
            if ~ismatrix(self.matrice_del_percorso)
                error('La matrice di adiacenza personalizzata non è una matrice valida.');
            end
            
            % Aggiungo il path delle funzioni necessarie per i controlli
            addpath('funzioni');
            
            % 4. Verifico che la matrice sia stocastica (righe sommano a 1)
            if Verifica_matrice_stocastica(self.matrice_del_percorso) == 0
                error('La matrice di adiacenza personalizzata non è stocastica.');
            end
            
            % 5. Verifico che esista un percorso dal nodo di partenza a uno dei nodi di arrivo
            lista_nodi_visitati = BreadthFirstSearch(self.matrice_del_percorso, self.nodo_di_partenza);
            if isempty(intersect(lista_nodi_visitati, self.nodi_di_arrivo))
                error('Non è possibile raggiungere nessuno dei nodi di arrivo partendo dal nodo di partenza.');
            end
            
        end
        
        
        % Metodo per personalizzare la matrice di transizione in base agli attributi
        function matr_personalizzata = PersonalizzaRoute(self, matr)
            % matr: cell array con numeri o function handle
            % restituisce matrice numerica con valori valutati
            
            prop_entita = self.proprieta;

            [num_righe, num_colonne] = size(matr);
            matr_personalizzata = zeros(num_righe, num_colonne);
            
            for i = 1:num_righe
                for j = 1:num_colonne
                    elem = matr{i,j};
                    
                    if isa(elem, 'function_handle')
                        try
                            val = elem(prop_entita);
                            
                            % Controllo che il valore sia numerico, scalare e in [0,1]
                            if ~isscalar(val) || ~isnumeric(val) || val < 0 || val > 1
                                error('Valore restituito dalla funzione non valido.');
                            end
                            matr_personalizzata(i,j) = val;
                        catch ME
                            error(['Errore nella valutazione del function handle in matrice(' num2str(i) ',' num2str(j) '): ' ME.message]);
                        end
                    elseif isnumeric(elem)
                        % Controllo valore numerico in [0,1]
                        if elem < 0 || elem > 1
                            error(['Valore numerico fuori range [0,1] in matrice(' num2str(i) ',' num2str(j) ')']);
                        end
                        matr_personalizzata(i,j) = elem;
                    else
                        error(['Elemento non valido in matrice(' num2str(i) ',' num2str(j) ')']);
                    end
                end
            end
        end
        
        
        % Qui puoi aggiungere altri metodi per la gestione delle statistiche o altro...
        
    end
end
