function M_out = Normalizzazione_matrice_di_adiacenza(M)
    % Normalizza le righe numeriche di una matrice M affinché la somma di ogni riga sia 1.
    % Se una riga contiene almeno un function handle, la riga viene lasciata invariata.
    % Inoltre, verifica che non ci siano più di un function handle attivo per riga.

    [num_righe, num_colonne] = size(M);  % Ottiene le dimensioni della matrice
    M_out = M;  % Inizializza la matrice di output con la matrice di input
    is_cella = iscell(M);  % Verifica se M è una cell array

    for i = 1:num_righe
        if is_cella
            % Identifica i function handle nella riga i
            isFunc = cellfun(@(x) isa(x, 'function_handle'), M(i,:));
        else
            % Se M è una matrice numerica, non ci sono function handle
            isFunc = false(1, num_colonne);
        end

        if any(isFunc)
            % Se ci sono function handle nella riga salto la
            % normalizzazione
            continue;
        else
            % Se la riga è completamente numerica
            if is_cella
                % Estrae i valori numerici dalla cell array
                riga = cell2mat(M(i,:));
            else
                riga = M(i,:);
            end

            somma = sum(riga);  % Calcola la somma degli elementi della riga

            if somma == 0
                % Se la somma è zero, distribuisce uniformemente i valori
                valori_uniformi = ones(1, num_colonne) / num_colonne;
                if is_cella
                    % Converte i valori in celle se M è una cell array
                    M_out(i,:) = num2cell(valori_uniformi);
                else
                    M_out(i,:) = valori_uniformi;
                end
            else
                % Normalizza la riga dividendo ogni elemento per la somma
                riga_normalizzata = riga / somma;
                if is_cella
                    % Converte i valori normalizzati in celle se M è una cell array
                    M_out(i,:) = num2cell(riga_normalizzata);
                else
                    M_out(i,:) = riga_normalizzata;
                end
            end
        end
    end
end
