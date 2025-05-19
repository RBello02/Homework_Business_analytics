%% provo a far funzionare la simulazione
addpath('funzioni')  
addpath('Sottoclassi_di_Distributions') 

% Matrice di adiacenza (3 nodi)
% Nodo 1 → Nodo 2 (con probabilità 1)
% Nodo 2 → Nodo 3 (con probabilità 1)
% Nodo 3 → Sink (rimane lì: loop su se stesso)

matr_adiac = {
    0, 1, 0;
    0, 0, 1;
    0, 0, 1;   % Nodo 3 è un sink: loop su se stesso
};

% Una distribuzione per ciascun nodo: solo il primo riceve arrivi esterni
distr_arrivo = cell(3,1);
distr_arrivo{1} = Exponential(1);  
distr_arrivo{2} = NaN;
distr_arrivo{3} = NaN;

% Una matrice 3x1 con distribuzioni di servizio per ciascun nodo (1 server per nodo)
distr_servizio = cell(3,1);
distr_servizio{1} = Exponential(2);  
distr_servizio{2} = Exponential(1.5);
distr_servizio{3} = Exponential(1);

% Costruzione dell'oggetto Network
net = Network(distr_arrivo, distr_servizio, matr_adiac);
disp(net.posizione_sink) 