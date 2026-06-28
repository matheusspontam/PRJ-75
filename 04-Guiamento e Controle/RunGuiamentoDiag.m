%% RunGuiamentoDiag.m - diagnostico do voo (series temporais ate o crash)
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

figure('Position',[40 40 1250 700]);
subplot(2,3,1); plot(S.Xe.Time,-S.Xe.Data(:,3),'b'); grid on; xlabel('t (s)'); ylabel('Altitude (m)'); title('Altitude'); yline(C.AltCruz,'r--');
subplot(2,3,2); plot(S.Euler.Time,S.Euler.Data(:,2)*R2D,'b'); grid on; xlabel('t (s)'); ylabel('\theta (deg)'); title('Atitude \theta');
subplot(2,3,3); plot(S.Mach.Time,S.Mach.Data,'b'); grid on; xlabel('t (s)'); ylabel('Mach'); title('Mach'); yline(0.6,'r--');
subplot(2,3,4); plot(S.wb.Time,S.wb.Data(:,2)*R2D,'b'); grid on; xlabel('t (s)'); ylabel('q (deg/s)'); title('Taxa de arfagem q');
subplot(2,3,5); plot(S.DeltaZ.Time,S.DeltaZ.Data*R2D,'b'); grid on; xlabel('t (s)'); ylabel('\delta_z (deg)'); title('Deflexao leme (pitch)');
subplot(2,3,6); plot(S.Alfa.Time,S.Alfa.Data*R2D,'b'); grid on; xlabel('t (s)'); ylabel('\alpha (deg)'); title('Angulo de ataque');
exportgraphics(gcf, fullfile(OUT,'figures','homing_diag.png'),'Resolution',130);
fprintf('Tfim=%.2f s  Alt max=%.1f m  theta range=[%.1f %.1f] deg  Mach final=%.2f\n', ...
        S.Xe.Time(end), max(-S.Xe.Data(:,3)), min(S.Euler.Data(:,2))*R2D, max(S.Euler.Data(:,2))*R2D, S.Mach.Data(end));
