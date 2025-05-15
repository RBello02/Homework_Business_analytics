classdef Network < handle
    % NETWORK è la classe che definisce la struttura della rete di Jackson 
    % da modellare a partire dalle informazioni fornite dall’utente.
    % La struttura è composta da nodi, la cui definizione è compito del
    % costruttore di questa classe.

    properties
        nodi                   
        matrice_di_adiacenza    
        distribuzioni_arrivo    % vettore (num_nodi x 1) delle distribuzioni di arrivo esterno
        distribuzioni_servizio  % matrice (num_nodi x max_num_server) delle distribuzioni di servizio
        posizione_sink          
    end

    methods
        % Costruttore
        function self = Network(distr_arrivo, distr_servizio, matrice_di_adiacenza)

            % INPUT:
            % - distr_arrivo: vettore (num_nodi x 1) contenente le distribuzioni
            %   che regolano gli arrivi esterni per ogni nodo
            % - distr_servizio: matrice (num_nodi x max_num_server) con distribuzioni
            %   dei tempi di servizio per ogni server di ogni nodo.
            %   Se un nodo ha meno server, le colonne in eccesso sono NaN.
            % - matrice_di_adiacenza: matrice quadrata contenente valori in [0,1] o
            %   function handle per selezione condizionale di nodi

            % Validazione della matrice di adiacenza
            if ~ismatrix(matrice_di_adiacenza)
                error('Al costruttore non è stata passata una matrice');
            end

            if size(matrice_di_adiacenza,1) ~= size(matrice_di_adiacenza,2)
                error('La matrice di adiacenza non è quadrata');
            end

            % Sostituisce i function handle con valori numerici per verifiche
            matrice_numerica = self.Trasforma_matrice_numerica(matrice_di_adiacenza);

            % Verifica stocasticità e trova il sink
            if ~Verifica_matrice_stocastica(matrice_numerica)
                matrice_di_adiacenza = Normalizzazione_matrice_di_adiacenza(matrice_di_adiacenza);
            end
            
            posizione_sink = self.Trova_sink(matrice_numerica);
            if length(posizione_sink) ~= 1
                error('La rete contiene più di un sink');
            end

            % Verifica che il sink sia raggiungibile da ogni nodo
            for i = 1:size(matrice_numerica,1)
                nodi_raggiungibili = BreadthFirstSearch(matrice_numerica, i);
                % Se l'intersezione è vuota, il sink NON è raggiungibile da i
                if isempty(intersect(nodi_raggiungibili, posizione_sink))
                    error('Il sink non è raggiungibile da tutti i nodi, rete non connessa');
                end
            end

            % Inizializza proprietà
            self.matrice_di_adiacenza = matrice_di_adiacenza;
            self.distribuzioni_arrivo = distr_arrivo;
            self.distribuzioni_servizio = distr_servizio;
            self.nodi = {};  % verrà popolata con istanze di Node
            self.posizione_sink = posizione_sink;
        end

        function M_num = Trasforma_matrice_numerica(M)
            % Trasforma una matrice mista (numeri + function handle) in matrice numerica
            % Sostituisce i function handle con valori equidistribuiti sulla riga.
        
            [num_righe, num_colonne] = size(M);
            M_num = zeros(num_righe, num_colonne);
    
            if ~iscell(M)
                % Se è già numerica, la restituisco direttamente
                M_num = M;
                return;
            end
        
            for i = 1:num_righe
                isFunc = cellfun(@(x) isa(x, 'function_handle'), M(i,:));
                nFunc = sum(isFunc);
        
                % Valore da assegnare a ogni function handle sulla riga
                if nFunc > 0
                    valore_func = 1 / nFunc;
                else
                    valore_func = 0; % non usato se nFunc==0
                end
        
                for j = 1:num_colonne
                    if isFunc(j)
                        M_num(i,j) = valore_func;
                    else
                        % Se è numerico, lo assegno così com'è
                        if isnumeric(M{i,j})
                            M_num(i,j) = M{i,j};
                        else
                            error('Elemento non numerico né function handle rilevato');
                        end
                    end
                end
            end
        end



        % Metodo per trovare il sink nella matrice senza function handle
        function posizione = Trova_sink(~, matrix)
            % Il sink è identificato come nodo con valore 1 sulla diagonale
            diagonale = diag(matrix);
            posizione = find(diagonale == 1);
        end
    end
end
