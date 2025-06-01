classdef LIFOQueue < AbstractQueue
    % Classe per la estione di code di tipo LIFO

    methods
        function enqueue(obj, elemento, clock)
            elemento.timestamp_coda = clock;
            obj.lista{end+1} = elemento;
        end

        function elemento = dequeue(obj)
            if isempty(obj.lista)
                error("La coda è vuota.");
            end

            % Estrae l’elemento con timestamp più recente
            timestamps = cellfun(@(x) x.timestamp_coda, obj.lista);
            [~, idx] = sort(timestamps);
            obj.lista = obj.lista(idx);
            elemento = obj.lista{end};
            obj.lista(end) = [];
        end

        % Metodo per svuotare la coda
        function clear_queue(obj)
            obj.lista = {};
        end
    end
end
