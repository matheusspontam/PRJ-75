function [D] = DadosControle(D)
%-------------------------------------------------------------------------
% Fun��o DadosControle.m
% Defini��o dos dados de controle do m�ssil anti-UAV
% Entrada:
%   - D: estrutura com dados do m�ssil
% Sa�da:
%   - D: estrutura com dados do m�ssil, com dados de
%        controle inclu�dos
%-------------------------------------------------------------------------

% Constantes
cte_grav = 9.8;
D2R = pi/180;
R2D = 180/pi;

% Dados do Autopiloto
D.Dlt_max = 20*D2R;         % Deflex�o m�xima do comando de pitch/yaw (subido p/ alvo 5g)
D.Dlt_max_roll = 0;         % Deflex�o m�xima do comando de rolamento
D.sat_integAP = inf;        % Saturador anti-windup do autopiloto
D.Ke_Ap_ac = 1;             % Sobre-ganho da malha externa de acelera��o
D.Ki_Ap_ac = 1;             % Sobre-ganho da malha interna de acelera��o
D.Ke_Ap_at = 1;             % Sobre-ganho da malha externa de atitude
D.Ki_Ap_at = 1;             % Sobre-ganho da malha interna de atitude

