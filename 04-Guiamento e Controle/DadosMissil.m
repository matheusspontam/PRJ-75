%-----------------------------------------------------
% Função DadosMissil.m
% Definição dos dados do míssil anti-UAV
% Saída:
%   - D: estrutura com dados do míssil
%-----------------------------------------------------

function [D] = DadosMissil

D2R = pi/180;           % Constante graus -> rad
cte_grav = 9.8;         % Gravidade

%-----------------------------------------------------
%% PARÂMETROS DO MÍSSIL

D.Mf = 31.6;                    % (kg) massa do missil vazio

D.DRef = 0.147;                 % (m) Diametro do missil
D.SRef = pi*D.DRef^2/4;         % (m2) Area do missil

% PROPULSÃO
% Booster
D.TqB = 2.8;                  % (s) Tempo de queima
D.MpB = 6.7;                  % (kg)Massa de propelente
D.EmpB = 5330;                % (N) Empuxo

% Sustainer
D.TqS = 36.7;                 % (s) Tempo de queima do sustainer
D.MpS = 11.6;                 % (kg) Propelente do sustainer
D.EmpS = 649;                 % (N) Empuxo do sustainer

% Vetor de empuxo e massa de propelente
D.VProp = ...
    [ 0                          D.EmpB      (D.MpB + D.MpS)
      D.TqB                      D.EmpB       D.MpS
      D.TqB + 0.1                D.EmpS       D.MpS
      D.TqB + 0.1 + D.TqS        D.EmpS       0
      D.TqB + 0.1 + D.TqS+0.1    0            0];

D.M0 = D.Mf + D.VProp(1,3);

D.Tfim = D.TqB + D.TqS + 10;

%-----------------------------------------------------
%% CONTROLE

% Condição de projeto aerodinâmico
D.v_max_ref = 0.9;
D.HRef = 2000;

% Controle de altitude
D.AngSubMax = 20*D2R;         % (rad) Angulo de subida máximo
D.ErrCruz = 0.1;              % (m) Tolerancia na altitude de cruzeiro
D.KAlt = 0.1*D2R;             % (rad/m) Ganho do controle de altitude
D.DAltSat = 400;              % (m) Diferenca de altitude para saturacao do
                              % ang subida

% Controle de atitude                            
D.KAtit = 1.6*9.8/D2R;        % ( (m/s2)/(rad) ) Constante de atitude

% Navegação Proporcional
D.KProp = 3.5;                % Ganho Nav Proporcional

D.TTrav = 0.5;                % (s) Tempo de trava do comando

D.VMin = 10;                 % (m/s) velocidade mínima para voo controlado


% Airframe
D.qsi = 0.7;                          % Fator de amortecimento equivalente
D.wn = 1*2*pi;                        % Banda passante da célula

% Aceleração lateral máxima
D.AcelLatMax = 10*cte_grav;

% Ângulo máximo do AD
D.ThetaADmax = 40*pi/180;

% Velocidade angular máxima do AD
D.OmegaADmax = 20*pi/180;

% Distância de saturação do AD
D.RSatAD = 100;

% Raio de detecção da espoleta (m)
D.REspoleta = 4;

end

