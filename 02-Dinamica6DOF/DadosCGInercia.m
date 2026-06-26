function [D] = Dados_CG_Inercia(D)
%-----------------------------------------------------
% Função Dados_CG_Inercia.m
% Definição dos dados de CG e Inércia do míssil anti-UAV
% Entrada:
%   - D: estrutura com dados do míssil
% Saída:
%   - D: estrutura com dados do míssil, com dados de
%        CG e Inércia incluídos
%-----------------------------------------------------

% Míssil
D.R = D.DRef/2;               % (m) Raio do Míssil

% Subsistemas

% Controle: Autodiretor, atuador, espoleta, computador de bordo
L_Cont = 0.90;              % (m) Comprimento da seção de controle
m_Cont = 17.7;              % (kg) Massa da seção de controle

% Cabeça de Guerra
L_CDG = 0.14;               % (m) Comprimento da cabeça de guerra
m_CDG = 7.8;                % (kg) Massa da cabeça de guerra

% Propulsão:

% Booster
L_Booster = 0.37;           % (m) Comprimento do Booster
LpropB = L_Booster;         % (m) Comprimento do propelente do Booster
Mf_Booster = 3;             % (kg) Massa do Booster sem propelente
m_prop0B = 6.7;             % (kg) Massa de propelente do Booster
m_MOTB = Mf_Booster + m_prop0B;

% Sustainer
L_Sustainer = 0.46;         % (m) Comprimento do Sustainer
LpropS = L_Sustainer;       % (m) Comprimento do propelente do Sustainer
Mf_Sustainer = 4;           % (kg) Massa do Sustainer sem propelente
m_prop0S = 11.6;            % (kg) Massa de propelente do Sustainer
m_MOTS = Mf_Sustainer + m_prop0S;

% Tubeira
L_Tub = 0.12;               % (m) Comprimento da Tubeira
M_Tub = 0.2;                  % (kg) Massa da Tubeira

L_MOT = L_Booster + L_Sustainer + L_Tub;       % (m) Comprimento do Propulsor
D.m_prop0 = m_prop0B + m_prop0S;               % massa inicial de propelente 

D.m = m_Cont + m_CDG + m_MOTB + m_MOTS;   % (kg) Massa do míssil cheio
L_missil = L_Cont + L_CDG + L_MOT;        % (m) Comprimento do míssil

D.mf = D.m - D.m_prop0;         % (kg) Massa após a queima

% Cálculo do CG inicial
xcg_Cont = -(L_Cont/2);
xcg_CDG  = -(L_Cont + L_CDG/2);
xcg_MOTS = -(L_Cont + L_CDG + L_Sustainer/2);
xcg_MOTB = -(L_Cont + L_CDG + L_Sustainer + L_Booster/2);
xcg_Tub  = -(L_Cont + L_CDG + L_Sustainer + L_Booster + L_Tub/2);

D.xcg0 = (xcg_Cont*m_Cont + xcg_CDG*m_CDG + xcg_MOTB*m_MOTB + ...
          xcg_MOTS*m_MOTS)/D.m;
D.ycg0 = 0;
D.zcg0 = 0;

% Cálculo do CG no meio da queima do Booster
D.xcgBm = (xcg_Cont*m_Cont + xcg_CDG*m_CDG + ...
           xcg_MOTB*(m_MOTB-m_prop0B/2) + ...
           xcg_MOTS*m_MOTS)/(D.m-m_prop0B/2);

% Cálculo do CG no final da queima do Booster
D.xcgBf = (xcg_Cont*m_Cont + xcg_CDG*m_CDG + ...
           xcg_MOTB*(m_MOTB-m_prop0B) + ...
           xcg_MOTS*m_MOTS)/(D.m-m_prop0B);

% Cálculo do CG no meio da queima do Sustainer
D.xcgSm = (xcg_Cont*m_Cont + xcg_CDG*m_CDG + ...
           xcg_MOTB*(m_MOTB-m_prop0B) + xcg_MOTS*(m_MOTS-m_prop0S) + ...
          (xcg_MOTS+L_Sustainer/4)*m_prop0S/2)/(D.m-m_prop0B-m_prop0S/2);

% Cálculo do CG no final da queima do Sustainer
D.xcgf = (xcg_Cont*m_Cont + xcg_CDG*m_CDG + ...
          xcg_MOTB*(m_MOTB-m_prop0B) + xcg_MOTS*(m_MOTS-m_prop0S))/D.mf;
    
D.ycgf = 0;
D.zcgf = 0;
    
% Centro de Referência de Momentos
D.CRM = [-0.92  0   0]';

% Cálculo das matrizes de inércia Ixx
D.Ix0 = D.m*D.R^2/2;                        % Inércia Ixx0 (kg.m2) - inicial
D.IxBm = (D.m-m_prop0B/2)*D.R^2/2;          % Meio da queima do booster
D.IxBf = (D.m-m_prop0B)*D.R^2/2;            % Fim da queima do booster
D.IxSm = (D.m-m_prop0B-m_prop0S/2)*D.R^2/2; % Meio da queima do sustainer
D.Ixf = D.mf*D.R^2/2;                       % Inércia Ixxf (kg.m2) - final

