clc;
clear;
close all;

Alt = 10;
[Temp, VSom, P, Ro] = atmosisa(Alt);

VCd = ...
    [0    0.33
     0.7  0.33
     0.9  0.42
     1.1  0.67
     1.2  0.68
     1.5  0.70
     1.8  0.70
     2.0  0.67
     2.5  0.62
     3.0  0.61
     3.5  0.61];

Vi = 0;
MachCruz = 0.9;
Vf = MachCruz*VSom;
VCruz = Vf;

MTotal = 855;
L_Missil = 5.8;
DRef = 0.35;
SRef = pi*DRef^2/4;

Dens_CDG = 3000;
M_CDG = 165;
V_CDG = M_CDG/Dens_CDG;
L_CDG = V_CDG/SRef;

PhiEB = DRef - 0.040;
PhiIB = 0.060;
VqB = 0.010;
IspB = 220;
RoB = 1700;
TqB = 4;

RB = TqB*VqB;
EpsB = 0.010;
AcelB = (Vf - Vi)/TqB;
Fb = AcelB*MTotal;
MpB = Fb*TqB/(IspB*9.8);
VolB = MpB/RoB;

NStar = floor(2*pi*(PhiEB/2 - RB)/(2*RB + EpsB));
EpsTB = (2*pi*(PhiEB/2 - RB) - NStar*2*RB)/NStar;
hStar = (PhiEB - PhiIB)/2 - RB;
BStar = 2*RB;
bStar = RB*PhiIB/(PhiEB/2 - RB);
AStar = (BStar + bStar)*hStar/2;
LengthB = VolB/(pi*RB*(PhiEB - RB) + NStar*AStar);
FilFactor = MpB/(RoB*pi*PhiEB^2*LengthB/4);

RoAco = 7850;
RVasoB = 0.005;
VolVasoB = pi*LengthB*RVasoB*(DRef - RVasoB);
MVasoB = VolVasoB*RoAco;

Cd = interp1(VCd(:,1), VCd(:,2), MachCruz);
DragCruz = 0.5*Ro*VCruz^2*SRef*Cd;

IspS = 240;
VqS = 0.010;
RoS = 1700;
SSust = DragCruz/(IspS*9.8*RoS*VqS);
PhiES = sqrt(4*SSust/pi);
TqS = 70000/VCruz;
LengthS = TqS*VqS;
MpS = SSust*LengthS*RoS;

RVasoS = 0.005;
VolVasoS = pi*LengthS*RVasoS*(DRef - RVasoS);
MVasoS = VolVasoS*RoAco;

L_Tubeira = 0.10;
L_Cont = L_Missil - (L_CDG + LengthB + LengthS + L_Tubeira);
M_Cont = MTotal - (MpB + MVasoB) - (MpS + MVasoS) - M_CDG;
Mf = MTotal - MpB - MpS;

VProp = ...
    [0              Fb        MpB+MpS
     TqB            Fb        MpS
     TqB+0.001      DragCruz  MpS
     TqB+TqS        DragCruz  0
     TqB+TqS+0.001  0         0];

sim('SimX');

outdir = fullfile(pwd, 'figures');
if ~exist(outdir, 'dir')
    mkdir(outdir);
end

fig = figure('Color','w');
subplot(1,2,1);
plot(t, Xm/1e3, 'LineWidth', 1.2); grid on;
xlabel('t (s)'); ylabel('Range (km)');
subplot(1,2,2);
plot(t, Vm, 'LineWidth', 1.2); grid on;
xlabel('t (s)'); ylabel('Velocity (m/s)');
sgtitle('Exocet-class solid propulsion simulation');
exportgraphics(fig, fullfile(outdir, 'range_velocity.png'), 'Resolution', 220);

save('dimensionamento_resultados.mat', 'Alt', 'VSom', 'Ro', 'VCruz', 'Cd', 'DragCruz', 'MpB', 'LengthB', 'Fb', 'TqB', 'NStar', 'FilFactor', 'MVasoB', 'MpS', 'LengthS', 'PhiES', 'TqS', 'MVasoS', 'L_Cont', 'M_Cont', 'L_CDG', 'Mf', 'MTotal', 'L_Missil', 't', 'Xm', 'Vm', 'VProp');

fprintf('Booster:\n');
fprintf('MpB = %.3f kg\nLengthB = %.3f m\nFb = %.3f kN\nTqB = %.3f s\n', MpB, LengthB, Fb/1e3, TqB);
fprintf('NStar = %.0f\nFilFactor = %.3f %%\nMVasoB = %.3f kg\n\n', NStar, FilFactor*100, MVasoB);
fprintf('Sustainer:\n');
fprintf('MpS = %.3f kg\nLengthS = %.3f m\nPhiES = %.3f m\nDrag = %.3f kN\nTqS = %.3f s\nMVasoS = %.3f kg\n\n', MpS, LengthS, PhiES, DragCruz/1e3, TqS, MVasoS);
fprintf('Missile:\n');
fprintf('MTotal = %.3f kg\nMf = %.3f kg\nL = %.3f m\nLCont = %.3f m\nMCont = %.3f kg\nRange = %.3f km\nVfinal = %.3f m/s\n', MTotal, Mf, L_Missil, L_Cont, M_Cont, Xm(end)/1e3, Vm(end));
