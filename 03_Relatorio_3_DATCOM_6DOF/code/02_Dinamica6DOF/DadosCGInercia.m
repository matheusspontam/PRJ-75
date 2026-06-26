function [D] = DadosCGInercia(D)

D.R = D.DRef/2;

% Estimativa por secoes, a partir da figura interna do Exocet.
L_Cont = 0.70;      m_Cont = 70.0;
L_CDG = 0.95;       m_CDG = 165.0;
L_Booster = 0.80;   Mf_Booster = 45.0;  m_prop0B = D.MpB;
L_Sustainer = 3.14; Mf_Sustainer = 70.0; m_prop0S = D.MpS;
L_Tub = 0.20;       M_Tub = 15.0;

LpropB = L_Booster;
LpropS = L_Sustainer;
m_MOTB = Mf_Booster + m_prop0B;
m_MOTS = Mf_Sustainer + m_prop0S;

D.m_prop0 = m_prop0B + m_prop0S;
D.m = m_Cont + m_CDG + m_MOTB + m_MOTS + M_Tub;
D.mf = D.m - D.m_prop0;
D.L = L_Cont + L_CDG + L_Booster + L_Sustainer + L_Tub;

xcg_Cont = L_Cont/2;
xcg_CDG = L_Cont + L_CDG/2;
xcg_MOTB = L_Cont + L_CDG + L_Booster/2;
xcg_MOTS = L_Cont + L_CDG + L_Booster + L_Sustainer/2;
xcg_Tub = L_Cont + L_CDG + L_Booster + L_Sustainer + L_Tub/2;

D.xcg0 = (xcg_Cont*m_Cont + xcg_CDG*m_CDG + xcg_MOTB*m_MOTB + ...
          xcg_MOTS*m_MOTS + xcg_Tub*M_Tub)/D.m;
D.ycg0 = 0;
D.zcg0 = 0;

D.xcgBm = (xcg_Cont*m_Cont + xcg_CDG*m_CDG + ...
           xcg_MOTB*(m_MOTB-m_prop0B/2) + xcg_MOTS*m_MOTS + ...
           xcg_Tub*M_Tub)/(D.m-m_prop0B/2);

D.xcgBf = (xcg_Cont*m_Cont + xcg_CDG*m_CDG + ...
           xcg_MOTB*(m_MOTB-m_prop0B) + xcg_MOTS*m_MOTS + ...
           xcg_Tub*M_Tub)/(D.m-m_prop0B);

D.xcgSm = (xcg_Cont*m_Cont + xcg_CDG*m_CDG + ...
           xcg_MOTB*(m_MOTB-m_prop0B) + xcg_MOTS*(m_MOTS-m_prop0S/2) + ...
           xcg_Tub*M_Tub)/(D.m-m_prop0B-m_prop0S/2);

D.xcgf = (xcg_Cont*m_Cont + xcg_CDG*m_CDG + ...
          xcg_MOTB*(m_MOTB-m_prop0B) + xcg_MOTS*(m_MOTS-m_prop0S) + ...
          xcg_Tub*M_Tub)/D.mf;
D.ycgf = 0;
D.zcgf = 0;

% Mesmo XCG usado no DATCOM.
D.CRM = [2.700 0 0]';

D.Ix0 = D.m*D.R^2/2;
D.IxBm = (D.m-m_prop0B/2)*D.R^2/2;
D.IxBf = (D.m-m_prop0B)*D.R^2/2;
D.IxSm = (D.m-m_prop0B-m_prop0S/2)*D.R^2/2;
D.Ixf = D.mf*D.R^2/2;

Iy0_Cont = (D.R^2/4 + L_Cont^2/12 + (D.xcg0 - xcg_Cont)^2)*m_Cont;
Iy0_CDG = (D.R^2/4 + L_CDG^2/12 + (D.xcg0 - xcg_CDG)^2)*m_CDG;
Iy0_MOTB = (D.R^2/4 + LpropB^2/12 + (D.xcg0 - xcg_MOTB)^2)*m_MOTB;
Iy0_MOTS = (D.R^2/4 + LpropS^2/12 + (D.xcg0 - xcg_MOTS)^2)*m_MOTS;
Iy0_Tub = (D.R^2/4 + L_Tub^2/12 + (D.xcg0 - xcg_Tub)^2)*M_Tub;
D.Iy0 = Iy0_Cont + Iy0_CDG + Iy0_MOTB + Iy0_MOTS + Iy0_Tub;

