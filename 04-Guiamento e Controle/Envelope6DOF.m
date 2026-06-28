%--------------------------------------------------------------------------
% Programa de C�lculo de Envelope Horizontal - Din�mica 6DOF.m
% Sa�da:
%   - S: estrutura com dados de simula��o
%   - Resultado: matriz com resultados dos voos do envelope
%   - Figura com envelope calculado
%--------------------------------------------------------------------------

clear all

D2R = pi/180;
R2D = 180/pi;
cte_grav = 9.8;

% Carrega dados gerais (comuns ao Massa-Ponto)
D = DadosMissil;

% Carrega dados de CG e In�rcia
D = DadosCGInercia(D);

% Carrega dados de aerodin�mica
load M_aed.mat;
D.Cmap = 0;

% Carrega dados de autopiloto
D = DadosControle(D);
load autopiloto.mat              % NOSSO autopiloto (xCG -2.62..-1.70), nao o anti-UAV

% Condicoes de lancamento - engajamento ANTINAVIO (sea-skim, navio parado)

C.TLaser = 10;                  % (s) sensor (autodiretor) ligado
C.Tfim = 300;

% Velocidade inicial do navio (alvo PARADO), Sistema Inercial (m/s)
C.Vxa0 = 0;
C.Vya0 = 0;
C.Vza0 = 0;

% Posicao inicial do navio, Sistema Inercial (m) - na origem
C.Xa0 = 0;
C.Ya0 = 0;
C.Za0 = 20;

% Posicao do missil no lancamento (sobrescrita no loop)
C.Xm0 = 0;
C.Ym0 = 0;
C.Zm0 = 10;                     % lancamento rasante (sea-skim)

% Velocidade do missil no lancamento (m/s)
C.Vmx0 = 40;
C.Vmy0 = 0;
C.Vmz0 = 0;

% Angulos de Euler do missil no lancamento
C.Phim0  = 0*D2R;
C.Tetam0 = 10*D2R;
C.Psim0  = 0*D2R;

% Velocidades angulares do missil no lancamento
C.p0 = 0;
C.q0 = 0;
C.r0 = 0;

% Condicoes iniciais para voo pre-programado
C.Rumo0 = atan2((C.Ya0 - C.Ym0),(C.Xa0 - C.Xm0));
C.AltCruz = 30;                 % cruzeiro sea-skim (NAO = Za0)

% Grade do envelope (alcance ate ~70 km; setor frontal - antinavio nao
% acerta atras). Coarse p/ runtime; refine se quiser mais resolucao.
VDist = [8000 18000 30000 45000 60000 72000 80000];
VAngApres = [0:30:180]*pi/180;

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
      
Resultado = nan(length(VDist),length(VAngApres));   % nan = nao rodado (early-stop)
for iAng = 1:length(VAngApres)
    iDist = 1;
    Last_Kill = logical([0]);
    Kill = logical([0]);
    Stop = logical([0]);
    while (~Stop)
            
        C.Ym0 = -VDist(iDist)*sin(VAngApres(iAng));
        C.Xm0 = -VDist(iDist)*cos(VAngApres(iAng));
        C.Psim0 = VAngApres(iAng);
        % Rumo pre-programado APONTANDO PARA O ALVO (corrige bug: antes
        % Rumo0 ficava fixo=0 p/ todos os angulos -> 40deg+ cruzava errado).
        C.Rumo0 = atan2(C.Ya0 - C.Ym0, C.Xa0 - C.Xm0);

        sim('GuiamentoControle');

        SalvaDinamica6DOF;
        Resultado(iDist, iAng) = S.Bingo(length(S.Bingo));
        fprintf('ang=%3.0f deg  dist=%2.0f km  -> bingo=%d  Tf=%.0f s\n', ...
                VAngApres(iAng)*R2D, VDist(iDist)/1e3, Resultado(iDist,iAng), S.Xe.Time(end));

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
% Estilo do prof: pontos azuis dos lancamentos que bigam (em metros).
figure(Fig); plot(0,0,'ks','MarkerFaceColor','k','MarkerSize',10);  % navio na origem
exportgraphics(Fig,'C:/Users/Savio/Documents/PRJ-75/Plots_Relevantes/09_envelope_antinavio.png','Resolution',140);
disp('ENVELOPE OK');
