function X = Sostituisci_uno(M)
    X = zeros(size(M,1),size(M,2));
    for i = 1:size(M,1)
        for j=1:size(M,2)
            elem = M{i,j};
            if isa(elem, 'function_handle')
                X(i, j) = 1;
            elseif isnumeric(elem) && elem > 0
                X(i, j) = 1;
            else
                X(i, j) = 0;
            end
        end
    end
end

