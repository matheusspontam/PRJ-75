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

% Carrega dados de autopiloto
D = DadosControle(D);
load autopiloto.mat

% Simulação

sim('GuiamentoControle.slx');

% Salva dados da simulação em S
SalvaDinamica6DOF;

if Bingo(length(Bingo)) == 1
    disp('Bingo');
end

if Stop_VMin(length(Stop_VMin)) == 1
    disp('Velocidade mínima');
end

if Stop_FugaAlvo(length(Stop_FugaAlvo)) == 1
    disp('Fuga do alvo');
end

if ImpactoSolo(length(ImpactoSolo)) == 1
    disp('Impacto com Solo');
end

plot6DOF(S);