% Cálculo de Iyy de cada subsistema em relação ao CG inicial
Iy0_Cont  = (D.R^2/4 + L_Cont^2/12 + (D.xcg0 - xcg_Cont)^2)*m_Cont;  
Iy0_CDG = (D.R^2/4 + L_CDG^2/12 + (D.xcg0 - xcg_CDG)^2)*m_CDG;  
Iy0_MOTB = (D.R^2/4 + LpropB^2/12 + (D.xcg0 - xcg_MOTB)^2)*m_MOTB;
Iy0_MOTS = (D.R^2/4 + LpropS^2/12 + (D.xcg0 - xcg_MOTS)^2)*m_MOTS;
D.Iy0 = Iy0_Cont + Iy0_CDG + Iy0_MOTB + Iy0_MOTS;

% Cálculo de Iyy de cada subsistema em relação ao CG no meio da queima do
% Booster
IyBm_Cont  = (D.R^2/4 + L_Cont^2/12 + (D.xcgBm - xcg_Cont)^2)*m_Cont;  
IyBm_CDG = (D.R^2/4 + L_CDG^2/12 + (D.xcgBm - xcg_CDG)^2)*m_CDG;  
IyBm_MOTB = (D.R^2/4 + LpropB^2/12 + (D.xcgBm - xcg_MOTB)^2)*(m_MOTB-m_prop0B/2);
IyBm_MOTS = (D.R^2/4 + LpropS^2/12 + (D.xcgBm - xcg_MOTS)^2)*m_MOTS;
D.IyBm = IyBm_Cont + IyBm_CDG + IyBm_MOTB + IyBm_MOTS;

% Cálculo de Iyy de cada subsistema em relação ao CG no final da queima do
% Booster
IyBf_Cont  = (D.R^2/4 + L_Cont^2/12 + (D.xcgBf - xcg_Cont)^2)*m_Cont;  
IyBf_CDG = (D.R^2/4 + L_CDG^2/12 + (D.xcgBf - xcg_CDG)^2)*m_CDG;  
IyBf_MOTB = (D.R^2/4 + LpropB^2/12 + (D.xcgBf - xcg_MOTB)^2)*(m_MOTB-m_prop0B);
IyBf_MOTS = (D.R^2/4 + LpropS^2/12 + (D.xcgBf - xcg_MOTS)^2)*m_MOTS;
D.IyBf = IyBf_Cont + IyBf_CDG + IyBf_MOTB + IyBf_MOTS;

% Cálculo de Iyy de cada subsistema em relação ao CG no meio da queima do
% Sustainer
IySm_Cont  = (D.R^2/4 + L_Cont^2/12 + (D.xcgSm - xcg_Cont)^2)*m_Cont;  
IySm_CDG = (D.R^2/4 + L_CDG^2/12 + (D.xcgSm - xcg_CDG)^2)*m_CDG;  
IySm_MOTB = (D.R^2/4 + LpropB^2/12 + (D.xcgSm - xcg_MOTB)^2)*(m_MOTB-m_prop0B);
IySm_MOTS = (D.R^2/4 + LpropS^2/12 + (D.xcgSm - xcg_MOTS)^2)*(m_MOTS-m_prop0S) + (D.R^2/4 + (LpropS/2)^2/12 + (D.xcgSm - (xcg_MOTS+LpropS/4))^2)*m_prop0S/2; 
D.IySm = IySm_Cont + IySm_CDG + IySm_MOTB + IySm_MOTS;

% Cálculo de Iyy de cada subsistema em relação ao CG no final da queima do
% Sustainer
Iyf_Cont  = (D.R^2/4 + L_Cont^2/12 + (D.xcgf - xcg_Cont)^2)*m_Cont;  
Iyf_CDG = (D.R^2/4 + L_CDG^2/12 + (D.xcgf - xcg_CDG)^2)*m_CDG;  
Iyf_MOTB = (D.R^2/4 + LpropB^2/12 + (D.xcgf - xcg_MOTB)^2)*(m_MOTB - m_prop0B);
Iyf_MOTS = (D.R^2/4 + LpropS^2/12 + (D.xcgf - xcg_MOTS)^2)*(m_MOTS - m_prop0S);
D.Iyf = Iyf_Cont + Iyf_CDG + Iyf_MOTB + Iyf_MOTS;

% Inércia inicial
D.I0 = [D.Ix0  0       0; ...
          0    D.Iy0   0; ...
          0    0      D.Iy0];

% Inércia no meio da queima do booster      
D.IBm = [D.IxBm  0       0; ...
          0    D.IyBm   0; ...
          0    0      D.IyBm];
            
% Inércia no final da queima do booster
D.IBf = [D.IxBf  0       0; ...
          0    D.IyBf   0; ...
          0    0      D.IyBf];

% Inércia no meio da queima do sustainer      
D.ISm = [D.IxSm  0       0; ...
          0    D.IySm   0; ...
          0    0      D.IySm];

% Inércia final      
D.If = [D.Ixf  0       0; ...
          0    D.Iyf   0; ...
          0    0      D.Iyf];      

    %   t                  Ixx         Iyy=Izz     
D.IMissil = ...
    [ 0                    D.Ix0        D.Iy0
      D.TqB/2              D.IxBm       D.IyBm
      D.TqB                D.IxBf       D.IyBf
      D.TqB + D.TqS/2      D.IxSm       D.IySm
      D.TqB + D.TqS        D.Ixf        D.Iyf];

    %   t                  xCG          yCG      zCG
D.CGMissil = ...
    [ 0                    D.xcg0       0       0
      D.TqB/2              D.xcgBm      0       0
      D.TqB                D.xcgBf      0       0
      D.TqB + D.TqS/2      D.xcgSm      0       0
      D.TqB + D.TqS        D.xcgf       0       0];  
  
end