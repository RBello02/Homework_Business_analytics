classdef Network < handle

    % NETWORK è la classe che si occupa di definire la strutture della rete di Jackson 
    % che si vuole modellare a partire dalle informazioni passate in input 
    % dall'uttilizzatore della libreria. La struttura è composta di nodi di
    % cui la definicione è un compito del costruttore di questa classe.
    
    properties
        nodi
        matrice_di_adiacenza
    end
    
    methods

        % Costruttore
        function self = Network(distr_arrivo, distr_servizio, matrice_di_adicenza)

            % INPUT:
            % - distr_arrivo sarà una struttura di dimensione (num_nodi) x 1 in cui in
            %   ogni riga sarà memorizzata la distribuzione che regola gli
            %   arrivi dall'esterno per il relativo nodo;
            % - distr_servizio sarà una struttura di dimensione (num_nodi)x(num_server_max)
            %   in cui si vanno a memorizzare le distribuzioni che regolano
            %   i tempi di processo per ogni server di un nodo
            %   ATTENZIONE: Essendo che due nodi possono avere un numero di
            %   server diversi, la seconda dimensione di questa matrice è
            %   determinata a partire dal numero massimo di server che un
            %   nodo può avere. Per convenzione, se un nodo ha un numero di
            %   server minore del numero di colonne, la relativa riga sarà
            %   completata con dei NaN.
            % - matrice_di_adicenza sarà una matrice (num_nodi)x(num_nodi)
            %   che regola la sequenza di nodi che bisogna visitare
            % - In generale la rete viene modellizzata come una matrice di
            %   adiacenza, ma serve solamente a tenere traccia di dove si
            %   trovano i nodi e quali sono i nodi adiacenti a ciascuno di
            %   essi => questa matrice deve essere una matrice di uni e
            %   deve essere simmetrica, per questo aggiungiamo il seguente
            %   controllo:

            % Validazione della matrice di adiacenza
            if ~ismatrix(matrice_di_adicenza) 
               error('al costruttore non è stata passata una matrice');
            end
            if ~isequaly(matrice_di_adicenza, matrice_di_adicenza.')
                error('la matrice di adiacenza non è simmetrica');
            end
            if ~all(matrice_di_adicenza(:) == 0 | matrice_di_adicenza(:) == 1)
                error('la matrice di adiacenza non è composta da uni e zeri');
            end

            % OUTPUT:
            % A partire da queste info si va a definire una lista di nodi

            self.matrice_di_adiacenza = matrice_di_adicenza;
            self.distr_arrivo = distr_arrivo; % matrice di dimensione (num_nodi)x1
            self.distr_servizio = distr_servizio; % matrice di dimensione (num_nodi)x(num_server_max)
            self.nodi = {}; % lista che sarà riempita con istanze di Node
        end
        
        
    end
end

