

% prova per la funzione di BFS


M = [0, 1, 0, 0, 0, 0;
     0, 0, 1, 0, 0, 0;
     0, 0, 0, 0.3, 0.7, 0;
     0, 0, 0, 0, 0, 1;
     0, 0, 0, 0.1, 0, 0.9;
     0, 0, 0, 0, 0, 1];

start_node = 3;
addpath('funzioni')  % andare nel path delle funzioni
visitati = BreadthFirstSearch(M, start_node);
disp('Nodi visitati:');
disp(find(visitati));