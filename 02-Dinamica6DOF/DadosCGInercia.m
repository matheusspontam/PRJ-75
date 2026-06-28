function [D] = DadosCGInercia(D)
%-----------------------------------------------------
% DadosCGInercia.m
% CG e inercia do missil anti-navio MANSUP (equivalente Exocet MM40).
% Layout por secoes (ver dimensionamento_exocet.m), nariz -> cauda:
%   Cont (guiamento) | CDG (cabeca de guerra) | Sustainer | Booster | Tubeira
% Referencia de x: ponta do nariz (x=0), POSITIVO para a frente
% (todas as posicoes abaixo sao negativas, medidas para tras).
%-----------------------------------------------------

D.R = D.DRef/2;               % (m) raio do missil

%% SUBSISTEMAS (comprimentos e massas - dimensionamento_exocet.m)
% Distribuicao nose-heavy: massa concentrada a frente para dar margem
% estatica no lancamento (xcg0 ~ -2.60 m, ~1.2 calibre). CG traseiro
% deixa o trim na borda da tabela aerodinamica (ver PlotGMax).
% Secao de guiamento/controle (radome, seeker, eletronica, bateria, estrutura)
L_Cont = 1.18;   m_Cont = 230;

% Cabeca de guerra
L_CDG  = 0.90;   m_CDG  = 165;

% Sustainer (grao end-burner; queima por ultimo)
L_Sustainer  = 2.30;   Mf_Sustainer = 65;    m_prop0S = D.MpS;
LpropS = L_Sustainer;  m_MOTS = Mf_Sustainer + m_prop0S;

% Booster (grao estrela; mais traseiro, queima primeiro)
L_Booster  = 1.21;     Mf_Booster = 39;       m_prop0B = D.MpB;
LpropB = L_Booster;    m_MOTB = Mf_Booster + m_prop0B;

% Tubeira
L_Tub  = 0.20;   M_Tub = 15.4;

L_missil   = L_Cont + L_CDG + L_Sustainer + L_Booster + L_Tub;
D.L        = L_missil;
D.m_prop0  = m_prop0B + m_prop0S;
D.m  = m_Cont + m_CDG + m_MOTB + m_MOTS + M_Tub;   % massa cheia (= M0)
D.mf = D.m - D.m_prop0;                            % massa vazia

%% POSICOES DO CG DE CADA SUBSISTEMA (negativas, do nariz para tras)
xcg_Cont = -(L_Cont/2);
xcg_CDG  = -(L_Cont + L_CDG/2);
xcg_MOTS = -(L_Cont + L_CDG + L_Sustainer/2);
xcg_MOTB = -(L_Cont + L_CDG + L_Sustainer + L_Booster/2);
xcg_Tub  = -(L_Cont + L_CDG + L_Sustainer + L_Booster + L_Tub/2);

% CG inicial (lancamento)
D.xcg0 = (xcg_Cont*m_Cont + xcg_CDG*m_CDG + xcg_MOTB*m_MOTB + ...
          xcg_MOTS*m_MOTS + xcg_Tub*M_Tub)/D.m;
D.ycg0 = 0;
D.zcg0 = 0;

% CG no meio da queima do booster
D.xcgBm = (xcg_Cont*m_Cont + xcg_CDG*m_CDG + xcg_MOTB*(m_MOTB-m_prop0B/2) + ...
           xcg_MOTS*m_MOTS + xcg_Tub*M_Tub)/(D.m-m_prop0B/2);

% CG no fim da queima do booster
D.xcgBf = (xcg_Cont*m_Cont + xcg_CDG*m_CDG + xcg_MOTB*(m_MOTB-m_prop0B) + ...
           xcg_MOTS*m_MOTS + xcg_Tub*M_Tub)/(D.m-m_prop0B);

% CG no meio da queima do sustainer (booster ja consumido)
D.xcgSm = (xcg_Cont*m_Cont + xcg_CDG*m_CDG + xcg_MOTB*(m_MOTB-m_prop0B) + ...
           xcg_MOTS*(m_MOTS-m_prop0S/2) + xcg_Tub*M_Tub)/(D.m-m_prop0B-m_prop0S/2);

% CG no fim da queima do sustainer (vazio)
D.xcgf = (xcg_Cont*m_Cont + xcg_CDG*m_CDG + xcg_MOTB*(m_MOTB-m_prop0B) + ...
          xcg_MOTS*(m_MOTS-m_prop0S) + xcg_Tub*M_Tub)/D.mf;
D.ycgf = 0;
D.zcgf = 0;

% Centro de referencia de momentos = CG de lancamento.
% Rodar o DATCOM com XCG = -D.xcg0 (ver valor impresso por dimensionamento_exocet.m).
D.CRM = [D.xcg0  0  0]';

%% INERCIA Ixx (cilindro macico)
D.Ix0  = D.m*D.R^2/2;
D.IxBm = (D.m-m_prop0B/2)*D.R^2/2;
D.IxBf = (D.m-m_prop0B)*D.R^2/2;
D.IxSm = (D.m-m_prop0B-m_prop0S/2)*D.R^2/2;
D.Ixf  = D.mf*D.R^2/2;

