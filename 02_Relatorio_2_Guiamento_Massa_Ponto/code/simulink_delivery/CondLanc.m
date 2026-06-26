function C = CondLanc(Plano, Dist_alvo, Ang_apres)
HORIZONTAL = 1;
cte_grav = 9.8;

C.Plano = Plano;
C.Dist_alvo = Dist_alvo;
C.Ang_apres = Ang_apres;
C.TLaser = 0;

C.X0Tgt = 0;
C.Z0Tgt = 0;
C.VxTgt = 0;
C.VzTgt = 0;
C.altvant = 10;
C.AltCruz = 10;
C.AltL = 10;

if C.Plano == HORIZONTAL
    C.Z0m = -C.Dist_alvo*sin(C.Ang_apres);
    C.X0m = -C.Dist_alvo*cos(C.Ang_apres);
    C.Gama0 = C.Ang_apres;
    C.g = 0;
else
    C.Z0Tgt = C.altvant;
    C.Z0m = C.AltL;
    C.X0m = -C.Dist_alvo;
    C.Gama0 = 0;
    C.g = cte_grav;
end

[C.VSom, C.Temp, C.PAtmos, C.Ro] = atmosisa(C.AltL);
C.MachL = 0.9;
C.V0 = C.MachL*C.VSom;

C.TerminalRange = inf;
C.CaseId = 0;
end
