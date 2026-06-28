function [D] = DadosMissilComum
%-----------------------------------------------------
% DadosMissilComum.m  -- FONTE UNICA dos dados do missil
% Missil anti-navio MANSUP equivalente ao Exocet MM40.
% Editar o missil SO AQUI (forwarders nas pastas chamam esta funcao).
%-----------------------------------------------------
D2R = pi/180;
cte_grav = 9.8;

%% PARAMETROS PRINCIPAIS
D.DRef = 0.35;                 % (m)  diametro de referencia
D.SRef = pi*D.DRef^2/4;        % (m2) area de referencia
D.Mf   = 455.7;                % (kg) massa vazia (= secoes - propelente)

%% PROPULSAO (dimensionamento_exocet.m)
% Booster - grao estrela (acelera ate ~Mach 0.93 em ~4 s)
D.TqB  = 4.0;                  % (s)
D.MpB  = 125.3;               % (kg)
D.EmpB = 6.742e4;             % (N)  ~67.4 kN

% Sustainer - grao end-burner. Empuxo dimensionado para o ARRASTO DE
% CRUZEIRO COM SUSTENTACAO (trim, Cd~0.60), +margem, p/ NAO desacelerar.
D.TqS  = 228.6;               % (s)
D.MpS  = 336;                 % (kg)
D.EmpS = 3.316e3;             % (N)  ~3.32 kN (= arrasto de cruzeiro c/ trim + margem)

% Vetor de empuxo e massa de propelente:  [t  Empuxo  Mprop]
D.VProp = ...
    [ 0                          D.EmpB      (D.MpB + D.MpS)
      D.TqB                      D.EmpB       D.MpS
      D.TqB + 0.1                D.EmpS       D.MpS
      D.TqB + 0.1 + D.TqS        D.EmpS       0
      D.TqB + 0.1 + D.TqS + 0.1  0            0];

D.M0   = D.Mf + D.VProp(1,3);  % (kg) massa de lancamento (~917)
D.Tfim = D.TqB + D.TqS + 10;

%% CONTROLE / GUIAMENTO
D.v_max_ref = 0.9;             % Mach de cruzeiro
D.HRef = 10;                   % (m) referencia rasante

D.AngSubMax = 20*D2R;
D.ErrCruz   = 0.1;
D.KAlt      = 1*D2R;           % ganho controle de altitude (tunado ~1, prof)
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
D.REspoleta = 20;             % (m) raio de detonacao da espoleta (prof)

end
