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
C.Tfim = 8;

% Entradas de simulação
C.DeltaY = 1*D2R;
C.DeltaZ = 1*D2R;


% Condições de lançamento

C.TLaser = 0;                   % (s) Instante em que laser é ligado

% Velocidade inicial do Vant, expressa no Sistema Inercial (m/s)
C.Vxa0 = 200;                  
C.Vya0 = 0;
C.Vza0 = 0;

% Posição inicial do Vant, expressa no Sistema Inercial (m)
C.Xa0 = 2000;                   
C.Ya0 = 0;
C.Za0 = 1000;          

% Manobra do Vant
C.ng = 0/cte_grav;

% Posição do míssil no lançamento
C.Xm0 = 0;
C.Ym0 = 0;
C.Zm0 = 1000;

% Velocidade do míssil no lançamento
C.Vmx0 = 27;
C.Vmy0 = 0;
C.Vmz0 = 0;

% Ângulos de Euler do míssil no lançamento
C.Phim0  = 0*D2R;
C.Tetam0 = 0*D2R;
C.Psim0  = 0*D2R;

% Velocidades angulares do míssil no lançamento
C.p0 = 0;
C.q0 = 0;
C.r0 = 0;
             

end


