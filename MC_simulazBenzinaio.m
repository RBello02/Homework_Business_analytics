%% SIMULAZIONE BENZINAIO (tempi dati in minuti)
clear all
close all
clc


seed = 343310;
rng(seed);


function u = rnd(a,b, n1, n2)
    u = a + (b-a)*rand(n1,n2);
end

TIMEORIZON = 4*60;

% La coda per le pompe la gestisco come una struct: ogni cliente incodato ha 2 attributi
% (clock all'arrivo e lato preferenziale). La coda potrà avere una massima
% lunghezza fissata a priori.
max_len_codaP = 5;
codaP_clienti = [];

% Avrò poi una coda clienti che gestisco similarmente per l'accesso alla
% cassa. Attributi: riferimento alla pompa 
% ATTENZIONE: il primo cliente in coda è quello che sto servendo
codaC_clienti = [];
inServizio_C = false;

% Le 4 pompe sono gestite in due blocchi: le pompe sono poste in serie due a due.
% I tempi di servizio delle 4 pompe sono distribuiti uniformemente e mi
% salverà il clock di termine servizio in una matrice 2x2.
% Per gestire gli accessi alle 4 pompe definisco una mask che mi indica se la pompa 
% corrispondente è in servizio oppure no(1 = True, 0 = False): considero in serie le due 
% pompe sulla stesa riga
aP = 2;
bP = 7;
inServizio_P = zeros(2,2);

% La cassa ha un tempo di servizio uniformemente distribuito.
aC = 1;
bC = 3;

% Gli arrivi dei clienti alla coda per le pompe segue un processo di
% Poisson 
rate_arrivi = 3;

%% DEFINIZIONE DEGLI EVENTI FUTURI
% gestisco gli eventi futuri in un'unica struct matlab così me li porto in
% giro assieme (inizio a riempire i campi)
eventi_futuri.prox_arrivo_alle_pompe = exprnd(rate_arrivi);
eventi_futuri.fine_servizio_alle_pompe = Inf(2,2);
eventi_futuri.fine_servizio_alla_cassa = Inf;


%% INIZIALIZZAZIONE DELLE STATISTICHE RILEVANTI
num_clienti_che_non_si_incodano = 0;
lunghezza_media_della_coda = 0; 
lunghezza_della_coda_nel_tempo = [];

%% INIZIO SIMULAZIONE AD EVENTI DISCRETI

clock = min([eventi_futuri.prox_arrivo_alle_pompe, min(eventi_futuri.fine_servizio_alle_pompe, [], 'all'), eventi_futuri.fine_servizio_alla_cassa]);

while clock < TIMEORIZON

    % EVENTO FUTURO = PROX_ARRIVO_ALLA_POMPA
    if eventi_futuri.prox_arrivo_alle_pompe < min(eventi_futuri.fine_servizio_alle_pompe, [], 'all') && eventi_futuri.prox_arrivo_alle_pompe <  eventi_futuri.fine_servizio_alla_cassa

       len_coda_pre_arrivo = length(codaP_clienti);

       % incodo un cliente solo se ho posto in coda
       if len_coda_pre_arrivo >= max_len_codaP
            num_clienti_che_non_si_incodano = num_clienti_che_non_si_incodano +1;
       else
           codaP_clienti(len_coda_pre_arrivo + 1).clockArrivo = clock;
           codaP_clienti(len_coda_pre_arrivo + 1).preferenzaLato = randsample(2,1); % sample intero tra 1 e 2

           % aggiorno le statistiche relative alla coda
           if length(lunghezza_della_coda_nel_tempo) >= 1
               lunghezza_media_della_coda = lunghezza_media_della_coda + lunghezza_della_coda_nel_tempo(1, end)*(clock - lunghezza_della_coda_nel_tempo(2, end)); 
               new_val = lunghezza_della_coda_nel_tempo(1, end) +1;
               lunghezza_della_coda_nel_tempo(:, end+1) = [new_val; clock];
           else
               lunghezza_della_coda_nel_tempo(:, end+1) = [1; clock];
           end
       end % end if

        % aggiorno il relativo evento futuro
        eventi_futuri.prox_arrivo_alle_pompe = exprnd(rate_arrivi) + clock;


    % EVENTO FUTURO = FINE_SERVIZIO_ALLE_POMPE
    elseif min(eventi_futuri.fine_servizio_alle_pompe, [], 'all') < eventi_futuri.prox_arrivo_alle_pompe && min(eventi_futuri.fine_servizio_alle_pompe, [], 'all')  < eventi_futuri.fine_servizio_alla_cassa

        % individuo la pompa che ha terminato il servizio
        [m, id_pompa] = min(eventi_futuri.fine_servizio_alle_pompe, [], 'all');
        
        % incodo il cliente alla coda per la cassa
        len_coda_pre_arrivo = length(codaC_clienti);
        codaC_clienti(len_coda_pre_arrivo + 1).id_pompa = id_pompa;

        % non libero ancora la pompa (il cliente deve ancora pagare) ma le
        % assegno un evento futuro all'infinito
        new_matr = eventi_futuri.fine_servizio_alle_pompe;
        new_matr(id_pompa) = Inf;
        eventi_futuri.fine_servizio_alle_pompe = new_matr;

    % EVENTO FUTURO = FINE_SERVIZIO_ALLA_CASSA
    elseif  eventi_futuri.fine_servizio_alla_cassa < eventi_futuri.prox_arrivo_alle_pompe && eventi_futuri.fine_servizio_alla_cassa < min(eventi_futuri.fine_servizio_alle_pompe, [], 'all')
        
        % libero la pompa associata al cliente
        id_pompa = codaC_clienti.id_pompa;
        inServizio_P(id_pompa) = 0;

        % tolgo il cliente dalla coda della cassa
        codaC_clienti(1) = [];  
        inServizio_C = false;

        % aggiorno i relativi eventi futuri che ne conseguono
        eventi_futuri.fine_servizio_alla_cassa = Inf;

        new_matr = eventi_futuri.fine_servizio_alle_pompe;
        new_matr(id_pompa) = Inf;
        eventi_futuri.fine_servizio_alle_pompe = new_matr;

    end % end if sul tipo di eventi



    % GESTISCO L'ACCESO AL SERVIZIO DELLE POMPE (vedere assunzioni dettagliate sugli appunti)
    cond_gen = not(any(inServizio_P,1));  % questa condizione la uso per vedere se in uno dei due slot della prima
                                            % colonna compare uno 0 (ossia se ho una pompa libera accessibile dalla coda) 
    flag = true;
    num_serviti = 0;

    while length(codaP_clienti) >= 1 && cond_gen(1) && flag
        % Perché il while?
        % flag mi dice se l'ultimo cliente visto dal while è stato
        % soddisfatto
        flag = false;


        % guardo la preferenza del primo cliente in coda e se riesco a
        % farlo accedere ad una pompa (meglio se quella più lontano)
        pref = codaP_clienti(1).preferenzaLato;
        
        for id_col = size(inServizio_P,2):-1:1
           
            if not(inServizio_P(pref,id_col)) && sum(inServizio_P(pref, 1:id_col)) == 0
                % condizioni = la pompa è libera && tutte le pompe
                % precedenti lo sono (la macchina riesce a raggiungere la pompa)
                inServizio_P(pref,id_col) = 1;
    
                % aggiorno gli eventi futuri
                new_matr = eventi_futuri.fine_servizio_alle_pompe;
                new_matr(pref, id_col) = clock + rnd(aP, bP, 1, 1);
                eventi_futuri.fine_servizio_alle_pompe = new_matr;
    
                % tolgo il cliente dalla coda
                codaP_clienti(1) = [];

                % una volta assegnata la pompa la cliente non sto a
                % continuare il loop per cercargli una pompa
                flag = true;
                num_serviti = num_serviti + 1;
                break

            end

            % riverifico se la prima colonna di pompe è tutta occupata
            cond_gen = not(any(inServizio_P,1));

        end % end while

        % Se alla fine del for il cliente non è stato servito vuol dire che
        % la pompa libera stava dall'altro lato e gli toccherà aspettare
        % ancora.

    end % end if

    if num_serviti > 0
        % aggiorno le statistiche della coda
        % Perché non lo faccio ogni volta che servo un cliente? Sennò
        % chiudo un numero di rettangolini pari al numero di clienti che ho
        % servito, ma in realtà ne devo chiudere uno solo (se ho servito almeno un cliente).
        lunghezza_media_della_coda = lunghezza_media_della_coda + lunghezza_della_coda_nel_tempo(1, end)*(clock - lunghezza_della_coda_nel_tempo(2, end)); 
        new_val = lunghezza_della_coda_nel_tempo(1, end) - num_serviti;
        lunghezza_della_coda_nel_tempo(:, end+1) = [new_val; clock];
    end


    % GESTISCO L'ACCESO AL SERVIZIO DELLA CASSA
    if not(inServizio_C) && length(codaC_clienti) >= 1 
        eventi_futuri.fine_servizio_alla_cassa = clock + rnd(aC, bC, 1, 1);
        inServizio_C = true;
    end

    clock = min([eventi_futuri.prox_arrivo_alle_pompe, min(eventi_futuri.fine_servizio_alle_pompe, [], 'all'), eventi_futuri.fine_servizio_alla_cassa]);
end % end while

lunghezza_media_della_coda = lunghezza_media_della_coda/TIMEORIZON;

%% PLOT DELLA CODA NEL TEMPO

% Crea il plot
stairs(lunghezza_della_coda_nel_tempo(2,:), lunghezza_della_coda_nel_tempo(1,:), 'LineWidth', 2, 'DisplayName', 'L(t)');
yline(lunghezza_media_della_coda, 'm--', 'LineWidth', 2, 'DisplayName', 'Lunghezza media');
yline(max_len_codaP, 'r', 'LineWidth', 1.5, 'DisplayName', 'Capacità coda')
xlabel('Tempo (in min)');
ylabel('Lunghezza della coda');
ylim([0, (max_len_codaP +1)])
title('Lunghezza della coda nel tempo');
legend()
grid on;

fprintf('Lunghezza media della coda: %4.3f \n', lunghezza_media_della_coda);
fprintf('Persone che hanno rinunciato a mettersi in coda: %d \n', num_clienti_che_non_si_incodano);