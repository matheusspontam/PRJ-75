function S = run_mansup_case(caseId)
D2R = pi/180;
cte_grav = 9.8;
HORIZONTAL = 1;

D = DadosMissil;
if caseId == 1
    C = CondLanc(HORIZONTAL, 65000, 0);
    C.TerminalRange = 20000;
else
    C = CondLanc(HORIZONTAL, 15000, 0);
    C.Gama0 = 90*D2R;
    C.TerminalRange = inf;
end
C.CaseId = caseId;

assignin('base', 'D2R', D2R);
assignin('base', 'cte_grav', cte_grav);
assignin('base', 'HORIZONTAL', HORIZONTAL);
assignin('base', 'D', D);
assignin('base', 'C', C);
evalin('base', "load('alfa_ref.mat');");
evalin('base', "load('M_aed_plano.mat');");
evalin('base', "sim('MassaPontoMANSUP_2018b');");
evalin('base', 'SaveResults;');
S = evalin('base', 'S');

outDir = fullfile(fileparts(fileparts(mfilename('fullpath'))), 'figures_simulink');
if ~exist(outDir, 'dir')
    mkdir(outDir);
end

plot_case(S, caseId, outDir);
save(fullfile(outDir, sprintf('case%d_results.mat', caseId)), 'S', 'C', 'D');
end

function plot_case(S, caseId, outDir)
xm = S.Xm.Data;
zm = S.Zm.Data;
xt = S.XTgt.Data;
zt = S.ZTgt.Data;
t = S.Xm.Time;

fig = figure('Color', 'w', 'Visible', 'off');
plot(xm/1000, zm/1000, 'b', 'LineWidth', 1.4);
hold on;
plot(xt(end)/1000, zt(end)/1000, 'rx', 'LineWidth', 1.5, 'MarkerSize', 9);
grid on;
axis equal;
xlabel('X (km)');
ylabel('Z (km)');
title(sprintf('Case %d - horizontal trajectory', caseId));
exportgraphics(fig, fullfile(outDir, sprintf('case%d_trajectory_simulink.png', caseId)), 'Resolution', 300);
close(fig);

fig = figure('Color', 'w', 'Visible', 'off');
subplot(3,1,1);
plot(t, S.MissDist.Data/1000, 'LineWidth', 1.2);
grid on;
ylabel('Range (km)');
subplot(3,1,2);
plot(t, S.Vm.Data, 'LineWidth', 1.2);
grid on;
ylabel('V (m/s)');
subplot(3,1,3);
if isa(S.Guiamento, 'timeseries')
    plot(S.Guiamento.Time, S.Guiamento.Data, 'LineWidth', 1.2);
else
    plot(t, S.Guiamento, 'LineWidth', 1.2);
end
grid on;
xlabel('t (s)');
ylabel('Terminal');
exportgraphics(fig, fullfile(outDir, sprintf('case%d_history_simulink.png', caseId)), 'Resolution', 300);
close(fig);
end
