%rng(1)

clear 
close all 
clc

%% provo a far funzionare la simulazione
addpath('lib')
addpath('lib\funzioni')  
addpath('lib\Sottoclassi_di_Distributions') 

% Matrice di adiacenza (3 nodi)
% Nodo 1 → Nodo 2 (con probabilità 1)
% Nodo 2 → Nodo 3 (con probabilità 1)
% Nodo 3 → Sink (rimane lì: loop su se stesso)

matrice_adiacenza = {
    0, @(ent) ent.prop == 0, 0, @(ent) ent.prop == 1;
    0, 0, @(ent) ent.prop == 0, 0;
    0, @(ent) ent.prop == 0, 0, @(ent) ent.prop == 1;
    0, 0, 0, 1;   
   };

n = size(matrice_adiacenza, 1);

% Una distribuzione di interarrivo per ciascun nodo: il -1 è un valore
% usato per dire che il corrispondente nodo non supporta arrivi esterni.
distr_InterArrivi = cell(n,1);
distr_InterArrivi{1} = Exponential(20);  
distr_InterArrivi{2} = -1;  
distr_InterArrivi{3} = -1; 
distr_InterArrivi{4} = -1; 

% Un cell array per ciascun nodo con distribuzioni di servizio per ciascun
% server del nodo.
distr_TempiServizio = cell(n,1);
distr_TempiServizio{1} = {Exponential(10)};  
distr_TempiServizio{2} = {Exponential(10)};
distr_TempiServizio{3} = {Exponential(10)};
distr_TempiServizio{4} = {Exponential(10)};


% Una cell array per definire la policy della coda di ciascun nodo.
policy = cell(n,1);
policy{1} = 'FIFO';
policy{2} = 'FIFO';
policy{3} = 'FIFO';
policy{4} = 'FIFO';


% Costruzione dell'oggetto Network
net = Network(matrice_adiacenza, distr_InterArrivi, distr_TempiServizio, policy);

% Inizializzo una simulazione
attributi_entita = [];
attributi_entita.peso =  {0, 1};
sim = Simulation(net, attributi_entita)
le = sim.run(100,true);
le1 = sim.run(100, true);
