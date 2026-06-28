%% DiagAz.m - varre KAz no terminal: overshoot, banda, amortecimento
S=load('autopiloto.mat'); D=DadosMissil; D=DadosCGInercia(D); D=DadosControle(D); CRM=D.CRM(1);
VetTmp=[D.TTrav, D.TqB/3, 2*D.TqB/3, D.TqB, D.TqB+D.TqS/2, D.TqB+D.TqS];
vet_I=interp1(D.IMissil(:,1),D.IMissil(:,3),VetTmp);
vet_m=interp1(D.VProp(:,1),D.VProp(:,3),VetTmp)+D.mf;
x_CG =interp1(D.CGMissil(:,1),D.CGMissil(:,2),VetTmp);
ic=6; ia=1; im=3; Mach=S.vet_Mach(im); alt=S.vet_altitude(ia);
m=vet_m(ic); Iy=vet_I(ic); dxcg=(x_CG(ic)-CRM)/D.DRef; Kat=S.T_at_k_int(ic,ia,im);
wnat=100*2*pi; AT=tf(wnat^2,[1 2*wnat*sqrt(2)/2 wnat^2]); Integ=tf(1,[1 0]);
[Din_acel,~,~,Din_q]=FTransDin(Mach,alt,m,Iy,dxcg,D.DRef,D.SRef);
A2=minreal(ss([Din_q;Din_acel]));
Lq=AT*Din_q; Sin=lsg(Lq,linspace(0,5,200));
sys_in=feedback(series(AT,A2),Kat,1,1,Sin); TAz=sys_in(2);
Laz=minreal(Integ*TAz); Saz=lsg(Laz,linspace(0,2,200)); Lazs=-Saz*Laz;
fprintf('KAz salvo=%.3f\n   KAz   overshoot  banda(Hz)  zeta_dom\n',S.T_acel_k_ext(ic,ia,im));
t=0:0.002:4;
for K=[0.21 0.12 0.08 0.06 0.04 0.03]
  T=feedback(K*Lazs,1); y=step(T,t); ov=(max(y)-1)*100; bw=bandwidth(T)/2/pi;
  p=pole(T); pc=p(imag(p)>1e-3); if isempty(pc); z=1; else; [~,j]=min(-real(pc)./abs(pc)); z=-real(pc(j))/abs(pc(j)); end
  fprintf('  %.3f  %7.1f%%  %7.2f   %6.2f  est=%d\n',K,ov,bw,z,isstable(T));
end
function SGN=lsg(G,K)
  R1=rlocus(G,K); R2=rlocus(-G,K); j=min(3,size(R1,2));
  if max(real(R2(:,j)))<max(real(R1(:,j))); SGN=+1; else; SGN=-1; end
end
