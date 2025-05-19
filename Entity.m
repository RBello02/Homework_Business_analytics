classdef Entity < handle
    % ENTITY è la classe che rappresenta un'entità nel sistema. Ogni
    % istanza di questa classe raggruppa le informazioni relative ad un
    % singola entità.
    
    properties
        matrice_del_percorso
        nodo_di_partenza       % rappresenta il nodo di partenza dell'entità 
        % nodi_di_arrivo      % rappresenta i nodi di arrivo del cliente (possono essere più i uno perchè il cliente può avere più possibili uscite)
        istante_di_arrivo_glob % info globale
        istante_di_arrivo_nodo % info locale per il calcolo di una statistica per un certo nodo (ad ogni nodo si sovvrascrive)
        proprieta % info addizionali sotto forma di struct
    end
    
    methods

        % Costruttore
        function self = Entity(clock, attr, nodo_generaz)
            self.istante_di_arrivo_glob = clock;
            self.nodo_di_partenza = nodo_generaz;
            self.nodi_di_arrivo = nodi_di_arrivo;

            % Definizione degli attributi dell'entità
            self.proprieta = [];
            campi = fieldnames(attr);
            for i = 1:length(campi)
                campo = campi{i};
                valori_possibili = attr.(campo);
        
                % Se valori_possibili è cell array, estrai uno a caso
                if iscell(valori_possibili)
                    idx = randi(length(valori_possibili));
                    self.proprieta.(campo) = valori_possibili{idx};
                elseif isnumeric(valori_possibili) || isstring(valori_possibili) || ischar(valori_possibili)
                    idx = randi(length(valori_possibili));
                    self.proprieta.(campo) = valori_possibili(idx);
                else
                    % valore singolo, assegna direttamente
                    self.proprieta.(campo) = valori_possibili;
                end
            end

            self.matrice_del_percorso = PersonalizzaRoute(matr, self.proprieta);

            % ATTENZIONE:
            %  - nodo di partenza è un elemento della matrice di adiacenza e viene memorizzato attraverso la coppia [i,j]
            %  - nodi di arrivo è un vettore di coppie [i,j] che rappresentano i nodi di arrivo

            % 1° controllo: verificare che il nodo di partenza sia un nodo della matrice di adiacenza
            if self.nodo_di_partenza > size(matr,1) 
                error('il nodo di partenza non è un nodo della matrice di adiacenza');
            end % --> CONTROLLO INUTILE

            % 2° controllo: verificare che i nodi di arrivo siano nodi della matrice di adiacenza
            for i = 1:length(self.nodi_di_arrivo)
                if self.nodi_di_arrivo(i) > size(self.matrice_del_percorso,1)
                    error('il nodo di arrivo non è un nodo della matrice di adiacenza');
                end
            end % --> CONTROLLO INUTILE

            % 3° controllo: la matrice di adiacenza delL'entità deve essere una matrice stocastica
            if ~ismatrix(self.matrice_del_percorso) 
                error('al costruttore non è stata passata una matrice');
            end
            addpath('funzioni')  % andare nel path delle funzioni
            if Verifica_matrice_stocastica(self.matrice_del_percorso) == 0
                error('la matrice di adiacenza non è stocastica');
            end

            % 4° controllo: verificare che esista almeno un percorso dal nodo di partenza a uno dei nodi di arrivo
            lista_nodi_visitati = BreadthFirstSearch(self.matrice_del_percorso, self.nodo_di_partenza);
            if ~isempty(intersect(lista_nodi_visitati, self.nodi_di_arrivo))
                error('è impossibile raggiungere uno dei nodi di arrivo partendo dai nodi di partenza');
            end
            
        
        end

        % aggiungere funzioni per la gestione delle statistiche??


        % Metodo per la 'personalizzazione'  della route di un entità
        function matr_personalizzata = PersonalizzaRoute(matr, prop_entita)
            % matr: cell array con numeri e function handle (funzioni anonime con input client)
            % prop_entita: struct con attributi
            % OUTPUT:
            % matr_personalizzata: matrice numerica, con function handle
            % valutati sull'entità
        
            [num_righe, num_colonne] = size(matr);
            matr_personalizzata = zeros(num_righe, num_colonne);
        
            for i = 1:num_righe
                for j = 1:num_colonne
                    elem = matr{i,j};
        
                    if isa(elem, 'function_handle')
                        % Provo a valutare la function handle
                        try
                            val = elem(prop_entita);  % passiamo la struct con gli attributi
        
                            % Controlla che il risultato sia numerico/scalar e tra 0 e 1
                            if ~isscalar(val) || ~isnumeric(val) || val < 0 || val > 1
                                error('Valore restituito dalla funzione non valido');
                            end
        
                            matr_personalizzata(i,j) = val;
        
                        catch ME
                            error(['Errore nella valutazione del function handle in matrice(' num2str(i) ',' num2str(j) '): ' ME.message]);
                        end
                    elseif isnumeric(elem)
                        % Se è numerico, copialo direttamente (controllo sommario)
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


    end %end methods
end

