function [D] = DadosMissil

D2R = pi/180;
cte_grav = 9.8;

% Dados principais do missil equivalente ao Exocet MM40 Block 2
D.Mf = 364.9;
D.DRef = 0.35;
D.SRef = pi*D.DRef^2/4;

% Propulsao solida estimada no dimensionamento preliminar
D.TqB = 3.45;
D.MpB = 126.4;
D.EmpB = 8.22e4;

D.TqS = 223.8;
D.MpS = 383.5;
D.EmpS = 4.75e3;

D.VProp = ...
    [ 0                          D.EmpB      (D.MpB + D.MpS)
      D.TqB                      D.EmpB       D.MpS
      D.TqB + 0.1                D.EmpS       D.MpS
      D.TqB + 0.1 + D.TqS        D.EmpS       0
      D.TqB + 0.1 + D.TqS + 0.1  0            0];

D.M0 = D.Mf + D.VProp(1,3);
D.Tfim = 2.8;

% Parametros de controle usados pelo modelo 6DOF da apostila
D.v_max_ref = 0.9;
D.HRef = 10;

D.AngSubMax = 20*D2R;
D.ErrCruz = 0.1;
D.KAlt = 0.1*D2R;
D.DAltSat = 400;

D.KAtit = 1.6*cte_grav/D2R;
D.KProp = 3.5;
D.TTrav = 0.5;
D.VMin = 170;

D.qsi = 0.7;
D.wn = 1*2*pi;
D.AcelLatMax = 5*cte_grav;

D.ThetaADmax = 40*pi/180;
D.OmegaADmax = 40*pi/180;
D.RSatAD = 500;
D.REspoleta = 4;

end
