function export_exocet_aero_plots_en(outdir)

if nargin < 1
    outdir = 'C:\Users\mathe\p1-prj75\exocet_datcom_report\figures';
end

if ~exist(outdir, 'dir')
    mkdir(outdir);
end

load('M_aed.mat');

delta = dados.delta;
mach = dados.mach;
alpha = dados.alpha;
sel_delta = 1:5:numel(delta);

for im = 1:numel(mach)
    fig = figure('Color', 'w');
    subplot(1,2,1);
    hold on;
    for id = sel_delta
        plot(alpha, squeeze(M_CN(id, im, :)), 'DisplayName', sprintf('\\delta = %.0f deg', delta(id)));
    end
    grid on;
    xlabel('Angle of attack, \alpha (deg)');
    ylabel('Normal-force coefficient, C_N');
    title(sprintf('Normal-force coefficient - Mach %.1f', mach(im)));
    legend('Location', 'best');

    subplot(1,2,2);
    hold on;
    for id = sel_delta
        plot(alpha, squeeze(M_CM(id, im, :)), 'DisplayName', sprintf('\\delta = %.0f deg', delta(id)));
    end
    grid on;
    xlabel('Angle of attack, \alpha (deg)');
    ylabel('Pitching-moment coefficient, C_M');
    title(sprintf('Pitching-moment coefficient - Mach %.1f', mach(im)));
    legend('Location', 'best');
    exportgraphics(fig, fullfile(outdir, sprintf('aero_cm_cn_%02d.png', im)), 'Resolution', 220);
    close(fig);

    fig = figure('Color', 'w');
    hold on;
    for id = sel_delta
        plot(alpha, squeeze(M_CD(id, im, :)), 'DisplayName', sprintf('\\delta = %.0f deg', delta(id)));
    end
    grid on;
    xlabel('Angle of attack, \alpha (deg)');
    ylabel('Drag coefficient, C_D');
    title(sprintf('Drag coefficient - Mach %.1f', mach(im)));
    legend('Location', 'best');
    exportgraphics(fig, fullfile(outdir, sprintf('aero_cd_%02d.png', im)), 'Resolution', 220);
    close(fig);

    id0 = find(delta == 0, 1);
    if isempty(id0)
        id0 = ceil(numel(delta)/2);
    end
    fig = figure('Color', 'w');
    subplot(2,2,1);
    plot(alpha, squeeze(M_CA(id0, im, :))); grid on;
    xlabel('\alpha (deg)'); ylabel('C_A');
    title('Axial-force coefficient');
    subplot(2,2,2);
    plot(alpha, squeeze(M_CN(id0, im, :))); grid on;
    xlabel('\alpha (deg)'); ylabel('C_N');
    title('Normal-force coefficient');
    subplot(2,2,3);
    plot(alpha, squeeze(M_CM(id0, im, :))); grid on;
    xlabel('\alpha (deg)'); ylabel('C_M');
    title('Pitching-moment coefficient');
    subplot(2,2,4);
    plot(alpha, squeeze(M_CMQ(id0, im, :))); grid on;
    xlabel('\alpha (deg)'); ylabel('C_{Mq}');
    title('Pitch-rate damping derivative');
    sgtitle(sprintf('Aerodynamic coefficients at Mach %.1f, \\delta = 0 deg', mach(im)));
    exportgraphics(fig, fullfile(outdir, sprintf('aero_coef_%02d.png', im)), 'Resolution', 220);
    close(fig);
end

end
