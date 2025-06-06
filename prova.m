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

matr_adiac = {
    0, 0.4, 0.6, 0, 0, 0;
    0, 0, 0, @(x) x.peso == 1, @(x) x.peso == 0, 0;
    0, 0, 0, 0, 0, 1;
    0.2, 0, 0, 0, 0, 0.8;
    0, 0, 0, 0, 0, 1;
    0, 0, 0, 0, 0, 1;
   };


n = size(matr_adiac, 1);


% Una distribuzione per ciascun nodo: solo il primo riceve arrivi esterni
distr_arrivo = cell(n,1);
distr_arrivo{1} = Exponential(20);  
distr_arrivo{2} = Exponential(60);
distr_arrivo{3} = -1;
distr_arrivo{4} = -1;
distr_arrivo{5} = Uniform(20,20,true);  
distr_arrivo{6} = -1;  

% Una matrice per ciascun nodo con distribuzioni di servizio per ciascun nodo (1 server per nodo)
distr_servizio = cell(n,1);
distr_servizio{1} = {Exponential(30)};  
distr_servizio{2} = {Exponential(2)};
distr_servizio{3} = {Exponential(18)};
distr_servizio{4} = {Exponential(1)};
distr_servizio{5} = {Uniform(5,20,false)};
distr_servizio{6} = {Uniform(inf, inf, false)};

% Una matrice per ciascun nodo con policy per cosa
policy = cell(n,1);
policy{1} = 'FIFO';
policy{2} = 'FIFO';
policy{3} = 'LIFO';
policy{4} = 'FIFO';
policy{5} = 'FIFO';
policy{6} = 'FIFO';

% Costruzione dell'oggetto Network
net = Network(matr_adiac, distr_arrivo, distr_servizio, policy);

% Inizializzo una simulazione
attributi_entita = [];
attributi_entita.peso =  {0, 1};
sim = Simulation(net, attributi_entita)
le = sim.run(100,true);
le1 = sim.run(100, true);