%% INERCIA Iyy=Izz (cilindros + Steiner em torno do CG de cada estado)
% Inicial
Iy0_Cont = (D.R^2/4 + L_Cont^2/12 + (D.xcg0 - xcg_Cont)^2)*m_Cont;
Iy0_CDG  = (D.R^2/4 + L_CDG^2/12  + (D.xcg0 - xcg_CDG)^2)*m_CDG;
Iy0_MOTB = (D.R^2/4 + LpropB^2/12 + (D.xcg0 - xcg_MOTB)^2)*m_MOTB;
Iy0_MOTS = (D.R^2/4 + LpropS^2/12 + (D.xcg0 - xcg_MOTS)^2)*m_MOTS;
Iy0_Tub  = (D.R^2/4 + L_Tub^2/12  + (D.xcg0 - xcg_Tub)^2)*M_Tub;
D.Iy0 = Iy0_Cont + Iy0_CDG + Iy0_MOTB + Iy0_MOTS + Iy0_Tub;

% Meio da queima do booster
IyBm_Cont = (D.R^2/4 + L_Cont^2/12 + (D.xcgBm - xcg_Cont)^2)*m_Cont;
IyBm_CDG  = (D.R^2/4 + L_CDG^2/12  + (D.xcgBm - xcg_CDG)^2)*m_CDG;
IyBm_MOTB = (D.R^2/4 + LpropB^2/12 + (D.xcgBm - xcg_MOTB)^2)*(m_MOTB-m_prop0B/2);
IyBm_MOTS = (D.R^2/4 + LpropS^2/12 + (D.xcgBm - xcg_MOTS)^2)*m_MOTS;
IyBm_Tub  = (D.R^2/4 + L_Tub^2/12  + (D.xcgBm - xcg_Tub)^2)*M_Tub;
D.IyBm = IyBm_Cont + IyBm_CDG + IyBm_MOTB + IyBm_MOTS + IyBm_Tub;

% Fim da queima do booster
IyBf_Cont = (D.R^2/4 + L_Cont^2/12 + (D.xcgBf - xcg_Cont)^2)*m_Cont;
IyBf_CDG  = (D.R^2/4 + L_CDG^2/12  + (D.xcgBf - xcg_CDG)^2)*m_CDG;
IyBf_MOTB = (D.R^2/4 + LpropB^2/12 + (D.xcgBf - xcg_MOTB)^2)*(m_MOTB-m_prop0B);
IyBf_MOTS = (D.R^2/4 + LpropS^2/12 + (D.xcgBf - xcg_MOTS)^2)*m_MOTS;
IyBf_Tub  = (D.R^2/4 + L_Tub^2/12  + (D.xcgBf - xcg_Tub)^2)*M_Tub;
D.IyBf = IyBf_Cont + IyBf_CDG + IyBf_MOTB + IyBf_MOTS + IyBf_Tub;

% Meio da queima do sustainer
IySm_Cont = (D.R^2/4 + L_Cont^2/12 + (D.xcgSm - xcg_Cont)^2)*m_Cont;
IySm_CDG  = (D.R^2/4 + L_CDG^2/12  + (D.xcgSm - xcg_CDG)^2)*m_CDG;
IySm_MOTB = (D.R^2/4 + LpropB^2/12 + (D.xcgSm - xcg_MOTB)^2)*(m_MOTB-m_prop0B);
IySm_MOTS = (D.R^2/4 + LpropS^2/12 + (D.xcgSm - xcg_MOTS)^2)*(m_MOTS-m_prop0S/2);
IySm_Tub  = (D.R^2/4 + L_Tub^2/12  + (D.xcgSm - xcg_Tub)^2)*M_Tub;
D.IySm = IySm_Cont + IySm_CDG + IySm_MOTB + IySm_MOTS + IySm_Tub;

% Fim da queima do sustainer (vazio)
Iyf_Cont = (D.R^2/4 + L_Cont^2/12 + (D.xcgf - xcg_Cont)^2)*m_Cont;
Iyf_CDG  = (D.R^2/4 + L_CDG^2/12  + (D.xcgf - xcg_CDG)^2)*m_CDG;
Iyf_MOTB = (D.R^2/4 + LpropB^2/12 + (D.xcgf - xcg_MOTB)^2)*(m_MOTB-m_prop0B);
Iyf_MOTS = (D.R^2/4 + LpropS^2/12 + (D.xcgf - xcg_MOTS)^2)*(m_MOTS-m_prop0S);
Iyf_Tub  = (D.R^2/4 + L_Tub^2/12  + (D.xcgf - xcg_Tub)^2)*M_Tub;
D.Iyf = Iyf_Cont + Iyf_CDG + Iyf_MOTB + Iyf_MOTS + Iyf_Tub;

%% MATRIZES DE INERCIA
D.I0  = [D.Ix0  0      0; 0 D.Iy0  0; 0 0 D.Iy0];
D.IBm = [D.IxBm 0      0; 0 D.IyBm 0; 0 0 D.IyBm];
D.IBf = [D.IxBf 0      0; 0 D.IyBf 0; 0 0 D.IyBf];
D.ISm = [D.IxSm 0      0; 0 D.IySm 0; 0 0 D.IySm];
D.If  = [D.Ixf  0      0; 0 D.Iyf  0; 0 0 D.Iyf];

%   t                  Ixx      Iyy=Izz
D.IMissil = ...
    [ 0                D.Ix0    D.Iy0
      D.TqB/2          D.IxBm   D.IyBm
      D.TqB            D.IxBf   D.IyBf
      D.TqB + D.TqS/2  D.IxSm   D.IySm
      D.TqB + D.TqS    D.Ixf    D.Iyf];

%   t                  xCG       yCG  zCG
D.CGMissil = ...
    [ 0                D.xcg0    0    0
      D.TqB/2          D.xcgBm   0    0
      D.TqB            D.xcgBf   0    0
      D.TqB + D.TqS/2  D.xcgSm   0    0
      D.TqB + D.TqS    D.xcgf    0    0];

end
