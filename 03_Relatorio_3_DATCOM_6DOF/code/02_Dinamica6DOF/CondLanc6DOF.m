function [C] = CondLanc6DOF

D2R = pi/180;

C.Tfim = 2.8;

% Degrau de comando nas superficies para avaliar alfa x delta.
C.DeltaY = 2*D2R;
C.DeltaZ = 0*D2R;

C.TLaser = 0;

% Alvo parado a frente, mantido apenas para compatibilidade do modelo.
C.Vxa0 = 0;
C.Vya0 = 0;
C.Vza0 = 0;
C.Xa0 = 70000;
C.Ya0 = 0;
C.Za0 = 1000;
C.ng = 0;

C.Xm0 = 0;
C.Ym0 = 0;
C.Zm0 = 1000;

% Voo inicial proximo a Mach 0,9.
C.Vmx0 = 10;
C.Vmy0 = 0;
C.Vmz0 = 0;

C.Phim0 = 0*D2R;
C.Tetam0 = 0*D2R;
C.Psim0 = 0*D2R;

C.p0 = 0;
C.q0 = 0;
C.r0 = 0;

end
