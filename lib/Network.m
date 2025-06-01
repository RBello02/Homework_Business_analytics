classdef Network < handle
    % NETWORK è la classe che definisce la struttura della rete di Jackson 
    % da modellare a partire dalle informazioni fornite dall’utente.
    % La struttura è composta da nodi, la cui definizione è compito del
    % costruttore di questa classe.

    properties
        nodi    
        numero_nodi
        matrice_di_adiacenza    
        distribuzioni_arrivo    % vettore (num_nodi x 1) delle distribuzioni di arrivo esterno
        distribuzioni_servizio  % matrice (num_nodi x max_num_server) delle distribuzioni di servizio
        posizione_sink          
    end

    methods
        % Costruttore
        function self = Network(matrice_di_adiacenza, distr_arrivo, distr_servizio, policy_code)

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

            posizione_sink = self.Trova_sink(matrice_di_adiacenza);
            if isempty(posizione_sink)
                error('La rete non contiene sink');
            elseif length(posizione_sink) > 1
                error('La rete contiene più di un sink')
            end

            % Verifica che il sink sia raggiungibile da ogni nodo
            % Esegui una BFS inversa dal sink (invertendo gli archi)
            matrice_invertita = matrice_numerica';  % Inverti la direzione degli archi
            nodi_che_possono_raggiungere_sink = BreadthFirstSearch(matrice_invertita, posizione_sink);
            generatori = self.trova_generatori(distr_arrivo);
            if all(ismember(generatori,nodi_che_possono_raggiungere_sink))
                error('Il sink non è raggiungibile da tutti i nodi, rete non connessa');
            end
            % Il controllo precendentemente fatto non garantisce al 100%
            % che partendo da un generatore raggiungo un sink, proprio
            % perchè ci sono degli archi con pesi che sono function handle,
            % in teoria dovremmo considerare tutte le possibili
            % combinazioni. In generale se non si passa il test
            % precedentemente fatto allora è sicuro che esiste un nodo
            % generatore dal quale non si può uscire dalla rete

            % Inizializza proprietà
            self.matrice_di_adiacenza = matrice_di_adiacenza;
            self.distribuzioni_arrivo = distr_arrivo;
            self.distribuzioni_servizio = distr_servizio;
            self.posizione_sink = posizione_sink;

            % Popoliamo i nodi
            self.nodi = {};
            num_nodi = size(matrice_di_adiacenza, 1);
            self.numero_nodi = num_nodi;
            for id_nodo = 1:num_nodi
                self.nodi{end+1} = Node(id_nodo, policy_code{id_nodo}, distr_servizio{id_nodo}, distr_arrivo{id_nodo});
            end
        end %end costruttore

        function M_num = Trasforma_matrice_numerica(~, M)
            % Trasforma una matrice mista (numeri + function handle) in matrice numerica
            % Sostituisce i function handle con valori equidistribuiti per
            % avere somma su riga = 1 
            
            % Se la matrice è già numerica, non devo fare nulla
            if ~iscell(M)
                M_num = M;
                return;
            end
        
            [num_righe, num_colonne] = size(M);
            M_num = zeros(num_righe, num_colonne);
        
            for i = 1:num_righe
                isFunc = cellfun(@(x) isa(x, 'function_handle'), M(i,:));
                numerici = ~isFunc;
        
                % Somma dei valori numerici esistenti sulla riga
                somma_numerici = sum(cellfun(@(x) double(x), M(i, numerici)));
        
                nFunc = sum(isFunc);
        
                % Calcolo quanto resta da distribuire ai function handle
                resto = max(1 - somma_numerici, 0);
        
                if nFunc > 0
                    valore_func = resto / nFunc;
                else
                    valore_func = 0;
                end
        
                for j = 1:num_colonne
                    if isFunc(j)
                        M_num(i,j) = valore_func;
                    elseif isnumeric(M{i,j})
                        % Devo convertire il format per non avere problemi
                        M_num(i,j) = double(M{i,j});
                    else
                        error('Elemento non numerico né function handle rilevato in posizione (%d,%d)', i, j);
                    end
                end %end for sulle colonne
            end %end for sulle righe
        end



       % Metodo per trovare il sink nella matrice senza function handle
       function posizione = Trova_sink(~, matrix)
            % Trova posizione del sink (elemento == 1) sulla diagonale
            % Su matrici numeriche cerca valori == 1 (con tolleranza)
            % Su matrici cell considera function handle come 1
            
            toll = 1e-12; % tolleranza per confronto numerico
            
            n = size(matrix, 1);
            valori = zeros(n,1); % vettore per valori sulla diagonale
            
            for k = 1:n
                if isnumeric(matrix)
                    elem = matrix(k,k);
                    valori(k) = elem;
                elseif iscell(matrix)
                    elem = matrix{k,k};
                    if isa(elem, 'function_handle')
                        % Considera function handle come 1
                        valori(k) = 1;
                    elseif isnumeric(elem)
                        valori(k) = elem;
                    else
                        valori(k) = 0; % altro tipo, consideralo 0
                    end
                else
                    error('Tipo matrice non supportato');
                end
            end %end for
            
            % Trova posizione dove valore è vicino a 1
            posizione = find(abs(valori - 1) < toll);
       end

       function vec = trova_generatori(~,distribuzioni_partenza)
            vec = [];
            for i=1:length(distribuzioni_partenza)
                if distribuzioni_partenza{i} ~=-1
                    vec(end+1)= i;
                end
            end
        end

    end%end methods
end
