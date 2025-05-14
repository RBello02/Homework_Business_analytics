function is_stocastica = Verifica_matrice_stocastica(M, tolleranza)
    % VERIFICA_MATRICE_STOCASTICA controlla se una matrice è stocastica per righe
    %
    % INPUT:
    % - M: matrice da verificare
    % - tolleranza: margine di errore per la somma delle righe (default: 1e-10)
    %
    % OUTPUT:
    % - is_stocastica: true se M è stocastica, false altrimenti

    if nargin < 2
        tolleranza = 1e-10;
    end

    % Condizione 1: tutti i valori devono essere compresi tra 0 e 1
    if any(M(:) < 0) || any(M(:) > 1)
        is_stocastica = false;
        return;
    end

    % Condizione 2: la somma di ogni riga deve essere ≈ 1
    somma_righe = sum(M, 2);
    if all(abs(somma_righe - 1) < tolleranza)
        is_stocastica = true;
    else
        is_stocastica = false;
    end
end
