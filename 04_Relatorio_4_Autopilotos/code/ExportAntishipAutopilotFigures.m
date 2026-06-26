function ExportAntishipAutopilotFigures(apFile, D, AT)
load(apFile);

rootDir = fileparts(fileparts(mfilename('fullpath')));
figDir = fullfile(rootDir, '1_report', 'figures');
if ~exist(figDir, 'dir')
    mkdir(figDir);
end

g = 9.80665;
altitude = vet_altitude(1);
Mach = vet_Mach(1);
nominalIndex = min(4, length(vet_x_CG));

fig = figure('Color', 'w', 'Visible', 'off');
tiledlayout(2, 2, 'TileSpacing', 'compact');
nexttile;
plot(vet_x_CG, squeeze(T_at_k_int(:,1,1)), 'o-', 'LineWidth', 1.2);
grid on; xlabel('X_{CG} (m)'); ylabel('K_q');
title('Attitude AP - inner gain');
nexttile;
plot(vet_x_CG, squeeze(T_at_k_ext(:,1,1)), 'o-', 'LineWidth', 1.2);
grid on; xlabel('X_{CG} (m)'); ylabel('K_\theta');
title('Attitude AP - outer gain');
nexttile;
plot(vet_x_CG, squeeze(T_acel_k_int(:,1,1)), 'o-', 'LineWidth', 1.2);
grid on; xlabel('X_{CG} (m)'); ylabel('K_q');
title('Acceleration AP - inner gain');
nexttile;
plot(vet_x_CG, squeeze(T_acel_k_ext(:,1,1)), 'o-', 'LineWidth', 1.2);
grid on; xlabel('X_{CG} (m)'); ylabel('K_a');
title('Acceleration AP - outer gain');
exportgraphics(fig, fullfile(figDir, 'gain_curves_vs_cg.png'), 'Resolution', 300);
close(fig);

fig = figure('Color', 'w', 'Visible', 'off');
plot(VetTmp, squeeze(T_at_k_int(:,1,1)), 'o-', ...
     VetTmp, squeeze(T_at_k_ext(:,1,1)), 's-', ...
     VetTmp, squeeze(T_acel_k_int(:,1,1)), '^-', ...
     VetTmp, squeeze(T_acel_k_ext(:,1,1)), 'd-', 'LineWidth', 1.2);
grid on;
xlabel('Time along nominal burn (s)');
ylabel('Gain');
legend('Attitude inner K_q', 'Attitude outer K_\theta', ...
       'Acceleration inner K_q', 'Acceleration outer K_a', 'Location', 'best');
title('Autopilot gain schedule');
exportgraphics(fig, fullfile(figDir, 'gain_schedule_vs_time.png'), 'Resolution', 300);
close(fig);

[systems, req] = buildNominalSystems(D, AT, Mach, altitude, VetTmp(nominalIndex), ...
    T_at_k_int(nominalIndex,1,1), T_at_k_ext(nominalIndex,1,1), ...
    T_acel_k_ext(nominalIndex,1,1));

exportRootLocus(systems.T_in_ma, 0:50/1500:50, figDir, ...
    'root_locus_inner_attitude.png', ...
    sprintf('Inner loop root locus: K_q = %.3g', T_at_k_int(nominalIndex,1,1)));
exportRootLocus(systems.T_in_ma, 0:50/1500:50, figDir, ...
    'root_locus_inner_acceleration.png', ...
    sprintf('Inner loop root locus used in acceleration AP: K_q = %.3g', T_acel_k_int(nominalIndex,1,1)));
exportRootLocus(systems.T_at_out_ma, 0:2000/1500:2000, figDir, ...
    'root_locus_outer_attitude.png', ...
    sprintf('Attitude outer-loop root locus: K_{\\theta} = %.3g', T_at_k_ext(nominalIndex,1,1)));
exportRootLocus(systems.T_ac_out_ma, 0:200/1500:200, figDir, ...
    'root_locus_outer_acceleration.png', ...
    sprintf('Acceleration outer-loop root locus: K_a = %.3g', T_acel_k_ext(nominalIndex,1,1)));

fig = figure('Color', 'w', 'Visible', 'off');
[yTheta, tTheta] = step(systems.T_at_out_mf, 5);
plot(tTheta, yTheta, 'LineWidth', 1.3);
grid on;
title('Attitude autopilot: unit step response');
xlabel('Time (s)');
ylabel('\theta / \theta_c');
ylim([0 1.2]);
exportgraphics(fig, fullfile(figDir, 'step_attitude.png'), 'Resolution', 300);
close(fig);

t = 0:0.002:5;
fig = figure('Color', 'w', 'Visible', 'off');
[y, tout] = step(systems.T_ac_out_mf, t);
plot(tout, y, 'LineWidth', 1.3);
grid on;
title('Acceleration autopilot: unit step response');
xlabel('Time (s)');
ylabel('A_z / A_{z,c}');
exportgraphics(fig, fullfile(figDir, 'step_acceleration_unit.png'), 'Resolution', 300);
close(fig);

fig = figure('Color', 'w', 'Visible', 'off');
[y5g, t5g] = step((5*g)*systems.T_ac_out_mf, t);
plot(t5g, y5g/g, 'LineWidth', 1.3);
hold on;
yline(5, '--', '5 g requirement');
grid on;
title('Acceleration autopilot: 5 g command');
xlabel('Time (s)');
ylabel('A_z (g)');
exportgraphics(fig, fullfile(figDir, 'step_acceleration_5g.png'), 'Resolution', 300);
close(fig);

