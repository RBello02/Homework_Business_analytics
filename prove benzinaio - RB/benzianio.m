
% ci sono due tipi di automobili: A e B

% le pompe sono omologate al tipo di automobile, di conseguenza ci sono
% Pompe di tipo A e B

% le pompe sono disposte in una serie di due paralleli, ovvero A||B -> A||B
% di conseguenza, una macchina all'arrivo, ha a disposizione le due pompe 

%% rate di arrivo delle macchine

rate_A = 10500;
rate_B = 10500;

%% rate di servizio delle pompe

min_servizio_pompe = 402;      % lo ipotizzio uguale per entrambe le pompe
max_servizio_pompe = 803.3;

%% rate di servizio del cassiere

min_cassiere = 100.4;
max_cassiere = 200.4;




% immaginiamo di voler servire N clienti, ovvero che N clienti pagano il
% cassiere

N = 1000;
toServe = 0;
clock = 0;
Numero_max_persone_in_coda_al_benzinaio = 4;

% stato iniziale: arriva il primo cliente

tempo_arrivo_A = exprnd(1/rate_A);
tempo_arrivo_B = exprnd(1/rate_B);
tempo_cassa = inf;

% definisco le Flag per le pompe

pompa_1_A = true;
pompa_1_B = true;
pompa_2_A = true;
pompa_2_B = true;

% definisco i tempi di servizio delle pompe

tempo_servizio_1_A = inf;
tempo_servizio_1_B = inf;
tempo_servizio_2_A = inf;
tempo_servizio_2_B = inf;


tempo_di_arrivo_in_coda_alla_benzina_per_auto_A = [];
tempo_di_arrivo_in_coda_alla_benzina_per_auto_B = [];

tempo_di_arrivo_coda_alla_cassa_da_1_A = [];
tempo_di_arrivo_coda_alla_cassa_da_1_B = [];
tempo_di_arrivo_coda_alla_cassa_da_2_A = [];
tempo_di_arrivo_coda_alla_cassa_da_2_B = [];

lunghezza_coda = 0;
clock_precedente = 0;  % serve per calcolare la lunghezza media della coda
lost = 0;

