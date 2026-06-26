function [D] = DadosControle(D)
%-------------------------------------------------------------------------
% Função DadosControle.m
% Definição dos dados de controle do míssil anti-UAV
% Entrada:
%   - D: estrutura com dados do míssil
% Saída:
%   - D: estrutura com dados do míssil, com dados de
%        controle incluídos
%-------------------------------------------------------------------------

% Constantes
cte_grav = 9.8;
D2R = pi/180;
R2D = 180/pi;

% Dados do Autopiloto
D.Dlt_max = 10*D2R;         % Deflexão máxima do comando de pitch/yaw
D.Dlt_max_roll = 0;         % Deflexão máxima do comando de rolamento
D.sat_integAP = inf;        % Saturador anti-windup do autopiloto
D.Ke_Ap_ac = 1;             % Sobre-ganho da malha externa de aceleração
D.Ki_Ap_ac = 1;             % Sobre-ganho da malha interna de aceleração
D.Ke_Ap_at = 1;             % Sobre-ganho da malha externa de atitude
D.Ki_Ap_at = 1;             % Sobre-ganho da malha interna de atitude