writeSummary(fullfile(fileparts(mfilename('fullpath')), 'autopilot_summary.txt'), ...
    VetTmp, vet_x_CG, squeeze(T_at_k_int(:,1,1)), squeeze(T_at_k_ext(:,1,1)), ...
    squeeze(T_acel_k_int(:,1,1)), squeeze(T_acel_k_ext(:,1,1)), req);
end

function [S, req] = buildNominalSystems(D, AT, Mach, altitude, tnow, kInt, kAtOuter, kAcOuter)
g = 9.80665;
m = interp1(D.VProp(:,1), D.VProp(:,3), tnow, 'linear', 'extrap') + D.mf;
Iy = interp1(D.IMissil(:,1), D.IMissil(:,3), tnow, 'linear', 'extrap');
xCG = interp1(D.CGMissil(:,1), D.CGMissil(:,2), tnow, 'linear', 'extrap');
dxcg = (xCG - D.CRM(1))/D.DRef;
[Din_acel, ~, ~, Din_q] = FTransDin(Mach, altitude, m, Iy, dxcg, D.DRef, D.SRef);

At0 = tf(AT.num, AT.den);
At0.InputName = 'ed'; At0.OutputName = 'dlt';
Sum_in_ma = sumblk('ed = ea');
S.T_in_ma = connect(Din_q, At0, Sum_in_ma, 'ea', 'q');

At = tf(AT.num*kInt, AT.den);
At.InputName = 'ed'; At.OutputName = 'dlt';
Sum_in_mf = sumblk('ed = ea-q');
S.T_in_mf = connect(Din_q, At, Sum_in_mf, 'ea', 'q');

Integ = tf(1, [1 0]);
Integ.InputName = 'q'; Integ.OutputName = 'theta';
AmpAt = tf(1, 1);
AmpAt.InputName = 'e'; AmpAt.OutputName = 'ea';
Sum_at_out_ma = sumblk('e = ref');
S.T_at_out_ma = connect(AmpAt, S.T_in_mf, Integ, Sum_at_out_ma, 'ref', 'theta');

AmpAt = tf(kAtOuter, 1);
AmpAt.InputName = 'e'; AmpAt.OutputName = 'ea';
Sum_at_out_mf = sumblk('e = ref-theta');
S.T_at_out_mf = connect(AmpAt, S.T_in_mf, Integ, Sum_at_out_mf, 'ref', 'theta');

S.T_ac_in_mf = connect(Din_q, At, Sum_in_mf, 'ea', 'dlt');
AmpAc = tf(-1, [1 0]);
AmpAc.InputName = 'e'; AmpAc.OutputName = 'ea';
Sum_ac_out_ma = sumblk('e = Aref');
S.T_ac_out_ma = connect(AmpAc, S.T_ac_in_mf, Din_acel, Sum_ac_out_ma, 'Aref', 'Az');

AmpAc = tf(-kAcOuter, [1 0]);
AmpAc.InputName = 'e'; AmpAc.OutputName = 'ea';
Sum_ac_out_mf = sumblk('e = Aref-Az');
S.T_ac_out_mf = connect(AmpAc, S.T_ac_in_mf, Din_acel, Sum_ac_out_mf, 'Aref', 'Az');

req.mass = m;
req.Iy = Iy;
req.xCG = xCG;
req.attitudeBandwidthHz = bandwidth(S.T_at_out_mf)/(2*pi);
req.accelBandwidthHz = bandwidth(S.T_ac_out_mf)/(2*pi);
req.attitudeDominantPoleHz = dominantFrequencyHz(S.T_at_out_mf);
req.accelDominantPoleHz = dominantFrequencyHz(S.T_ac_out_mf);
req.maxAccelG = abs(dcgain(Din_acel))*D.Dlt_max/g;
req.attitudeStep = stepinfo(S.T_at_out_mf);
req.accelStep = stepinfo(S.T_ac_out_mf);
end

function exportRootLocus(sysOpen, K, figDir, fileName, ttl)
fig = figure('Color', 'w', 'Visible', 'off');
rlocusplot(sysOpen, K);
grid on;
axis equal;
title(ttl);
xlabel('Real axis');
ylabel('Imaginary axis');
exportgraphics(fig, fullfile(figDir, fileName), 'Resolution', 300);
close(fig);
end

function fHz = dominantFrequencyHz(sys)
poles = pole(sys);
poles = poles(real(poles) < 0);
[~, id] = max(real(poles));
fHz = abs(poles(id))/(2*pi);
end

function writeSummary(fname, timeGrid, xCG, kAtInt, kAtExt, kAcInt, kAcExt, req)
fid = fopen(fname, 'w');
fprintf(fid, 'Antiship missile autopilot design summary\n');
fprintf(fid, 'Nominal point: xCG=%.4f m, mass=%.3f kg, Iy=%.3f kg.m2\n', req.xCG, req.mass, req.Iy);
fprintf(fid, 'Attitude bandwidth: %.4f Hz\n', req.attitudeBandwidthHz);
fprintf(fid, 'Acceleration bandwidth: %.4f Hz\n', req.accelBandwidthHz);
fprintf(fid, 'Attitude dominant-pole frequency: %.4f Hz\n', req.attitudeDominantPoleHz);
fprintf(fid, 'Acceleration dominant-pole frequency: %.4f Hz\n', req.accelDominantPoleHz);
fprintf(fid, 'Estimated lateral acceleration capability at 10 deg fin: %.4f g\n\n', req.maxAccelG);
fprintf(fid, 'time_s, xcg_m, Kq_att, Ktheta, Kq_acc, Ka\n');
for i = 1:length(timeGrid)
    fprintf(fid, '%.3f, %.4f, %.6g, %.6g, %.6g, %.6g\n', ...
        timeGrid(i), xCG(i), kAtInt(i), kAtExt(i), kAcInt(i), kAcExt(i));
end
fclose(fid);
end
