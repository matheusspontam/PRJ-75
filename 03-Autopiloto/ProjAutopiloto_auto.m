%% ProjAutopiloto_auto.m
% Projeto automatizado dos autopilotos de ATITUDE e ACELERACAO (root locus),
% baseado em ProjRLocus.m do prof. Seleciona automaticamente o sinal de
% realimentacao estabilizante (nosso Din_q tem ganho negativo).
% Gera: autopiloto.mat, curvas de ganho, respostas degrau e checa requisitos.
clear; close all;
OUT=getenv('OUTDIR'); if isempty(OUT); OUT=tempdir; end
D=DadosMissil; D=DadosCGInercia(D); D=DadosControle(D);
CRM=D.CRM(1); R2D=180/pi; g=9.8;

% Atuador (2a ordem, rapido)
wnat=100*2*pi; qsiat=sqrt(2)/2; AT=tf(wnat^2,[1 2*wnat*qsiat wnat^2]);
Integ=tf(1,[1 0]);

% grade de projeto
VetTmp=[D.TTrav, D.TqB, D.TqB+D.TqS/2, D.TqB+D.TqS];
altitude=[10 100]; Mach=[0.6 0.75 0.9];
vet_I=interp1(D.IMissil(:,1),D.IMissil(:,3),VetTmp);
vet_m=interp1(D.VProp(:,1),D.VProp(:,3),VetTmp)+D.mf;
x_CG=interp1(D.CGMissil(:,1),D.CGMissil(:,2),VetTmp);
NC=numel(x_CG); NA=numel(altitude); NM=numel(Mach);

T_at_k_int=zeros(NC,NA,NM); T_at_k_ext=zeros(NC,NA,NM);
T_acel_k_int=zeros(NC,NA,NM); T_acel_k_ext=zeros(NC,NA,NM);
BW_at=zeros(NC,NA,NM); BW_ac=zeros(NC,NA,NM); MaxAz_g=zeros(NC,NA,NM);
nomC=2; nomA=1; nomM=3; nom=struct();

for ic=1:NC
 for ia=1:NA
  for im=1:NM
    m=vet_m(ic); Iy=vet_I(ic); dxcg=(x_CG(ic)-CRM)/D.DRef;
    [Din_acel,~,~,Din_q]=FTransDin(Mach(im),altitude(ia),m,Iy,dxcg,D.DRef,D.SRef);

    % --- airframe como UM state-space, 2 saidas [q; Az] (polos compartilhados) ---
    A2=minreal(ss([Din_q;Din_acel]));         % in: dlt   out: [q; Az]

    % --- malha interna (girometro): maximiza amortecimento do short-period ---
    Lq=AT*Din_q;                              % SISO p/ achar sinal e ganho do giro
    Kg=linspace(0,5,4000);
    [Rin,Sin]=rlocStab(Lq,Kg);                % Sin = sinal de realimentacao
    z=domDamp(Rin,60); [zin_max,jb]=max(z); Kat=Kg(jb);
    Lq2=series(AT,A2);                         % ed -> [q; Az]
    sys_in=feedback(Lq2,Kat,1,1,Sin);          % fecha giro (q=saida1):  ea -> [q; Az]
    Tq=sys_in(1); TAz=sys_in(2);

    % --- malha externa de ATITUDE (theta = q/s), modo de manobra zeta=0.5 ---
    Lat=minreal(Tq*Integ);
    [~,Sat]=rlocStab(Lat,linspace(0,50,200));
    KAt=findKdes(Lat,Sat,linspace(0.05,300,600),0.5);
    Tat=feedback(KAt*Lat,1,Sat);              % ref -> theta (fechada)
    if dcgain(Tat)<0; Tat=feedback(-KAt*Lat,1,-Sat); end  % polaridade p/ rastrear +1

    % --- malha externa de ACELERACAO (Az), integrador, modo de manobra zeta=0.5 ---
    Laz=minreal(Integ*TAz);
    [~,Saz]=rlocStab(Laz,linspace(0,2,200));
    KAz=findKdes(Laz,Saz,linspace(0.001,2,600),0.5);
    Taz=feedback(KAz*Laz,1,Saz);              % Aref -> Az (fechada)
    if dcgain(Taz)<0; Taz=feedback(-KAz*Laz,1,-Saz); end  % polaridade p/ rastrear +1

    T_at_k_int(ic,ia,im)=Kat; T_acel_k_int(ic,ia,im)=Kat;
    T_at_k_ext(ic,ia,im)=KAt; T_acel_k_ext(ic,ia,im)=KAz;
    try BW_at(ic,ia,im)=bandwidth(Tat)/2/pi; catch; BW_at(ic,ia,im)=NaN; end
    try BW_ac(ic,ia,im)=bandwidth(Taz)/2/pi; catch; BW_ac(ic,ia,im)=NaN; end
    MaxAz_g(ic,ia,im)=abs(dcgain(Din_acel))*D.Dlt_max/g;

    if ic==nomC && ia==nomA && im==nomM
       nom.Tat=Tat; nom.Taz=Taz; nom.Kat=Kat; nom.KAt=KAt; nom.KAz=KAz; nom.xcg=x_CG(ic);
       nom.zin=zin_max;
    end
  end
 end
