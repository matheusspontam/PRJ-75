%% PlotRootLocus.m
% Desenha os 3 root loci do projeto (malha interna, externa de atitude,
% externa de aceleracao) com o GANHO ESCOLHIDO marcado (quadrado vermelho).
% Usa os ganhos salvos em autopiloto.mat (gerados por ProjAutopiloto_auto.m).
%
% Ponto de operacao (edite se quiser ver outra condicao):
ic = 2;     % indice de CG  (1=lancamento ... 4=vazio)
ia = 1;     % indice de altitude (1=10 m, 2=100 m)
im = 3;     % indice de Mach (1=0.6, 2=0.75, 3=0.9)
% --------------------------------------------------------------------------
clearvars -except ic ia im; close all;
D=DadosMissil; D=DadosCGInercia(D); D=DadosControle(D); CRM=D.CRM(1);
S=load('autopiloto.mat');
Mach=S.vet_Mach(im); alt=S.vet_altitude(ia); xcg=S.vet_x_CG(ic);
Kat=S.T_at_k_int(ic,ia,im); KAt=S.T_at_k_ext(ic,ia,im); KAz=S.T_acel_k_ext(ic,ia,im);

% massa/inercia na fase correspondente (mesma logica do projeto)
VetTmp=[D.TTrav, D.TqB, D.TqB+D.TqS/2, D.TqB+D.TqS];
m  = interp1(D.VProp(:,1),D.VProp(:,3),VetTmp(ic))+D.mf;
Iy = interp1(D.IMissil(:,1),D.IMissil(:,3),VetTmp(ic));
dxcg=(xcg-CRM)/D.DRef;

% atuador e dinamica
wnat=100*2*pi; AT=tf(wnat^2,[1 2*wnat*sqrt(2)/2 wnat^2]); Integ=tf(1,[1 0]);
[Din_acel,~,~,Din_q]=FTransDin(Mach,alt,m,Iy,dxcg,D.DRef,D.SRef);
A2=minreal(ss([Din_q;Din_acel]));            % in:dlt  out:[q;Az]

% sinal de realimentacao estabilizante (mesma regra do projeto)
sgnOf=@(G,K) localSgn(G,K);

figure('Position',[60 60 1300 430]);

% ---- 1) MALHA INTERNA (giro): ea -> q, ganho Kat na realimentacao ----
Lq=AT*Din_q; Sin=sgnOf(Lq,linspace(0,5,200));
Ls=-Sin*Lq;                                  % locus exibido = sinal estabilizante
subplot(1,3,1); rlocusplot(Ls); hold on; sgrid;
p=rlocus(Ls,Kat); plot(real(p),imag(p),'rs','MarkerFaceColor','r','MarkerSize',8);
axis([-15 2 -15 15]); title(sprintf('INTERNA (giro)  K_{int}=%.3f',Kat));

% inner fechada p/ montar as externas
Lq2=series(AT,A2); sys_in=feedback(Lq2,Kat,1,1,Sin); Tq=sys_in(1); TAz=sys_in(2);

% ---- 2) MALHA EXTERNA DE ATITUDE: ea -> theta=q/s ----
Lat=minreal(Tq*Integ); Sat=sgnOf(Lat,linspace(0,50,200)); Lats=-Sat*Lat;
subplot(1,3,2); rlocusplot(Lats); hold on; sgrid;
p=rlocus(Lats,KAt); plot(real(p),imag(p),'rs','MarkerFaceColor','r','MarkerSize',8);
axis([-30 5 -30 30]); title(sprintf('ATITUDE externa  K_{ext}=%.3f',KAt));

% ---- 3) MALHA EXTERNA DE ACELERACAO: Aref -> Az (integrador) ----
Laz=minreal(Integ*TAz); Saz=sgnOf(Laz,linspace(0,2,200)); Lazs=-Saz*Laz;
subplot(1,3,3); rlocusplot(Lazs); hold on; sgrid;
p=rlocus(Lazs,KAz); plot(real(p),imag(p),'rs','MarkerFaceColor','r','MarkerSize',8);
axis([-20 5 -20 20]); title(sprintf('ACELERACAO externa  K_{ext}=%.4f',KAz));

sgtitle(sprintf('Root locus - Mach %.2f, alt %d m, CG %.2f m  (\\square = ganho escolhido)',Mach,alt,xcg));

OUT=getenv('OUTDIR'); if isempty(OUT); OUT=pwd; end
if ~exist(fullfile(OUT,'figures'),'dir'); mkdir(fullfile(OUT,'figures')); end
exportgraphics(gcf,fullfile(OUT,'figures','rootlocus.png'),'Resolution',140);

function SGN=localSgn(G,K)
  R1=rlocus(G,K); R2=rlocus(-G,K); j=min(3,size(R1,2));
  if max(real(R2(:,j)))<max(real(R1(:,j))); SGN=+1; else; SGN=-1; end
end
