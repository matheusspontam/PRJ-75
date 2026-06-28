function PlotGanhosMach(ap_fname, ia)
%-----------------------------------------------------
% PlotGanhosMach.m - curvas de ganho do autopiloto em funcao do MACH
% (uma curva por CG), para uma altitude fixa.
% Diferente do PlotAP.m do prof, que plota ganho x ALTITUDE (1 fig/Mach):
% como so ha 2 altitudes e o ganho quase nao varia com altitude, a
% variacao relevante e com o Mach -> esta e a visao informativa.
%
% Uso:  PlotGanhosMach            % autopiloto.mat, altitude 10 m
%       PlotGanhosMach('autopiloto.mat', 2)   % altitude 100 m
%-----------------------------------------------------
if nargin < 1 || isempty(ap_fname); ap_fname = 'autopiloto.mat'; end
if nargin < 2 || isempty(ia);       ia = 1;  end          % 1=10m, 2=100m
S = load(ap_fname);
NCG = numel(S.vet_x_CG);
LEG = arrayfun(@(x) sprintf('CG=%.2f m', x), S.vet_x_CG, 'uni', 0);

figure('Position',[60 60 1200 360]);

subplot(1,3,1); hold on
for ic = 1:NCG; plot(S.vet_Mach, squeeze(S.T_at_k_int(ic,ia,:)), '-o'); end
grid on; xlabel('Mach'); ylabel('K_{int}'); title('Ganho interno (giro)');
legend(LEG,'Location','best');

subplot(1,3,2); hold on
for ic = 1:NCG; plot(S.vet_Mach, squeeze(S.T_at_k_ext(ic,ia,:)), '-o'); end
grid on; xlabel('Mach'); ylabel('K_{ext}'); title('Ganho externo - ATITUDE');

subplot(1,3,3); hold on
for ic = 1:NCG; plot(S.vet_Mach, squeeze(S.T_acel_k_ext(ic,ia,:)), '-o'); end
grid on; xlabel('Mach'); ylabel('K_{ext}'); title('Ganho externo - ACELERACAO');

sgtitle(sprintf('Curvas de ganho x Mach (gain scheduling, alt %d m)', S.vet_altitude(ia)));
end