end

vet_x_CG=x_CG; vet_altitude=altitude; vet_Mach=Mach;
save autopiloto.mat T_acel_k_ext T_at_k_ext T_at_k_int T_acel_k_int vet_x_CG vet_altitude vet_Mach;

%% curvas de ganho
if ~exist(fullfile(OUT,'figures'),'dir'); mkdir(fullfile(OUT,'figures')); end
FIG=fullfile(OUT,'figures');
% --- ganhos vs Mach (alt=10 m), uma linha por CG ---
cores=lines(NC); LEG=arrayfun(@(x)sprintf('CG=%.2f m',x),x_CG,'uni',0);
figure('Position',[80 80 1100 720]);
subplot(2,2,1); hold on; for ic=1:NC; plot(Mach,squeeze(T_at_k_int(ic,1,:)),'o-','Color',cores(ic,:)); end
grid on; xlabel('Mach'); ylabel('K_{int} (giro)'); title('Malha INTERNA (comum)'); legend(LEG,'Location','best');
subplot(2,2,2); hold on; for ic=1:NC; plot(Mach,squeeze(T_at_k_ext(ic,1,:)),'o-','Color',cores(ic,:)); end
grid on; xlabel('Mach'); ylabel('K_{ext}'); title('ATITUDE - malha externa');
subplot(2,2,3); hold on; for ic=1:NC; plot(Mach,squeeze(T_acel_k_ext(ic,1,:)),'o-','Color',cores(ic,:)); end
grid on; xlabel('Mach'); ylabel('K_{ext}'); title('ACELERACAO - malha externa');
subplot(2,2,4); hold on; for ic=1:NC; plot(Mach,squeeze(BW_at(ic,1,:)),'o-','Color',cores(ic,:)); plot(Mach,squeeze(BW_ac(ic,1,:)),'s--','Color',cores(ic,:)); end
yline(0.5,'k:','req 0.5 Hz'); grid on; xlabel('Mach'); ylabel('Banda (Hz)'); title('Banda passante: o=atitude  \square=aceleracao');
sgtitle('Curvas de ganho e banda - alt 10 m');
exportgraphics(gcf,fullfile(FIG,'ganhos_vs_mach.png'),'Resolution',140);
% --- curvas do prof (vs altitude) ---
PlotAP('autopiloto.mat');
figs=findobj('type','figure');
for k=1:numel(figs)-1
  exportgraphics(figs(k),fullfile(FIG,sprintf('ganhos_alt_mach%.2f.png',vet_Mach(min(k,NM)))),'Resolution',120);
end
OUT=FIG;  % respostas degrau tambem na pasta figures

%% respostas degrau (ponto nominal)
figure('Position',[100 100 950 380]);
subplot(1,2,1); t=0:0.005:3; plot(t,step(nom.Tat,t),'LineWidth',1.4); grid on;
xlabel('t (s)'); ylabel('\theta/\theta_{ref}');
title(sprintf('Degrau ATITUDE  (M0.9, 10m, CG%.2f)\nK_{int}=%.3g  K_{ext}=%.3g',nom.xcg,nom.Kat,nom.KAt));
subplot(1,2,2); t2=0:0.01:6; plot(t2,step(nom.Taz,t2),'LineWidth',1.4); grid on;
xlabel('t (s)'); ylabel('A_z/A_{z,ref}');
title(sprintf('Degrau ACELERACAO\nK_{int}=%.3g  K_{ext}=%.3g',nom.Kat,nom.KAz));
exportgraphics(gcf,fullfile(OUT,'degrau.png'),'Resolution',140);

%% capacidade de aceleracao NAO-LINEAR (trim)
Aer=load('M_aed.mat');
fprintf('\n--- Capacidade de aceleracao por trim (alt 10m) ---\n');
fprintf('  Mach  CG       d=10deg  d=15deg  d=20deg\n');
azNL=[];
for im2=[3 2]
  for ic2=1:NC
    g10=trimAzg(Aer.dados,Aer.M_CN,Aer.M_CM,x_CG(ic2),Mach(im2),10,10,vet_m(ic2));
    g15=trimAzg(Aer.dados,Aer.M_CN,Aer.M_CM,x_CG(ic2),Mach(im2),15,10,vet_m(ic2));
    g20=trimAzg(Aer.dados,Aer.M_CN,Aer.M_CM,x_CG(ic2),Mach(im2),20,10,vet_m(ic2));
    fprintf('  %.2f  %6.2f   %6.2f   %6.2f   %6.2f\n',Mach(im2),x_CG(ic2),g10,g15,g20);
    azNL(end+1,:)=[g10 g15 g20];
  end
end

