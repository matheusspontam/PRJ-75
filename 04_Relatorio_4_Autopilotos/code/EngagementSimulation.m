function EngagementSimulation
close all;

D2R = pi/180;
g = 9.8;
D = DadosMissil;

[~, a] = atmosisa(10);
cfg.V = 0.9*a;
cfg.aMax = 5*g;
cfg.wn = 2*pi*0.5;
cfg.qsi = 0.7;
cfg.N = 4;
cfg.dt = 0.01;
cfg.hitRadius = 50;
cfg.maxTime = 280;
cfg.seekerCone = 40*D2R;
cfg.terminalRange = 20000;
cfg.preTurnGain = 1.8;
cfg.outDir = fullfile(fileparts(mfilename('fullpath')), 'figures_engagement');

if ~exist(cfg.outDir, 'dir')
    mkdir(cfg.outDir);
end

case1 = runCase(1, [-65000 0], 0, cfg);
case2 = runCase(2, [-15000 0], 90*D2R, cfg);

plotCase(case1, cfg);
plotCase(case2, cfg);
writeSummary(case1, case2, cfg, D);

save(fullfile(cfg.outDir, 'engagement_results.mat'), 'case1', 'case2', 'cfg', 'D');
end

function S = runCase(id, pos0, gamma0, cfg)
n = floor(cfg.maxTime/cfg.dt) + 1;
t = zeros(n,1);
x = zeros(n,1);
z = zeros(n,1);
gamma = zeros(n,1);
range = zeros(n,1);
los = zeros(n,1);
seeker = zeros(n,1);
terminal = zeros(n,1);
aCmd = zeros(n,1);
aLat = zeros(n,1);
aDot = zeros(n,1);

x(1) = pos0(1);
z(1) = pos0(2);
gamma(1) = gamma0;
range(1) = hypot(-x(1), -z(1));
los(1) = atan2(-z(1), -x(1));
seeker(1) = wrapPiLocal(los(1) - gamma(1));

hitIndex = n;
for k = 1:n-1
    t(k+1) = t(k) + cfg.dt;
    dx = -x(k);
    dz = -z(k);
    range(k) = hypot(dx, dz);
    los(k) = atan2(dz, dx);
    seeker(k) = wrapPiLocal(los(k) - gamma(k));

    if id == 1
        terminal(k) = (range(k) <= cfg.terminalRange) && (abs(seeker(k)) <= cfg.seekerCone);
    else
        terminal(k) = abs(seeker(k)) <= cfg.seekerCone;
    end

    if terminal(k)
        lambdaDot = cfg.V*sin(seeker(k))/max(range(k), 1);
        aDemand = cfg.N*cfg.V*lambdaDot;
    else
        aDemand = cfg.preTurnGain*cfg.V*wrapPiLocal(los(k) - gamma(k));
    end

    aCmd(k) = min(max(aDemand, -cfg.aMax), cfg.aMax);

    aDDot = cfg.wn^2*(aCmd(k) - aLat(k)) - 2*cfg.qsi*cfg.wn*aDot(k);
    aDot(k+1) = aDot(k) + aDDot*cfg.dt;
    aLat(k+1) = aLat(k) + aDot(k+1)*cfg.dt;
    aLat(k+1) = min(max(aLat(k+1), -cfg.aMax), cfg.aMax);

    gamma(k+1) = wrapPiLocal(gamma(k) + (aLat(k+1)/cfg.V)*cfg.dt);
    x(k+1) = x(k) + cfg.V*cos(gamma(k+1))*cfg.dt;
    z(k+1) = z(k) + cfg.V*sin(gamma(k+1))*cfg.dt;
    range(k+1) = hypot(-x(k+1), -z(k+1));
    los(k+1) = atan2(-z(k+1), -x(k+1));
    seeker(k+1) = wrapPiLocal(los(k+1) - gamma(k+1));

    if range(k+1) <= cfg.hitRadius
        hitIndex = k+1;
        break;
    end
end

idx = 1:hitIndex;
S.id = id;
S.t = t(idx);
S.x = x(idx);
S.z = z(idx);
S.gamma = gamma(idx);
S.range = range(idx);
S.los = los(idx);
S.seeker = seeker(idx);
S.terminal = terminal(idx);
S.aCmd = aCmd(idx);
S.aLat = aLat(idx);
S.hit = S.range(end) <= cfg.hitRadius;
[S.minRange, iMin] = min(S.range);
S.tMin = S.t(iMin);
end

function plotCase(S, cfg)
fig = figure('Color', 'w', 'Visible', 'off');
plot(S.x/1000, S.z/1000, 'b', 'LineWidth', 1.4);
hold on;
plot(0, 0, 'rx', 'LineWidth', 1.8, 'MarkerSize', 10);
grid on;
axis equal;
xlabel('X (km)');
ylabel('Z (km)');
title(sprintf('Case %d - horizontal engagement trajectory', S.id));
exportgraphics(fig, fullfile(cfg.outDir, sprintf('case%d_engagement_trajectory.png', S.id)), 'Resolution', 300);
close(fig);

fig = figure('Color', 'w', 'Visible', 'off');
subplot(3,1,1);
plot(S.t, S.range, 'LineWidth', 1.2);
hold on;
yline(cfg.hitRadius, '--r', '50 m');
grid on;
ylabel('Range (m)');

subplot(3,1,2);
plot(S.t, S.seeker*180/pi, 'LineWidth', 1.2);
hold on;
yline(40, '--r');
yline(-40, '--r');
grid on;
ylabel('Seeker angle (deg)');

subplot(3,1,3);
plot(S.t, S.aLat/9.8, 'LineWidth', 1.2);
hold on;
yline(5, '--r');
yline(-5, '--r');
grid on;
xlabel('t (s)');
ylabel('Lateral accel. (g)');
exportgraphics(fig, fullfile(cfg.outDir, sprintf('case%d_engagement_history.png', S.id)), 'Resolution', 300);
close(fig);
end

function writeSummary(case1, case2, cfg, D)
fid = fopen(fullfile(cfg.outDir, 'engagement_summary.txt'), 'w');
fprintf(fid, 'Horizontal engagement simulation with R4 autopilot constraints\n');
fprintf(fid, 'Speed = %.2f m/s\n', cfg.V);
fprintf(fid, 'Lateral acceleration limit = %.2f g\n', cfg.aMax/9.8);
fprintf(fid, 'Airframe response wn = %.2f Hz\n', cfg.wn/(2*pi));
fprintf(fid, 'Seeker cone = %.1f deg\n', cfg.seekerCone*180/pi);
fprintf(fid, 'Hit criterion = %.1f m\n\n', cfg.hitRadius);
printCase(fid, case1);
printCase(fid, case2);
fprintf(fid, '\nMissile data source: DadosMissil.m, M0 = %.1f kg, solid booster+sustainer.\n', D.M0);
fclose(fid);
end

function printCase(fid, S)
fprintf(fid, 'Case %d\n', S.id);
fprintf(fid, 'Hit = %d\n', S.hit);
fprintf(fid, 'Minimum range = %.2f m at %.2f s\n', S.minRange, S.tMin);
fprintf(fid, 'Final range = %.2f m\n', S.range(end));
fprintf(fid, 'Maximum lateral acceleration = %.2f g\n\n', max(abs(S.aLat))/9.8);
end

function a = wrapPiLocal(a)
a = mod(a + pi, 2*pi) - pi;
end
