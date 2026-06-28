%% RunGuiamento.m - roda Autopiloto.slx com o cenario antinavio e plota
clear; close all;
cte_grav = 9.8; D2R = pi/180; R2D = 180/pi;
C = CondLanc6DOF;
D = DadosMissil; D = DadosCGInercia(D);
load M_aed.mat; D.Cmap = 0;
D = DadosControle(D);
load autopiloto.mat
sim('Autopiloto.slx');
SalvaDinamica6DOF;

OUT = getenv('OUTDIR'); if isempty(OUT); OUT = pwd; end
if ~exist(fullfile(OUT,'figures'),'dir'); mkdir(fullfile(OUT,'figures')); end
R2D = 180/pi;

% trajetoria e alvo
xa=C.Xa0; ya=C.Ya0; za=C.Za0;
figure('Position',[60 60 1200 700]);
subplot(2,3,1);
plot(S.Xe.Data(:,1)/1e3, S.Xe.Data(:,2)/1e3,'b'); hold on; plot(xa/1e3,ya/1e3,'rx','MarkerSize',12,'LineWidth',2);
grid on; xlabel('X (km)'); ylabel('Y (km)'); title('Trajetoria horizontal'); axis equal;
subplot(2,3,2);
plot(S.Xe.Data(:,1)/1e3, -S.Xe.Data(:,3),'b'); hold on; plot(xa/1e3,za,'rx','MarkerSize',12,'LineWidth',2);
grid on; xlabel('X (km)'); ylabel('Altitude (m)'); title('Perfil de altitude'); ylim([0 60]);
subplot(2,3,3);
plot(S.V.Time, S.V.Data,'b'); grid on; xlabel('t (s)'); ylabel('V (m/s)'); title('Velocidade');
subplot(2,3,4);
plot(S.Euler.Time, S.Euler.Data(:,2)*R2D,'b'); hold on;
if isfield(S,'Theta_Ref'); plot(S.Theta_Ref.Time,S.Theta_Ref.Data*R2D,'r--'); end
grid on; xlabel('t (s)'); ylabel('\theta (deg)'); title('Atitude \theta (azul) x ref (verm)');
subplot(2,3,5);
plot(S.Ab.Time, S.Ab.Data(:,3)/9.8,'b'); hold on;
if isfield(S,'Acel_z_ref'); plot(S.Acel_z_ref.Time,S.Acel_z_ref.Data/9.8,'r--'); end
grid on; xlabel('t (s)'); ylabel('Az (g)'); title('Acel Z exec (azul) x ref (verm)');
subplot(2,3,6);
plot(S.Ab.Time, S.Ab.Data(:,2)/9.8,'b'); hold on;
if isfield(S,'Acel_y_ref'); plot(S.Acel_y_ref.Time,S.Acel_y_ref.Data/9.8,'r--'); end
grid on; xlabel('t (s)'); ylabel('Ay (g)'); title('Acel Y exec (azul) x ref (verm)');
exportgraphics(gcf, fullfile(OUT,'figures','guiamento.png'),'Resolution',130);

% miss distance
N=length(S.Xe.Time);
dist = sqrt((S.Xe.Data(:,1)-xa).^2 + (S.Xe.Data(:,2)-ya).^2 + (S.Xe.Data(:,3)+za).^2);
[dmin,imin]=min(dist);
fprintf('Tempo final sim = %.1f s\n', S.Xe.Time(end));
fprintf('Distancia minima ao alvo (miss distance) = %.1f m em t=%.1f s\n', dmin, S.Xe.Time(imin));
fprintf('Mach final=%.2f  Alt final=%.1f m\n', S.Mach.Data(end), -S.Xe.Data(end,3));
