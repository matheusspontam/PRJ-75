%-----------------------------------------------------
% Funcao CondLanc6DOF.m
% Definicao das condicoes de lancamento do missil antinavio (Exocet)
% Saida:
%   - C: Estrutura com condicoes de lancamento
%-----------------------------------------------------

function [C] = CondLanc6DOF


% Constantes

cte_grav = 9.8;
D2R = pi/180;

% Tempo de maximo de simulacao
% Voo ate ~62 km a ~Mach 0.9 (~300 m/s) leva ~210 s; folga ate 300 s.
C.Tfim = 300;
C.NPer = 1;


% Condicoes de lancamento (engajamento antinavio)

C.TLaser = 10;                  % (s) Instante em que o sensor e ligado

% Velocidade inicial do alvo (navio), expressa no Sistema Inercial (m/s)
C.Vxa0 = 0;
C.Vya0 = 0;
C.Vza0 = 0;

% Posicao inicial do alvo (navio), expressa no Sistema Inercial (m)
C.Xa0 = 60000;
C.Ya0 = 15000;
C.Za0 = 20;

% Posicao do missil no lancamento (m)
C.Xm0 = 0;
C.Ym0 = 0;
C.Zm0 = 10;

% Velocidade do missil no lancamento (m/s)
C.Vmx0 = 40;
C.Vmy0 = 0;
C.Vmz0 = 0;

% Angulos de Euler do missil no lancamento
C.Phim0  = 0*D2R;
C.Tetam0 = 10*D2R;
C.Psim0  = 0*D2R;

% Velocidades angulares do missil no lancamento
C.p0 = 0;
C.q0 = 0;
C.r0 = 0;

% Condicoes iniciais para voo pre-programado
% Rumo do alvo em relacao ao missil
C.Rumo0 = atan2((C.Ya0 - C.Ym0),(C.Xa0 - C.Xm0));

% Altitude de cruzeiro sea-skimming (m)
C.AltCruz = 30;

end
