%% RunGuiamentoFull.m - voo homing completo (GuiamentoControle.slx), sem menu
clear; close all;
cte_grav = 9.8; D2R = pi/180; R2D = 180/pi;
C = CondLanc6DOF;
D = DadosMissil; D = DadosCGInercia(D);
load M_aed.mat; D.Cmap = 0;
D = DadosControle(D);
load autopiloto.mat
sim('GuiamentoControle.slx');
SalvaDinamica6DOF;

OUT = getenv('OUTDIR'); if isempty(OUT); OUT = pwd; end
if ~exist(fullfile(OUT,'figures'),'dir'); mkdir(fullfile(OUT,'figures')); end

xa=C.Xa0; ya=C.Ya0; za=C.Za0;
N=length(S.Xe.Time);
dist = sqrt((S.Xe.Data(:,1)-xa).^2 + (S.Xe.Data(:,2)-ya).^2 + (S.Xe.Data(:,3)+za).^2);
[dmin,imin]=min(dist);
fprintf('Tempo final = %.1f s | miss distance = %.1f m (t=%.1f s)\n', S.Xe.Time(end), dmin, S.Xe.Time(imin));
fprintf('Mach final=%.2f  Alt final=%.1f m\n', S.Mach.Data(end), -S.Xe.Data(end,3));
try, fprintf('Bingo=%d ImpactoSolo=%d Stop_VMin=%d Stop_FugaAlvo=%d\n', Bingo(end),ImpactoSolo(end),Stop_VMin(end),Stop_FugaAlvo(end)); catch; end

figure('Position',[60 60 1200 380]);
subplot(1,3,1); plot(S.Xe.Data(:,1)/1e3,S.Xe.Data(:,2)/1e3,'b'); hold on; plot(xa/1e3,ya/1e3,'rx','MarkerSize',12,'LineWidth',2);
grid on; xlabel('X (km)'); ylabel('Y (km)'); title('Trajetoria horizontal'); axis equal;
subplot(1,3,2); plot(S.Xe.Data(:,1)/1e3,-S.Xe.Data(:,3),'b'); hold on; plot(xa/1e3,za,'rx','MarkerSize',12,'LineWidth',2);
grid on; xlabel('X (km)'); ylabel('Altitude (m)'); title('Perfil de altitude');
subplot(1,3,3); plot(S.V.Time,S.V.Data,'b'); grid on; xlabel('t (s)'); ylabel('V (m/s)'); title('Velocidade');
exportgraphics(gcf, fullfile(OUT,'figures','homing_baseline.png'),'Resolution',130);