while toServe <= N

    %% arrivo macchine

    if tempo_arrivo_A < min([tempo_arrivo_B,tempo_servizio_1_A, tempo_servizio_1_B, tempo_servizio_2_A, tempo_servizio_2_B, tempo_cassa]) % 1° evento arrivo A

        clock = tempo_arrivo_A;
        
        if (pompa_1_A && pompa_2_A)     % se ho due posti liberi davanti vado alla pompa più lontana

            pompa_2_A = false;
            tempo_servizio_2_A = clock + unifrnd(min_servizio_pompe, max_servizio_pompe); % aggiorno il tempo di servizio di A

            if length(tempo_di_arrivo_in_coda_alla_benzina_per_auto_A) ~= 0
                [~, idx_min] = min(tempo_di_arrivo_in_coda_alla_benzina_per_auto_A);
                tempo_di_arrivo_in_coda_alla_benzina_per_auto_A(idx_min) = [];
            end 

        elseif (pompa_1_A && ~pompa_2_A)  % se è libera la prima ma non la seconda

            pompa_1_A = false; 
            tempo_servizio_1_A = clock + unifrnd(min_servizio_pompe, max_servizio_pompe);

            if length(tempo_di_arrivo_in_coda_alla_benzina_per_auto_A) ~= 0
                [~, idx_min] = min(tempo_di_arrivo_in_coda_alla_benzina_per_auto_A);
                tempo_di_arrivo_in_coda_alla_benzina_per_auto_A(idx_min) = [];
            end 

        else  
            tempo_di_arrivo_in_coda_alla_benzina_per_auto_A(1) = clock;
        end
        tempo_arrivo_A = inf;

    end

    if tempo_arrivo_B < min([tempo_arrivo_A,tempo_servizio_1_A, tempo_servizio_1_B, tempo_servizio_2_A, tempo_servizio_2_B, tempo_cassa]) % 1° evento arrivo B

        clock =  tempo_arrivo_B;
        
        if (pompa_1_B && pompa_2_B)     % se ho due posti liberi davanti vado alla pompa più lontana
            pompa_2_B = false;
            tempo_servizio_2_B = clock + unifrnd(min_servizio_pompe, max_servizio_pompe); % aggiorno il tempo di servizio di A

            if length(tempo_di_arrivo_in_coda_alla_benzina_per_auto_B) ~= 0
                [~, idx_min] = min(tempo_di_arrivo_in_coda_alla_benzina_per_auto_B);
                tempo_di_arrivo_in_coda_alla_benzina_per_auto_B(idx_min) = [];
            end 

        elseif (pompa_1_B && ~pompa_2_B)  % se è libera la prima ma non la seconda
            pompa_1_B = false; 
            tempo_servizio_1_B = clock + unifrnd(min_servizio_pompe, max_servizio_pompe);

            if length(tempo_di_arrivo_in_coda_alla_benzina_per_auto_B) ~= 0
                [~, idx_min] = min(tempo_di_arrivo_in_coda_alla_benzina_per_auto_B);
                tempo_di_arrivo_in_coda_alla_benzina_per_auto_B(idx_min) = [];
            end 

        else  
            tempo_di_arrivo_in_coda_alla_benzina_per_auto_B(1) = clock;
        end
        tempo_arrivo_B = inf;

    end

    %% calcolo lunghezza della coda 

        lunghezza_coda = lunghezza_coda + (length(tempo_di_arrivo_in_coda_alla_benzina_per_auto_A) + length(tempo_di_arrivo_in_coda_alla_benzina_per_auto_B))*(clock-clock_precedente);
        clock_precedente = clock;

    %% servizio benzinaio

    if tempo_servizio_1_A < min([tempo_arrivo_A,tempo_arrivo_B, tempo_servizio_1_B, tempo_servizio_2_A, tempo_servizio_2_B, tempo_cassa]) % 1° evento si libera la pompa 1 A
       
        clock = tempo_servizio_1_A;
        tempo_di_arrivo_coda_alla_cassa_da_1_A(1) = clock; % il cliente al questo tempo arriva in coda alla cassa
        tempo_servizio_1_A = inf;

    end
    if tempo_servizio_1_B < min([tempo_arrivo_A,tempo_arrivo_B, tempo_servizio_1_A, tempo_servizio_2_A, tempo_servizio_2_B, tempo_cassa]) % 1° evento si libera la pompa 1 B
       
        clock = tempo_servizio_1_B;
        tempo_di_arrivo_coda_alla_cassa_da_1_B(1) = clock; % il cliente al questo tempo arriva in coda alla cassa
        tempo_servizio_1_B = inf;
        
    end
    if tempo_servizio_2_A < min([tempo_arrivo_A,tempo_arrivo_B, tempo_servizio_1_B, tempo_servizio_1_A, tempo_servizio_2_B, tempo_cassa]) % 1° evento si libera la pompa 2 A
       
        clock = tempo_servizio_2_A;
        tempo_di_arrivo_coda_alla_cassa_da_2_A(1) = clock; % il cliente al questo tempo arriva in coda alla cassa
        tempo_servizio_2_A = inf;
        
    end
    if tempo_servizio_2_B < min([tempo_arrivo_A,tempo_arrivo_B, tempo_servizio_1_B, tempo_servizio_2_A, tempo_servizio_1_A, tempo_cassa]) % 1° evento si libera la pompa 2 B
       
        clock = tempo_servizio_2_B;
        tempo_di_arrivo_coda_alla_cassa_da_2_B(1) = clock; % il cliente al questo tempo arriva in coda alla cassa
        tempo_servizio_2_B = inf;
        
    end

    %% servizio cassa

    % se c'è qualcuno in coda, simulo i tempi di servizio 

    if length(tempo_di_arrivo_coda_alla_cassa_da_1_A) ~= 0 || length(tempo_di_arrivo_coda_alla_cassa_da_1_B) ~= 0 || length(tempo_di_arrivo_coda_alla_cassa_da_2_A) ~= 0 || length(tempo_di_arrivo_coda_alla_cassa_da_2_B) ~= 0
        tempo_cassa = clock + unifrnd(min_cassiere,max_cassiere);
    end

    % servo il cliente

    if tempo_cassa < min([tempo_arrivo_B,tempo_servizio_1_A, tempo_servizio_1_B, tempo_servizio_2_A, tempo_servizio_2_B, tempo_arrivo_A]) % 1° evento servizio cassa
        
        % servo il cliente che è arrivato prima 

        if length(tempo_di_arrivo_coda_alla_cassa_da_1_A) ~= 0
            [min_1_A, idx_min_1_A] = min(tempo_di_arrivo_coda_alla_cassa_da_1_A);
        else 
            min_1_A = inf;
        end

        if length(tempo_di_arrivo_coda_alla_cassa_da_1_B) ~= 0
            [min_1_B, idx_min_1_B] = min(tempo_di_arrivo_coda_alla_cassa_da_1_B);
        else 
            min_1_B = inf;
        end

        if length(tempo_di_arrivo_coda_alla_cassa_da_2_A) ~= 0
            [min_2_A, idx_min_2_A] = min(tempo_di_arrivo_coda_alla_cassa_da_2_A);
        else
            min_2_A = inf;
        end

        if length(tempo_di_arrivo_coda_alla_cassa_da_2_B) ~= 0
            [min_2_B, idx_min_2_B] = min(tempo_di_arrivo_coda_alla_cassa_da_2_B);
        else
            min_2_B = inf;
        end

        if min_1_A < min([min_1_B, min_2_B, min_2_A])
            pompa_1_A = true;
            tempo_di_arrivo_coda_alla_cassa_da_1_A(idx_min_1_A) = [];
        end

        if min_1_B < min([min_1_A, min_2_B, min_2_A])
            pompa_1_B = true;
            tempo_di_arrivo_coda_alla_cassa_da_1_B(idx_min_1_B) = [];
        end

        if min_2_A < min([min_1_B, min_2_B, min_1_A])
            pompa_2_A = true;
            tempo_di_arrivo_coda_alla_cassa_da_2_A(idx_min_2_A) = [];
        end

        if min_2_B < min([min_1_B, min_1_A, min_2_A])
            pompa_2_B = true;
            tempo_di_arrivo_coda_alla_cassa_da_2_B(idx_min_2_B) = [];
        end

        toServe = toServe+1;
    end

    %% nuovo arrivo macchina

    if length(tempo_di_arrivo_in_coda_alla_benzina_per_auto_A) + length(tempo_di_arrivo_in_coda_alla_benzina_per_auto_B) < Numero_max_persone_in_coda_al_benzinaio
        tempo_arrivo_A = clock + exprnd(1/rate_A);
        tempo_arrivo_B = clock + exprnd(1/rate_B);
    else
        lost = lost + 1;
    end

end

lunghezza_coda/clock
lost 