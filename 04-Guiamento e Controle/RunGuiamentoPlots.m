%% RunGuiamentoPlots.m - voo homing completo + plots (trajetoria e series)
clear; close all;
cte_grav=9.8; D2R=pi/180; R2D=180/pi;
P='C:/Users/Savio/Documents/PRJ-75/Plots_Relevantes/';
C=CondLanc6DOF; D=DadosMissil; D=DadosCGInercia(D); load M_aed.mat; D.Cmap=0; D=DadosControle(D); load autopiloto.mat
sim('GuiamentoControle.slx'); SalvaDinamica6DOF;
xa=C.Xa0; ya=C.Ya0; za=C.Za0;
dist=sqrt((S.Xe.Data(:,1)-xa).^2+(S.Xe.Data(:,2)-ya).^2+(S.Xe.Data(:,3)+za).^2); [dmin,~]=min(dist);
fprintf('BINGO=%d  miss=%.1f m  Tfim=%.1f s  Mach_fim=%.2f  Alt_fim=%.1f m\n', Bingo(end),dmin,S.Xe.Time(end),S.Mach.Data(end),-S.Xe.Data(end,3));

% trajetoria
figure('Position',[60 60 1200 360]);
subplot(1,3,1); plot(S.Xe.Data(:,1)/1e3,S.Xe.Data(:,2)/1e3,'b'); hold on; plot(xa/1e3,ya/1e3,'rx','MarkerSize',12,'LineWidth',2); grid on; xlabel('X (km)'); ylabel('Y (km)'); title('Trajetoria horizontal'); axis equal;
subplot(1,3,2); plot(S.Xe.Data(:,1)/1e3,-S.Xe.Data(:,3),'b'); grid on; xlabel('X (km)'); ylabel('Altitude (m)'); title('Perfil de altitude (sea-skim)'); ylim([0 40]);
subplot(1,3,3); plot(S.V.Time,S.V.Data,'b'); grid on; xlabel('t (s)'); ylabel('V (m/s)'); title('Velocidade (segura cruzeiro)');
sgtitle(sprintf('Guiamento antinavio - BINGO miss %.1f m',dmin)); exportgraphics(gcf,[P '06_guiamento_trajetoria.png'],'Resolution',140);

% series temporais
figure('Position',[60 60 1200 600]);
subplot(2,3,1); plot(S.Xe.Time,-S.Xe.Data(:,3),'b'); yline(C.AltCruz,'r--'); grid on; xlabel('t (s)'); ylabel('Alt (m)'); title('Altitude x ref');
subplot(2,3,2); plot(S.Euler.Time,S.Euler.Data(:,2)*R2D,'b'); grid on; xlabel('t (s)'); ylabel('\theta (deg)'); title('Atitude');
subplot(2,3,3); plot(S.Mach.Time,S.Mach.Data,'b'); yline(0.9,'r--'); grid on; xlabel('t (s)'); ylabel('Mach'); title('Mach');
subplot(2,3,4); plot(S.Ab.Time,S.Ab.Data(:,3)/9.8,'b'); grid on; xlabel('t (s)'); ylabel('Az (g)'); title('Acel Z');
subplot(2,3,5); plot(S.DeltaZ.Time,S.DeltaZ.Data*R2D,'b'); grid on; xlabel('t (s)'); ylabel('\delta_z (deg)'); title('Deflexao leme');
subplot(2,3,6); plot(S.Alfa.Time,S.Alfa.Data*R2D,'b'); grid on; xlabel('t (s)'); ylabel('\alpha (deg)'); title('Angulo de ataque');
sgtitle('Guiamento - series temporais'); exportgraphics(gcf,[P '07_guiamento_series.png'],'Resolution',140);
