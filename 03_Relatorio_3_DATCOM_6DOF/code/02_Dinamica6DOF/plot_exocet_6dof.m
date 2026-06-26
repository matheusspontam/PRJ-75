function plot_exocet_6dof(S, outdir)

if ~exist(outdir, 'dir')
    mkdir(outdir);
end

R2D = 180/pi;
g = 9.8;

fig = figure('Color', 'w');
subplot(2,2,1);
plot(S.Alfa.Time, S.Alfa.Data*R2D); grid on;
xlabel('t (s)'); ylabel('Alpha (deg)');
subplot(2,2,2);
plot(S.Beta.Time, S.Beta.Data*R2D); grid on;
xlabel('t (s)'); ylabel('Beta (deg)');
subplot(2,2,3);
plot(S.DeltaY.Time, S.DeltaY.Data*R2D); grid on;
xlabel('t (s)'); ylabel('Delta Y (deg)');
subplot(2,2,4);
plot(S.DeltaZ.Time, S.DeltaZ.Data*R2D); grid on;
xlabel('t (s)'); ylabel('Delta Z (deg)');
sgtitle('Alpha and beta response to control deflection');
exportgraphics(fig, fullfile(outdir, 'dof_alfa_delta.png'), 'Resolution', 220);
close(fig);

fig = figure('Color', 'w');
yyaxis left;
plot(S.Alfa.Time, S.Alfa.Data*R2D, 'LineWidth', 1.2);
ylabel('Alpha (deg)');
yyaxis right;
plot(S.DeltaY.Time, S.DeltaY.Data*R2D, '--', 'LineWidth', 1.2);
ylabel('Delta Y (deg)');
grid on;
xlabel('t (s)');
title('Alpha response compared with control deflection');
exportgraphics(fig, fullfile(outdir, 'dof_alpha_delta_overlay.png'), 'Resolution', 220);
close(fig);

fig = figure('Color', 'w');
subplot(2,2,1);
plot(S.Xe.Time, S.Xe.Data(:,1)); grid on;
xlabel('t (s)'); ylabel('X (m)');
subplot(2,2,2);
plot(S.Xe.Data(:,1), S.Xe.Data(:,2)); grid on; axis equal;
xlabel('X (m)'); ylabel('Y (m)');
subplot(2,2,3);
plot(S.Xe.Data(:,1), -S.Xe.Data(:,3)); grid on; axis equal;
xlabel('X (m)'); ylabel('Z (m)');
subplot(2,2,4);
plot(S.Xe.Data(:,2), -S.Xe.Data(:,3)); grid on; axis equal;
xlabel('Y (m)'); ylabel('Z (m)');
sgtitle('6DOF trajectory');
exportgraphics(fig, fullfile(outdir, 'dof_trajetoria.png'), 'Resolution', 220);
close(fig);

fig = figure('Color', 'w');
subplot(2,2,1);
plot(S.V.Time, S.V.Data); grid on;
xlabel('t (s)'); ylabel('V (m/s)');
subplot(2,2,2);
plot(S.Mach.Time, S.Mach.Data); grid on;
xlabel('t (s)'); ylabel('Mach');
subplot(2,2,3);
plot(S.Ab.Time, S.Ab.Data(:,2)/g); grid on;
xlabel('t (s)'); ylabel('Ay (g)');
subplot(2,2,4);
plot(S.Ab.Time, S.Ab.Data(:,3)/g); grid on;
xlabel('t (s)'); ylabel('Az (g)');
sgtitle('Velocity and accelerations');
exportgraphics(fig, fullfile(outdir, 'dof_velocidade_aceleracao.png'), 'Resolution', 220);
close(fig);

fig = figure('Color', 'w');
subplot(2,2,1);
plot(S.FProp.Time, S.FProp.Data(:,1)); grid on;
xlabel('t (s)'); ylabel('Thrust (N)');
subplot(2,2,2);
plot(S.m.Time, S.m.Data); grid on;
xlabel('t (s)'); ylabel('Mass (kg)');
subplot(2,2,3);
plot(S.XCG.Time, S.XCG.Data(:,1)); grid on;
xlabel('t (s)'); ylabel('XCG (m)');
subplot(2,2,4);
plot(S.Ixx.Time, S.Ixx.Data, S.Iyy.Time, S.Iyy.Data); grid on;
legend('Ixx', 'Iyy', 'Location', 'best');
xlabel('t (s)'); ylabel('Inertia (kg.m2)');
sgtitle('Propulsion, mass, and inertia');
exportgraphics(fig, fullfile(outdir, 'dof_propulsao_massa.png'), 'Resolution', 220);
close(fig);

end
