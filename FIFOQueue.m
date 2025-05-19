classdef FIFOQueue < AbstractQueue
    % Classe per la gestione di code di tipo FIFO
    
    methods
        function enqueue(obj, elemento, clock)
            elemento.timestamp_coda = clock;
            obj.lista{end+1} = elemento;
        end

        function elemento = dequeue(obj)
            if isempty(obj.lista)
                error("La coda è vuota.");
            end

            % Estrae l’elemento con timestamp più vecchio
            timestamps = cellfun(@(x) x.timestamp_coda, obj.lista);
            [~, idx] = sort(timestamps);
            obj.lista = obj.lista(idx);
            elemento = obj.lista{1};
            obj.lista(1) = [];
        end
    end
end