IyBm_Cont = (D.R^2/4 + L_Cont^2/12 + (D.xcgBm - xcg_Cont)^2)*m_Cont;
IyBm_CDG = (D.R^2/4 + L_CDG^2/12 + (D.xcgBm - xcg_CDG)^2)*m_CDG;
IyBm_MOTB = (D.R^2/4 + LpropB^2/12 + (D.xcgBm - xcg_MOTB)^2)*(m_MOTB-m_prop0B/2);
IyBm_MOTS = (D.R^2/4 + LpropS^2/12 + (D.xcgBm - xcg_MOTS)^2)*m_MOTS;
IyBm_Tub = (D.R^2/4 + L_Tub^2/12 + (D.xcgBm - xcg_Tub)^2)*M_Tub;
D.IyBm = IyBm_Cont + IyBm_CDG + IyBm_MOTB + IyBm_MOTS + IyBm_Tub;

IyBf_Cont = (D.R^2/4 + L_Cont^2/12 + (D.xcgBf - xcg_Cont)^2)*m_Cont;
IyBf_CDG = (D.R^2/4 + L_CDG^2/12 + (D.xcgBf - xcg_CDG)^2)*m_CDG;
IyBf_MOTB = (D.R^2/4 + LpropB^2/12 + (D.xcgBf - xcg_MOTB)^2)*(m_MOTB-m_prop0B);
IyBf_MOTS = (D.R^2/4 + LpropS^2/12 + (D.xcgBf - xcg_MOTS)^2)*m_MOTS;
IyBf_Tub = (D.R^2/4 + L_Tub^2/12 + (D.xcgBf - xcg_Tub)^2)*M_Tub;
D.IyBf = IyBf_Cont + IyBf_CDG + IyBf_MOTB + IyBf_MOTS + IyBf_Tub;

IySm_Cont = (D.R^2/4 + L_Cont^2/12 + (D.xcgSm - xcg_Cont)^2)*m_Cont;
IySm_CDG = (D.R^2/4 + L_CDG^2/12 + (D.xcgSm - xcg_CDG)^2)*m_CDG;
IySm_MOTB = (D.R^2/4 + LpropB^2/12 + (D.xcgSm - xcg_MOTB)^2)*(m_MOTB-m_prop0B);
IySm_MOTS = (D.R^2/4 + LpropS^2/12 + (D.xcgSm - xcg_MOTS)^2)*(m_MOTS-m_prop0S/2);
IySm_Tub = (D.R^2/4 + L_Tub^2/12 + (D.xcgSm - xcg_Tub)^2)*M_Tub;
D.IySm = IySm_Cont + IySm_CDG + IySm_MOTB + IySm_MOTS + IySm_Tub;

Iyf_Cont = (D.R^2/4 + L_Cont^2/12 + (D.xcgf - xcg_Cont)^2)*m_Cont;
Iyf_CDG = (D.R^2/4 + L_CDG^2/12 + (D.xcgf - xcg_CDG)^2)*m_CDG;
Iyf_MOTB = (D.R^2/4 + LpropB^2/12 + (D.xcgf - xcg_MOTB)^2)*(m_MOTB-m_prop0B);
Iyf_MOTS = (D.R^2/4 + LpropS^2/12 + (D.xcgf - xcg_MOTS)^2)*(m_MOTS-m_prop0S);
Iyf_Tub = (D.R^2/4 + L_Tub^2/12 + (D.xcgf - xcg_Tub)^2)*M_Tub;
D.Iyf = Iyf_Cont + Iyf_CDG + Iyf_MOTB + Iyf_MOTS + Iyf_Tub;

D.I0 = [D.Ix0 0 0; 0 D.Iy0 0; 0 0 D.Iy0];
D.IBm = [D.IxBm 0 0; 0 D.IyBm 0; 0 0 D.IyBm];
D.IBf = [D.IxBf 0 0; 0 D.IyBf 0; 0 0 D.IyBf];
D.ISm = [D.IxSm 0 0; 0 D.IySm 0; 0 0 D.IySm];
D.If = [D.Ixf 0 0; 0 D.Iyf 0; 0 0 D.Iyf];

D.IMissil = ...
    [0                  D.Ix0   D.Iy0
     D.TqB/2            D.IxBm  D.IyBm
     D.TqB              D.IxBf  D.IyBf
     D.TqB + D.TqS/2    D.IxSm  D.IySm
     D.TqB + D.TqS      D.Ixf   D.Iyf];

D.CGMissil = ...
    [0                  D.xcg0   0 0
     D.TqB/2            D.xcgBm  0 0
     D.TqB              D.xcgBf  0 0
     D.TqB + D.TqS/2    D.xcgSm  0 0
     D.TqB + D.TqS      D.xcgf   0 0];

end