%% requisitos
fprintf('\n==================== REQUISITOS ====================\n');
fprintf('1) Banda passante >= 0.5 Hz:\n');
fprintf('   ATITUDE: %.2f a %.2f Hz  -> %s\n',min(BW_at(:)),max(BW_at(:)),tf2str(min(BW_at(:))>=0.5));
fprintf('   ACELER.: %.2f a %.2f Hz  -> %s\n',min(BW_ac(:)),max(BW_ac(:)),tf2str(min(BW_ac(:))>=0.5));
fprintf('2) Aceleracao lateral (trim nao-linear) - ALVO >= 5 g:\n');
azM09=azNL(1:NC,:);  % primeiras NC linhas = Mach 0.9
azM075=azNL(NC+1:end,:); % Mach 0.75
fprintf('   @20deg  Mach0.9: %.2f a %.2f g  -> %s\n',min(azM09(:,3)),max(azM09(:,3)),tf2str(min(azM09(:,3))>=5));
fprintf('   @20deg  Mach0.75: %.2f a %.2f g  -> %s\n',min(azM075(:,3)),max(azM075(:,3)),tf2str(min(azM075(:,3))>=5));
fprintf('   (limite de leme Dlt_max=%.0f deg)\n',D.Dlt_max*R2D);
fprintf('Ganhos nominais (M0.9,10m,CG%.2f): K_int=%.4g  K_ext_at=%.4g  K_ext_ac=%.4g\n',nom.xcg,nom.Kat,nom.KAt,nom.KAz);
fprintf('Amortecimento malha interna (nominal) = %.2f\n',nom.zin);
fprintf('Nominal BW(-3dB): atitude=%.2f Hz  aceleracao=%.2f Hz\n',BW_at(nomC,nomA,nomM),BW_ac(nomC,nomA,nomM));
fprintf('===================================================\n');

%% ===== funcoes locais =====
function [R,SGN]=rlocStab(G,K)
  % escolhe o sinal de realimentacao estabilizante comparando em GANHO PEQUENO
  % (onde o sinal correto mantem os polos no semiplano esquerdo)
  R1=rlocus(G,K); R2=rlocus(-G,K);
  j=min(3,size(R1,2));
  if max(real(R2(:,j)))<max(real(R1(:,j))); R=R2; SGN=+1; else; R=R1; SGN=-1; end
end
function z=domDamp(R,fmax)
  % amortecimento do polo mais proximo da instabilidade (maior parte real),
  % entre os polos "lentos" (exclui integrador~0 e atuador>fmax)
  nK=size(R,2); z=ones(1,nK);
  for j=1:nK
    p=R(:,j); p=p(imag(p)>=-1e-9); p=p(abs(p)>1e-2 & abs(p)<fmax);
    if isempty(p); z(j)=1; continue; end
    [~,id]=max(real(p)); z(j)=-real(p(id))/abs(p(id));
  end
end
function azg=trimAzg(dados,M_CN,M_CM,xcg,Mach,delta_deg,alt,m)
  S=pi*0.35^2/4; [~,a,~,rho]=atmosisa(alt); q=0.5*rho*(Mach*a)^2; CRMx=-dados.XCG;
  al=linspace(min(dados.alpha),max(dados.alpha),600);
  dg=dados.delta(:); mg=dados.mach(:); ag=dados.alpha(:);
  CMv=reshape(interpn(dg,mg,ag,M_CM,delta_deg*ones(size(al)),Mach*ones(size(al)),al),1,[]);
  CNv=reshape(interpn(dg,mg,ag,M_CN,delta_deg*ones(size(al)),Mach*ones(size(al)),al),1,[]);
  Cm=CMv-(xcg-CRMx)*CNv; s=sign(Cm); idx=find(s(1:end-1).*s(2:end)<0,1);
  if isempty(idx); azg=NaN; return; end
  at=interp1([Cm(idx) Cm(idx+1)],[al(idx) al(idx+1)],0);
  CNt=interp1([al(idx) al(idx+1)],[CNv(idx) CNv(idx+1)],at);
  azg=abs(q*S*CNt/m)/9.8;
end
function K=findKdes(L,Sgn,Kv,ztgt)
  % ganho de projeto = min( ganho onde o modo de manobra (par complexo 3..60 rad/s)
  % atinge zeta=ztgt , 0.5*ganho_de_instabilidade ).  Garante amortecimento E margem.
  Kstab=Kv(end); Kz=Kv(end); foundz=false;
  for kk=Kv
    T=feedback(kk*L,1,Sgn); p=pole(T);
    if any(real(p)>1e-6); Kstab=kk; break; end
    if ~foundz
      pc=p(imag(p)>1e-6 & abs(p)>3 & abs(p)<60);
      if ~isempty(pc); [~,id]=max(real(pc));
         if -real(pc(id))/abs(pc(id))<ztgt; Kz=kk; foundz=true; end; end
    end
  end
  K=min(Kz,0.5*Kstab); if K<Kv(1); K=Kv(1); end
end
function s=tf2str(b); if b; s='OK'; else; s='NAO ATENDE'; end; end
