%% GeraPlots.m - regenera plots 01-05 em Plots_Relevantes (06/07 sao do guiamento)
OUT='C:/Users/Savio/Documents/PRJ-75/Plots_Relevantes/';
R2D=180/pi;

%% ---- 02: coeficientes aerodinamicos (Cn, Cm, Cd vs alpha) ----
A=load('M_aed.mat'); d=A.dados; [~,i0]=min(abs(d.delta));  % delta=0
al=d.alpha; ims=[1 5]; cor={'b','r'};
f=figure('Position',[60 60 1200 360]);
subplot(1,3,1); hold on; for k=1:2; plot(al,squeeze(A.M_CN(i0,ims(k),:)),cor{k}); end
grid on; xlabel('\alpha (deg)'); ylabel('C_N'); title('Forca normal'); legend('Mach 0.6','Mach 1.0','Location','best');
subplot(1,3,2); hold on; for k=1:2; plot(al,squeeze(A.M_CM(i0,ims(k),:)),cor{k}); end
grid on; xlabel('\alpha (deg)'); ylabel('C_m'); title('Momento (\delta=0)');
subplot(1,3,3); hold on; for k=1:2; plot(al,squeeze(A.M_CD(i0,ims(k),:)),cor{k}); end
grid on; xlabel('\alpha (deg)'); ylabel('C_D'); title('Arrasto');
sgtitle(sprintf('Coeficientes aerodinamicos (DATCOM, XCG=%.2f)',d.XCG));
exportgraphics(f,[OUT '02_coef_aerodinamicos.png'],'Resolution',140);

%% ---- 03: curvas de ganho do autopiloto (vs Mach, alt 10 m) ----
S=load('autopiloto.mat'); ia=1; NCG=numel(S.vet_x_CG);
LEG=arrayfun(@(x)sprintf('CG=%.2f',x),S.vet_x_CG,'uni',0);
f=figure('Position',[60 60 1200 360]);
subplot(1,3,1); hold on; for ic=1:NCG; plot(S.vet_Mach,squeeze(S.T_at_k_int(ic,ia,:)),'-o'); end
grid on; xlabel('Mach'); ylabel('K_{int}'); title('Ganho interno (giro)'); legend(LEG,'Location','best');
subplot(1,3,2); hold on; for ic=1:NCG; plot(S.vet_Mach,squeeze(S.T_at_k_ext(ic,ia,:)),'-o'); end
grid on; xlabel('Mach'); ylabel('K_{ext}'); title('Ganho externo - ATITUDE');
subplot(1,3,3); hold on; for ic=1:NCG; plot(S.vet_Mach,squeeze(S.T_acel_k_ext(ic,ia,:)),'-o'); end
grid on; xlabel('Mach'); ylabel('K_{ext}'); title('Ganho externo - ACELERACAO');
sgtitle('Curvas de ganho (gain scheduling, alt 10 m)');
exportgraphics(f,[OUT '03_ganhos_autopiloto.png'],'Resolution',140);

%% ---- 04: respostas ao degrau (atitude + aceleracao) no ponto nominal ----
D=DadosMissil; D=DadosCGInercia(D); D=DadosControle(D); CRM=D.CRM(1);
ic=2; ia=1; im=3; Mach=S.vet_Mach(im); alt=S.vet_altitude(ia); xcg=S.vet_x_CG(ic);
Kat=S.T_at_k_int(ic,ia,im); KAt=S.T_at_k_ext(ic,ia,im); KAz=S.T_acel_k_ext(ic,ia,im);
VetTmp=[D.TTrav, D.TqB, D.TqB+D.TqS/2, D.TqB+D.TqS];
m=interp1(D.VProp(:,1),D.VProp(:,3),VetTmp(ic))+D.mf; Iy=interp1(D.IMissil(:,1),D.IMissil(:,3),VetTmp(ic));
dxcg=(xcg-CRM)/D.DRef;
wnat=100*2*pi; AT=tf(wnat^2,[1 2*wnat*sqrt(2)/2 wnat^2]); Integ=tf(1,[1 0]);
[Din_acel,~,~,Din_q]=FTransDin(Mach,alt,m,Iy,dxcg,D.DRef,D.SRef);
A2=minreal(ss([Din_q;Din_acel]));
sg=@(G,K)localSgn(G,K);
Lq=AT*Din_q; Sin=sg(Lq,linspace(0,5,200));
Lq2=series(AT,A2); sys_in=feedback(Lq2,Kat,1,1,Sin); Tq=sys_in(1); TAz=sys_in(2);
Lat=minreal(Tq*Integ); Sat=sg(Lat,linspace(0,50,200)); Tat=feedback(KAt*(-Sat*Lat),1);
Laz=minreal(Integ*TAz); Saz=sg(Laz,linspace(0,2,200)); Taz=feedback(KAz*(-Saz*Laz),1);
fprintf('DC atitude=%.3f  DC acel=%.3f\n',dcgain(Tat),dcgain(Taz));
f=figure('Position',[60 60 1000 380]);
subplot(1,2,1); step(Tat,3); grid on; title(sprintf('Degrau ATITUDE (DC=%.2f) Mach %.1f',dcgain(Tat),Mach)); ylabel('\theta/\theta_{cmd}');
subplot(1,2,2); step(Taz,5); grid on; title(sprintf('Degrau ACELERACAO (DC=%.2f)',dcgain(Taz))); ylabel('A_z/A_{z,cmd}');
sgtitle(sprintf('Respostas ao degrau - CG %.2f m, alt %d m',xcg,alt));
exportgraphics(f,[OUT '04_degrau_autopiloto.png'],'Resolution',140);

%% ---- 05: root locus ----
setenv('OUTDIR',OUT(1:end-1)); PlotRootLocus;
copyfile([OUT 'figures/rootlocus.png'],[OUT '05_rootlocus.png']);

%% ---- 01: PlotGMax (faz clear all -> por ultimo; sobrescreve P) ----
cd('C:/Users/Savio/Documents/PRJ-75/02-Dinamica6DOF'); PlotGMax;
OUT='C:/Users/Savio/Documents/PRJ-75/Plots_Relevantes/';
exportgraphics(gcf,[OUT '01_Gmax_manobra_maxima.png'],'Resolution',140);
disp('PLOTS 01-05 OK');

function SGN=localSgn(G,K)
  R1=rlocus(G,K); R2=rlocus(-G,K); j=min(3,size(R1,2));
  if max(real(R2(:,j)))<max(real(R1(:,j))); SGN=+1; else; SGN=-1; end
end
