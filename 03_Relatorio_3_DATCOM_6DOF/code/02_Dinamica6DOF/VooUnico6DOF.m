addpath(fullfile(fileparts(mfilename('fullpath')), '..', '..', '..', '00_Comum'));  % fonte comum (00_Comum)
%-----------------------------------------------------
% Programa VooUnico6DOF.m
% Saída:
%   - S: estrutura com dados de simulação
%-----------------------------------------------------

clear all;

% Constantes
cte_grav = 9.8;
D2R = pi/180;
R2D = 180/pi;

% Define condições de lançamento
C = CondLanc6DOF;

% Carrega dados gerais (comuns ao Massa-Ponto)
D = DadosMissil;

% Carrega dados de CG e Inércia
D = DadosCGInercia(D);

% Carrega dados de aerodinâmica
load M_aed.mat;
D.Cmap = 0;

% Simulação

sim('Dinamica6DOF.slx');

% Salva dados da simulação em S
SalvaDinamica6DOF;

plot6DOF(S);

