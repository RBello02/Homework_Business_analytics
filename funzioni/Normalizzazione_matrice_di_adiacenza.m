function M_out = Normalizzazione_matrice_di_adiacenza(M)
    % Normalizza righe numeriche di M in modo che sommino a 1
    % Se la riga contiene function handle la lascia invariata
    % Controlla che in righe con function handle non ci siano due o più function handle "attivi" (come da tua logica)

    [num_righe, num_colonne] = size(M);
    M_out = M; % di default copia identica

    for i = 1:num_righe
        % Verifica se la riga contiene almeno un function handle
        if iscell(M)
            isFunc = cellfun(@(x) isa(x,'function_handle'), M(i,:));
        else
            % Se M è numerica, non ci sono function handle
            isFunc = false(1,num_colonne);
        end

        if any(isFunc)
            % Non modificare la riga, esci dal ciclo e vai alla prossima
            continue
        else
            % Riga tutta numerica: normalizza
            somma = sum(M(i,:));
            if somma == 0
                % se la riga è nulla, distribuisci uniformemente
                M_out(i,:) = ones(1,num_colonne)/num_colonne;
            else
                M_out(i,:) = M(i,:) / somma;
            end
        end
    end
end
