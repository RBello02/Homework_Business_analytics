
function visitati = BreadthFirstSearch(Matrice_adiacenza, Nodo_partenza)

    % BREADTHFIRSTSEARCH esegue una ricerca in ampiezza a partire da un nodo

    % - Matrice_adiacenza: è la matrice di adiacenza del grafo
    % - Nodo_partenza: è il nodo da cui partire per la ricerca

    % - Visitati è un vettore che contiene i nodi visitati sul grafo

    % STEP 1: Inizializzazione del vettore dei nodi visitati:
    visitati = zeros(1, size(Matrice_adiacenza, 1));

    % STEP 2: Inizializzazione della coda:
    coda = [];
    coda = [coda Nodo_partenza];

    % STEP 3: ciclo while per la ricerca in ampiezza
    while ~isempty(coda)

        nodo_corrente = coda(1);
        coda(1) = []; % rimuovi il primo nodo dalla coda

        if visitati(nodo_corrente) == 0
            visitati(nodo_corrente) = 1; % segno il nodo come visitato

            lista_di_adiacenza = crea_lista_di_adiacenza(Matrice_adiacenza, nodo_corrente);

            for i = 1:length(lista_di_adiacenza)
                nodo_adiacente = lista_di_adiacenza(i);
                if visitati(nodo_adiacente) == 0
                    coda = [coda nodo_adiacente]; % aggiungi il nodo adiacente alla coda
                end
            end
        end

    end 

end

function lista_di_adiacenza = crea_lista_di_adiacenza(matrice_di_adiacenza, nodo)

    % CREA_LISTA_DI_ADIACENZA crea una lista di adiacenza a partire da una matrice di adiacenza

    % INPUT:
    % - matrice_di_adiacenza: matrice di adiacenza del grafo
    % - nodo: nodo di partenza per la creazione della lista di adiacenza

    % OUTPUT:
    % - lista_di_adiacenza: lista di adiacenza del nodo

    vettore = matrice_di_adiacenza(nodo, :);
    lista_di_adiacenza = find(vettore > 0); % trova gli indici dei nodi adiacenti

end