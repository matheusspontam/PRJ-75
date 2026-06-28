addpath(fullfile(fileparts(mfilename('fullpath')), '..', '..', '..', '00_Comum'));  % fonte comum (00_Comum)
clear all;

cte_grav = 9.8;
D2R = pi/180;
R2D = 180/pi;

C = CondLanc6DOF;
D = DadosMissil;
D = DadosCGInercia(D);

load M_aed.mat;
D.Cmap = 0;

sim('Dinamica6DOF.slx');

SalvaDinamica6DOF;

outdir = 'C:\Users\mathe\p1-prj75\exocet_datcom_report\figures';
plot_exocet_6dof(S, outdir);
save('S_exocet.mat', 'S', 'D', 'C');
