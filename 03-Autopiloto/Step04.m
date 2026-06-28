%% Step04.m - respostas ao degrau (atitude + aceleracao) no ponto nominal
OUT='C:/Users/Savio/Documents/PRJ-75/Plots_Relevantes/'; R2D=180/pi;
S=load('autopiloto.mat'); D=DadosMissil; D=DadosCGInercia(D); D=DadosControle(D); CRM=D.CRM(1);
ic=2; ia=1; im=3; Mach=S.vet_Mach(im); alt=S.vet_altitude(ia); xcg=S.vet_x_CG(ic);
Kat=S.T_at_k_int(ic,ia,im); KAt=S.T_at_k_ext(ic,ia,im); KAz=S.T_acel_k_ext(ic,ia,im);
VetTmp=[D.TTrav, D.TqB, D.TqB+D.TqS/2, D.TqB+D.TqS];
m=interp1(D.VProp(:,1),D.VProp(:,3),VetTmp(ic))+D.mf; Iy=interp1(D.IMissil(:,1),D.IMissil(:,3),VetTmp(ic));
dxcg=(xcg-CRM)/D.DRef;
wnat=100*2*pi; AT=tf(wnat^2,[1 2*wnat*sqrt(2)/2 wnat^2]); Integ=tf(1,[1 0]);
[Din_acel,~,~,Din_q]=FTransDin(Mach,alt,m,Iy,dxcg,D.DRef,D.SRef);
A2=minreal(ss([Din_q;Din_acel]));
Lq=AT*Din_q; Sin=lsg(Lq,linspace(0,5,200));
Lq2=series(AT,A2); sys_in=feedback(Lq2,Kat,1,1,Sin); Tq=sys_in(1); TAz=sys_in(2);
Lat=minreal(Tq*Integ); Sat=lsg(Lat,linspace(0,50,200)); Tat=feedback(KAt*(-Sat*Lat),1);
Laz=minreal(Integ*TAz); Saz=lsg(Laz,linspace(0,2,200)); Taz=feedback(KAz*(-Saz*Laz),1);
bwa=bandwidth(Tat)/2/pi; bwz=bandwidth(Taz)/2/pi;
fprintf('estavel at=%d acel=%d | DC at=%.3f acel=%.3f | banda at=%.2f Hz acel=%.2f Hz\n',...
        isstable(Tat),isstable(Taz),dcgain(Tat),dcgain(Taz),bwa,bwz);
f=figure('Position',[60 60 1050 440]);
subplot(1,2,1); step(Tat,3); grid on; ylabel('\theta/\theta_{cmd}');
title({'ATITUDE',sprintf('DC=%.2f, banda %.1f Hz',dcgain(Tat),bwa)});
subplot(1,2,2); step(Taz,8); grid on; ylabel('A_z/A_{z,cmd}');
title({'ACELERACAO',sprintf('DC=%.2f, banda %.1f Hz',dcgain(Taz),bwz)});
sgtitle(sprintf('Respostas ao degrau   (CG %.2f m, Mach %.1f, alt %d m)',xcg,Mach,alt));
exportgraphics(f,[OUT '04_degrau_autopiloto.png'],'Resolution',140); disp('04 OK');

function SGN=lsg(G,K)
  R1=rlocus(G,K); R2=rlocus(-G,K); j=min(3,size(R1,2));
  if max(real(R2(:,j)))<max(real(R1(:,j))); SGN=+1; else; SGN=-1; end
end
