function stampa_grafo(network)

% questa funzione si occupa della stampa del grafo della rete 

matrice_di_adiacenza = network.matrice_di_adiacenza;
posizione_function_handle = [];
for i = 1:size(matrice_di_adiacenza,1)
    for j = 1:size(matrice_di_adiacenza,2)
        if isa(matrice_di_adiacenza{i,j},'function_handle')
            posizione_function_handle(end+1,:) = [i,j];
        end
    end
end
posizione_sink = network.posizione_sink;
matrice_con_uni = Sostituisci_uno(matrice_di_adiacenza);
matrice_con_uni(posizione_sink,:)=zeros(size(matrice_di_adiacenza,1),1); % tolgo il self loop nel sink
posizione_generatori = [];

for i = 1:length(network.distribuzioni_arrivo)
    if  isa(network.distribuzioni_arrivo{i}, 'Distributions')
        posizione_generatori(end+1) = i;
    end
end

G = digraph(matrice_con_uni);   % crea il grafo

% Inizializza il colore di tutti i nodi
num_nodi = numnodes(G);
colore_nodi = repmat([0 0.4470 0.7410], num_nodi, 1); % blu standard

colore_nodi(posizione_sink,:) = [0,0,0]; %il sink è nero
for ind = 1:length(posizione_generatori)
    colore_nodi(posizione_generatori(ind),:) = [0.8500 0.3250 0.0980]; % rosso
end

% Disegna il grafo con i colori personalizzati
figure;
p = plot(G, 'NodeColor', colore_nodi, 'MarkerSize', 15, 'LineWidth', 1.5);
% Rimuovi le etichette di default (se presenti)
p.NodeLabel = [];

% Prendi le coordinate x e y dei nodi
x = p.XData;
y = p.YData;

% Scrivi il numero dentro al cerchio (posizione x,y)
for k = 1:numel(x)
    text(x(k), y(k), num2str(k), ...
        'HorizontalAlignment', 'center', ...
        'VerticalAlignment', 'middle', ...
        'FontWeight', 'bold', ...
        'FontSize', 10, ...
        'Color', 'w');  % colore bianco o nero a scelta
end
title('Graph');
p.HandleVisibility = 'off';  % <-- Nasconde questo oggetto dalla legenda

% Estrai archi: lista di coppie (source, target)
sorgenti = G.Edges.EndNodes(:,1);
destinazioni = G.Edges.EndNodes(:,2);

% Prepara cell array di etichette da mettere sugli archi
edgeLabels = cell(height(G.Edges), 1);

for k = 1:height(G.Edges)
    i = sorgenti(k);
    j = destinazioni(k);
    val = matrice_di_adiacenza{i,j};

    if isa(val, 'function_handle')
        % Converte il function handle in stringa
        fstr = regexprep(func2str(val), '^@\([a-zA-Z0-9_,]+\)', '');  
        edgeLabels{k} = fstr;
    elseif isnumeric(val)
        % Converti numero in stringa
        edgeLabels{k} = num2str(val);
    else
        % Se altro tipo (es. cella vuota, stringa, ecc)
        edgeLabels{k} = '';
    end
end

% Aggiungi le etichette agli archi nel plot
labeledge(p, sorgenti, destinazioni, edgeLabels);

% Trova l'indice di questi archi nel grafo
for k = 1:size(posizione_function_handle,1)
    s = posizione_function_handle(k,1);
    t = posizione_function_handle(k,2);
    idx_arco = findedge(G, s, t);  % trova indice dell'arco
    if idx_arco ~= 0
        highlight(p, s, t, 'EdgeColor', 'g', 'LineWidth', 2); % verde e più spesso
    end
end




%  legenda
hold on
scatter(nan, nan, 70, [0,0,0], 'filled', 'DisplayName', 'Sink');
scatter(nan, nan, 70, [0.8500 0.3250 0.0980], 'filled', 'DisplayName', 'Starting Nodes');
if ~isempty(posizione_function_handle)
    scatter(nan, nan, 70, [0 1 0], 'filled', 'DisplayName', 'Function Handle Arcs');
end
legend('Location', 'bestoutside');



end

