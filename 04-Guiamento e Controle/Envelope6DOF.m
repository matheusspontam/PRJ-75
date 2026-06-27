%--------------------------------------------------------------------------
% Programa de Cálculo de Envelope Horizontal - Dinâmica 6DOF.m
% Saída:
%   - S: estrutura com dados de simulação
%   - Resultado: matriz com resultados dos voos do envelope
%   - Figura com envelope calculado
%--------------------------------------------------------------------------

clear all

D2R = pi/180;
R2D = 180/pi;
cte_grav = 9.8;

% Carrega dados gerais (comuns ao Massa-Ponto)
D = DadosMissil;

% Carrega dados de CG e Inércia
D = DadosCGInercia(D);

% Carrega dados de aerodinâmica
load M_aed.mat;
D.Cmap = 0;

% Carrega dados de autopiloto
D = DadosControle(D);
load autopiloto0.mat

% Condições de lançamento (normalmente definidas em CondLanc6DOF)

C.TLaser = 0;                   % (s) Instante em que laser é ligado
C.Tfim = 200;

% Velocidade inicial do Vant, expressa no Sistema Inercial (m/s)
C.Vxa0 = 200;                  
C.Vya0 = 0;
C.Vza0 = 0;

% Posição inicial do Vant, expressa no Sistema Inercial (m)
C.Xa0 = 0;                   
C.Ya0 = 0;
C.Za0 = 1000;          

% Posição do míssil no lançamento
C.Xm0 = 0;
C.Ym0 = 0;
C.Zm0 = 1000;

% Velocidade do míssil no lançamento
C.Vmx0 = 30;
C.Vmy0 = 0;
C.Vmz0 = 0;

% Ângulos de Euler do míssil no lançamento
C.Phim0  = 45*D2R;
C.Tetam0 = 0*D2R;
C.Psim0  = 0*D2R;

% Velocidades angulares do míssil no lançamento
C.p0 = 0;
C.q0 = 0;
C.r0 = 0;
             
% Condições iniciais para voo pré-programado
% Rumo do alvo em relação o míssil
C.Rumo0 = atan2((C.Ya0 - C.Ym0),(C.Xa0 - C.Xm0));
C.AltCruz = C.Za0;


VDist = [500:500:2000 2000:1000:6000 8000:2000:20000];
VAngApres = [0:15:180]*pi/180;

% VDist = [1500]
% VAngApres = 150*pi/180

% VDist = [500 1000 1500 ];
% VAngApres = [0:15:45]*pi/180;

Titulo = ['Manobra: '  num2str(D.AcelLatMax/cte_grav) ' g - '...
          'TetaAD: '  num2str(D.ThetaADmax/D2R) ' graus - '...
          'WxAD: ' num2str(D.OmegaADmax/D2R) ' graus/s - '...
          'WnAir: '  num2str(D.wn/2/pi) ' Hz - '...
          'RSatAD: ' num2str(D.RSatAD), ' m - ' ...
          'REsp: ' num2str(D.REspoleta) ' m - '];

Fig = figure;
axis('equal');
xlabel('Downrange (m)');
ylabel('Crossrange (m)');
title(Titulo);
hold on
grid on
      
for iAng = 1:length(VAngApres)
    iDist = 1;
    Last_Kill = logical([0]);
    Kill = logical([0]);
    Stop = logical([0]);
    while (~Stop)
            
        C.Ym0 = -VDist(iDist)*sin(VAngApres(iAng));
        C.Xm0 = -VDist(iDist)*cos(VAngApres(iAng));
        C.Psim0 = VAngApres(iAng);
        
        sim('GuiamentoControle');

        SalvaDinamica6DOF;
        Result(iDist,iAng) = S;
        Resultado(iDist, iAng) = S.Bingo(length(S.Bingo));

        if Resultado(iDist, iAng)
            plot(C.Xm0,C.Ym0,'b.', C.Xm0,-C.Ym0,'b.');
        else
            %plot(C.Xm0,C.Ym0,'bo', C.Xm0,-C.Ym0,'bo');
        end
        
        Last_Kill = Kill;
        Kill = Resultado(iDist, iAng);
        Stop = (Last_Kill == 1 && Kill == 0) || iDist == length(VDist) ;
        iDist = iDist + 1;
    end
end

Name = ['fc'  num2str(D.AcelLatMax/cte_grav)...
        '_th'  num2str(D.ThetaADmax/D2R) ...
        '_wad' num2str(D.OmegaADmax/D2R) ...
        '_wn'  num2str(D.wn/2/pi) ...
        '_rsatad' num2str(D.RSatAD) ...
        '_resp' num2str(D.REspoleta)];
FileName = [Name '.mat'];
FigName = [Name '.fig'];
    
save(FileName,'D','Titulo','Resultado') 
hgsave(Fig, FigName);

save
