%% RespostaDegrau5g.m - resposta a degrau de 5 g (Simulacao vs Requisito)
% Reproduz a malha de ACELERACAO comandada a 5 g, em g, comparada a um 2a
% ordem com a banda exigida. Usa a montagem EXATA do ProjRLocus (T_ac_out_mf).
OUT='C:/Users/Savio/Documents/PRJ-75/Plots_Relevantes/'; f_req=0.5;
S=load('autopiloto.mat'); D=DadosMissil; D=DadosCGInercia(D); D=DadosControle(D); CRM=D.CRM(1);
VetTmp=[D.TTrav, D.TqB/3, 2*D.TqB/3, D.TqB, D.TqB+D.TqS/2, D.TqB+D.TqS];
vet_I=interp1(D.IMissil(:,1),D.IMissil(:,3),VetTmp);
vet_m=interp1(D.VProp(:,1),D.VProp(:,3),VetTmp)+D.mf;
x_CG =interp1(D.CGMissil(:,1),D.CGMissil(:,2),VetTmp);
ic=6; ia=1; im=3;                       % terminal (mais leve), 10 m, Mach 0.9
Mach=S.vet_Mach(im); alt=S.vet_altitude(ia);
m=vet_m(ic); Iy=vet_I(ic); dxcg=(x_CG(ic)-CRM)/D.DRef;
Kat=S.T_at_k_int(ic,ia,im); KAz=S.T_acel_k_ext(ic,ia,im);

wnat=100*2*pi; qsiat=sqrt(2)/2; ATnum=wnat^2; ATden=[1 2*wnat*qsiat wnat^2];
[Din_acel,~,~,Din_q]=FTransDin(Mach,alt,m,Iy,dxcg,D.DRef,D.SRef);
% malha fechada de aceleracao EXATA do projeto/modelo:
At=tf(-ATnum*Kat,ATden); At.u='ed'; At.y='dlt';      % atuador*Kat (sinal -)
Tin=connect(Din_q,At,sumblk('ed=ea-q'),'ea','dlt');  % inner (giro) fechado
Amp=tf(-KAz,[1 0]); Amp.u='e'; Amp.y='ea';           % integrador externo *KAz
Taz=connect(Amp,Tin,Din_acel,sumblk('e=Aref-Az'),'Aref','Az');

wn=2*pi*f_req; zt=0.7; Gref=tf(wn^2,[1 2*zt*wn wn^2]);   % requisito de banda
t=0:0.002:3; y_sim=5*step(Taz,t); y_req=5*step(Gref,t); bw=bandwidth(Taz)/2/pi;
fprintf('KAz=%.3f  banda=%.2f Hz  pico=%.2f g (overshoot %.0f%%)  estavel=%d\n',...
        KAz,bw,max(y_sim),(max(y_sim)/5-1)*100,isstable(Taz));
fig=figure('Position',[60 60 720 520]); hold on;
plot(t,y_req,'k','LineWidth',1.1); plot(t,y_sim,'b','LineWidth',1.1);
grid on; xlabel('t (s)'); ylabel('Aceleracao Lateral (g)'); ylim([0 6]);
legend(sprintf('Requisito (%.1f Hz)',f_req),'Simulacao','Location','southeast');
title(sprintf('Resposta a degrau de 5 g  (terminal, Mach %.1f, banda %.1f Hz)',Mach,bw));
exportgraphics(fig,[OUT '08_degrau_5g.png'],'Resolution',140); disp('08 OK');
