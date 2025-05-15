classdef Costumer < handle
    % COSTUMER è la classe che rappresenta un cliente nel sistema. Ogni
    % istanza di questa classe raggruppa le informazioni relative ad un
    % singolo cliente.
    
    properties
        matrice_del_percorso
        nodo_di_partenza       % rappresenta il nodo di partenza del cliente 
        nodi_di_arrivo      % rappresenta i nodi di arrivo del cliente (possono essere più i uno perchè il cliente può avere più possibili uscite)
        istante_di_arrivo_glob % info globale
        istante_di_arrivo_nodo % info locale per il calcolo di una statistica per un certo nodo (ad ogni nodo si sovvrascrive)
        proprieta % info addizionali sotto forma di struct
    end
    
    methods

        % Costruttore
        function self = Costumer(matr, clock, prop)
            self.matrice_del_percorso = matr;
            self.istante_di_arrivo_glob = clock;
            self.proprieta = prop;
            self.nodo_di_partenza = nodo_di_partenza;
            self.nodi_di_arrivo = nodi_di_arrivo;

            % ATTENZIONE:
            % - nodo di partenza è un elemento della matrice di adiacenza e viene memorizzato attraverso la coppia [i,j]
            %  - nodi di arrivo è un vettore di coppie [i,j] che rappresentano i nodi di arrivo

            %% 1° controllo: verificare che il nodo di partenza sia un nodo della matrice di adiacenza
            if self.nodo_di_partenza > size(matr,1) 
                error('il nodo di partenza non è un nodo della matrice di adiacenza');
            end

            %% 2° controllo: verificare che i nodi di arrivo siano nodi della matrice di adiacenza
            for i = 1:length(self.nodi_di_arrivo)
                if self.nodi_di_arrivo(i) > size(self.matrice_del_percorso,1)
                    error('il nodo di arrivo non è un nodo della matrice di adiacenza');
                end
            end

            %% 3° controllo: la matrice di adiacenza del customer deve essere una matrice stocastica

            if ~ismatrix(self.matrice_del_percorso) 
                error('al costruttore non è stata passata una matrice');
            end
            addpath('funzioni')  % andare nel path delle funzioni
            if Verifica_matrice_stocastica(self.matrice_del_percorso) == 0
                error('la matrice di adiacenza non è stocastica');
            end

            %% 4° controllo: verificare che esista almeno un percorso dal nodo di partenza a uno dei nodi di arrivo
            
            lista_nodi_visitati = BreadthFirstSearch(self.matrice_del_percorso, self.nodo_di_partenza);
            if ~isempty(intersect(lista_nodi_visitati, self.nodi_di_arrivo))
                error('è impossibile raggiungere uno dei nodi di arrivo partendo dai nodi di partenza');
            end
            
        
        end
        % aggiungere funzioni per la gestione delle statistiche??

    end %end methods
end

