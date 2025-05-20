%% provo a far funzionare la simulazione
addpath('funzioni')  
addpath('Sottoclassi_di_Distributions') 

% Matrice di adiacenza (3 nodi)
% Nodo 1 → Nodo 2 (con probabilità 1)
% Nodo 2 → Nodo 3 (con probabilità 1)
% Nodo 3 → Sink (rimane lì: loop su se stesso)

matr_adiac = {
    0, 1/4, 0, 3/4, 0;
    @(x) abs(x.peso - 1) < 1e-12, 0, @(x) abs(x.peso )<1e-12 , 0, 0;
    0, 0, 0, 1, 0;
    0, 0, 0, 0, 1;   
    0, 0, 0, 0, 1; % nodo 5 è un sink
};

n = size(matr_adiac, 1);


% Una distribuzione per ciascun nodo: solo il primo riceve arrivi esterni
distr_arrivo = cell(n,1);
distr_arrivo{1} = Exponential(1);  
distr_arrivo{2} = -1;
distr_arrivo{3} = -1;
distr_arrivo{4} = Uniform(4,4,true);  
distr_arrivo{5} = -1;  

% Una matrice per ciascun nodo con distribuzioni di servizio per ciascun nodo (1 server per nodo)
distr_servizio = cell(n,1);
distr_servizio{1} = Exponential(2);  
distr_servizio{2} = Exponential(1.5);
distr_servizio{3} = Exponential(1);
distr_servizio{4} = Exponential(1);
distr_servizio{5} = Uniform(inf, inf, false);

% Una matrice per ciascun nodo con policy per cosa
policy = cell(n,1);
policy{1} = 'FIFO';
policy{2} = 'FIFO';
policy{3} = 'FIFO';
policy{4} = 'FIFO';
policy{5} = 'FIFO';

% Costruzione dell'oggetto Network
net = Network(matr_adiac, distr_arrivo, distr_servizio, policy);

% Inizializzo una simulazione
attributi_entita = [];
attributi_entita.peso =  {0, 1};
sim = Simulation(net, attributi_entita)
le = sim.run(100)
