%% PlotRootLocus.m
% Desenha os 3 root loci do projeto (malha interna de giro, externa de atitude,
% externa de aceleracao) com o GANHO ESCOLHIDO marcado (quadrado vermelho).
% Usa a montagem EXATA do ProjRLocus.m (connect), de modo que os marcadores de
% ganho ficam na posicao certa do locus. Le os ganhos de autopiloto.mat.
%
% Ponto de operacao (edite se quiser ver outra condicao):
ic = 4;     % indice de CG  (1=lancamento ... 6=vazio/terminal)
ia = 1;     % indice de altitude (1=10 m, 2=100 m)
im = 3;     % indice de Mach (1=0.6, 2=0.75, 3=0.9)
% --------------------------------------------------------------------------
clearvars -except ic ia im; close all;
D=DadosMissil; D=DadosCGInercia(D); D=DadosControle(D); CRM=D.CRM(1);
S=load('autopiloto.mat');
VetTmp=[D.TTrav, D.TqB/3, 2*D.TqB/3, D.TqB, D.TqB+D.TqS/2, D.TqB+D.TqS];
vet_I=interp1(D.IMissil(:,1),D.IMissil(:,3),VetTmp);
vet_m=interp1(D.VProp(:,1),D.VProp(:,3),VetTmp)+D.mf;
x_CG =interp1(D.CGMissil(:,1),D.CGMissil(:,2),VetTmp);
Mach=S.vet_Mach(im); alt=S.vet_altitude(ia); xcg=x_CG(ic);
m=vet_m(ic); Iy=vet_I(ic); dxcg=(xcg-CRM)/D.DRef;
Kat=S.T_at_k_int(ic,ia,im); KAt=S.T_at_k_ext(ic,ia,im); KAz=S.T_acel_k_ext(ic,ia,im);

wnat=100*2*pi; qsiat=sqrt(2)/2; ATnum=wnat^2; ATden=[1 2*wnat*qsiat wnat^2];
[Din_acel,~,~,Din_q]=FTransDin(Mach,alt,m,Iy,dxcg,D.DRef,D.SRef);

figure('Position',[60 60 1300 430]);

% ---- 1) MALHA INTERNA (giro): ea -> q, ganho do giro Kat ----
At0=tf(-ATnum,ATden); At0.u='ed'; At0.y='dlt';
Tin_ma=connect(Din_q,At0,sumblk('ed=ea'),'ea','q');
subplot(1,3,1); rlocusplot(Tin_ma); hold on; sgrid;
p=rlocus(Tin_ma,Kat); plot(real(p),imag(p),'rs','MarkerFaceColor','r','MarkerSize',8);
axis([-15 2 -15 15]); title({sprintf('INTERNA (giro)  K_{int}=%.3f',Kat),sprintf('Mach %.2f, CG %.2f m, alt %d m',Mach,xcg,alt)});

% inner fechada (At=-AT*Kat) p/ montar as externas
At=tf(-ATnum*Kat,ATden); At.u='ed'; At.y='dlt';
Tin_mf_q=connect(Din_q,At,sumblk('ed=ea-q'),'ea','q');
Tin_mf_d=connect(Din_q,At,sumblk('ed=ea-q'),'ea','dlt');

% ---- 2) MALHA EXTERNA DE ATITUDE: ref -> theta (Amp=1, integrador q->theta) ----
Integ=tf(1,[1 0]); Integ.u='q'; Integ.y='theta';
AmpA=tf(1,1); AmpA.u='e'; AmpA.y='ea';
Tout_ma=minreal(connect(AmpA,Tin_mf_q,Integ,sumblk('e=ref'),'ref','theta'));
subplot(1,3,2); rlocusplot(Tout_ma); hold on; sgrid;
p=rlocus(Tout_ma,KAt); plot(real(p),imag(p),'rs','MarkerFaceColor','r','MarkerSize',8);
axis([-30 5 -30 30]); title(sprintf('ATITUDE externa  K_{ext}=%.3f',KAt));

% ---- 3) MALHA EXTERNA DE ACELERACAO: Aref -> Az (integrador -1/s) ----
AmpZ=tf(-1,[1 0]); AmpZ.u='e'; AmpZ.y='ea';
Tac_out_ma=minreal(connect(AmpZ,Tin_mf_d,Din_acel,sumblk('e=Aref'),'Aref','Az'));
subplot(1,3,3); rlocusplot(Tac_out_ma); hold on; sgrid;
p=rlocus(Tac_out_ma,KAz); plot(real(p),imag(p),'rs','MarkerFaceColor','r','MarkerSize',8);
axis([-20 5 -20 20]); title(sprintf('ACELERACAO externa  K_{ext}=%.4f',KAz));

OUT=getenv('OUTDIR'); if isempty(OUT); OUT=pwd; end
exportgraphics(gcf,fullfile(OUT,'05_rootlocus.png'),'Resolution',140);
