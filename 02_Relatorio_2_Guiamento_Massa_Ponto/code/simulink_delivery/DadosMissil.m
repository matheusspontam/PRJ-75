function D = DadosMissil
D2R = pi/180;
g = 9.8;

D.Mf = 354.4;
D.DRef = 0.35;
D.SRef = pi*D.DRef^2/4;

D.TqB = 3.45;
D.MpB = 126.4;
D.EmpB = 82200;
D.TqS = 223.8;
D.MpS = 383.5;
D.EmpS = 4750;

D.VProp = ...
    [0                    D.EmpB      (D.MpB + D.MpS)
     D.TqB                D.EmpB       D.MpS
     D.TqB + 0.001        D.EmpS       D.MpS
     D.TqB + D.TqS        D.EmpS       0
     D.TqB + D.TqS+0.001  0            0];

D.M0 = D.Mf + D.VProp(1,3);
D.Tfim = 320;

D.Cd = ...
    [0    0.82
     0.7  0.82
     0.9  1.08
     1.1  1.52
     1.2  1.49
     1.5  1.50
     1.8  1.50
     2.0  1.43
     2.5  1.38
     3.0  1.33
     3.5  1.33];

D.HRef = 10;
D.v_max_ref = 0.9;
D.AngSubMax = 20*D2R;
D.ErrCruz = 0.1;
D.KAlt = 0.1*D2R;
D.DAltSat = 400;
D.KAtit = 1.6*g/D2R;
D.KProp = 3.5;
D.KPreTurn = 1.5*g/D2R;
D.TTrav = 0.5;
D.VMin = 170;

D.qsi = 0.7;
D.wn = 0.5*2*pi;
D.AcelLatMax = 5*g;
D.ThetaADmax = 40*D2R;
D.OmegaADmax = 40*D2R;
D.RSatAD = 500;
D.REspoleta = 500;
end
