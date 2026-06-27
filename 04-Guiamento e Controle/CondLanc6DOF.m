%-----------------------------------------------------
% Função CondLanc6DOF.m
% Definição das condições de lançamento do míssil anti-UAV
% Saída:
%   - C: Estrutura com condições de lançamento
%-----------------------------------------------------

function [C] = CondLanc6DOF


% Constantes

cte_grav = 9.8;
D2R = pi/180;

% Tempo de máximo de simulação
C.Tfim = 300;
C.NPer = 1;


% Condições de lançamento

C.TLaser = 20;                   % (s) Instante em que laser é ligado

% Velocidade inicial do Vant, expressa no Sistema Inercial (m/s)
C.Vxa0 = 0;                  
C.Vya0 = 0;
C.Vza0 = 0;

% Posição inicial do Vant, expressa no Sistema Inercial (m)
C.Xa0 = 60000;                   
C.Ya0 = 10000;
C.Za0 = 20;          

% Posição do míssil no lançamento
C.Xm0 = 0;
C.Ym0 = 0;
C.Zm0 = 10;

% Velocidade do míssil no lançamento
C.Vmx0 = 40;
C.Vmy0 = 0;
C.Vmz0 = 0;

% Ângulos de Euler do míssil no lançamento
C.Phim0  = 45*D2R;
C.Tetam0 = 10*D2R;
C.Psim0  = 0*D2R;

% Velocidades angulares do míssil no lançamento
C.p0 = 0;
C.q0 = 0;
C.r0 = 0;
             
% Condições iniciais para voo pré-programado
% Rumo do alvo em relação o míssil
C.Rumo0 = atan2((C.Ya0 - C.Ym0),(C.Xa0 - C.Xm0));
C.AltCruz = 30;

end


