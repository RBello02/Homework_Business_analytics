classdef Costumer < handle
    % COSTUMER è la classe che rappresenta un cliente nel sistema. Ogni
    % istanza di questa classe raggruppa le informazioni relative ad un
    % singolo cliente.
    
    properties
        matrice_del_percorso
        istante_di_arrivo_glob % info globale
        istante_di_arrivo_nodo % info locale per il calcolo di una statistica per un certo nodo (ad ogni nodo si sovvrascrive)
        istante_di_partenza_nodo % info locale per il calcolo di una statistica per un certo nodo (ad ogni nodo si sovvrascrive)
        proprieta % info addizionali sotto forma di struct
    end
    
    methods

        % Costruttore
        function self = Costumer(matr, clock, prop)
            self.matrice_del_percorso = matr;
            self.istante_di_arrivo_glob = clock;
            self.proprieta = prop;
        end
        

        % aggiungere funzioni per la gestione delle statistiche??

    end %end methods
end

