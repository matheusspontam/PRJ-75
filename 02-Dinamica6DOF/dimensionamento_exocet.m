%% =====================================================================
%  dimensionamento_exocet.m
%  Dimensionamento preliminar do missil anti-navio MANSUP
%  equivalente ao Exocet MM40 (alvo: 875 kg, 5.79 m, D=0.35 m,
%  Mach 0.9 em voo rasante, alcance 70 km).
%
%  Metodologia (ver DefMissil.mlx):
%    - Booster: grao tipo ESTRELA, dimensionado pelo impulso necessario
%               para acelerar o missil ate a velocidade de cruzeiro.
%    - Sustainer: grao tipo END-BURNER, dimensionado para que o empuxo
%               iguale o arrasto de cruzeiro durante todo o alcance.
%
%  Saidas alimentam DadosMissil.m e DadosCGInercia.m.
%  Referencia de x: ponta do nariz (x=0), positivo para tras NESTE script
%  (as posicoes sao convertidas para negativas em DadosCGInercia.m).
% =====================================================================
clc; clear; close all;

g    = 9.80665;             % (m/s2) gravidade

%% ---------------------------------------------------------------------
%  1) ALVO E AMBIENTE (voo rasante - sea skimming)
% ---------------------------------------------------------------------
M0      = 875;              % (kg) massa de lancamento alvo (MM40)
L_missil= 5.79;             % (m)  comprimento total alvo
DRef    = 0.35;             % (m)  diametro de referencia
SRef    = pi*DRef^2/4;      % (m2) area de referencia
Alcance = 70e3;            % (m)  alcance alvo
MachCruz= 0.9;             % Mach de cruzeiro

Alt = 10;                                  % (m) altitude rasante
[Temp, VSom, Pamb, Ro] = atmosisa(Alt);
VCruz = MachCruz*VSom;                      % (m/s) velocidade de cruzeiro

% Curva de Cd x Mach (estimativa preliminar - corpo + asas)
VCd = [0    0.33
       0.7  0.33
       0.9  0.42
       1.1  0.67
       1.2  0.68
       1.5  0.70];
Cd = interp1(VCd(:,1), VCd(:,2), MachCruz);
DragCruz = 0.5*Ro*VCruz^2*SRef*Cd;          % (N) arrasto de cruzeiro

fprintf('--- AMBIENTE / CRUZEIRO ---\n');
fprintf('VSom=%.1f m/s  VCruz=%.1f m/s  Ro=%.3f  Cd=%.2f  Drag=%.1f N\n\n',...
        VSom, VCruz, Ro, Cd, DragCruz);

%% ---------------------------------------------------------------------
%  2) BOOSTER - grao tipo ESTRELA (DefMissil.mlx, Geometria 3)
% ---------------------------------------------------------------------
Isp_B = 220;               % (s)   impulso especifico do booster
RoProp= 1700;              % (kg/m3) densidade do propelente
Vq    = 0.010;             % (m/s) taxa de queima (web/segundo)
TqB   = 4.0;               % (s)   tempo de queima do booster
phiE  = 0.30;              % (m)   diametro externo do grao (parede do case)
phiI  = 0.06;              % (m)   diametro interno (porto)
epsP  = 0.010;             % (m)   distancia entre petalas

R     = TqB*Vq;                          % (m) espessura do propelente (web)
Bstar = 2*R;                             % base maior da petala
bstar = R*phiI/(phiE/2 - R);             % base menor da petala
Nstar = floor(2*pi*(phiE/2 - R)/(2*R + epsP));  % numero de petalas
hstar = (phiE - phiI)/2 - R;             % altura da petala
Astar = (bstar + Bstar)/2*hstar;         % area de uma petala
% Volume de propelente por metro de grao (tarugo + petalas)
Vp_por_L = pi*R*(phiE - R) + Nstar*Astar;

% Massa de propelente do booster: impulso p/ levar M0 ate VCruz
% (equacao de momento + arrasto medio durante o boost)
Drag_boost = 0.5*Ro*(VCruz/2)^2*SRef*Cd;
MpB    = (M0*VCruz + Drag_boost*TqB)/(Isp_B*g);
L_graoB= MpB/(RoProp*Vp_por_L);          % (m) comprimento do grao do booster
EmpB   = MpB*Isp_B*g/TqB;                % (N) empuxo do booster
AcelB  = EmpB/M0/g;                       % (g) aceleracao no boost

fprintf('--- BOOSTER (estrela) ---\n');
fprintf('R(web)=%.3f m  Nstar=%d  hstar=%.3f  Astar=%.5f m2  Vp/L=%.5f m3/m\n',...
        R, Nstar, hstar, Astar, Vp_por_L);
fprintf('MpB=%.1f kg  L_grao=%.3f m  EmpB=%.0f N (%.1f kN)  acel=%.1f g\n\n',...
        MpB, L_graoB, EmpB, EmpB/1e3, AcelB);

%% ---------------------------------------------------------------------
%  3) SUSTAINER - grao END-BURNER (DefMissil.mlx)
%     F = Isp*g*Ro*S*Vq = F_Drag   ->   S = Drag/(Isp*g*Ro*Vq)
% ---------------------------------------------------------------------
Isp_S = 230;               % (s) impulso especifico do sustainer
TqS   = Alcance/VCruz;     % (s) tempo de cruzeiro = alcance/velocidade
S_sust= DragCruz/(Isp_S*g*RoProp*Vq);    % (m2) area de queima
phiES = sqrt(4*S_sust/pi);               % (m)  diametro do grao end-burner
Lp_S  = Vq*TqS;                          % (m)  comprimento do grao
MpS   = RoProp*S_sust*Lp_S;              % (kg) massa de propelente
EmpS  = Isp_S*g*RoProp*S_sust*Vq;        % (N)  empuxo (= arrasto)

