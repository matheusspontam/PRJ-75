function [D] = DadosMissil
%-----------------------------------------------------
% DadosMissil.m
% Dados do missil anti-navio MANSUP equivalente ao Exocet MM40.
% Propulsao gerada por dimensionamento_exocet.m (booster estrela +
% sustainer end-burner). Ver DefMissil.mlx para a metodologia.
%-----------------------------------------------------

D2R = pi/180;
cte_grav = 9.8;

%% PARAMETROS PRINCIPAIS (alvo MM40: M0=875 kg, L=5.79 m)
D.DRef = 0.35;                 % (m)  diametro de referencia
D.SRef = pi*D.DRef^2/4;        % (m2) area de referencia
D.Mf   = 514.4;                % (kg) massa apos a queima (vazio)

%% PROPULSAO SOLIDA (dimensionamento_exocet.m)
% Booster - grao tipo estrela (acelera ate Mach 0.9 em ~4 s)
D.TqB  = 4.0;                  % (s) tempo de queima
D.MpB  = 125.3;               % (kg) massa de propelente
D.EmpB = 6.757e4;             % (N)  empuxo (~67.6 kN, ~7.9 g)

% Sustainer - grao end-burner (empuxo = arrasto de cruzeiro, 70 km)
D.TqS  = 228.6;               % (s) tempo de queima (= alcance/VCruz)
D.MpS  = 235.0;               % (kg) massa de propelente
D.EmpS = 2.319e3;             % (N)  empuxo (= arrasto de cruzeiro)

% Vetor de empuxo e massa de propelente remanescente:  [t  Empuxo  Mprop]
D.VProp = ...
    [ 0                          D.EmpB      (D.MpB + D.MpS)
      D.TqB                      D.EmpB       D.MpS
      D.TqB + 0.1                D.EmpS       D.MpS
      D.TqB + 0.1 + D.TqS        D.EmpS       0
      D.TqB + 0.1 + D.TqS + 0.1  0            0];

D.M0   = D.Mf + D.VProp(1,3);  % (kg) massa de lancamento (= 875)
D.Tfim = D.TqB + D.TqS + 10;   % (s)  tempo final de simulacao

%% CONTROLE (modelo 6DOF da apostila)
D.v_max_ref = 0.9;             % Mach de cruzeiro
D.HRef = 10;                   % (m) altitude rasante de cruzeiro

D.AngSubMax = 20*D2R;
D.ErrCruz   = 0.1;
D.KAlt      = 0.1*D2R;
D.DAltSat   = 400;

D.KAtit = 1.6*cte_grav/D2R;
D.KProp = 3.5;
D.TTrav = 0.5;
D.VMin  = 170;

D.qsi = 0.7;
D.wn  = 1*2*pi;
D.AcelLatMax = 5*cte_grav;

D.ThetaADmax = 40*pi/180;
D.OmegaADmax = 40*pi/180;
D.RSatAD = 500;
D.REspoleta = 4;

end
