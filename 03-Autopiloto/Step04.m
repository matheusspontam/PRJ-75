%% Step04.m - respostas ao degrau (atitude + aceleracao), montagem EXATA do projeto
OUT='C:/Users/Savio/Documents/PRJ-75/Plots_Relevantes/';
S=load('autopiloto.mat'); D=DadosMissil; D=DadosCGInercia(D); D=DadosControle(D); CRM=D.CRM(1);
VetTmp=[D.TTrav, D.TqB/3, 2*D.TqB/3, D.TqB, D.TqB+D.TqS/2, D.TqB+D.TqS];
vet_I=interp1(D.IMissil(:,1),D.IMissil(:,3),VetTmp);
vet_m=interp1(D.VProp(:,1),D.VProp(:,3),VetTmp)+D.mf;
x_CG =interp1(D.CGMissil(:,1),D.CGMissil(:,2),VetTmp);
ic=4; ia=1; im=3; Mach=S.vet_Mach(im); alt=S.vet_altitude(ia); xcg=x_CG(ic);
m=vet_m(ic); Iy=vet_I(ic); dxcg=(xcg-CRM)/D.DRef;
Kat=S.T_at_k_int(ic,ia,im); KAt=S.T_at_k_ext(ic,ia,im); KAz=S.T_acel_k_ext(ic,ia,im);
wnat=100*2*pi; qsiat=sqrt(2)/2; ATnum=wnat^2; ATden=[1 2*wnat*qsiat wnat^2];
[Din_acel,~,~,Din_q]=FTransDin(Mach,alt,m,Iy,dxcg,D.DRef,D.SRef);
At=tf(-ATnum*Kat,ATden); At.u='ed'; At.y='dlt';
Tin=connect(Din_q,At,sumblk('ed=ea-q'),'ea','q');               % inner (giro), saida q
% ATITUDE: externa proporcional (ganho KAt), integrador q->theta
Integ=tf(1,[1 0]); Integ.u='q'; Integ.y='theta';
AmpA=tf(KAt,1); AmpA.u='e'; AmpA.y='ea';
Tat=connect(AmpA,Tin,Integ,sumblk('e=ref-theta'),'ref','theta');
% ACELERACAO: externa com integrador (-KAz/s); inner com saida Az
Tin2=connect(Din_q,At,sumblk('ed=ea-q'),'ea','dlt');
AmpZ=tf(-KAz,[1 0]); AmpZ.u='e'; AmpZ.y='ea';
Taz=connect(AmpZ,Tin2,Din_acel,sumblk('e=Aref-Az'),'Aref','Az');
bwa=bandwidth(Tat)/2/pi; bwz=bandwidth(Taz)/2/pi;
fprintf('estavel at=%d acel=%d | DC at=%.3f acel=%.3f | banda at=%.2f Hz acel=%.2f Hz\n',...
        isstable(Tat),isstable(Taz),dcgain(Tat),dcgain(Taz),bwa,bwz);
ta=0:0.005:3; ya=step(Tat,ta); tz=0:0.005:4; yz=step(Taz,tz);
f=figure('Position',[60 60 1050 440]);
subplot(1,2,1); plot(ta,ya,'b','LineWidth',1.1); grid on; xlabel('t (s)'); ylabel('\theta/\theta_{cmd}');
yline(1,'k:'); title({'ATITUDE',sprintf('DC=%.2f, banda %.1f Hz',dcgain(Tat),bwa)});
subplot(1,2,2); plot(tz,yz,'b','LineWidth',1.1); grid on; xlabel('t (s)'); ylabel('A_z/A_{z,cmd}');
yline(1,'k:'); title({'ACELERACAO',sprintf('DC=%.2f, banda %.1f Hz',dcgain(Taz),bwz)});
sgtitle(sprintf('Respostas ao degrau   (CG %.2f m, Mach %.1f, alt %d m)',xcg,Mach,alt));
exportgraphics(f,[OUT '04_degrau_autopiloto.png'],'Resolution',140); disp('04 OK');