fprintf('--- SUSTAINER (end-burner) ---\n');
fprintf('TqS=%.1f s  S=%.4f m2  phiES=%.3f m  Lp=%.3f m\n', TqS, S_sust, phiES, Lp_S);
fprintf('MpS=%.1f kg  EmpS=%.0f N (= Drag %.0f N)\n\n', MpS, EmpS, DragCruz);

Mp_tot = MpB + MpS;
fprintf('PROPELENTE TOTAL = %.1f kg  (fracao = %.1f%% de M0)\n\n', Mp_tot, 100*Mp_tot/M0);

%% ---------------------------------------------------------------------
%  4) LAYOUT (comprimentos das secoes, nariz -> cauda)
%     Cont (guiamento) | CDG (cabeca de guerra) | Sustainer | Booster | Tubeira
% ---------------------------------------------------------------------
L_CDG  = 0.90;                                  % (m) cabeca de guerra
L_S    = 2.30;                                  % (m) secao do sustainer (grao 2.286 + fechamento)
L_B    = 1.21;                                  % (m) secao do booster (grao 1.205 + fechamento)
L_Tub  = 0.20;                                  % (m) tubeira
L_Cont = L_missil - (L_CDG + L_S + L_B + L_Tub); % (m) secao de guiamento (restante)

%% ---------------------------------------------------------------------
%  5) MASSAS (alvo: somatorio = M0 = 875 kg)
% ---------------------------------------------------------------------
% Distribuicao nose-heavy para garantir margem estatica no lancamento
% (ver analise de manobra maxima / PlotGMax: CG traseiro deixa o trim na
%  borda da tabela aerodinamica). Alvo de xcg0 ~ -2.60 m (~1.2 calibre).
m_CDG      = 165;          % (kg) cabeca de guerra (referencia Exocet)
m_Cont     = 230;          % (kg) secao de guiamento (radome+seeker+eletronica+bateria+estrutura)
Mf_caseB   = 39;           % (kg) estrutura/case do booster (sem propelente)
Mf_caseS   = 65;           % (kg) estrutura/case do sustainer (sem propelente)
M_Tub      = 15.4;         % (kg) tubeira

m_MOTB = Mf_caseB + MpB;   % massa total do booster (cheio)
m_MOTS = Mf_caseS + MpS;   % massa total do sustainer (cheio)
Mtot   = m_Cont + m_CDG + m_MOTB + m_MOTS + M_Tub;
Mf     = Mtot - Mp_tot;    % massa apos a queima (vazio)

%% ---------------------------------------------------------------------
%  6) CG (posicoes POSITIVAS a partir do nariz; negadas em DadosCGInercia)
% ---------------------------------------------------------------------
xCont = L_Cont/2;
xCDG  = L_Cont + L_CDG/2;
xS    = L_Cont + L_CDG + L_S/2;
xB    = L_Cont + L_CDG + L_S + L_B/2;
xT    = L_Cont + L_CDG + L_S + L_B + L_Tub/2;

xcg0 = (xCont*m_Cont + xCDG*m_CDG + xS*m_MOTS + xB*m_MOTB + xT*M_Tub)/Mtot;
% migracao do CG ao longo da queima (booster - mais traseiro - queima primeiro)
xcgBf = (xCont*m_Cont + xCDG*m_CDG + xS*m_MOTS + xB*(m_MOTB-MpB) + xT*M_Tub)/(Mtot-MpB);
xcgf  = (xCont*m_Cont + xCDG*m_CDG + xS*(m_MOTS-MpS) + xB*(m_MOTB-MpB) + xT*M_Tub)/Mf;

fprintf('--- LAYOUT / MASSA ---\n');
fprintf('L: Cont=%.2f CDG=%.2f Sust=%.2f Boost=%.2f Tub=%.2f  SOMA=%.3f m\n',...
        L_Cont, L_CDG, L_S, L_B, L_Tub, L_Cont+L_CDG+L_S+L_B+L_Tub);
fprintf('m: Cont=%.0f CDG=%.0f MOTB=%.1f MOTS=%.1f Tub=%.1f  SOMA=%.1f kg (Mf=%.1f)\n',...
        m_Cont, m_CDG, m_MOTB, m_MOTS, M_Tub, Mtot, Mf);
fprintf('xcg0 (lancamento, do nariz) = -%.3f m   [alvo: -2.4 a -2.8]\n', xcg0);
fprintf('xcg fim booster = -%.3f m   xcg vazio = -%.3f m\n', xcgBf, xcgf);

if xcg0>2.4 && xcg0<2.8
    fprintf('>>> xcg0 DENTRO da faixa. OK para rodar no DATCOM.\n');
else
    fprintf('>>> ATENCAO: xcg0 fora da faixa alvo.\n');
end

%% ---------------------------------------------------------------------
%  7) Salva resultados
% ---------------------------------------------------------------------
save('dimensionamento_resultados.mat', ...
     'M0','L_missil','DRef','SRef','VCruz','Cd','DragCruz', ...
     'Isp_B','RoProp','Vq','TqB','phiE','phiI','epsP','R','Nstar','hstar',...
     'Astar','Vp_por_L','MpB','L_graoB','EmpB', ...
     'Isp_S','TqS','S_sust','phiES','Lp_S','MpS','EmpS', ...
     'L_Cont','L_CDG','L_S','L_B','L_Tub', ...
     'm_Cont','m_CDG','Mf_caseB','Mf_caseS','M_Tub','Mtot','Mf','xcg0');
